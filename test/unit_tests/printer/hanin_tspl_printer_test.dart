// ignore_for_file: no-magic-number

import 'package:flutter/services.dart';
import 'package:flutter_label_printer/exception/connection_exception.dart';
import 'package:flutter_label_printer/exception/invalid_connection_state_exception.dart';
import 'package:flutter_label_printer/exception/no_current_activity_exception.dart';
import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_label_printer/printer/hanin_tspl_classes.dart';
import 'package:flutter_label_printer/printer/hanin_tspl_printer.dart';
import 'package:flutter_label_printer/printer_search_result/bluetooth_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hanin_tspl_printer_test.mocks.dart';

class TestCase {
  TestCase(
      this.name,
      this.functionToTest,
      this.platformFunction,
      );

  final String name;
  final Function functionToTest;
  final Function platformFunction;
}

@GenerateNiceMocks([
  // ignore: deprecated_member_use, no alternative found for now
  MockSpec<FlutterLabelPrinterPlatform>(mixingIn: [MockPlatformInterfaceMixin]),
])
void main() {
  final device = BluetoothResult('12:34:56:AB:CD:EF', 'PRT-H29-29501');
  final printerPlatform = MockFlutterLabelPrinterPlatform();

  FlutterLabelPrinterPlatform.instance = printerPlatform;

  const HaninTSPLTextParams textParams =
  HaninTSPLTextParams(xPosition: 40, yPosition: 20, text: 'Hello World!');
  const HaninTSPLBarcodeParams barcodeParams = HaninTSPLBarcodeParams(
    barcodeType: HaninTSPLBarcodeType.code39,
    height: 40,
    xPosition: 30,
    yPosition: 20,
    data: 'https://example.com',
  );
  const HaninTSPLQRCodeParams qrcodeParams = HaninTSPLQRCodeParams(
    xPosition: 30,
    yPosition: 10,
    unitSize: 6,
    data: 'https://example.com',
  );
  const HaninTSPLImageParams imageParams = HaninTSPLImageParams(
    imagePath: '/sdcard/1.jpg',
    xPosition: 40,
    yPosition: 20,
  );

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

  test('connect failure', () async {
    final printer = HaninTSPLPrinter(device);

    when(printerPlatform.connectHaninTSPL('12:34:56:AB:CD:EF'))
        .thenThrow(PlatformException(code: '1006', details: ''));

    expect(
          () async => printer.connect(),
      throwsA(isA<ConnectionException>()),
    );
    expect(printer.isConnected(), false);
  });

  test('disconnect - not connected', () async {
    final printer = HaninTSPLPrinter(device);
    expect(await printer.disconnect(), true);
  });

  test('disconnect failure', () async {
    final printer = HaninTSPLPrinter(device);

    when(printerPlatform.connectHaninTSPL('12:34:56:AB:CD:EF'))
        .thenAnswer((realInvocation) async => true);
    when(printerPlatform.disconnectHaninTSPL())
        .thenThrow(PlatformException(code: '1003', details: ''));

    expect(await printer.connect(), true);
    expect(
          () async => printer.disconnect(),
      throwsA(isA<NoCurrentActivityException>()),
    );
    expect(printer.isConnected(), true);
  });

  test('setLogLevel', () async {
    final printer = HaninTSPLPrinter(device);

    when(printerPlatform.connectHaninTSPL('12:34:56:AB:CD:EF'))
        .thenAnswer((realInvocation) async => true);
    when(printerPlatform.setLogLevel(3))
        .thenAnswer((realInvocation) async => true);

    expect(await printer.connect(), true);
    await printer.setLogLevel(3);
    verify(printerPlatform.setLogLevel(3)).called(1);
  });

  test('getStatus', () async {
    final printer = HaninTSPLPrinter(device);

    when(printerPlatform.connectHaninTSPL('12:34:56:AB:CD:EF'))
        .thenAnswer((realInvocation) async => true);
    when(printerPlatform.getStatusHaninTSPL())
        .thenAnswer((realInvocation) async => 6);

    expect(await printer.connect(), true);
    expect(await printer.getStatus(), const HaninTSPLPrinterStatus(6));
    verify(printerPlatform.getStatusHaninTSPL()).called(1);
  });

  group('printer platform tests', () {
    final testData = [
      TestCase(
        'printTestPage',
            (printer) => printer.printTestPage(),
        printerPlatform.printTestPageHaninTSPL,
      ),
      TestCase(
        'print',
            (printer) => printer.print(),
        printerPlatform.printHaninTSPL,
      ),
      TestCase(
        'addTextParams',
            (printer) => printer.addTextParams(textParams),
            () => printerPlatform.addTextHaninTSPL(textParams),
      ),
      TestCase(
        'prefeed',
            (printer) => printer.addSpace(24),
            () => printerPlatform.addSpaceHaninTSPL(24),
      ),
      TestCase(
        'addBarcodeParams',
            (printer) => printer.addBarcodeParams(barcodeParams),
            () => printerPlatform.addBarcodeHaninTSPL(barcodeParams),
      ),
      TestCase(
        'addQRCodeParams',
            (printer) => printer.addQRCodeParams(qrcodeParams),
            () => printerPlatform.addQRCodeHaninTSPL(qrcodeParams),
      ),
      TestCase(
        'addRectangleParam',
            (printer) =>
            printer.addRectangleParam(const Rect.fromLTRB(10, 20, 30, 40), 2),
            () => printerPlatform.addRectangleHaninTSPL(
          const Rect.fromLTRB(10, 20, 30, 40), 2,),
      ),
      TestCase(
        'addLineParam',
            (printer) =>
            printer.addLineParam(const Rect.fromLTRB(10, 20, 30, 40),),
            () => printerPlatform.addLineHaninTSPL(
          const Rect.fromLTRB(10, 20, 30, 40),),
      ),
      TestCase(
        'addImageParams',
            (printer) => printer.addImageParams(imageParams),
            () => printerPlatform.addImageHaninTSPL(imageParams),
      ),
    ];

    for (final data in testData) {
      test('invalid connection for ${data.name}', () {
        final printer = HaninTSPLPrinter(device);
        expect(
              () async => data.functionToTest(printer),
          throwsA(isA<InvalidConnectionStateException>()),
        );
      });

      test('platform failure ${data.name}', () async {
        final printer = HaninTSPLPrinter(device);
        when(printerPlatform.connectHaninTSPL('12:34:56:AB:CD:EF'))
            .thenAnswer((realInvocation) async => true);

        when(data.platformFunction()).thenThrow(
          PlatformException(code: '1006', details: 'Disconnected'),
        );

        expect(await printer.connect(), true);
        expect(
              () async => data.functionToTest(printer),
          throwsA(isA<ConnectionException>()),
        );

        verify(data.platformFunction()).called(1);
      });

      test('success ${data.name}', () async {
        final printer = HaninTSPLPrinter(device);

        when(printerPlatform.connectHaninTSPL('12:34:56:AB:CD:EF'))
            .thenAnswer((realInvocation) async => true);
        when(data.platformFunction()).thenAnswer((realInvocation)async => true);

        expect(await printer.connect(), true);
        expect(await data.functionToTest(printer), true);
        verify(data.platformFunction()).called(1);
      });
    }
  });
}
