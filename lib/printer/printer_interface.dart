import 'package:flutter/foundation.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';

/// Interface all printers should implement.
abstract class PrinterInterface {
  /// Whether the device has been connected.
  bool _connected = false;

  /// Whether the device has been connected.
  @nonVirtual
  bool isConnected() => _connected;

  /// Connect to the specified printer.
  /// The printer should be one of the printers returned by the `search` method from a compatible PrinterSearcherInterface class.
  /// Return true if connection successful, false otherwise.
  @nonVirtual
  Future<bool> connect(PrinterSearchResult device) async {
    if (!_connected) {
      final result = await connectImpl(device);
      _connected = true;

      return result;
    } else {
      return false;
    }
  }

  /// Implementors should implement this method to connect to the printer.
  /// Return true if connection successful, false otherwise.
  ///
  /// Implementors should connect to the specified device, and the device should be ready to use when this method returns normally.
  /// This method should be idempotent - multiple invocation of this method should not result in errors or multiple connections.
  Future<bool> connectImpl(PrinterSearchResult device);

  /// Disconnect to the currently connected device.
  /// Return true if disconnection successful, false otherwise.
  @nonVirtual
  Future<bool> disconnect() async {
    if (_connected) {
      final result = await disconnectImpl();
      _connected = false;

      return result;
    } else {
      return false;
    }
  }

  /// Implementors should implement this method to disconnect the printer,.
  /// Return true if connection successful, false otherwise.
  ///
  /// Implementors should disconnect the current device, and do any cleanup needed.
  /// This method should be idempotent - multiple invocation of this method should not result in errors or multiple disconnections.
  Future<bool> disconnectImpl();
}
