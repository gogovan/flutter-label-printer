// ignore_for_file: no-magic-number, for enum codes and some default values.

import 'package:flutter/foundation.dart';

/// Resolution of printing in dpi (dots per inch).
enum HMA300LLabelResolution {
  res100(100),
  res200(200);

  const HMA300LLabelResolution(this.res);

  final int res;
}

/// Rotation settings for Hanyin HM-A300L: values are angles in counterclockwise direction.
enum HMA300LRotation90 {
  text(0),
  text90(90),
  text180(180),
  text270(270);

  const HMA300LRotation90(this.rot);

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
enum HMA300LFont {
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

  const HMA300LFont(this.code);

  final int code;
}

enum HMA300LPaperType {
  continuous(0),
  label(2),
  blackMark2Inch(4),
  blackMark3Inch(5),
  blackMark4Inch(6);

  const HMA300LPaperType(this.code);

  final int code;
}

enum HMA300LPrinterTextAlign {
  left(0),
  center(1),
  right(2);

  const HMA300LPrinterTextAlign(this.code);

  final int code;
}

enum HMA300LPrintOrientation {
  horizontal(0),
  vertical(1);

  const HMA300LPrintOrientation(this.code);

  final int code;
}

enum HMA300LBarcodeType {
  upca(0),
  upce(1),
  ean13(2),
  ean8(3),
  code39(4),
  code93(5),
  code128(6),
  codabar(7);

  const HMA300LBarcodeType(this.code);

  final int code;
}

enum HMA300LBarcodeRatio {
  ratio0(0),
  ratio1(1),
  ratio2(2),
  ratio3(3),
  ratio4(4),
  ratio20(20),
  ratio21(21),
  ratio22(22),
  ratio23(23),
  ratio24(24),
  ratio25(25),
  ratio26(26),
  ratio27(27),
  ratio28(28),
  ratio29(29),
  ratio30(30);

  const HMA300LBarcodeRatio(this.code);

  final int code;
}

enum HMA300LQRCodeModel {
  normal(1),
  extraSymbols(2);

  const HMA300LQRCodeModel(this.code);

  final int code;
}

enum HMA300LPrintImageMode {
  binary(0),
  dithering(1),
  cluster(2);

  const HMA300LPrintImageMode(this.code);

  final int code;
}

@immutable
class HMA300LPrintAreaSizeParams {
  const HMA300LPrintAreaSizeParams({
    this.offset = 0,
    this.horizontalRes = HMA300LLabelResolution.res200,
    this.verticalRes = HMA300LLabelResolution.res200,
    required this.height,
    this.quantity = 1,
  });

  final int offset;
  final HMA300LLabelResolution horizontalRes;
  final HMA300LLabelResolution verticalRes;
  final int height;
  final int quantity;


  @override
  String toString() => 'PrintAreaSizeParams{offset: $offset, horizontalRes: $horizontalRes, verticalRes: $verticalRes, height: $height, quantity: $quantity}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HMA300LPrintAreaSizeParams &&
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
class HMA300LTextParams {
  const HMA300LTextParams({
    this.rotate = HMA300LRotation90.text,
    this.font = HMA300LFont.font0,
    required this.xPosition,
    required this.yPosition,
    required this.text,
  });

  final HMA300LRotation90 rotate;
  final HMA300LFont font;
  final int xPosition;
  final int yPosition;
  final String text;

  @override
  String toString() =>
      'TextParams{rotate: $rotate, font: $font, xPosition: $xPosition, yPosition: $yPosition, text: $text}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HMA300LTextParams &&
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

@immutable
class HMA300LBarcodeParams {
  const HMA300LBarcodeParams({
    this.orientation = HMA300LPrintOrientation.horizontal,
    required this.type,
    required this.ratio,
    required this.barWidthUnit,
    required this.height,
    required this.xPosition,
    required this.yPosition,
    required this.data,
    this.dataTextParams,
  });

  final HMA300LPrintOrientation orientation;
  final HMA300LBarcodeType type;
  final int barWidthUnit;
  final HMA300LBarcodeRatio ratio;
  final int height;
  final int xPosition;
  final int yPosition;
  final String data;
  final HMA300LBarcodeDataTextParams? dataTextParams;

  @override
  String toString() =>
      'BarcodeParams{orientation: $orientation, type: $type, barWidthUnit: $barWidthUnit, ratio: $ratio, height: $height, xPosition: $xPosition, yPosition: $yPosition, data: $data, dataTextParams: $dataTextParams}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HMA300LBarcodeParams &&
          runtimeType == other.runtimeType &&
          orientation == other.orientation &&
          type == other.type &&
          barWidthUnit == other.barWidthUnit &&
          ratio == other.ratio &&
          height == other.height &&
          xPosition == other.xPosition &&
          yPosition == other.yPosition &&
          data == other.data &&
          dataTextParams == other.dataTextParams;

  @override
  int get hashCode =>
      orientation.hashCode ^
      type.hashCode ^
      barWidthUnit.hashCode ^
      ratio.hashCode ^
      height.hashCode ^
      xPosition.hashCode ^
      yPosition.hashCode ^
      data.hashCode ^
      dataTextParams.hashCode;
}

@immutable
class HMA300LBarcodeDataTextParams {
  const HMA300LBarcodeDataTextParams({
    required this.font,
    required this.size,
    required this.offset,
  });

  final HMA300LFont font;
  final int size;
  final int offset;

  @override
  String toString() =>
      'BarcodeDataTextParams{font: $font, size: $size, offset: $offset}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HMA300LBarcodeDataTextParams &&
          runtimeType == other.runtimeType &&
          font == other.font &&
          size == other.size &&
          offset == other.offset;

  @override
  int get hashCode => font.hashCode ^ size.hashCode ^ offset.hashCode;
}

@immutable
class HMA300LQRCodeParams {
  const HMA300LQRCodeParams({
    required this.orientation,
    required this.xPosition,
    required this.yPosition,
    required this.model,
    required this.unitSize,
    required this.data,
  });

  final HMA300LPrintOrientation orientation;
  final int xPosition;
  final int yPosition;
  final HMA300LQRCodeModel model;
  final int unitSize;
  final String data;

  @override
  String toString() =>
      'QRCodeParams{orientation: $orientation, xPosition: $xPosition, yPosition: $yPosition, model: $model, unitSize: $unitSize, data: $data}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HMA300LQRCodeParams &&
          runtimeType == other.runtimeType &&
          orientation == other.orientation &&
          xPosition == other.xPosition &&
          yPosition == other.yPosition &&
          model == other.model &&
          unitSize == other.unitSize &&
          data == other.data;

  @override
  int get hashCode =>
      orientation.hashCode ^
      xPosition.hashCode ^
      yPosition.hashCode ^
      model.hashCode ^
      unitSize.hashCode ^
      data.hashCode;
}

@immutable
class HMA300LPrintImageParams {
  const HMA300LPrintImageParams({
    required this.imagePath,
    required this.xPosition,
    required this.yPosition,
    this.mode = HMA300LPrintImageMode.binary,
    this.compress = true,
    this.package = false,
  });

  /// Path to the image to be printed, in either PNG or JPG format.
  /// Size should be set accordingly. At 200 dpi, 8px in image corresponds to 1mm printed.
  final String imagePath;
  final int xPosition;
  final int yPosition;
  final HMA300LPrintImageMode mode;
  final bool compress;
  final bool package;
}

/// Printer status.
@immutable
class HMA300LPrinterStatus {
  const HMA300LPrinterStatus(this.code);

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
      other is HMA300LPrinterStatus &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
