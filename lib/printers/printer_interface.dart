import 'package:flutter/foundation.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';

/// Interface all printers should implement.
abstract class PrinterInterface {
  /// Whether the device has been connected.
  /// Implementors should change this value to indicate whether the device has been connected or not.
  @protected
  bool connected = false;

  /// Whether the device has been connected.
  @nonVirtual
  bool isConnected() => connected;

  /// Connect to the specified printer.
  /// The printer should be one of the printers returned by the `search` method from a compatible PrinterSearcherInterface class.
  ///
  /// Implementors should connect to the specified device, and the device should be ready to use when this method returns normally.
  /// This method should be idempotent - multiple invocation of this method should not result in errors or multiple connections.
  void connect(PrinterSearchResult device);

  /// Disconnect to the currently connected device.
  ///
  /// Implementors should disconnect the current device, and do any cleanup needed.
  /// This method should be idempotent - multiple invocation of this method should not result in errors or multiple disconnections.
  void disconnect();
}
