import 'package:flutter/foundation.dart';
import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';

/// Interface all printers should implement.
abstract class PrinterInterface {
  PrinterInterface(this.device);

  /// PrinterSearchResult indicating the device this instance is representing.
  @protected
  PrinterSearchResult device;

  bool _connected = false;

  /// Whether the device has been connected.
  @nonVirtual
  bool isConnected() => _connected;

  /// Connect to the specified printer.
  /// The printer should be one of the printers returned by the `search` method from a compatible PrinterSearcherInterface class.
  /// Return true if connection successful or already connected, false otherwise.
  @nonVirtual
  Future<bool> connect() async {
    if (!_connected) {
      final result = await connectImpl(device);
      _connected = true;

      return result;
    } else {
      return true;
    }
  }

  /// Implementors should implement this method to connect to the printer.
  /// Return true if connection successful, false otherwise.
  ///
  /// Implementors should connect to the specified device, and the device should be ready to use when this method returns normally.
  /// This method should be idempotent - multiple invocation of this method should not result in errors or multiple connections.
  @protected
  Future<bool> connectImpl(PrinterSearchResult device);

  /// Disconnect to the currently connected device.
  /// Return true if disconnection successful or already disconnected, false otherwise.
  @nonVirtual
  Future<bool> disconnect() async {
    if (_connected) {
      final result = await disconnectImpl();
      _connected = false;

      return result;
    } else {
      return true;
    }
  }

  /// Implementors should implement this method to disconnect the printer.
  /// Return true if connection successful, false otherwise.
  ///
  /// Implementors should disconnect the current device, and do any cleanup needed.
  /// This method should be idempotent - multiple invocation of this method should not result in errors or multiple disconnections.
  @protected
  Future<bool> disconnectImpl();

  /// Signal the printer and print a test page.
  ///
  /// If the printer provides a function to print a test page, that is preferred.
  /// Otherwise, implementors are free to implement any printing routine to achieve testing purposes.
  Future<bool> printTestPage();
}
