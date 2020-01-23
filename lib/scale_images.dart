/*
BSD 3-Clause License

Copyright (c) 2020, Martin Arnberg marnberg@gmail.com
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import 'dart:io';
import 'package:image/image.dart';
import 'config_model.dart';

Future scaleImages(
  String source,
  String destination,
  TangoConfig config,
) async {
  for (final fileEntry in config.scaledImages.entries) {
    final imageFile = File('$source/${fileEntry.value}').readAsBytesSync();
    final i = fileEntry.key.lastIndexOf('.');
    final type = fileEntry.key.substring(i + 1);

    final image = decodeImage(imageFile);

    final baseOutput = '$destination${fileEntry.key}';

    print('Scaling $source/${fileEntry.key} => $baseOutput');

    for (final scale in config.scalesMap.entries) {
      final dirIndex = baseOutput.lastIndexOf('/');
      final dirPath = baseOutput.substring(0, dirIndex) + scale.key;
      final fileName = baseOutput.substring(dirIndex + 1);
      final dir = await Directory(dirPath);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      final resized = copyResize(image,
          width: (image.width * scale.value).toInt(),
          height: (image.height * scale.value).toInt());

      final destName = '$dirPath$fileName';
      switch (type) {
        case 'jpg':
        case 'jpeg':
          File(destName).writeAsBytesSync(encodeJpg(resized));
          break;
        case 'png':
          File(destName).writeAsBytesSync(encodePng(resized));
          break;
        default:
          exitCode = 1;
          stderr.writeln('unsupported image file');
          return;
      }
    }
  }
}
