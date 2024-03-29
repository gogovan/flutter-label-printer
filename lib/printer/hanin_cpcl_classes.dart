// ignore_for_file: no-magic-number, for enum codes, default values and manufacturer codes.

import 'package:flutter/foundation.dart';
import 'package:flutter_label_printer/printer/common_classes.dart';

/// Font settings for Hanin CPCL
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
enum HaninCPCLFont {
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

  const HaninCPCLFont(this.code);

  final int code;
}

enum HaninCPCLPaperType {
  continuous(0),
  label(2),
  blackMark2Inch(4),
  blackMark3Inch(5),
  blackMark4Inch(6);

  const HaninCPCLPaperType(this.code);

  final int code;
}

enum HaninCPCLTextAlign {
  left(0),
  center(1),
  right(2);

  const HaninCPCLTextAlign(this.code);

  final int code;
}

enum HaninCPCLOrientation {
  horizontal(0),
  vertical(1);

  const HaninCPCLOrientation(this.code);

  final int code;
}

enum HaninCPCLBarcodeType {
  upca(0),
  upce(1),
  ean13(2),
  ean8(3),
  code39(4),
  code93(5),
  code128(6),
  codabar(7);

  const HaninCPCLBarcodeType(this.code);

  final int code;
}

enum HaninCPCLBarcodeRatio {
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

  const HaninCPCLBarcodeRatio(this.code);

  final int code;
}

enum HaninCPCLQRCodeModel {
  normal(1),
  extraSymbols(2);

  const HaninCPCLQRCodeModel(this.code);

  final int code;
}

@immutable
class HaninCPCLPrintAreaSizeParams {
  const HaninCPCLPrintAreaSizeParams({
    this.offset = 0,
    required this.height,
    this.quantity = 1,
  });

  final int offset;
  final int height;
  final int quantity;

  @override
  String toString() =>
      'PrintAreaSizeParams{offset: $offset, height: $height, quantity: $quantity}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HaninCPCLPrintAreaSizeParams &&
          runtimeType == other.runtimeType &&
          offset == other.offset &&
          height == other.height &&
          quantity == other.quantity;

  @override
  int get hashCode => offset.hashCode ^ height.hashCode ^ quantity.hashCode;
}

@immutable
class HaninCPCLTextParams {
  const HaninCPCLTextParams({
    this.rotate = Rotation90.text,
    this.font = HaninCPCLFont.font0,
    required this.xPosition,
    required this.yPosition,
    required this.text,
  });

  final Rotation90 rotate;
  final HaninCPCLFont font;
  final int xPosition;
  final int yPosition;
  final String text;

  @override
  String toString() =>
      'TextParams{rotate: $rotate, font: $font, xPosition: $xPosition, yPosition: $yPosition, text: $text}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HaninCPCLTextParams &&
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
class HaninCPCLBarcodeParams {
  const HaninCPCLBarcodeParams({
    this.orientation = HaninCPCLOrientation.horizontal,
    required this.type,
    required this.ratio,
    required this.barWidthUnit,
    required this.height,
    required this.xPosition,
    required this.yPosition,
    required this.data,
    this.dataTextParams,
  });

  final HaninCPCLOrientation orientation;
  final HaninCPCLBarcodeType type;
  final int barWidthUnit;
  final HaninCPCLBarcodeRatio ratio;
  final int height;
  final int xPosition;
  final int yPosition;
  final String data;
  final HaninCPCLBarcodeDataTextParams? dataTextParams;

  @override
  String toString() =>
      'BarcodeParams{orientation: $orientation, type: $type, barWidthUnit: $barWidthUnit, ratio: $ratio, height: $height, xPosition: $xPosition, yPosition: $yPosition, data: $data, dataTextParams: $dataTextParams}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HaninCPCLBarcodeParams &&
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
class HaninCPCLBarcodeDataTextParams {
  const HaninCPCLBarcodeDataTextParams({
    required this.font,
    required this.size,
    required this.offset,
  });

  final HaninCPCLFont font;
  final int size;
  final int offset;

  @override
  String toString() =>
      'BarcodeDataTextParams{font: $font, size: $size, offset: $offset}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HaninCPCLBarcodeDataTextParams &&
          runtimeType == other.runtimeType &&
          font == other.font &&
          size == other.size &&
          offset == other.offset;

  @override
  int get hashCode => font.hashCode ^ size.hashCode ^ offset.hashCode;
}

@immutable
class HaninCPCLQRCodeParams {
  const HaninCPCLQRCodeParams({
    required this.orientation,
    required this.xPosition,
    required this.yPosition,
    required this.model,
    required this.unitSize,
    required this.data,
  });

  final HaninCPCLOrientation orientation;
  final int xPosition;
  final int yPosition;
  final HaninCPCLQRCodeModel model;
  final int unitSize;
  final String data;

  @override
  String toString() =>
      'QRCodeParams{orientation: $orientation, xPosition: $xPosition, yPosition: $yPosition, model: $model, unitSize: $unitSize, data: $data}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HaninCPCLQRCodeParams &&
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
class HaninCPCLImageParams {
  const HaninCPCLImageParams({
    required this.imagePath,
    required this.xPosition,
    required this.yPosition,
    this.mode = ImageMode.binary,
    this.compress = true,
    this.package = false,
  });

  /// Path to the image to be printed, in either PNG or JPG format.
  /// Size should be set accordingly. At 200 dpi, 8px in image corresponds to 1mm printed.
  final String imagePath;
  final int xPosition;
  final int yPosition;
  final ImageMode mode;
  final bool compress;
  final bool package;
}

/// Printer status.
@immutable
class HaninCPCLPrinterStatus {
  const HaninCPCLPrinterStatus(this.code);

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
      other is HaninCPCLPrinterStatus &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
