# qrc-exfil

A simple demonstration of using rapidly cycling QR codes to 
visually exfiltrate data from a restricted environment.

The encoder uses [qrcode-js](https://github.com/davidshimjs/qrcodejs) to
create QR codes on the fly, and the decoder uses [zxing-cpp](https://github.com/nu-book/zxing-cpp)
for decoding QR codes found in images.

## Prerequisites
* ffmpeg (for decoding only)

## Building
To build zxing-cpp:
```
$ cd decoder/zxing-cpp
$ mkdir build && cd build
$ cmake ../
$ make
```

## Example
Load the [encoder](encoder/qrc-encoder.html) in a browser (tested only on Chromium-based
browsers, including Edge).  Set up your camera to focus on the displayed example QR code
and begin recording.

Select a file to encode using the dialog box, and capture all of the QR frames with your camera.

Once you have captured all the frames, transfer the video file to your computer and use [ffmpeg](https://ffmpeg.org/)
to extract all of the video frames into still images.
```
$ mkdir /tmp/qrc-out/
$ ffmpeg -i VID_20210324_164101.mp4 /tmp/qrc-out/out%08d.png
ffmpeg version 3.4.8-0ubuntu0.2 Copyright (c) 2000-2020 the FFmpeg developers
  built with gcc 7 (Ubuntu 7.5.0-3ubuntu1~18.04)
   [...]
frame= 1557 fps= 35 q=-0.0 size=N/A time=00:00:51.63 bitrate=N/A speed=1.17x

$ ls /tmp/qrc-out/out*.png | head
/tmp/qrc-out/out00000001.png
/tmp/qrc-out/out00000002.png
/tmp/qrc-out/out00000003.png
/tmp/qrc-out/out00000004.png
/tmp/qrc-out/out00000005.png
/tmp/qrc-out/out00000006.png
/tmp/qrc-out/out00000007.png
/tmp/qrc-out/out00000008.png
/tmp/qrc-out/out00000009.png
/tmp/qrc-out/out00000010.png
```

Once the video frames are extracted, use zxing-cpp to find the QR codes embedded in the images and decode them
into the original base64 content.

```
$ cd decoder
$ ./zxing-cpp/build/example/ZXingReader /tmp/qrc-out/out*.png | ./qr-decoder.pl | base64 --decode > /tmp/qrc-out.decoded
MIME type: data:image/jpeg;base64

$ md5sum /tmp/qrc-out.decoded
1f5ab5f204f3086dc1994af718ccdbd3  /tmp/qrc-out.decoded
```
