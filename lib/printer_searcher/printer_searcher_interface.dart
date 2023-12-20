import 'package:flutter_label_printer/printer_search_result/printer_search_result.dart';

/// Interface all printer searchers should implement.
abstract class PrinterSearcherInterface {
  /// Initiate a search for nearby printers.
  /// Returns a list of `PrinterSearchResult`, allowing client to select one to be passed to the `connect` method on a compatible PrinterInterface class.
  ///
  /// To stop searching for printers, cancel the stream returned by this method.
  ///
  /// Implementors should search for devices (using USB, WiFi, BLE etc) and return a list of found compatible devices.
  /// The Stream should continuously emit new lists of devices as they are found.
  /// The Stream should be a broadcast stream.
  /// These devices should be indicated by an ID stored in a `PrinterSearchResult` instance.
  /// Such IDs should be able to be used to connect a specified printer.
  Stream<List<PrinterSearchResult>> search();
}
