import 'package:flutter_label_printer/exception/label_printer_exception.dart';

/// DeviceNotConnectedException: Printer is not connected and hence cannot perform the operation.
class DeviceNotConnectedException extends LabelPrinterException {
  const DeviceNotConnectedException(super.message, super.cause);
}
