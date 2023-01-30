import 'package:flutter_label_printer/exception/label_printer_exception.dart';

/// ConnectionException: Unable to connect to the printer due to unspecified reasons.
class ConnectionException extends LabelPrinterException {
  const ConnectionException(super.message, super.cause);
}
