import 'package:flutter_label_printer/templating/command_parameters/print_area_size.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_barcode.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_image.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_qr_code.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_rect.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text.dart';
import 'package:flutter_label_printer/templating/templatable_printer_interface.dart';
import 'package:flutter_label_printer/templating/template.dart';

/// Instantiate a TemplatePrinter to print a template.
/// The printer provided must implement TemplatablePrinterInterface.
/// ```
/// final yml = await rootBundle.loadString('assets/template.yaml'); // Load a yml file in Flutter Assets to a string
/// final template = Template.fromYaml(yml); // Create a Template from a yml string
/// final printer = TemplatePrinter(printer, template); // Create a TemplatePrinter with previously obtained TemplatablePrinterInterface and Template
/// final result = await printer.printTemplate(); // Print the template
/// ```
class TemplatePrinter {
  TemplatePrinter(this.printer, this.template);

  TemplatablePrinterInterface printer;
  Template template;

  /// Initiate printing.
  /// Return true on success, false if any command failed.
  /// If any commands failed, it will be skipped.
  Future<bool> printTemplate() async {
    var result = true;
    for (final cmd in template.commands) {
      switch (cmd.type) {
        case CommandType.size:
          final cmdResult = await printer.setPrintAreaSize(cmd.params as PrintAreaSize);
          result = result && cmdResult;
          break;
        case CommandType.text:
          final cmdResult = await printer.addText(cmd.params as PrintText);
          result = result && cmdResult;
          break;
        case CommandType.barcode:
          final cmdResult = await printer.addBarcode(cmd.params as PrintBarcode);
          result = result && cmdResult;
          break;
        case CommandType.qrcode:
          final cmdResult = await printer.addQRCode(cmd.params as PrintQRCode);
          result = result && cmdResult;
          break;
        case CommandType.line:
          final cmdResult = await printer.addLine(cmd.params as PrintRect);
          result = result && cmdResult;
          break;
        case CommandType.rectangle:
          final cmdResult = await printer.addRectangle(cmd.params as PrintRect);
          result = result && cmdResult;
          break;
        case CommandType.image:
          final cmdResult = await printer.addImage(cmd.params as PrintImage);
          result = result && cmdResult;
          break;
      }
    }

    return result && (await printer.print());
  }
}
