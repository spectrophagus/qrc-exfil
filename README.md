# qrc-exfil

A simple demonstration of using rapidly cycling QR codes to 
visually exfiltrate data from a restricted environment.

The encoder uses [qrcode-js](https://github.com/davidshimjs/qrcodejs) to
create QR codes on the fly, and the decoder uses [zxing-cpp](https://github.com/nu-book/zxing-cpp)
for decoding QR codes found in images.

## Encoder Prerequisites
* Chromium-based browser

## Decoder Prerequisites
* cmake / make / c++ compiler
* ffmpeg
* perl

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
$ ./zxing-cpp/build/example/ZXingReader /tmp/qrc-out/out*.png | ./qrc-decode-single.pl | base64 --decode > /tmp/qrc-out.decoded
MIME type: data:image/jpeg;base64
```

The [example](example/) directory contains a sample JPEG file (borrowed from [@bigendiansmalls](https://twitter.com/bigendiansmalls),
who initially posted [here](https://twitter.com/bigendiansmalls/status/1374783712714485763) looking for stupid data exfiltration
tricks.  That file was encoded with the encoder, and the video was captured with a cellphone camera.  The corresponding ZXing output
generated from that video file (via ffmpeg) can also be found in the example directory.

```
$ cd example/
$ md5sum test.jpg
1f5ab5f204f3086dc1994af718ccdbd3  test.jpg
$ gzip -cd ./test.zxing.output.gz | ../decoder/qrc-decode-single.pl | base64 --decode | md5sum
MIME type: data:image/jpeg;base64
1f5ab5f204f3086dc1994af718ccdbd3  -
```

## Notes
Throughput of the encoder can be modified with `frameSize` and `frameInterval` parameters at the
top of [qrc-encoder.html](encoder/qrc-encoder.html).  The overall throughput can be calculated by the formula:

```
throughput (bytes/sec) = 750 * frameSize / frameInterval
```

The default settings (`frameSize = 256` and `frameInterval = 100`) are quite conservative and result in a modest
1.9kB/s transfer rate to maximize reliability.  Using a handheld 1080p cellphone camera recording at 30 fps,
zxing detects 3-5 copies of each QR frame in the output.  This implies that a with a fast display and a 4K camera
recording at 60 fps, an 8x increase in throughput (`frameSize = 1024` and `frameInterval = 50`) could be achieved
with no loss of robustness at 15kB/s.

Depending on display responsiveness, camera resolution, framerate, and image stability, you may find even more
aggressive settings (higher `frameSize`, lower `frameInterval`) that still work reliably with the devices
in your situation.
