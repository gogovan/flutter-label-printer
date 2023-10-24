import 'package:flutter/foundation.dart';
import 'package:flutter_label_printer/printer/common_classes.dart';

/// Font settings for Hanin N31.
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
enum N31Font {
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

  const N31Font(this.code);

  final int code;
}

enum N31PrinterTextAlign {
  left(1),
  center(2),
  right(3);

  const N31PrinterTextAlign(this.code);

  final int code;
}

enum N31BarcodeType {
  code128('128'),
  code128m('128M'),
  ean128('EAN128'),
  code39('39'),
  code93('93'),
  upca('UPCA'),
  msi('MSI'),
  itf14('ITF14'),
  ean13('EAN13');

  const N31BarcodeType(this.code);

  final String code;
}

enum N31QRCodeECC {
  low('L'),
  medium('M'),
  quality('Q'),
  high('H');

  const N31QRCodeECC(this.code);

  final String code;
}

enum N31QRCodeMode {
  auto(0),
  manual(1);

  const N31QRCodeMode(this.code);

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
    required this.xPos,
    required this.yPos,
    required this.text,
    this.rotate = Rotation90.text,
    this.font = N31Font.fontChinese,
    this.alignment = N31PrinterTextAlign.left,
    this.charWidth = 1,
    this.charHeight = 1,
  });

  final int xPos;
  final int yPos;
  final String text;
  final Rotation90 rotate;
  final N31Font font;
  final N31PrinterTextAlign alignment;
  final int charWidth;
  final int charHeight;

  @override
  String toString() =>
      'N31TextParams{xPos: $xPos, yPos: $yPos, text: $text, rotate: $rotate, font: $font, alignment: $alignment, charWidth: $charWidth, charHeight: $charHeight}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HaninTSPLTextParams &&
          runtimeType == other.runtimeType &&
          xPos == other.xPos &&
          yPos == other.yPos &&
          text == other.text &&
          rotate == other.rotate &&
          font == other.font &&
          alignment == other.alignment &&
          charWidth == other.charWidth &&
          charHeight == other.charHeight;

  @override
  int get hashCode =>
      xPos.hashCode ^
      yPos.hashCode ^
      text.hashCode ^
      rotate.hashCode ^
      font.hashCode ^
      alignment.hashCode ^
      charWidth.hashCode ^
      charHeight.hashCode;
}

@immutable
class HaninTSPLBarcodeParams {
  const HaninTSPLBarcodeParams({
    required this.xPos,
    required this.yPos,
    required this.barcodeType,
    required this.height,
    this.showData = false,
    this.rotate = Rotation90.text,
    required this.data,
  });

  final int xPos;
  final int yPos;
  final N31BarcodeType barcodeType;
  final int height;
  final bool showData;
  final Rotation90 rotate;
  final String data;

  @override
  String toString() =>
      'HaninTSPLBarcodeParams{xPos: $xPos, yPos: $yPos, barcodeType: $barcodeType, height: $height, showData: $showData, rotate: $rotate, data: $data}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HaninTSPLBarcodeParams &&
          runtimeType == other.runtimeType &&
          xPos == other.xPos &&
          yPos == other.yPos &&
          barcodeType == other.barcodeType &&
          height == other.height &&
          showData == other.showData &&
          rotate == other.rotate &&
          data == other.data;

  @override
  int get hashCode =>
      xPos.hashCode ^
      yPos.hashCode ^
      barcodeType.hashCode ^
      height.hashCode ^
      showData.hashCode ^
      rotate.hashCode ^
      data.hashCode;
}

@immutable
class HaninTSPLQRCodeParams {
  const HaninTSPLQRCodeParams({
    required this.xPos,
    required this.yPos,
    this.eccLevel = N31QRCodeECC.low,
    required this.unitSize,
    this.mode = N31QRCodeMode.auto,
    this.rotate = Rotation90.text,
    required this.data,
  });

  final int xPos;
  final int yPos;
  final N31QRCodeECC eccLevel;
  final int unitSize;
  final N31QRCodeMode mode;
  final Rotation90 rotate;
  final String data;

  @override
  String toString() =>
      'HaninTSPLQRCodeParams{xPos: $xPos, yPos: $yPos, eccLevel: $eccLevel, unitSize: $unitSize, mode: $mode, rotate: $rotate, data: $data}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HaninTSPLQRCodeParams &&
          runtimeType == other.runtimeType &&
          xPos == other.xPos &&
          yPos == other.yPos &&
          eccLevel == other.eccLevel &&
          unitSize == other.unitSize &&
          mode == other.mode &&
          rotate == other.rotate &&
          data == other.data;

  @override
  int get hashCode =>
      xPos.hashCode ^
      yPos.hashCode ^
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
    required this.xPos,
    required this.yPos,
    this.imageMode = ImageMode.binary,
  });

  final String imagePath;
  final int xPos;
  final int yPos;
  final ImageMode imageMode;

  @override
  String toString() =>
      'HaninTSPLImageParams{imagePath: $imagePath, xPos: $xPos, yPos: $yPos, imageMode: $imageMode}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HaninTSPLImageParams &&
          runtimeType == other.runtimeType &&
          imagePath == other.imagePath &&
          xPos == other.xPos &&
          yPos == other.yPos &&
          imageMode == other.imageMode;

  @override
  int get hashCode =>
      imagePath.hashCode ^ xPos.hashCode ^ yPos.hashCode ^ imageMode.hashCode;
}
