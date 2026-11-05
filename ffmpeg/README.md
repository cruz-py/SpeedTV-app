# FFmpeg in SpeedTV

SpeedTV uses the [AndroidX Media3](https://github.com/androidx/media) FFmpeg extension, built with only the audio decoders `mp3` (MPEG Layer I/II/III, including MP2), `ac3`, `eac3` and `dca` (DTS). The app uses it only when the TV has no system decoder for that format.

## Licences

- **FFmpeg** is licensed under the GNU Lesser General Public License 2.1 or later. It is configured **without** `--enable-gpl` and **without** `--enable-nonfree`. The exact branch and commit are in [`FFMPEG_BUILD_INFO.txt`](FFMPEG_BUILD_INFO.txt). The source code is at <https://git.ffmpeg.org/ffmpeg.git>.
- **The Media3 extension** (Java code and `ffmpeg_jni.cc`) is licensed under the Apache License 2.0, © The Android Open Source Project, and is used unchanged from the Media3 version listed in `FFMPEG_BUILD_INFO.txt`.

## Rebuilding the library

[`build-ffmpeg-audio.sh`](build-ffmpeg-audio.sh) downloads the listed versions of Media3 and FFmpeg and builds `libffmpegJNI.so` for every ABI. You can point it at a modified FFmpeg and replace `lib/<abi>/libffmpegJNI.so` in the APK with your own build.

Requirements: Linux x86_64, git and Android NDK r26b.

```
ffmpeg/build-ffmpeg-audio.sh                     # uses ~/Android/Sdk/ndk/26.1.10909125
NDK_PATH=/path/to/ndk ffmpeg/build-ffmpeg-audio.sh
```

The output goes to `ffmpeg-decoder/src/main/jniLibs/<abi>/libffmpegJNI.so`. [`NOTICE.md`](NOTICE.md) is the original notice (in Portuguese).
