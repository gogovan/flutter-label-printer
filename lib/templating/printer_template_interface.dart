import 'package:flutter_label_printer/printer/printer_interface.dart';
import 'package:flutter_label_printer/templating/model/print_area_size.dart';

abstract class PrinterTemplateInterface extends PrinterInterface {
  PrinterTemplateInterface(super.device);

  Future<bool> setPrintAreaSize(PrintAreaSize printAreaSize);
}