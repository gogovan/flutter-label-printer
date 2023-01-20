package hk.gogovan.flutter_label_printer.util.exception

import hk.gogovan.flutter_label_printer.PluginException

class BluetoothScanException(code: Int): PluginException(1004, "Bluetooth Scan exception: code $code")