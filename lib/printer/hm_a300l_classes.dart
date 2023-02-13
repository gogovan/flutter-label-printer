// ignore_for_file: no-magic-number, for enum codes and some default values.

import 'package:flutter/foundation.dart';

/// Resolution of printing in dpi (dots per inch).
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

@immutable
class PrintAreaSizeParams {
  const PrintAreaSizeParams({
    this.offset = 0,
    this.horizontalRes = LabelResolution.res200,
    this.verticalRes = LabelResolution.res200,
    required this.height,
    this.quantity = 1,
  });

  final int offset;
  final LabelResolution horizontalRes;
  final LabelResolution verticalRes;
  final int height;
  final int quantity;

  @override
  String toString() =>
      'PrintAreaSizeParams{offset: $offset, horizontalRes: $horizontalRes, verticalRes: $verticalRes, height: $height, quantity: $quantity}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintAreaSizeParams &&
          runtimeType == other.runtimeType &&
          offset == other.offset &&
          horizontalRes == other.horizontalRes &&
          verticalRes == other.verticalRes &&
          height == other.height &&
          quantity == other.quantity;

  @override
  int get hashCode =>
      offset.hashCode ^
      horizontalRes.hashCode ^
      verticalRes.hashCode ^
      height.hashCode ^
      quantity.hashCode;
}

@immutable
class TextParams {
  const TextParams({
    this.rotate = Rotation90.text,
    this.font = Font.font0,
    required this.xPosition,
    required this.yPosition,
    required this.text,
  });

  final Rotation90 rotate;
  final Font font;
  final int xPosition;
  final int yPosition;
  final String text;

  @override
  String toString() =>
      'TextParams{rotate: $rotate, font: $font, xPosition: $xPosition, yPosition: $yPosition, text: $text}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextParams &&
          runtimeType == other.runtimeType &&
          rotate == other.rotate &&
          font == other.font &&
          xPosition == other.xPosition &&
          yPosition == other.yPosition &&
          text == other.text;

  @override
  int get hashCode =>
      rotate.hashCode ^
      font.hashCode ^
      xPosition.hashCode ^
      yPosition.hashCode ^
      text.hashCode;
}

/// Printer status.
@immutable
class PrinterStatus {
  const PrinterStatus(this.code);

  final int code;

  bool isFailure() => code == -1;

  bool isBusy() => code & 1 == 1;

  bool isOutOfPaper() => code & 2 == 2;

  bool isCaseOpened() => code & 4 == 4;

  bool isBatteryLow() => code & 8 == 8;

  bool isNormal() => code == 0;

  @override
  String toString() =>
      'isFail: ${isFailure()}, isBusy: ${isBusy()}, isOutOfPaper: ${isOutOfPaper()}, isCaseOpened: ${isCaseOpened()}, isBatteryLow: ${isBatteryLow()}, code=$code';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrinterStatus &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
