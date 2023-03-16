import 'package:flutter_label_printer/exception/invalid_argument_exception.dart';
import 'package:flutter_label_printer/exception/invalid_connection_state_exception.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';
import 'package:flutter_label_printer/printer/hm_a300l_printer.dart';
import 'package:flutter_label_printer/templating/model/print_barcode.dart';
import 'package:flutter_label_printer/templating/model/print_barcode_type.dart';
import 'package:flutter_label_printer/templating/model/print_area_size.dart';
import 'package:flutter_label_printer/templating/model/print_image.dart';
import 'package:flutter_label_printer/templating/model/print_text.dart';
import 'package:flutter_label_printer/templating/model/print_text_align.dart';
import 'package:flutter_label_printer/templating/model/print_text_style.dart';
import 'package:flutter_label_printer/templating/model/print_qr_code.dart';
import 'package:flutter_label_printer/templating/printer_template_interface.dart';

/// Interface for Templating for the Hanyin (HPRT) HM-A300L Printer.
class HMA300LPrinterInterface extends HMA300LPrinter
    implements PrinterTemplateInterface {
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
    HMA300LLabelResolution? hRes, vRes;
    for (final HMA300LLabelResolution res in HMA300LLabelResolution.values) {
      if (printAreaSize.horizontalResolution == res.res) {
        hRes = res;
      }
    }
    for (final HMA300LLabelResolution res in HMA300LLabelResolution.values) {
      if (printAreaSize.verticalResolution == res.res) {
        vRes = res;
      }
    }

    final HMA300LPrintAreaSizeParams params = HMA300LPrintAreaSizeParams(
      offset: printAreaSize.originX?.toInt() ?? 0,
      horizontalRes: hRes ?? HMA300LLabelResolution.res200,
      verticalRes: vRes ?? HMA300LLabelResolution.res200,
      height: height.toInt(),
    );

    return setPrintAreaSizeParams(params);
  }

  @override
  Future<bool> addText(PrintText printText, PrintTextStyle style) async {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    final style = printText.style;

    final bool sizeResult;
    final bool boldResult;
    final bool alignResult;
    if (style != null) {
      sizeResult = await setTextSize(
        style.width?.toInt() ?? 1,
        style.height?.toInt() ?? 1,
      );
      boldResult = await setBold(style.bold?.toInt() ?? 1);

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
    );
    final textResult = await addTextParams(textParams);

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
      orientation: HMA300LPrintOrientation.horizontal,
      xPosition: qrCode.xPosition.toInt(),
      yPosition: qrCode.yPosition.toInt(),
      model: HMA300LQRCodeModel.normal,
      unitSize: qrCode.unitSize.toInt(),
      data: qrCode.data,
    );

    return addQRCodeParams(qrCodeParams);
  }

  @override
  Future<bool> addImage(PrintImage printImage) {
    if (!isConnected()) {
      throw InvalidConnectionStateException(
        'Device not connected.',
        StackTrace.current.toString(),
      );
    }

    final imageParams = HMA300LPrintImageParams(
      imagePath: printImage.path,
      xPosition: printImage.xPosition.toInt(),
      yPosition: printImage.yPosition.toInt(),
    );

    return addImageParams(imageParams);
  }
}
