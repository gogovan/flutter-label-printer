import 'package:flutter/foundation.dart';

/// Search result indicating a single printer device.
/// This is a marker interface. It should contain the identifier needed in order to connect the device, such as a Bluetooth address or an address and port for Wifi connection.
/// Search result should be immutable.
@immutable
abstract class PrinterSearchResult {}
