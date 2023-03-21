import 'package:flutter_label_printer/exception/invalid_argument_exception.dart';
import 'package:flutter_label_printer/exception/invalid_connection_state_exception.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';
import 'package:flutter_label_printer/printer/hm_a300l_printer.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_area_size.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_barcode.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_image.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_qr_code.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_rect.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text_align.dart';
import 'package:flutter_label_printer/templating/templatable_printer_interface.dart';

/// Interface for Templating for the Hanyin (HPRT) HM-A300L Printer.
class HMA300LPrinterInterface extends HMA300LPrinter
    implements TemplatablePrinterInterface {
  HMA300LPrinterInterface(super.device);

  @override
  Future<bool> setPrintAreaSize(PrintAreaSize printAreaSize) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    final height = printAreaSize.height;
    if (height == null) {
      throw InvalidArgumentException(
        'Height must not be null',
        StackTrace.current.toString(),
      );
    }

    final HMA300LPaperType paperType;
    switch (printAreaSize.paperType) {
      case PrintPaperType.continuous:
        paperType = HMA300LPaperType.continuous;
        break;
      case PrintPaperType.label:
        paperType = HMA300LPaperType.label;
        break;
      default:
        paperType = HMA300LPaperType.continuous;
        break;
    }

    final typeResult = await setPaperType(paperType);

    final HMA300LPrintAreaSizeParams params = HMA300LPrintAreaSizeParams(
      offset: printAreaSize.originX?.toInt() ?? 0,
      height: height.toInt(),
    );

    final sizeResult = await setPrintAreaSizeParams(params);

    return typeResult && sizeResult;
  }

  HMA300LRotation90 getHMA300LRotation(double angle) {
    final roundedRotation = (angle / 90).round() * 90 % 360;
    switch (roundedRotation) {
      case 0:
        return HMA300LRotation90.text;
      // ignore: no-magic-number, well-formed angles.
      case 90:
        return HMA300LRotation90.text90;
      // ignore: no-magic-number, well-formed angles.
      case 180:
        return HMA300LRotation90.text180;
      // ignore: no-magic-number, well-formed angles.
      case 270:
        return HMA300LRotation90.text270;
      default:
        return HMA300LRotation90.text;
    }
  }

  HMA300LPrintOrientation getHMA300LPrintOrientation(double angle) {
    final roundedRotation = (angle / 90).round() * 90 % 180;
    switch (roundedRotation) {
      case 0:
        return HMA300LPrintOrientation.horizontal;
      // ignore: no-magic-number, well-formed angles.
      case 90:
        return HMA300LPrintOrientation.vertical;
      default:
        return HMA300LPrintOrientation.horizontal;
    }
  }

  @override
  Future<bool> addText(PrintText printText) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    final style = printText.style;

    bool sizeResult;
    bool boldResult;
    bool alignResult;
    if (style != null) {
      sizeResult = await setTextSize(
        style.width?.toInt() ?? 1,
        style.height?.toInt() ?? 1,
      );
      boldResult = await setBold(style.bold?.toInt() ?? 0);

      HMA300LPrinterTextAlign hmA300lAlign;
      switch (style.align) {
        case PrintTextAlign.left:
          hmA300lAlign = HMA300LPrinterTextAlign.left;
          break;
        case PrintTextAlign.center:
          hmA300lAlign = HMA300LPrinterTextAlign.center;
          break;
        case PrintTextAlign.right:
          hmA300lAlign = HMA300LPrinterTextAlign.right;
          break;
        default:
          hmA300lAlign = HMA300LPrinterTextAlign.left;
      }
      alignResult = await setAlign(hmA300lAlign);
    } else {
      sizeResult = true;
      boldResult = true;
      alignResult = true;
    }

    final textParams = HMA300LTextParams(
      xPosition: printText.xPosition.toInt(),
      yPosition: printText.yPosition.toInt(),
      text: printText.text,
      rotate: getHMA300LRotation(printText.rotation),
    );
    final textResult = await addTextParams(textParams);

    if (style != null) {
      sizeResult = sizeResult && await setTextSize(1, 1);
      boldResult = boldResult && await setBold(0);
      alignResult = alignResult && await setAlign(HMA300LPrinterTextAlign.left);
    }

    return sizeResult && boldResult && alignResult && textResult;
  }

  @override
  Future<bool> addBarcode(PrintBarcode barcode) {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    final HMA300LBarcodeType barcodeType;
    switch (barcode.type) {
      case PrintBarcodeType.upca:
        barcodeType = HMA300LBarcodeType.upca;
        break;
      case PrintBarcodeType.upce:
        barcodeType = HMA300LBarcodeType.upce;
        break;
      case PrintBarcodeType.ean13:
        barcodeType = HMA300LBarcodeType.ean13;
        break;
      case PrintBarcodeType.ean8:
        barcodeType = HMA300LBarcodeType.ean8;
        break;
      case PrintBarcodeType.code39:
        barcodeType = HMA300LBarcodeType.code39;
        break;
      case PrintBarcodeType.code93:
        barcodeType = HMA300LBarcodeType.code93;
        break;
      case PrintBarcodeType.code128:
        barcodeType = HMA300LBarcodeType.code128;
        break;
      case PrintBarcodeType.codabar:
        barcodeType = HMA300LBarcodeType.codabar;
        break;
      default:
        throw UnsupportedError(
          'Barcode format ${barcode.type} is unsupported on the HM-A300L.',
        );
    }

    final barcodeParams = HMA300LBarcodeParams(
      orientation: getHMA300LPrintOrientation(barcode.rotation),
      type: barcodeType,
      ratio: HMA300LBarcodeRatio.ratio0,
      barWidthUnit: barcode.barLineWidth.toInt(),
      height: barcode.height.toInt(),
      xPosition: barcode.xPosition.toInt(),
      yPosition: barcode.yPosition.toInt(),
      data: barcode.data,
    );

    return addBarcodeParams(barcodeParams);
  }

  @override
  Future<bool> addQRCode(PrintQRCode qrCode) {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    final qrCodeParams = HMA300LQRCodeParams(
      orientation: getHMA300LPrintOrientation(qrCode.rotation),
      xPosition: qrCode.xPosition.toInt(),
      yPosition: qrCode.yPosition.toInt(),
      model: HMA300LQRCodeModel.normal,
      unitSize: qrCode.unitSize.toInt(),
      data: qrCode.data,
    );

    return addQRCodeParams(qrCodeParams);
  }

  @override
  Future<bool> addLine(PrintRect rect) {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    return addLineParam(rect.rect, rect.strokeWidth.toInt());
  }

  @override
  Future<bool> addRectangle(PrintRect rect) {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    return addRectangleParam(rect.rect, rect.strokeWidth.toInt());
  }

  @override
  Future<bool> addImage(PrintImage printImage) {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    final HMA300LPrintImageMode printImageMode;
    switch (printImage.monochromizationAlgorithm) {
      case MonochromizationAlgorithm.binary:
        printImageMode = HMA300LPrintImageMode.binary;
        break;
      case MonochromizationAlgorithm.dithering:
        printImageMode = HMA300LPrintImageMode.dithering;
        break;
      case MonochromizationAlgorithm.cluster:
        printImageMode = HMA300LPrintImageMode.cluster;
        break;
      default:
        throw UnsupportedError(
          'Monochromization Algorithm ${printImage.monochromizationAlgorithm} is unsupported on the HM-A300L.',
        );
    }

    final imageParams = HMA300LPrintImageParams(
      imagePath: printImage.path,
      xPosition: printImage.xPosition.toInt(),
      yPosition: printImage.yPosition.toInt(),
      mode: printImageMode,
    );

    return addImageParams(imageParams);
  }
}