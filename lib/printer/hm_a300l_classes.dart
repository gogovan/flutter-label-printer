// ignore_for_file: no-magic-number, for enum codes and some default values.

enum LabelResolution {
  res100(100),
  res200(200);

  const LabelResolution(this.res);

  final int res;
}

/// Rotation settings for Hanyin HM-A300L: values are angles in counterclockwise direction.
enum Rotation90 {
  text(0),
  text90(90),
  text180(180),
  text270(270);

  const Rotation90(this.rot);

  final int rot;
}

/// Font settings for Hanyin HM-A300L.
/// 字体点阵大小:(单位:dot).
/// 注意:英文固件只支持(0和1).
/// 0:12x24.
/// 1:12x24(中文模式下打印繁体)，英文模式下字体变成(9x17)大小.
/// 2:8x16.
/// 3:20x20.
/// 4:32x32或者16x32，由ID3字体宽高各放大两倍.
/// 5:< chinese:24x24  english: 12x24.
/// 7:24x24或者12x24，视中英文而定.
/// 8:24x24或者12x24，视中英文而定.
/// 20:16x16或者8x16，视中英文而定.
/// 24:24x24或者12x24，视中英文而定.
/// 28:< chinese:28x28  english: 14x28.
/// 55:16x16或者8x16，视中英文而定.
enum Font {
  font0(0),
  font1(1),
  font2(2),
  font3(3),
  font4(4),
  font5(5),
  font7(7),
  font8(8),
  font20(20),
  font24(24),
  font28(28),
  font55(55);

  const Font(this.code);

  final int code;
}

enum PaperType {
  continuous(0),
  label(2),
  blackMark2Inch(4),
  blackMark3Inch(5),
  blackMark4Inch(6);

  const PaperType(this.code);

  final int code;
}

class PrintAreaSizeParams {
  PrintAreaSizeParams({
    this.offset = 0,
    this.horizontalRes = LabelResolution.res200,
    this.verticalRes = LabelResolution.res200,
    required this.height,
    this.quantity = 1,
  });

  int offset;
  LabelResolution horizontalRes;
  LabelResolution verticalRes;
  int height;
  int quantity;
}

class TextParams {
  TextParams({
    this.rotate = Rotation90.text,
    this.font = Font.font0,
    required this.xPosition,
    required this.yPosition,
    required this.text,
  });

  Rotation90 rotate;
  Font font;
  int xPosition;
  int yPosition;
  String text;
}
