import 'package:flutter_label_printer/exception/invalid_argument_exception.dart';
import 'package:flutter_label_printer/exception/invalid_connection_state_exception.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';
import 'package:flutter_label_printer/printer/hm_a300l_printer.dart';
import 'package:flutter_label_printer/templating/model/print_area_size.dart';
import 'package:flutter_label_printer/templating/model/print_text.dart';
import 'package:flutter_label_printer/templating/model/print_text_align.dart';
import 'package:flutter_label_printer/templating/model/print_text_style.dart';
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
          style.width?.toInt() ?? 1, style.height?.toInt() ?? 1);
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
}
