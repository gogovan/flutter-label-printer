import 'package:flutter_label_printer/templating/templatable_printer_interface.dart';
import 'package:flutter_label_printer/templating/template.dart';

class TemplatePrinter {
  TemplatePrinter(this.printer, this.template);

  TemplatablePrinterInterface printer;
  Template template;


}
