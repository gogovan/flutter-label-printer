import 'package:flutter_label_printer/exception/label_printer_exception.dart';

/// MissingSearchPermissionException: When the client does not have permission to search for printers.
/// Typically this is thrown when the user denied the permissions required to search a printer device.
/// For example, BLUETOOTH permission is denied when trying to scan for Bluetooth devices.
class MissingSearchPermissionException extends LabelPrinterException {
  const MissingSearchPermissionException(super.message, super.cause);
}
