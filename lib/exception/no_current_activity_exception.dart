import 'package:flutter_label_printer/exception/label_printer_exception.dart';

/// NoActiveActivityException: When there are no activity being active on the current app.
/// Check that there is an activity in the foreground when calling the method.
class NoCurrentActivityException extends LabelPrinterException {
  const NoCurrentActivityException(super.message, super.cause);
}
