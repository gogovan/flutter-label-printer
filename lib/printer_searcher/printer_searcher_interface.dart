import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';

/// Interface all printer searchers should implement.
abstract class PrinterSearcherInterface {
  /// Initiate a search for nearby printers.
  /// Returns a list of `PrinterSearchResult`, allowing client to select one to be passed to the `connect` method on a compatible PrinterInterface class.
  ///
  /// Implementors should search for devices (using USB, WiFi, BLE etc) and return a list of found compatible devices.
  /// These devices should be indicated by an ID stored in a `PrinterSearchResult` instance.
  Future<List<PrinterSearchResult>> search();
}
