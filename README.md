# SpeedTV

**A fast, clean IPTV player for Android TV, phones and tablets.**

SpeedTV turns your own IPTV subscription into a proper TV experience. You get live channels with a TV guide, movies, series and radio, all in one place and easy to use from the couch with the remote, or by touch on your phone and tablet. It starts quickly, switches channels fast, and plays the formats that cheap TV boxes often struggle with.

> **SpeedTV is a player only.** It doesn't provide, sell or recommend any channels or content. You need a playlist from your own provider (an M3U link or an Xtream Codes account).

![Home screen](screenshots/01-home.png)

## Features

### Easy setup
- **Set up from your phone:** scan a QR code on the TV and type your playlist details on your phone instead of with the remote.
- **Connection check before loading**, with clear messages for a wrong password, an expired account or a wrong address.
- **Xtream links are detected automatically**, so movies, series and the TV guide come along.
- Several playlists (profiles), each with its own settings.

### Made for TV
- Live TV, movies, series and radio in one place.
- **TV guide (EPG)** with what's on now and next.
- Favorites and your own custom lists.
- Quick channel switching with the remote (Up/Down or CH+/CH−, or type the channel number) and a channel list over the picture.
- **Multiview:** watch two channels at once.
- Search across everything.
- Resume movies and episodes where you left off.

### Playback
- Hardware decoding with automatic software fallback for streams the TV can't decode.
- MP2, AC3, E-AC3 and DTS audio support (FFmpeg).
- HLS quality options, buffer presets and display refresh-rate matching.
- Audio track and subtitle selection.

### On your phone and tablet
- **A touch interface of its own**, with the same lists, TV guide and favorites.
- TV guide as a grid that starts at what's on now.
- **Picture-in-picture:** keep watching in a small window while you use other apps.
- **Keeps playing with the screen off**, with controls on the lock screen and in the notification.
- Light or dark theme.

### Private and safe
- Parental control with a PIN and locked categories.
- No ads, no accounts, no tracking.
- Your playlists and passwords stay on your device. See the [privacy policy](https://gist.github.com/cruz-py/960da5f83a9266b0a5e02fdb1da9e0a0).

Available in English, Spanish, French, German, Italian, Portuguese, Brazilian Portuguese, Turkish and Arabic.

## Screenshots

### Android TV

| | |
|---|---|
| ![TV guide](screenshots/02-tv-guide.png) | ![Player](screenshots/03-player.png) |
| ![Channel list](screenshots/04-channel-list.png) | ![Phone setup](screenshots/05-phone-setup.png) |

### Phone

<p>
<img src="screenshots/phone/01-home.png" width="200" alt="Home">
<img src="screenshots/phone/02-live-tv.png" width="200" alt="Live TV">
<img src="screenshots/phone/03-tv-guide.png" width="200" alt="TV guide">
<img src="screenshots/phone/05-movies.png" width="200" alt="Movies">
</p>

![Player on a phone](screenshots/phone/04-player.png)

### Tablet

| | |
|---|---|
| ![Live TV on a tablet](screenshots/tablet/01-live-tv.png) | ![TV guide on a tablet](screenshots/tablet/03-tv-guide.png) |


## Install

- **Google Play:** coming soon.
- **APK:** download the latest version from [Releases](https://github.com/cruz-py/SpeedTV-app/releases) and install it on your Android TV, phone or tablet (Android 7.0 or newer). Version 1.0.8 is still there as the last TV-only build.

## Getting started

1. On a TV, open SpeedTV and choose **Use your phone** (scan the QR code) or type your details with the remote. On a phone or tablet, just type them in.
2. Enter your M3U link or your Xtream Codes server, username and password.
3. SpeedTV checks the connection, loads your channels and guide, and you're ready to watch.

## Support the project

SpeedTV is free, with no ads and no tracking, and it's made in my spare time. If you enjoy it and want to help with its development, you can buy me a coffee:

**[Donate with PayPal](https://www.paypal.com/paypalme/ruicruz27)**

Bug reports and ideas are welcome in [Issues](https://github.com/cruz-py/SpeedTV-app/issues).

## Open-source components

SpeedTV is closed source. It uses these open-source libraries:

- **AndroidX Media3** (Apache License 2.0) for playback.
- **FFmpeg 6.0** (GNU LGPL 2.1 or later) for MP2, AC3, E-AC3 and DTS audio. The exact version, the licence notice and the script to rebuild the FFmpeg library used by the app are in [`ffmpeg/`](ffmpeg/).
