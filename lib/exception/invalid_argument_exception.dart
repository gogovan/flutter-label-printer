import 'package:flutter_label_printer/exception/label_printer_exception.dart';

/// InvalidArgumentException: Invalid arguments are passed to a print call.
/// E.g. A string is passed to a parameter that only accept integers.
class InvalidArgumentException extends LabelPrinterException {
  const InvalidArgumentException(super.message, super.cause);
}
