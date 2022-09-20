import '../eink_display.dart';
import 'image_converter_stub.dart'
    if (dart.library.io) 'default_image_converter.dart'
    if (dart.library.html) 'web_image_converter.dart';

import 'dart:io';

abstract class ImageConverter {
  static ImageConverter instance() => getImageConverter();

  Future<List<int>> convert(
      final File image, final EinkClut? einkClut, final bool dither);

  int repackPackedVals(
      int val, int pixelsPerPackedUnit, int packedMultiplyVal) {
    int ret = 0;

    for (int i = 0; i < pixelsPerPackedUnit; i++) {
      ret = ret * packedMultiplyVal + val % packedMultiplyVal;
      val ~/= packedMultiplyVal;
    }

    return ret;
  }
}
