import 'package:flutter_label_printer/exception/label_printer_exception.dart';

/// UnknownLabelPrinterException: When an unknown error occurs.
/// This should not be thrown in normal circumstances. Report an issue if you received this exception.
class UnknownLabelPrinterException extends LabelPrinterException {
  const UnknownLabelPrinterException(super.message, super.cause);
}
