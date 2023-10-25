import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_label_printer/printer/hanin_tspl_printer.dart';
import 'package:flutter_label_printer/printer_search_result/bluetooth_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hanin_tspl_printer_test.mocks.dart';

@GenerateNiceMocks([
  // ignore: deprecated_member_use, no alternative found for now
  MockSpec<FlutterLabelPrinterPlatform>(mixingIn: [MockPlatformInterfaceMixin]),
])
void main() {
  final device = BluetoothResult('12:34:56:AB:CD:EF', 'PRT-H29-29501');
  final printerPlatform = MockFlutterLabelPrinterPlatform();

  FlutterLabelPrinterPlatform.instance = printerPlatform;

  test('connect success, disconnect success', () async {
    final printer = HaninTSPLPrinter(device);

    when(printerPlatform.connectHaninTSPL('12:34:56:AB:CD:EF'))
        .thenAnswer((realInvocation) async => true);
    when(printerPlatform.disconnectHaninTSPL())
        .thenAnswer((realInvocation) async => true);

    expect(await printer.connect(), true);
    expect(printer.isConnected(), true);

    verify(printerPlatform.connectHaninTSPL('12:34:56:AB:CD:EF')).called(1);

    expect(await printer.disconnect(), true);
    expect(printer.isConnected(), false);

    verify(printerPlatform.disconnectHaninTSPL()).called(1);
  });
}
