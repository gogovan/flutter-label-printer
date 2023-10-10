import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_label_printer/printer/hm_a300l_printer.dart';
import 'package:flutter_label_printer/printer_search_result/bluetooth_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hm_a300l_printer_test.mocks.dart';

@GenerateNiceMocks([MockSpec<FlutterLabelPrinterPlatform>()])
void main() {
  final device = BluetoothResult('12:34:56:AB:CD:EF');
  final printerPlatform = MockFlutterLabelPrinterPlatform();

  test('connect success', () async {
    final printer = HMA300LPrinter(device)..platformInstance = printerPlatform;

    when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
        .thenAnswer((realInvocation) async => true);

    expect(await printer.connect(), true);

    verify(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF')).called(1);
  });
}
