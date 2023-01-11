import 'package:flutter/services.dart';
import 'package:flutter_label_printer/flutter_label_printer_method_channel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final MethodChannelFlutterLabelPrinter platform = MethodChannelFlutterLabelPrinter();
  const MethodChannel channel = MethodChannel('flutter_label_printer');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async => '42');
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
