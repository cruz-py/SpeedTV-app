#!/usr/bin/env bash
#
# Compila a extensão FFmpeg do Media3 (só descodificadores de ÁUDIO) para o módulo :ffmpeg-decoder.
#
# Porquê: muitos canais europeus em TS trazem áudio MP2, AC3, E-AC3 ou DTS e várias boxes baratas não
# têm descodificador de sistema para algum deles: o canal toca SEM SOM. A extensão do Media3 resolve,
# mas a Google não a publica no Maven, por isso é compilada aqui e o resultado fica no repositório
# (o build normal da app NÃO precisa do NDK; só quem quiser recompilar estas bibliotecas).
#
# Licença: o FFmpeg é configurado SEM --enable-gpl e SEM --enable-nonfree, ou seja LGPL 2.1 ou
# posterior (o script confirma no fim). O código da extensão (Java + JNI) é Apache 2.0 (Media3).
#
# Requisitos: Linux x86_64, git, NDK r26b (o make vem incluído no NDK).
# Uso:  tools/build-ffmpeg-audio.sh
#       NDK_PATH=/caminho/para/ndk tools/build-ffmpeg-audio.sh
set -euo pipefail

# --- Versões fixas (mudar o Media3 aqui E em gradle/libs.versions.toml ao mesmo tempo) -----------
MEDIA3_VERSION="1.11.1"
FFMPEG_BRANCH="release/6.0"            # versão recomendada pelo README da extensão no Media3 1.11.1
DECODERS=(mp3 ac3 eac3 dca)            # "mp3" também descodifica MPEG Layer I/II (MP2); dca = DTS
ANDROID_API=24                         # = minSdk da app (não pode ser maior)
ABIS=(armeabi-v7a arm64-v8a x86 x86_64)

HOST_PLATFORM="linux-x86_64"
NDK_PATH="${NDK_PATH:-$HOME/Android/Sdk/ndk/26.1.10909125}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="${WORK_DIR:-$REPO_ROOT/build/ffmpeg-work}"   # pasta temporária (ignorada pelo git)
MODULE_DIR="$REPO_ROOT/ffmpeg-decoder"

TOOLCHAIN="$NDK_PATH/toolchains/llvm/prebuilt/$HOST_PLATFORM/bin"
if [[ ! -x "$TOOLCHAIN/clang" ]]; then
    echo "NDK não encontrado em '$NDK_PATH' (define NDK_PATH)." >&2
    exit 1
fi
# O build do FFmpeg precisa de GNU make: usa o que vem com o NDK
export PATH="$NDK_PATH/prebuilt/$HOST_PLATFORM/bin:$PATH"

mkdir -p "$WORK_DIR"

# O script do Media3 usa um job de compilação por núcleo; limita (JOBS=n) para não esgotar a RAM
JOBS="${JOBS:-4}"
mkdir -p "$WORK_DIR/bin"
printf '#!/bin/sh\necho %s\n' "$JOBS" > "$WORK_DIR/bin/nproc"
chmod +x "$WORK_DIR/bin/nproc"
export PATH="$WORK_DIR/bin:$PATH"

# --- 1. Código-fonte -------------------------------------------------------------------------
if [[ ! -d "$WORK_DIR/media" ]]; then
    git clone --quiet --depth 1 --branch "$MEDIA3_VERSION" https://github.com/androidx/media.git "$WORK_DIR/media"
fi
if [[ ! -d "$WORK_DIR/ffmpeg" ]]; then
    git clone --quiet --depth 1 --branch "$FFMPEG_BRANCH" https://git.ffmpeg.org/ffmpeg.git "$WORK_DIR/ffmpeg"
fi
FFMPEG_MODULE_PATH="$WORK_DIR/media/libraries/decoder_ffmpeg/src/main"
ln -sfn "$WORK_DIR/ffmpeg" "$FFMPEG_MODULE_PATH/jni/ffmpeg"

# --- 2. Bibliotecas estáticas do FFmpeg (script oficial do Media3) -----------------------------
# SKIP_FFMPEG_BUILD=1 reaproveita as bibliotecas já compiladas e só refaz o passo JNI (segundos)
if [[ "${SKIP_FFMPEG_BUILD:-0}" == "1" && -f "$WORK_DIR/ffmpeg/android-libs/arm64-v8a/libavcodec.a" ]]; then
    echo "A reaproveitar as bibliotecas do FFmpeg já compiladas"
else
    (cd "$FFMPEG_MODULE_PATH/jni" && ./build_ffmpeg.sh \
        "$FFMPEG_MODULE_PATH" "$NDK_PATH" "$HOST_PLATFORM" "$ANDROID_API" "${DECODERS[@]}")
fi

# Garante que a configuração ficou LGPL (sem componentes GPL / nonfree)
grep -q '#define CONFIG_GPL 0' "$WORK_DIR/ffmpeg/config.h"
grep -q '#define CONFIG_NONFREE 0' "$WORK_DIR/ffmpeg/config.h"

# --- 3. Biblioteca JNI (equivalente ao CMakeLists.txt da extensão, sem precisar de CMake) -------
target_for_abi() {
    case "$1" in
        armeabi-v7a) echo "armv7a-linux-androideabi" ;;
        arm64-v8a)   echo "aarch64-linux-android" ;;
        x86)         echo "i686-linux-android" ;;
        x86_64)      echo "x86_64-linux-android" ;;
    esac
}

for abi in "${ABIS[@]}"; do
    libs="$WORK_DIR/ffmpeg/android-libs/$abi"
    out_dir="$MODULE_DIR/src/main/jniLibs/$abi"
    mkdir -p "$out_dir"
    extra_flags=()
    # Igual ao CMakeLists.txt do Media3 (ExoPlayer issue 9933)
    [[ "$abi" == "arm64-v8a" ]] && extra_flags+=("-Wl,-Bsymbolic")
    [[ "$abi" == "armeabi-v7a" ]] && extra_flags+=("-march=armv7-a" "-mfloat-abi=softfp")

    "$TOOLCHAIN/$(target_for_abi "$abi")${ANDROID_API}-clang++" \
        -std=c++11 -O2 -fPIC -shared \
        -fvisibility=hidden -fvisibility-inlines-hidden \
        -I"$WORK_DIR/ffmpeg" \
        "$FFMPEG_MODULE_PATH/jni/ffmpeg_jni.cc" \
        "$libs/libswresample.a" "$libs/libavcodec.a" "$libs/libavutil.a" \
        -landroid -llog -lm -static-libstdc++ \
        -Wl,--no-undefined \
        -Wl,--exclude-libs,ALL \
        -Wl,-z,max-page-size=16384 \
        "${extra_flags[@]}" \
        -o "$out_dir/libffmpegJNI.so"
    # Páginas de 16 KB: obrigatório para apps em aparelhos Android 15+ com páginas de 16 KB
    "$TOOLCHAIN/llvm-strip" --strip-unneeded "$out_dir/libffmpegJNI.so"
    # Só o JNI_OnLoad fica visível (regista os métodos nativos); os símbolos av_* do FFmpeg ficam
    # escondidos (--exclude-libs): biblioteca mais pequena e sem choques com outro FFmpeg no processo
    echo "OK  $abi  $(du -h "$out_dir/libffmpegJNI.so" | cut -f1)"
done

# --- 4. Código Java da extensão, da MESMA versão do Media3 ----------------------------------
java_src="$FFMPEG_MODULE_PATH/java/androidx/media3/decoder/ffmpeg"
java_dst="$MODULE_DIR/src/main/java/androidx/media3/decoder/ffmpeg"
mkdir -p "$java_dst"
rm -f "$java_dst"/*.java
# O renderizador de vídeo experimental fica de fora (só se compilam descodificadores de áudio)
for f in FfmpegAudioDecoder FfmpegAudioRenderer FfmpegDecoderException FfmpegLibrary package-info; do
    cp "$java_src/$f.java" "$java_dst/"
done
cp "$WORK_DIR/media/libraries/decoder_ffmpeg/proguard-rules.txt" "$MODULE_DIR/consumer-rules.pro"

# --- 5. Registo do que foi compilado (para cumprir a LGPL: versão exata do FFmpeg usada) -------
{
    echo "Media3:   $MEDIA3_VERSION ($(git -C "$WORK_DIR/media" rev-parse HEAD))"
    echo "FFmpeg:   $FFMPEG_BRANCH ($(git -C "$WORK_DIR/ffmpeg" rev-parse HEAD))"
    echo "          https://git.ffmpeg.org/ffmpeg.git"
    echo "Decoders: ${DECODERS[*]}"
    echo "NDK:      $(grep Pkg.Revision "$NDK_PATH/source.properties" | cut -d= -f2 | tr -d ' ')"
    echo "API:      $ANDROID_API"
    echo "Licença:  FFmpeg LGPL 2.1+ (CONFIG_GPL=0, CONFIG_NONFREE=0); extensão Media3 Apache 2.0"
} > "$MODULE_DIR/FFMPEG_BUILD_INFO.txt"

echo
cat "$MODULE_DIR/FFMPEG_BUILD_INFO.txt"
