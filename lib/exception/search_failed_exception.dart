import 'package:flutter_label_printer/exception/label_printer_exception.dart';

/// SearchFailedException: When the plugin is unable to start searching for devices.
/// It could be user denied Bluetooth connection or error occurred while enabling Bluetooth.
class SearchFailedException extends LabelPrinterException {
  const SearchFailedException(super.message, super.cause);
}
