import 'package:flutter_label_printer/flutter_label_printer.dart';
import 'package:flutter_label_printer/flutter_label_printer_method_channel.dart';
import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterLabelPrinterPlatform
    with MockPlatformInterfaceMixin
    implements FlutterLabelPrinterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterLabelPrinterPlatform initialPlatform = FlutterLabelPrinterPlatform.instance;

  test('$MethodChannelFlutterLabelPrinter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterLabelPrinter>());
  });

  test('getPlatformVersion', () async {
    final FlutterLabelPrinter flutterLabelPrinterPlugin = FlutterLabelPrinter();
    final MockFlutterLabelPrinterPlatform fakePlatform = MockFlutterLabelPrinterPlatform();
    FlutterLabelPrinterPlatform.instance = fakePlatform;

    expect(await flutterLabelPrinterPlugin.getPlatformVersion(), '42');
  });
}
