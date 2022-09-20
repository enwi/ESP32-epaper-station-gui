import 'dart:io';
import 'dart:math';

import '../eink_display.dart';
import 'image_converter.dart';

class DefaultImageConverter extends ImageConverter {
  @override
  Future<List<int>> convert(
      final File image, final EinkClut? einkClut, final bool dither) async {
    int rowBytesOut;
    int outBpp = 1;
    int i;
    int numRows;
    int pixelsPerPackedUnit = 1;
    int packedMultiplyVal = 0x01000000;
    int packedOutBpp = 0;
    int compressionFormat = 0;
    int numGrays = 2;
    int extraColor = 0;
    // const char *self = argv[0];
    List<List<int>> clut = List.generate(
        256, (index) => List.generate(3, (index) => 0)); //[256][3];
    int skipBytes;

    switch (einkClut) {
      case EinkClut.TwoBlacks:
        numGrays = 2;
        outBpp = 1;
        break;

      case EinkClut.TwoBlacksAndYellow:
        extraColor = 0xffff00;
        numGrays = 2;
        outBpp = 2;
        break;

      case EinkClut.TwoBlacksAndRed:
        extraColor = 0xff0000;
        numGrays = 2;
        outBpp = 2;
        break;

      case EinkClut.TwoBlacksAndYellowPacked:
        numGrays = 2;
        extraColor = 0xffff00;
        outBpp = 2; //for clut purposes, we have 2..3 entries so a 2-bit clut
        packedOutBpp = 8; //packing is in 8-bit quantities
        pixelsPerPackedUnit = 5;
        packedMultiplyVal = 3;
        compressionFormat = COMPRESSION_BITPACKED_5x3_to_8;
        break;

      case EinkClut.TwoBlacksAndRedPacked:
        numGrays = 2;
        extraColor = 0xff0000;
        outBpp = 2; //for clut purposes, we have 2..3 entries so a 2-bit clut
        packedOutBpp = 8; //packing is in 8-bit quantities
        pixelsPerPackedUnit = 5;
        packedMultiplyVal = 3;
        compressionFormat = COMPRESSION_BITPACKED_5x3_to_8;
        break;

      case EinkClut.FourBlacks:
        numGrays = 4;
        outBpp = 2;
        break;

      case EinkClut.ThreeBlacksAndYellow:
        numGrays = 3;
        extraColor = 0xffff00;
        outBpp = 2;
        break;

      case EinkClut.ThreeBlacksAndRed:
        numGrays = 3;
        extraColor = 0xff0000;
        outBpp = 2;
        break;

      case EinkClut.FourBlacksAndYellowPacked:
        numGrays = 4;
        extraColor = 0xffff00;
        outBpp = 3; //for clut purposes, we have 5..8 entries so a 3-bit clut
        packedOutBpp = 7; //packing is in 7-bit quantities
        pixelsPerPackedUnit = 3;
        packedMultiplyVal = 5;
        compressionFormat = COMPRESSION_BITPACKED_3x5_to_7;
        break;

      case EinkClut.FourBlacksAndRedPacked:
        numGrays = 4;
        extraColor = 0xff0000;
        outBpp = 3; //for clut purposes, we have 5..8 entries so a 3-bit clut
        packedOutBpp = 7; //packing is in 7-bit quantities
        pixelsPerPackedUnit = 3;
        packedMultiplyVal = 5;
        compressionFormat = COMPRESSION_BITPACKED_3x5_to_7;
        break;

      case EinkClut.FiveBlacksAndYellowPacked:
        numGrays = 5;
        extraColor = 0xffff00;
        outBpp = 3; //for clut purposes, we have 5..8 entries so a 3-bit clut
        packedOutBpp = 8; //packing is in 8-bit quantities
        pixelsPerPackedUnit = 3;
        packedMultiplyVal = 6;
        compressionFormat = COMPRESSION_BITPACKED_3x6_to_8;
        break;

      case EinkClut.FiveBlacksAndRedPacked:
        numGrays = 5;
        extraColor = 0xff0000;
        outBpp = 3; //for clut purposes, we have 5..8 entries so a 3-bit clut
        packedOutBpp = 8; //packing is in 8-bit quantities
        pixelsPerPackedUnit = 3;
        packedMultiplyVal = 6;
        compressionFormat = COMPRESSION_BITPACKED_3x6_to_8;
        break;

      case EinkClut.EightBlacks:
        numGrays = 8;
        outBpp = 3;
        break;

      case EinkClut.SevenBlacksAndYellow:
        numGrays = 7;
        extraColor = 0xffff00;
        outBpp = 3;
        break;

      case EinkClut.SevenBlacksAndRed:
        numGrays = 7;
        extraColor = 0xff0000;
        outBpp = 3;
        break;

      case EinkClut.SixteenBlacks:
        numGrays = 16;
        outBpp = 4;
        break;

      case null:
        // TODO error
        break;
    }

    if (packedOutBpp == 0) {
      packedOutBpp = outBpp;
    }

    final hdr = BitMapFileHeader.fromList(await image.openRead(0, 54).first);

    if (hdr == null) {
      throw Exception('Bitmap header could not be read!');
    }

    if (hdr.sig[0] != 66 || // != 'B'
        hdr.sig[1] != 77 || // != 'M'
        hdr.headerSz < 40 ||
        hdr.colorplanes != 1 ||
        hdr.bpp != 24 ||
        hdr.compression > 0) {
      throw Exception('Warning bitmap header invalid!');
    }

    skipBytes = hdr.dataOfst - BitMapFileHeader.size;
    if (skipBytes < 0) {
      throw Exception('File header was too short!');
    }
    skipBytes = hdr.dataOfst;

    // We will use hdr.dataOfst instead
    //getBytes(NULL, skipBytes);

    // rowBytesIn = (hdr.width * hdr.bpp + 31) ~/ 32 * 4;

    // first sort out how many pixel packages we'll have and round up
    rowBytesOut =
        ((hdr.width + pixelsPerPackedUnit - 1) ~/ pixelsPerPackedUnit) *
            packedOutBpp;

    // then convert that to row bytes (round up to nearest multiple of 4 bytes)
    rowBytesOut = (rowBytesOut + 31) ~/ 32 * 4;

    numRows = hdr.height < 0 ? -hdr.height : hdr.height;
    hdr.bpp = outBpp;
    hdr.numColors = 1 << outBpp;
    hdr.numImportantColors = 1 << outBpp;
    hdr.dataOfst = BitMapFileHeader.size + 4 * hdr.numColors;
    hdr.dataLen = numRows * rowBytesOut;
    hdr.fileSz = hdr.dataOfst + hdr.dataLen;
    hdr.headerSz = 40 /* do not ask */;
    hdr.compression = compressionFormat;

    final outBytes = hdr.toList();

    //emit & record grey clut entries
    for (i = 0; i < numGrays; i++) {
      final int val = 255 * i ~/ (numGrays - 1);

      outBytes.add(val);
      outBytes.add(val);
      outBytes.add(val);
      outBytes.add(val);

      clut[i][0] = val;
      clut[i][1] = val;
      clut[i][2] = val;
    }

    //if there is a color CLUT entry, emit that
    if (extraColor > 0) {
      outBytes.add((extraColor >> 0) & 0xff); //B
      outBytes.add((extraColor >> 8) & 0xff); //G
      outBytes.add((extraColor >> 16) & 0xff); //R
      outBytes.add(0x00); //A

      clut[i][0] = (extraColor >> 0) & 0xff;
      clut[i][1] = (extraColor >> 8) & 0xff;
      clut[i][2] = (extraColor >> 16) & 0xff;
    }

    //pad clut to size
    for (i = numGrays + (extraColor > 0 ? 1 : 0); i < hdr.numColors; i++) {
      outBytes.add(0x00);
      outBytes.add(0x00);
      outBytes.add(0x00);
      outBytes.add(0x00);
    }

    final random = Random();
    final fileData = await image.openRead(skipBytes).fold<List<int>>([],
        (previous, element) {
      previous.addAll(element);
      return previous;
    });
    int fileIndex = 0;
    while (numRows-- > 0) {
      int pixelValsPackedSoFar = 0;
      int numPixelsPackedSoFar = 0;
      int valSoFar = 0;
      int bytesIn = 0;
      int bytesOut = 0;
      int bitsSoFar = 0;

      for (int column = 0; column < hdr.width; ++column, bytesIn += 3) {
        int bestDist = 0x7fffffffffffffff;
        int bestIdx = 0;
        int ditherFudge = 0;

        // getBytes(rgb, sizeof(rgb));
        List<int> rgb = fileData.sublist(fileIndex, fileIndex + 3);
        fileIndex += 3;

        if (dither) {
          ditherFudge = (random.nextInt(0xFFFFFFFF) % 255 - 127) ~/ numGrays;
        }

        for (i = 0; i < hdr.numColors; i++) {
          int dist = 0;

          dist += (rgb[0] - clut[i][0] + ditherFudge) *
              (rgb[0] - clut[i][0] + ditherFudge) *
              4750;
          dist += (rgb[1] - clut[i][1] + ditherFudge) *
              (rgb[1] - clut[i][1] + ditherFudge) *
              47055;
          dist += (rgb[2] - clut[i][2] + ditherFudge) *
              (rgb[2] - clut[i][2] + ditherFudge) *
              13988;

          if (dist < bestDist) {
            bestDist = dist;
            bestIdx = i;
          }
        }

        //pack pixels as needed
        pixelValsPackedSoFar =
            pixelValsPackedSoFar * packedMultiplyVal + bestIdx;
        if (++numPixelsPackedSoFar != pixelsPerPackedUnit) {
          continue;
        }

        numPixelsPackedSoFar = 0;

        //it is easier to display when low val is firts pixel. currently last pixel is low - reverse this
        pixelValsPackedSoFar = repackPackedVals(
            pixelValsPackedSoFar, pixelsPerPackedUnit, packedMultiplyVal);

        valSoFar = (valSoFar << packedOutBpp) | pixelValsPackedSoFar;
        pixelValsPackedSoFar = 0;
        bitsSoFar += packedOutBpp;

        if (bitsSoFar >= 8) {
          outBytes.add(valSoFar >> (bitsSoFar -= 8));
          valSoFar &= (1 << bitsSoFar) - 1;
          bytesOut++;
        }
      }

      //see if we have unfinished pixel packages to write
      if (numPixelsPackedSoFar > 0) {
        while (numPixelsPackedSoFar++ != pixelsPerPackedUnit)
          pixelValsPackedSoFar *= packedMultiplyVal;

        //it is easier to display when low val is firts pixel. currently last pixel is low - reverse this
        pixelValsPackedSoFar = repackPackedVals(
            pixelValsPackedSoFar, pixelsPerPackedUnit, packedMultiplyVal);

        valSoFar = (valSoFar << packedOutBpp) | pixelValsPackedSoFar;
        pixelValsPackedSoFar = 0;
        bitsSoFar += packedOutBpp;

        if (bitsSoFar >= 8) {
          outBytes.add(valSoFar >> (bitsSoFar -= 8));
          valSoFar &= (1 << bitsSoFar) - 1;
          bytesOut++;
        }
      }

      if (bitsSoFar > 0) {
        valSoFar <<= 8 - bitsSoFar; //left-align it as is expected
        outBytes.add(valSoFar);
        bytesOut++;
      }

      // while (bytesIn++ < rowBytesIn) {
      //   getchar();
      // }
      while (bytesOut++ < rowBytesOut) {
        outBytes.add(0);
      }
    }

    return outBytes;
  }
}

//Provides DefaultImageConverter
ImageConverter getImageConverter() => DefaultImageConverter();
