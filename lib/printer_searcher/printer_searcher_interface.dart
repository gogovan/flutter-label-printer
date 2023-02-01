import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';

/// Interface all printer searchers should implement.
abstract class PrinterSearcherInterface {
  /// Initiate a search for nearby printers.
  /// Returns a list of `PrinterSearchResult`, allowing client to select one to be passed to the `connect` method on a compatible PrinterInterface class.
  ///
  /// Implementors should search for devices (using USB, WiFi, BLE etc) and return a list of found compatible devices.
  /// These devices should be indicated by an ID stored in a `PrinterSearchResult` instance.
  /// Such IDs should be able to be used to connect a specified printer.
  Stream<List<PrinterSearchResult>> search();

  /// Stop searching for nearby printers.
  ///
  /// If the searching method needs to be disconnected or otherwise closed, implement this method.
  /// Return true if closing is successful.
  Future<bool> stopSearch() => Future.value(true);

  /// Connect to a specified printer identified by a PrinterSearchResult returned from the `search` function.
  ///
  /// Return true if operation successful.
  Future<bool> connect(PrinterSearchResult id);

  /// Disconnect to currently connected printer.
  ///
  /// Return true if operation successful.
  Future<bool> disconnect();
}
