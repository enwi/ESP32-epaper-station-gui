import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:developer' as dev;

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';

import 'conversion/image_converter.dart';
import 'eink_display.dart';
import 'http_client.dart';

class ImageUpload extends StatefulWidget {
  final String host;
  final String fileName;
  final String? uploadFilename;
  const ImageUpload(
      {Key? key,
      required this.host,
      required this.fileName,
      this.uploadFilename})
      : super(key: key);

  @override
  State<ImageUpload> createState() => _ImageUploadState();

  static void fromDevice(final BuildContext context, final String host,
      final String? uploadFilename) {
    FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bmp', 'BMP'],
    ).then((value) {
      if (value == null || value.files.first.path == null) {
        return;
      }
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageUpload(
              host: host,
              fileName: value.files.first.path!,
              uploadFilename: uploadFilename,
            ),
          ));
    });
  }
}

class _ImageUploadState extends State<ImageUpload> {
  final ImageConverter converter = ImageConverter.instance();
  late final inputImageFile = File(widget.fileName);
  late final inputImageSize = inputImageFile.lengthSync();
  late Image outImage = Image.file(inputImageFile, fit: BoxFit.fitHeight);
  Uint8List rawOutImage = Uint8List(0);
  EinkClut? einkClut = EinkClut.TwoBlacks;
  bool dither = false;
  int conversionTime = 0;

  /// Are we currently uploading a file (true) or not (false)
  bool uploading = false;

  void timeConversion() async {
    Stopwatch stopwatch = Stopwatch()..start();
    await converter
        .convert(inputImageFile, einkClut, dither)
        .then((image) => setState(() {
              rawOutImage = Uint8List.fromList(image);
              outImage = Image.memory(rawOutImage, fit: BoxFit.fitHeight);
            }))
        .onError((error, stackTrace) {
      rawOutImage = inputImageFile.readAsBytesSync();
      outImage = Image.memory(rawOutImage, fit: BoxFit.fitHeight);
      dev.log(error.toString());
    });
    stopwatch.stop();
    setState(() {
      conversionTime = stopwatch.elapsedMilliseconds;
    });
  }

  @override
  void initState() {
    timeConversion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceData = MediaQuery.of(context);
    final screenSize = deviceData.size;
    final small = screenSize.width <= 808;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Upload'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: small ? buildSmall() : buildBig(),
      ),
    );
  }

  Widget buildSmall() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            const Text('Input'),
            SizedBox(
              height: 150,
              child: Transform.scale(
                scale: 2,
                child: Transform.rotate(
                  angle: pi / 180 * -90,
                  child: Image.file(inputImageFile, fit: BoxFit.fitHeight),
                ),
              ),
            ),
            Text('Size: ${inputImageSize}b'),
          ],
        ),
        Column(
          children: [
            const Text('Upload'),
            SizedBox(
              height: 150,
              child: Transform.scale(
                scale: 2,
                child: Transform.rotate(
                  angle: pi / 180 * -90,
                  child: outImage,
                ),
              ),
            ),
            Text('Size: ${rawOutImage.length}b'),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                DropdownButton<EinkClut>(
                  isExpanded: true,
                  value: einkClut,
                  items: EinkClut.values
                      .map((e) => DropdownMenuItem<EinkClut>(
                            value: e,
                            child: Text(e.displayTitle),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      einkClut = value;
                      timeConversion();
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Dithering'),
                  value: dither,
                  onChanged: (value) {
                    setState(() {
                      dither = value ?? false;
                      timeConversion();
                    });
                  },
                ),
                ListTile(
                  title: Text(
                      'Compression: ${(100 - rawOutImage.length / inputImageSize * 100).toStringAsFixed(2)}%'),
                  subtitle: Text('Took $conversionTime ms'),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() => uploading = true);
                        uploadFile(
                                widget.host,
                                widget.uploadFilename ?? widget.fileName,
                                rawOutImage)
                            .then((value) {
                          if (value) {
                            Navigator.pop(context);
                          }
                        }).whenComplete(
                                () => setState(() => uploading = false));
                      },
                      child: const Text('Upload'),
                    ),
                    TextButton(
                      onPressed: () {
                        FileSaver.instance.saveFile(
                          widget.fileName,
                          rawOutImage,
                          "bmp",
                          mimeType: MimeType.BMP,
                        );
                      },
                      child: const Text('Download'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildBig() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          children: [
            const Text('Input'),
            Expanded(
              child: Image.file(inputImageFile, fit: BoxFit.fitHeight),
            ),
            Text('Size: ${inputImageSize}b'),
          ],
        ),
        Column(
          children: [
            const Text('Upload'),
            Expanded(
              child: outImage,
            ),
            Text('Size: ${rawOutImage.length}b'),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                DropdownButton<EinkClut>(
                  isExpanded: true,
                  value: einkClut,
                  items: EinkClut.values
                      .map((e) => DropdownMenuItem<EinkClut>(
                            value: e,
                            child: Text(e.displayTitle),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      einkClut = value;
                      timeConversion();
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Dithering'),
                  value: dither,
                  onChanged: (value) {
                    setState(() {
                      dither = value ?? false;
                      timeConversion();
                    });
                  },
                ),
                ListTile(
                  title: Text(
                      'Compression: ${(100 - rawOutImage.length / inputImageSize * 100).toStringAsFixed(2)}%'),
                  subtitle: Text('Took $conversionTime ms'),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() => uploading = true);
                        uploadFile(
                                widget.host,
                                widget.uploadFilename ?? widget.fileName,
                                rawOutImage)
                            .then((value) {
                          if (value) {
                            Navigator.pop(context);
                          }
                        }).whenComplete(
                                () => setState(() => uploading = false));
                      },
                      child: const Text('Upload'),
                    ),
                    TextButton(
                      onPressed: () {
                        FileSaver.instance.saveFile(
                          widget.fileName,
                          rawOutImage,
                          "bmp",
                          mimeType: MimeType.BMP,
                        );
                      },
                      child: const Text('Download'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
