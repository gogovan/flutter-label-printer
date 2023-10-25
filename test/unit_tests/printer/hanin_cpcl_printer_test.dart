// ignore_for_file: no-magic-number

import 'package:flutter/services.dart';
import 'package:flutter_label_printer/exception/connection_exception.dart';
import 'package:flutter_label_printer/exception/invalid_connection_state_exception.dart';
import 'package:flutter_label_printer/exception/no_current_activity_exception.dart';
import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_label_printer/printer/hanin_cpcl_classes.dart';
import 'package:flutter_label_printer/printer/hanin_cpcl_printer.dart';
import 'package:flutter_label_printer/printer_search_result/bluetooth_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hanin_cpcl_printer_test.mocks.dart';

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

  const HaninCPCLPrintAreaSizeParams printAreaSizeParams =
      HaninCPCLPrintAreaSizeParams(
    height: 240,
  );
  const HaninCPCLTextParams textParams =
      HaninCPCLTextParams(xPosition: 40, yPosition: 20, text: 'Hello World!');
  const HaninCPCLBarcodeParams barcodeParams = HaninCPCLBarcodeParams(
    type: HaninCPCLBarcodeType.code39,
    ratio: HaninCPCLBarcodeRatio.ratio23,
    barWidthUnit: 3,
    height: 40,
    xPosition: 30,
    yPosition: 20,
    data: 'https://example.com',
  );
  const HaninCPCLQRCodeParams qrcodeParams = HaninCPCLQRCodeParams(
    orientation: HaninCPCLOrientation.horizontal,
    xPosition: 30,
    yPosition: 10,
    model: HaninCPCLQRCodeModel.normal,
    unitSize: 6,
    data: 'https://example.com',
  );
  const HaninCPCLImageParams imageParams = HaninCPCLImageParams(
    imagePath: '/sdcard/1.jpg',
    xPosition: 40,
    yPosition: 20,
  );

  test('connect success, disconnect success', () async {
    final printer = HaninCPCLPrinter(device);

    when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
        .thenAnswer((realInvocation) async => true);
    when(printerPlatform.disconnectHaninCPCL())
        .thenAnswer((realInvocation) async => true);

    expect(await printer.connect(), true);
    expect(printer.isConnected(), true);

    verify(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF')).called(1);

    expect(await printer.disconnect(), true);
    expect(printer.isConnected(), false);

    verify(printerPlatform.disconnectHaninCPCL()).called(1);
  });

  test('connect failure', () async {
    final printer = HaninCPCLPrinter(device);

    when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
        .thenThrow(PlatformException(code: '1006', details: ''));

    expect(
      () async => printer.connect(),
      throwsA(isA<ConnectionException>()),
    );
    expect(printer.isConnected(), false);
  });

  test('disconnect - not connected', () async {
    final printer = HaninCPCLPrinter(device);
    expect(await printer.disconnect(), true);
  });

  test('disconnect failure', () async {
    final printer = HaninCPCLPrinter(device);

    when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
        .thenAnswer((realInvocation) async => true);
    when(printerPlatform.disconnectHaninCPCL())
        .thenThrow(PlatformException(code: '1003', details: ''));

    expect(await printer.connect(), true);
    expect(
      () async => printer.disconnect(),
      throwsA(isA<NoCurrentActivityException>()),
    );
    expect(printer.isConnected(), true);
  });

  test('setLogLevel', () async {
    final printer = HaninCPCLPrinter(device);

    when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
        .thenAnswer((realInvocation) async => true);
    when(printerPlatform.setLogLevel(3))
        .thenAnswer((realInvocation) async => true);

    expect(await printer.connect(), true);
    await printer.setLogLevel(3);
    verify(printerPlatform.setLogLevel(3)).called(1);
  });

  test('getStatus', () async {
    final printer = HaninCPCLPrinter(device);

    when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
        .thenAnswer((realInvocation) async => true);
    when(printerPlatform.getStatusHaninCPCL())
        .thenAnswer((realInvocation) async => 6);

    expect(await printer.connect(), true);
    expect(await printer.getStatus(), const HaninCPCLPrinterStatus(6));
    verify(printerPlatform.getStatusHaninCPCL()).called(1);
  });

  group('printer platform failures', () {
    final testData = [
      TestCase(
        'printTestPage',
        (printer) => printer.printTestPage(),
        printerPlatform.printTestPageHaninCPCL,
      ),
      TestCase(
        'print',
        (printer) => printer.print(),
        printerPlatform.printHaninCPCL,
      ),
      TestCase(
        'setPrintAreaSizeParams',
        (printer) => printer.setPrintAreaSizeParams(printAreaSizeParams),
        () => printerPlatform.setPrintAreaHaninCPCL(printAreaSizeParams),
      ),
      TestCase(
        'addTextParams',
        (printer) => printer.addTextParams(textParams),
        () => printerPlatform.addTextHaninCPCL(textParams),
      ),
      TestCase(
        'setPaperType',
        (printer) => printer.setPaperType(HaninCPCLPaperType.label),
        () => printerPlatform.setPaperTypeHaninCPCL(HaninCPCLPaperType.label),
      ),
      TestCase(
        'setBold',
        (printer) => printer.setBold(5),
        () => printerPlatform.setBoldHaninCPCL(5),
      ),
      TestCase(
        'setTextSize',
        (printer) => printer.setTextSize(3, 4),
        () => printerPlatform.setHaninCPCLTextSize(3, 4),
      ),
      TestCase(
        'prefeed',
        (printer) => printer.prefeed(24),
        () => printerPlatform.addSpaceHaninCPCL(24),
      ),
      TestCase(
        'setAlign',
        (printer) => printer.setAlign(HaninCPCLTextAlign.center),
        () => printerPlatform.setAlignHaninCPCL(HaninCPCLTextAlign.center),
      ),
      TestCase(
        'addBarcodeParams',
        (printer) => printer.addBarcodeParams(barcodeParams),
        () => printerPlatform.addBarcodeHaninCPCL(barcodeParams),
      ),
      TestCase(
        'addQRCodeParams',
        (printer) => printer.addQRCodeParams(qrcodeParams),
        () => printerPlatform.addQRCodeHaninCPCL(qrcodeParams),
      ),
      TestCase(
        'addRectangleParam',
        (printer) =>
            printer.addRectangleParam(const Rect.fromLTRB(10, 20, 30, 40), 2),
        () => printerPlatform.addRectangleHaninCPCL(
            const Rect.fromLTRB(10, 20, 30, 40), 2,),
      ),
      TestCase(
        'addLineParam',
        (printer) =>
            printer.addLineParam(const Rect.fromLTRB(10, 20, 30, 40), 2),
        () => printerPlatform.addLineHaninCPCL(
            const Rect.fromLTRB(10, 20, 30, 40), 2,),
      ),
      TestCase(
        'addImageParams',
        (printer) => printer.addImageParams(imageParams),
        () => printerPlatform.addImageHaninCPCL(imageParams),
      ),
    ];

    for (final data in testData) {
      test('invalid connection for ${data.name}', () {
        final printer = HaninCPCLPrinter(device);
        expect(
          () async => data.functionToTest(printer),
          throwsA(isA<InvalidConnectionStateException>()),
        );
      });

      test('platform failure ${data.name}', () async {
        final printer = HaninCPCLPrinter(device);
        when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
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
        final printer = HaninCPCLPrinter(device);

        when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
            .thenAnswer((realInvocation) async => true);
        when(data.platformFunction()).thenAnswer((realInvocation)async => true);

        expect(await printer.connect(), true);
        expect(await data.functionToTest(printer), true);
        verify(data.platformFunction()).called(1);
      });
    }
  });
}
