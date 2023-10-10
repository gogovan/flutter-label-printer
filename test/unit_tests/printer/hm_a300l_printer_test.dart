// ignore_for_file: no-magic-number

import 'package:flutter/services.dart';
import 'package:flutter_label_printer/exception/connection_exception.dart';
import 'package:flutter_label_printer/exception/invalid_connection_state_exception.dart';
import 'package:flutter_label_printer/exception/no_current_activity_exception.dart';
import 'package:flutter_label_printer/flutter_label_printer_platform_interface.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';
import 'package:flutter_label_printer/printer/hm_a300l_printer.dart';
import 'package:flutter_label_printer/printer_search_result/bluetooth_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hm_a300l_printer_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FlutterLabelPrinterPlatform>(mixingIn: [MockPlatformInterfaceMixin]),
])
void main() {
  final device = BluetoothResult('12:34:56:AB:CD:EF');
  final printerPlatform = MockFlutterLabelPrinterPlatform();

  const HMA300LPrintAreaSizeParams printAreaSizeParams =
      HMA300LPrintAreaSizeParams(
    height: 240,
  );
  const HMA300LTextParams textParams =
      HMA300LTextParams(xPosition: 40, yPosition: 20, text: 'Hello World!');
  const HMA300LBarcodeParams barcodeParams = HMA300LBarcodeParams(
    type: HMA300LBarcodeType.code39,
    ratio: HMA300LBarcodeRatio.ratio23,
    barWidthUnit: 3,
    height: 40,
    xPosition: 30,
    yPosition: 20,
    data: 'https://example.com',
  );
  const HMA300LQRCodeParams qrcodeParams = HMA300LQRCodeParams(
    orientation: HMA300LPrintOrientation.horizontal,
    xPosition: 30,
    yPosition: 10,
    model: HMA300LQRCodeModel.normal,
    unitSize: 6,
    data: 'https://example.com',
  );
  const HMA300LPrintImageParams imageParams = HMA300LPrintImageParams(
    imagePath: '/sdcard/1.jpg',
    xPosition: 40,
    yPosition: 20,
  );

  test('connect success, disconnect success', () async {
    final printer = HMA300LPrinter(device)..platformInstance = printerPlatform;

    when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
        .thenAnswer((realInvocation) async => true);
    when(printerPlatform.disconnectHMA300L())
        .thenAnswer((realInvocation) async => true);

    expect(await printer.connect(), true);
    expect(printer.isConnected(), true);

    verify(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF')).called(1);

    expect(await printer.disconnect(), true);
    expect(printer.isConnected(), false);

    verify(printerPlatform.disconnectHMA300L()).called(1);
  });

  test('connect failure', () async {
    final printer = HMA300LPrinter(device)..platformInstance = printerPlatform;

    when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
        .thenThrow(PlatformException(code: '1006', details: ''));

    expect(
      () async => printer.connect(),
      throwsA(isA<ConnectionException>()),
    );
    expect(printer.isConnected(), false);
  });

  test('disconnect - not connected', () async {
    final printer = HMA300LPrinter(device)..platformInstance = printerPlatform;
    expect(await printer.disconnect(), true);
  });

  test('disconnect failure', () async {
    final printer = HMA300LPrinter(device)..platformInstance = printerPlatform;

    when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
        .thenAnswer((realInvocation) async => true);
    when(printerPlatform.disconnectHMA300L())
        .thenThrow(PlatformException(code: '1003', details: ''));

    expect(await printer.connect(), true);
    expect(
      () async => printer.disconnect(),
      throwsA(isA<NoCurrentActivityException>()),
    );
    expect(printer.isConnected(), true);
  });

  group('not connected failures', () {
    final printer = HMA300LPrinter(device)..platformInstance = printerPlatform;
    final paramlessFuncs = [
      printer.printTestPage,
      printer.print,
      printer.getStatus,
    ];

    for (final func in paramlessFuncs) {
      test('not connected $func', () {
        expect(
          () async => func(),
          throwsA(isA<InvalidConnectionStateException>()),
        );
      });
    }

    test('not connected setPrintAreaSizeParams', () {
      expect(
        () async => printer.setPrintAreaSizeParams(printAreaSizeParams),
        throwsA(isA<InvalidConnectionStateException>()),
      );
    });

    test('not connected addTextParams', () {
      expect(
        () async => printer.addTextParams(textParams),
        throwsA(isA<InvalidConnectionStateException>()),
      );
    });

    test('not connected setPaperType', () {
      expect(
        () async => printer.setPaperType(HMA300LPaperType.label),
        throwsA(isA<InvalidConnectionStateException>()),
      );
    });

    test('not connected setBold', () {
      expect(
        () async => printer.setBold(5),
        throwsA(isA<InvalidConnectionStateException>()),
      );
    });

    test('not connected setTextSize', () {
      expect(
        () async => printer.setTextSize(3, 4),
        throwsA(isA<InvalidConnectionStateException>()),
      );
    });

    test('not connected prefeed', () {
      expect(
        () async => printer.prefeed(24),
        throwsA(isA<InvalidConnectionStateException>()),
      );
    });

    test('not connected setPageWidth', () {
      expect(
        () async => printer.setPageWidth(8),
        throwsA(isA<InvalidConnectionStateException>()),
      );
    });

    test('not connected setAlign', () {
      expect(
        () async => printer.setAlign(HMA300LPrinterTextAlign.center),
        throwsA(isA<InvalidConnectionStateException>()),
      );
    });

    test('not connected addBarcodeParams', () {
      expect(
        () async => printer.addBarcodeParams(barcodeParams),
        throwsA(isA<InvalidConnectionStateException>()),
      );
    });

    test('not connected addQRCodeParams', () {
      expect(
        () async => printer.addQRCodeParams(qrcodeParams),
        throwsA(isA<InvalidConnectionStateException>()),
      );
    });

    test('not connected addRectangleParam', () {
      expect(
        () async =>
            printer.addRectangleParam(const Rect.fromLTRB(10, 20, 30, 40), 2),
        throwsA(isA<InvalidConnectionStateException>()),
      );
    });

    test('not connected addLineParam', () {
      expect(
        () async =>
            printer.addLineParam(const Rect.fromLTRB(10, 20, 30, 40), 2),
        throwsA(isA<InvalidConnectionStateException>()),
      );
    });

    test('not connected addImageParams', () {
      expect(
        () async => printer.addImageParams(imageParams),
        throwsA(isA<InvalidConnectionStateException>()),
      );
    });
  });
}
