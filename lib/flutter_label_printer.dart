import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';

class FlutterLabelPrinter {
  Future<String?> getPlatformVersion() => FlutterLabelPrinterPlatform.instance.getPlatformVersion();
}
