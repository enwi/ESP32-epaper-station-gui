import 'dart:ui';

int calcCrossAxisCount(final Size screenSize, final int itemWidth) {
  if (screenSize.width >= itemWidth) {
    return screenSize.width ~/ itemWidth;
  }
  return 1;
}
