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

  test('setLogLevel', () async {
    final printer = HMA300LPrinter(device)..platformInstance = printerPlatform;

    when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
        .thenAnswer((realInvocation) async => true);
    when(printerPlatform.setLogLevel(3))
        .thenAnswer((realInvocation) async => true);

    expect(await printer.connect(), true);
    await printer.setLogLevel(3);
    verify(printerPlatform.setLogLevel(3)).called(1);
  });

  group('successes', () {
    test('printTestPage', () async {
      final printer = HMA300LPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.printTestPageHMA300L())
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.printTestPage(), true);
      verify(printerPlatform.printTestPageHMA300L()).called(1);
    });

    test('setPrintAreaSizeParams', () async {
      final printer = HMA300LPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.setPrintAreaSizeHMA300L(printAreaSizeParams))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.setPrintAreaSizeParams(printAreaSizeParams), true);
      verify(printerPlatform.setPrintAreaSizeHMA300L(printAreaSizeParams))
          .called(1);
    });

    test('addTextParams', () async {
      final printer = HMA300LPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.addTextHMA300L(textParams))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.addTextParams(textParams), true);
      verify(printerPlatform.addTextHMA300L(textParams)).called(1);
    });

    test('print', () async {
      final printer = HMA300LPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.printHMA300L())
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.print(), true);
      verify(printerPlatform.printHMA300L()).called(1);
    });

    test('setPaperType', () async {
      final printer = HMA300LPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.setPaperTypeHMA300L(HMA300LPaperType.label))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.setPaperType(HMA300LPaperType.label), true);
      verify(printerPlatform.setPaperTypeHMA300L(HMA300LPaperType.label))
          .called(1);
    });

    test('setBold', () async {
      final printer = HMA300LPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.setBoldHMA300L(2))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.setBold(2), true);
      verify(printerPlatform.setBoldHMA300L(2)).called(1);
    });

    test('setTextSize', () async {
      final printer = HMA300LPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.setTextSizeHMA300L(2, 4))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.setTextSize(2, 4), true);
      verify(printerPlatform.setTextSizeHMA300L(2, 4)).called(1);
    });

    test('getStatus', () async {
      final printer = HMA300LPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.getStatusHMA300L())
          .thenAnswer((realInvocation) async => 6);

      expect(await printer.connect(), true);
      expect(await printer.getStatus(), const HMA300LPrinterStatus(6));
      verify(printerPlatform.getStatusHMA300L()).called(1);
    });

    test('prefeed', () async {
      final printer = HMA300LPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.prefeedHMA300L(16))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.prefeed(16), true);
      verify(printerPlatform.prefeedHMA300L(16)).called(1);
    });

    test('setPageWidth', () async {
      final printer = HMA300LPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.setPageWidthHMA300L(80))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.setPageWidth(80), true);
      verify(printerPlatform.setPageWidthHMA300L(80)).called(1);
    });

    test('setAlign', () async {
      final printer = HMA300LPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.setAlignHMA300L(1))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.setAlign(HMA300LPrinterTextAlign.center), true);
      verify(printerPlatform.setAlignHMA300L(1)).called(1);
    });

    test('addBarcodeParams', () async {
      final printer = HMA300LPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.addBarcode(barcodeParams))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.addBarcodeParams(barcodeParams), true);
      verify(printerPlatform.addBarcode(barcodeParams)).called(1);
    });

    test('addQRCodeParams', () async {
      final printer = HMA300LPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.addQRCode(qrcodeParams))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.addQRCodeParams(qrcodeParams), true);
      verify(printerPlatform.addQRCode(qrcodeParams)).called(1);
    });

    test('addRectangleParam', () async {
      final printer = HMA300LPrinter(device)
        ..platformInstance = printerPlatform;
      const rect = Rect.fromLTRB(10, 20, 30, 40);

      when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.addRectangle(rect, 3))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.addRectangleParam(rect, 3), true);
      verify(printerPlatform.addRectangle(rect, 3)).called(1);
    });

    test('addLineParam', () async {
      final printer = HMA300LPrinter(device)
        ..platformInstance = printerPlatform;
      const rect = Rect.fromLTRB(10, 20, 30, 40);

      when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.addLine(rect, 3))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.addLineParam(rect, 3), true);
      verify(printerPlatform.addLine(rect, 3)).called(1);
    });

    test('addImageParams', () async {
      final printer = HMA300LPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHMA300L('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.addImage(imageParams))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.addImageParams(imageParams), true);
      verify(printerPlatform.addImage(imageParams)).called(1);
    });
  });

  group('not connected failures', () {
    final printer = HMA300LPrinter(device)..platformInstance = printerPlatform;
    final funcs = {
      printer.printTestPage: [],
      printer.print: [],
      printer.getStatus: [],
      printer.setPrintAreaSizeParams: [printAreaSizeParams],
      printer.addTextParams: [textParams],
      printer.setPaperType: [HMA300LPaperType.label],
      printer.setBold: [5],
      printer.setTextSize: [3, 4],
      printer.prefeed: [24],
      printer.setPageWidth: [8],
      printer.setAlign: [HMA300LPrinterTextAlign.center],
      printer.addBarcodeParams: [barcodeParams],
      printer.addQRCodeParams: [qrcodeParams],
      printer.addRectangleParam: [const Rect.fromLTRB(10, 20, 30, 40), 2],
      printer.addLineParam: [const Rect.fromLTRB(10, 20, 30, 40), 2],
      printer.addImageParams: [imageParams],
    };

    for (final func in funcs.entries) {
      if (func.value.isEmpty) {
        test('not connected ${func.key}', () {
          expect(
                () async => func.key(),
            throwsA(isA<InvalidConnectionStateException>()),
          );
        });
      } else if (func.value.length == 1) {
        test('not connected ${func.key}', () {
          expect(
                () async => func.key(func.value.first),
            throwsA(isA<InvalidConnectionStateException>()),
          );
        });
      } else if (func.value.length == 2) {
        test('not connected ${func.key}', () {
          expect(
                () async => func.key(func.value.first, func.value[1]),
            throwsA(isA<InvalidConnectionStateException>()),
          );
        });
      }
    }
  });

  group('printer platform failures', () {

  });
}
