enum EinkClut {
  TwoBlacks,
  TwoBlacksAndYellow,
  TwoBlacksAndRed,
  TwoBlacksAndYellowPacked,
  TwoBlacksAndRedPacked,
  FourBlacks,
  ThreeBlacksAndYellow,
  ThreeBlacksAndRed,
  FourBlacksAndYellowPacked,
  FourBlacksAndRedPacked,
  FiveBlacksAndYellowPacked,
  FiveBlacksAndRedPacked,
  EightBlacks,
  SevenBlacksAndYellow,
  SevenBlacksAndRed,
  SixteenBlacks,
}

extension EinkClutExtension on EinkClut {
  String get displayTitle {
    switch (this) {
      case EinkClut.TwoBlacks:
        return '1bpp (2 blacks)';
      case EinkClut.TwoBlacksAndYellow:
        return '1bppY (2 blacks & yellow)';
      case EinkClut.TwoBlacksAndRed:
        return '1bppR (2 blacks & red)';
      case EinkClut.TwoBlacksAndYellowPacked:
        return '3clrPkdY (2 blacks & yellow packed)';
      case EinkClut.TwoBlacksAndRedPacked:
        return '3clrPkdR (2 blacks & red packed)';
      case EinkClut.FourBlacks:
        return '2bpp (4 blacks)';
      case EinkClut.ThreeBlacksAndYellow:
        return '2bppY (3 blacks & yellow)';
      case EinkClut.ThreeBlacksAndRed:
        return '2bppR (3 blacks & red)';
      case EinkClut.FourBlacksAndYellowPacked:
        return '5clrPkdY (4 blacks & yellow packed)';
      case EinkClut.FourBlacksAndRedPacked:
        return '5clrPkdR (4 blacks & red packed)';
      case EinkClut.FiveBlacksAndYellowPacked:
        return '6clrPkdY (5 blacks & yellow packed)';
      case EinkClut.FiveBlacksAndRedPacked:
        return '6clrPkdR (5 blacks & red packed)';
      case EinkClut.EightBlacks:
        return '3bpp (8 blacks)';
      case EinkClut.SevenBlacksAndYellow:
        return '3bppY (7 blacks & yellow)';
      case EinkClut.SevenBlacksAndRed:
        return '3bppR (7 blacks & red)';
      case EinkClut.SixteenBlacks:
        return '4bpp (16 blacks)';
    }
  }
}

/// 3 pixels of 5 possible colors in 7 bits
const int COMPRESSION_BITPACKED_3x5_to_7 = 0x62700357;

/// 5 pixels of 3 possible colors in 8 bits
const int COMPRESSION_BITPACKED_5x3_to_8 = 0x62700538;

/// 3 pixels of 6 possible colors in 8 bits
const int COMPRESSION_BITPACKED_3x6_to_8 = 0x62700368;

class BitMapFileHeader {
  // uint8_t sig[2];
  // uint32_t fileSz;
  // uint8_t rfu[4];
  // uint32_t dataOfst;
  // uint32_t headerSz;			//40
  // int32_t width;
  // int32_t height;
  // uint16_t colorplanes;		//must be one
  // uint16_t bpp;
  // uint32_t compression;
  // uint32_t dataLen;			//may be 0
  // uint32_t pixelsPerMeterX;
  // uint32_t pixelsPerMeterY;
  // uint32_t numColors;			//if zero, assume 2^bpp
  // uint32_t numImportantColors;
  static int size = 54;

  List<int> sig;
  int fileSz;
  List<int> rfu;
  int dataOfst;
  int headerSz; //40
  int width;
  int height;
  int colorplanes; //must be one
  /// Bits per pixel
  int bpp;
  int compression;
  int dataLen; //may be 0
  int pixelsPerMeterX;
  int pixelsPerMeterY;
  int numColors; //if zero, assume 2^bpp
  int numImportantColors;

  BitMapFileHeader(
      {required this.sig,
      required this.fileSz,
      required this.rfu,
      required this.dataOfst,
      required this.headerSz,
      required this.width,
      required this.height,
      required this.colorplanes,
      required this.bpp,
      required this.compression,
      required this.dataLen,
      required this.pixelsPerMeterX,
      required this.pixelsPerMeterY,
      required this.numColors,
      required this.numImportantColors});

  List<int> toList() {
    List<int> list = [];

    list += sig;

    list.add((fileSz) & 0xFF);
    list.add((fileSz >> 8) & 0xFF);
    list.add((fileSz >> 16) & 0xFF);
    list.add((fileSz >> 24) & 0xFF);

    list += rfu;

    list.add((dataOfst) & 0xFF);
    list.add((dataOfst >> 8) & 0xFF);
    list.add((dataOfst >> 16) & 0xFF);
    list.add((dataOfst >> 24) & 0xFF);

    list.add((headerSz) & 0xFF);
    list.add((headerSz >> 8) & 0xFF);
    list.add((headerSz >> 16) & 0xFF);
    list.add((headerSz >> 24) & 0xFF);

    list.add((width) & 0xFF);
    list.add((width >> 8) & 0xFF);
    list.add((width >> 16) & 0xFF);
    list.add((width >> 24) & 0xFF);

    list.add((height) & 0xFF);
    list.add((height >> 8) & 0xFF);
    list.add((height >> 16) & 0xFF);
    list.add((height >> 24) & 0xFF);

    list.add((colorplanes) & 0xFF);
    list.add((colorplanes >> 8) & 0xFF);

    list.add((bpp) & 0xFF);
    list.add((bpp >> 8) & 0xFF);

    list.add((compression) & 0xFF);
    list.add((compression >> 8) & 0xFF);
    list.add((compression >> 16) & 0xFF);
    list.add((compression >> 24) & 0xFF);

    list.add((dataLen) & 0xFF);
    list.add((dataLen >> 8) & 0xFF);
    list.add((dataLen >> 16) & 0xFF);
    list.add((dataLen >> 24) & 0xFF);

    list.add((pixelsPerMeterX) & 0xFF);
    list.add((pixelsPerMeterX >> 8) & 0xFF);
    list.add((pixelsPerMeterX >> 16) & 0xFF);
    list.add((pixelsPerMeterX >> 24) & 0xFF);

    list.add((pixelsPerMeterY) & 0xFF);
    list.add((pixelsPerMeterY >> 8) & 0xFF);
    list.add((pixelsPerMeterY >> 16) & 0xFF);
    list.add((pixelsPerMeterY >> 24) & 0xFF);

    list.add((numColors) & 0xFF);
    list.add((numColors >> 8) & 0xFF);
    list.add((numColors >> 16) & 0xFF);
    list.add((numColors >> 24) & 0xFF);

    list.add((numImportantColors) & 0xFF);
    list.add((numImportantColors >> 8) & 0xFF);
    list.add((numImportantColors >> 16) & 0xFF);
    list.add((numImportantColors >> 24) & 0xFF);

    return list;
  }

  static BitMapFileHeader? fromList(final List<int> list) {
    if (list.length < size) {
      return null;
    }

    return BitMapFileHeader(
        sig: list.sublist(0, 2),
        fileSz: list[5] << 24 | list[4] << 16 | list[3] << 8 | list[2],
        rfu: list.sublist(6, 10),
        dataOfst: list[13] << 24 | list[12] << 16 | list[11] << 8 | list[10],
        headerSz: list[17] << 24 | list[16] << 16 | list[15] << 8 | list[14],
        width: list[21] << 24 | list[20] << 16 | list[19] << 8 | list[18],
        height: list[25] << 24 | list[24] << 16 | list[23] << 8 | list[22],
        colorplanes: list[27] << 8 | list[26],
        bpp: list[29] << 8 | list[28],
        compression: list[33] << 24 | list[32] << 16 | list[31] << 8 | list[30],
        dataLen: list[37] << 24 | list[36] << 16 | list[35] << 8 | list[34],
        pixelsPerMeterX:
            list[41] << 24 | list[40] << 16 | list[39] << 8 | list[38],
        pixelsPerMeterY:
            list[45] << 24 | list[44] << 16 | list[43] << 8 | list[42],
        numColors: list[49] << 24 | list[48] << 16 | list[47] << 8 | list[46],
        numImportantColors:
            list[53] << 24 | list[52] << 16 | list[51] << 8 | list[50]);
  }

  @override
  String toString() {
    return 'BitMapFileHeader[$sig,$fileSz,$rfu,$dataOfst,$headerSz,$width,$height,$colorplanes,$bpp,$compression,$dataLen,$pixelsPerMeterX,$pixelsPerMeterY,$numColors,$numImportantColors]';
  }
}
