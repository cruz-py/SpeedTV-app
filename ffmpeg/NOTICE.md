# ffmpeg-decoder

Extensão FFmpeg do [AndroidX Media3](https://github.com/androidx/media) (`libraries/decoder_ffmpeg`),
compilada só com os descodificadores de áudio `mp3` (MPEG Layer I/II/III, inclui MP2), `ac3`,
`eac3` e `dca` (DTS). É usada pela app apenas quando o aparelho não tem descodificador de sistema
para o formato.

## Licenças

- **Código da extensão** (`src/main/java`, `ffmpeg_jni.cc`): Apache License 2.0, © The Android Open
  Source Project. Copiado sem alterações da versão do Media3 indicada em `FFMPEG_BUILD_INFO.txt`.
- **FFmpeg** (ligado estaticamente em `src/main/jniLibs/*/libffmpegJNI.so`): GNU Lesser General
  Public License 2.1 ou posterior. Configurado **sem** `--enable-gpl` e **sem** `--enable-nonfree`
  (o script de build verifica). Versão exata (ramo e commit) em `FFMPEG_BUILD_INFO.txt`; código-fonte
  em <https://git.ffmpeg.org/ffmpeg.git>.

Para cumprir a LGPL ao distribuir a app: incluir este aviso, indicar a versão do FFmpeg usada e
disponibilizar o código-fonte do FFmpeg e o script `tools/build-ffmpeg-audio.sh`, que permite a
qualquer pessoa recompilar `libffmpegJNI.so` (com uma versão modificada do FFmpeg, se quiser) e
substituí-la. Isto é um resumo, não aconselhamento jurídico.

## Recompilar

```
tools/build-ffmpeg-audio.sh            # usa ~/Android/Sdk/ndk/26.1.10909125
NDK_PATH=/outro/ndk tools/build-ffmpeg-audio.sh
```

Ao atualizar o Media3 em `gradle/libs.versions.toml`, atualizar também `MEDIA3_VERSION` no script e
recompilar: o código Java e a biblioteca nativa têm de corresponder à versão do Media3.
