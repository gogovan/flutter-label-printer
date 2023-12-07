// ignore_for_file: no-magic-number, for enum codes, default values and manufacturer codes.

import 'package:flutter/foundation.dart';
import 'package:flutter_label_printer/printer/common_classes.dart';

/// Font settings for Hanin TSPL
/// 0: Monotye CG Triumvirate Bold Condensed, font width and height is stretchable.
/// 1: 8 x 12 fixed pitch dot font.
/// 2: 12 x 20 fixed pitch dot font.
/// 3: 16 x 24 fixed pitch dot font.
/// 4: 24 x 32 fixed pitch dot font.
/// 5: 32 x 48 dot fixed pitch font.
/// 6: 14 x 19 dot fixed pitch font OCR-B.
/// 7: 21 x 27 dot fixed pitch font OCR-B.
/// 8: 14 x 25 dot fixed pitch font OCR-A.
/// 9: 只有这个字体能够打印中文。.
enum HaninTSPLFont {
  fontTriumvirate(0),
  font1(1),
  font2(2),
  font3(3),
  font4(4),
  font5(5),
  font6(6),
  font7(7),
  font8(8),
  fontChinese(9);

  const HaninTSPLFont(this.code);

  final int code;
}

enum HaninTSPLTextAlign {
  left(1),
  center(2),
  right(3);

  const HaninTSPLTextAlign(this.code);

  final int code;
}

enum HaninTSPLBarcodeType {
  code128('128'),
  code128m('128M'),
  ean128('EAN128'),
  code39('39'),
  code93('93'),
  upca('UPCA'),
  msi('MSI'),
  itf14('ITF14'),
  ean13('EAN13');

  const HaninTSPLBarcodeType(this.code);

  final String code;
}

enum HaninTSPLQRCodeECC {
  low('L'),
  medium('M'),
  quality('Q'),
  high('H');

  const HaninTSPLQRCodeECC(this.code);

  final String code;
}

enum HaninTSPLQRCodeMode {
  auto(0),
  manual(1);

  const HaninTSPLQRCodeMode(this.code);

  final int code;
}

@immutable
class HaninTSPLPrintAreaSizeParams {
  const HaninTSPLPrintAreaSizeParams({
    required this.width,
    required this.height,
  });

  final int width;
  final int height;

  @override
  String toString() => 'N31PrintAreaSizeParams{width: $width, height: $height}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HaninTSPLPrintAreaSizeParams &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => width.hashCode ^ height.hashCode;
}

@immutable
class HaninTSPLTextParams {
  const HaninTSPLTextParams({
    required this.xPosition,
    required this.yPosition,
    required this.text,
    this.rotate = Rotation90.text,
    this.font = HaninTSPLFont.fontChinese,
    this.alignment = HaninTSPLTextAlign.left,
    this.charWidth = 1,
    this.charHeight = 1,
    this.bold = 0,
  });

  final int xPosition;
  final int yPosition;
  final String text;
  final Rotation90 rotate;
  final HaninTSPLFont font;
  final HaninTSPLTextAlign alignment;
  final int charWidth;
  final int charHeight;
  final int bold;

  @override
  String toString() =>
      'HaninTSPLTextParams{xPosition: $xPosition, yPosition: $yPosition, text: $text, rotate: $rotate, font: $font, alignment: $alignment, charWidth: $charWidth, charHeight: $charHeight, bold: $bold}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HaninTSPLTextParams &&
          runtimeType == other.runtimeType &&
          xPosition == other.xPosition &&
          yPosition == other.yPosition &&
          text == other.text &&
          rotate == other.rotate &&
          font == other.font &&
          alignment == other.alignment &&
          charWidth == other.charWidth &&
          charHeight == other.charHeight &&
          bold == other.bold;

  @override
  int get hashCode =>
      xPosition.hashCode ^
      yPosition.hashCode ^
      text.hashCode ^
      rotate.hashCode ^
      font.hashCode ^
      alignment.hashCode ^
      charWidth.hashCode ^
      charHeight.hashCode ^
      bold.hashCode;
}

@immutable
class HaninTSPLTextBlockParams {
  const HaninTSPLTextBlockParams({
    required this.xPosition,
    required this.yPosition,
    required this.text,
    required this.width,
    this.height = 0,
    this.rotate = Rotation90.text,
    this.alignment = HaninTSPLTextAlign.left,
    this.charWidth = 1,
    this.charHeight = 1,
    this.bold = 0,
    this.lineSpacing = 0,
  });

  final int xPosition;
  final int yPosition;
  final String text;
  final int width;
  final int height;
  final Rotation90 rotate;
  final HaninTSPLTextAlign alignment;
  final int charWidth;
  final int charHeight;
  final int bold;
  final int lineSpacing;

  @override
  String toString() =>
      'HaninTSPLTextBlockParams{xPosition: $xPosition, yPosition: $yPosition, text: $text, width: $width, height: $height, rotate: $rotate, alignment: $alignment, charWidth: $charWidth, charHeight: $charHeight, bold: $bold, lineSpacing: $lineSpacing}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HaninTSPLTextBlockParams &&
          runtimeType == other.runtimeType &&
          xPosition == other.xPosition &&
          yPosition == other.yPosition &&
          text == other.text &&
          width == other.width &&
          height == other.height &&
          rotate == other.rotate &&
          alignment == other.alignment &&
          charWidth == other.charWidth &&
          charHeight == other.charHeight &&
          bold == other.bold &&
          lineSpacing == other.lineSpacing;

  @override
  int get hashCode =>
      xPosition.hashCode ^
      yPosition.hashCode ^
      text.hashCode ^
      width.hashCode ^
      height.hashCode ^
      rotate.hashCode ^
      alignment.hashCode ^
      charWidth.hashCode ^
      charHeight.hashCode ^
      bold.hashCode ^
      lineSpacing.hashCode;
}

@immutable
class HaninTSPLBarcodeParams {
  const HaninTSPLBarcodeParams({
    required this.xPosition,
    required this.yPosition,
    required this.barcodeType,
    required this.height,
    required this.barLineWidth,
    this.showData = false,
    this.rotate = Rotation90.text,
    required this.data,
  });

  final int xPosition;
  final int yPosition;
  final HaninTSPLBarcodeType barcodeType;
  final int height;
  final int barLineWidth;
  final bool showData;
  final Rotation90 rotate;
  final String data;

  @override
  String toString() =>
      'HaninTSPLBarcodeParams{xPosition: $xPosition, yPosition: $yPosition, barcodeType: $barcodeType, height: $height, barLineWidth: $barLineWidth, showData: $showData, rotate: $rotate, data: $data}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HaninTSPLBarcodeParams &&
          runtimeType == other.runtimeType &&
          xPosition == other.xPosition &&
          yPosition == other.yPosition &&
          barcodeType == other.barcodeType &&
          height == other.height &&
          barLineWidth == other.barLineWidth &&
          showData == other.showData &&
          rotate == other.rotate &&
          data == other.data;

  @override
  int get hashCode =>
      xPosition.hashCode ^
      yPosition.hashCode ^
      barcodeType.hashCode ^
      height.hashCode ^
      barLineWidth.hashCode ^
      showData.hashCode ^
      rotate.hashCode ^
      data.hashCode;
}

@immutable
class HaninTSPLQRCodeParams {
  const HaninTSPLQRCodeParams({
    required this.xPosition,
    required this.yPosition,
    this.eccLevel = HaninTSPLQRCodeECC.low,
    required this.unitSize,
    this.mode = HaninTSPLQRCodeMode.auto,
    this.rotate = Rotation90.text,
    required this.data,
  });

  final int xPosition;
  final int yPosition;
  final HaninTSPLQRCodeECC eccLevel;
  final int unitSize;
  final HaninTSPLQRCodeMode mode;
  final Rotation90 rotate;
  final String data;

  @override
  String toString() =>
      'HaninTSPLQRCodeParams{xPos: $xPosition, yPos: $yPosition, eccLevel: $eccLevel, unitSize: $unitSize, mode: $mode, rotate: $rotate, data: $data}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HaninTSPLQRCodeParams &&
          runtimeType == other.runtimeType &&
          xPosition == other.xPosition &&
          yPosition == other.yPosition &&
          eccLevel == other.eccLevel &&
          unitSize == other.unitSize &&
          mode == other.mode &&
          rotate == other.rotate &&
          data == other.data;

  @override
  int get hashCode =>
      xPosition.hashCode ^
      yPosition.hashCode ^
      eccLevel.hashCode ^
      unitSize.hashCode ^
      mode.hashCode ^
      rotate.hashCode ^
      data.hashCode;
}

@immutable
class HaninTSPLImageParams {
  const HaninTSPLImageParams({
    required this.imagePath,
    required this.xPosition,
    required this.yPosition,
    this.imageMode = ImageMode.binary,
  });

  final String imagePath;
  final int xPosition;
  final int yPosition;
  final ImageMode imageMode;

  @override
  String toString() =>
      'HaninTSPLImageParams{imagePath: $imagePath, xPos: $xPosition, yPos: $yPosition, imageMode: $imageMode}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HaninTSPLImageParams &&
          runtimeType == other.runtimeType &&
          imagePath == other.imagePath &&
          xPosition == other.xPosition &&
          yPosition == other.yPosition &&
          imageMode == other.imageMode;

  @override
  int get hashCode =>
      imagePath.hashCode ^
      xPosition.hashCode ^
      yPosition.hashCode ^
      imageMode.hashCode;
}

@immutable
class HaninTSPLPrinterStatus {
  const HaninTSPLPrinterStatus(this.code);

  final int code;

  bool isDisconnected() => code == -1;

  bool isTimeout() => code == -2;

  bool isNormal() => code == 0;

  bool isHeadOpened() => code & 1 == 1;

  bool isPaperJammed() => code & 2 == 2;

  bool isOutOfPaper() => code & 4 == 4;

  bool isOutOfInk() => code & 8 == 8;

  bool isPaused() => code & 16 == 16;

  bool isPrinting() => code & 32 == 32;

  bool isCoverOpened() => code & 64 == 64;

  bool isOverheated() => code & 128 == 128;

  @override
  String toString() => 'HaninTSPLPrinterStatus{code: $code}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HaninTSPLPrinterStatus &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
