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

class PrinterPlatformFailureData {
  PrinterPlatformFailureData(
    this.functionToTest,
    this.platformFunction,
    this.args, [
    this._platformArgs,
  ]);

  final Function functionToTest;
  final Function platformFunction;
  final List<dynamic> args;
  final List<dynamic>? _platformArgs;

  List<dynamic> get platformArgs => _platformArgs ?? args;
}

@GenerateNiceMocks([
  // ignore: deprecated_member_use, no alternative found for now
  MockSpec<FlutterLabelPrinterPlatform>(mixingIn: [MockPlatformInterfaceMixin]),
])
void main() {
  final device = BluetoothResult('12:34:56:AB:CD:EF', 'PRT-H29-29501');
  final printerPlatform = MockFlutterLabelPrinterPlatform();

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
  const HaninCPCLPrintImageParams imageParams = HaninCPCLPrintImageParams(
    imagePath: '/sdcard/1.jpg',
    xPosition: 40,
    yPosition: 20,
  );

  test('connect success, disconnect success', () async {
    final printer = HaninCPCLPrinter(device)..platformInstance = printerPlatform;

    when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
        .thenAnswer((realInvocation) async => true);
    when(printerPlatform.disconnectHaninTSPL())
        .thenAnswer((realInvocation) async => true);

    expect(await printer.connect(), true);
    expect(printer.isConnected(), true);

    verify(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF')).called(1);

    expect(await printer.disconnect(), true);
    expect(printer.isConnected(), false);

    verify(printerPlatform.disconnectHaninTSPL()).called(1);
  });

  test('connect failure', () async {
    final printer = HaninCPCLPrinter(device)..platformInstance = printerPlatform;

    when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
        .thenThrow(PlatformException(code: '1006', details: ''));

    expect(
      () async => printer.connect(),
      throwsA(isA<ConnectionException>()),
    );
    expect(printer.isConnected(), false);
  });

  test('disconnect - not connected', () async {
    final printer = HaninCPCLPrinter(device)..platformInstance = printerPlatform;
    expect(await printer.disconnect(), true);
  });

  test('disconnect failure', () async {
    final printer = HaninCPCLPrinter(device)..platformInstance = printerPlatform;

    when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
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
    final printer = HaninCPCLPrinter(device)..platformInstance = printerPlatform;

    when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
        .thenAnswer((realInvocation) async => true);
    when(printerPlatform.setLogLevel(3))
        .thenAnswer((realInvocation) async => true);

    expect(await printer.connect(), true);
    await printer.setLogLevel(3);
    verify(printerPlatform.setLogLevel(3)).called(1);
  });

  group('successes', () {
    test('printTestPage', () async {
      final printer = HaninCPCLPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.printTestPageHaninTSPL())
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.printTestPage(), true);
      verify(printerPlatform.printTestPageHaninTSPL()).called(1);
    });

    test('setPrintAreaSizeParams', () async {
      final printer = HaninCPCLPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.setPrintAreaHaninCPCL(printAreaSizeParams))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.setPrintAreaSizeParams(printAreaSizeParams), true);
      verify(printerPlatform.setPrintAreaHaninCPCL(printAreaSizeParams))
          .called(1);
    });

    test('addTextParams', () async {
      final printer = HaninCPCLPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.addTextHaninCPCL(textParams))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.addTextParams(textParams), true);
      verify(printerPlatform.addTextHaninCPCL(textParams)).called(1);
    });

    test('print', () async {
      final printer = HaninCPCLPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.printHaninCPCL())
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.print(), true);
      verify(printerPlatform.printHaninCPCL()).called(1);
    });

    test('setPaperType', () async {
      final printer = HaninCPCLPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.setPaperTypeHaninCPCL(HaninCPCLPaperType.label))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.setPaperType(HaninCPCLPaperType.label), true);
      verify(printerPlatform.setPaperTypeHaninCPCL(HaninCPCLPaperType.label))
          .called(1);
    });

    test('setBold', () async {
      final printer = HaninCPCLPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.setBoldHaninCPCL(2))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.setBold(2), true);
      verify(printerPlatform.setBoldHaninCPCL(2)).called(1);
    });

    test('setTextSize', () async {
      final printer = HaninCPCLPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.setHaninCPCLTextSize(2, 4))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.setTextSize(2, 4), true);
      verify(printerPlatform.setHaninCPCLTextSize(2, 4)).called(1);
    });

    test('getStatus', () async {
      final printer = HaninCPCLPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.getStatusHaninCPCL())
          .thenAnswer((realInvocation) async => 6);

      expect(await printer.connect(), true);
      expect(await printer.getStatus(), const HaninCPCLPrinterStatus(6));
      verify(printerPlatform.getStatusHaninCPCL()).called(1);
    });

    test('prefeed', () async {
      final printer = HaninCPCLPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.addSpaceHaninCPCL(16))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.prefeed(16), true);
      verify(printerPlatform.addSpaceHaninCPCL(16)).called(1);
    });

    test('setPageWidth', () async {
      final printer = HaninCPCLPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.setPageWidthHaninCPCL(80))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.setPageWidth(80), true);
      verify(printerPlatform.setPageWidthHaninCPCL(80)).called(1);
    });

    test('setAlign', () async {
      final printer = HaninCPCLPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.setAlignHaninCPCL(1))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.setAlign(HMA300LPrinterTextAlign.center), true);
      verify(printerPlatform.setAlignHaninCPCL(1)).called(1);
    });

    test('addBarcodeParams', () async {
      final printer = HaninCPCLPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.addBarcodeHaninCPCL(barcodeParams))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.addBarcodeParams(barcodeParams), true);
      verify(printerPlatform.addBarcodeHaninCPCL(barcodeParams)).called(1);
    });

    test('addQRCodeParams', () async {
      final printer = HaninCPCLPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.addQRCodeHaninCPCL(qrcodeParams))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.addQRCodeParams(qrcodeParams), true);
      verify(printerPlatform.addQRCodeHaninCPCL(qrcodeParams)).called(1);
    });

    test('addRectangleParam', () async {
      final printer = HaninCPCLPrinter(device)
        ..platformInstance = printerPlatform;
      const rect = Rect.fromLTRB(10, 20, 30, 40);

      when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.addRectangleHaninCPCL(rect, 3))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.addRectangleParam(rect, 3), true);
      verify(printerPlatform.addRectangleHaninCPCL(rect, 3)).called(1);
    });

    test('addLineParam', () async {
      final printer = HaninCPCLPrinter(device)
        ..platformInstance = printerPlatform;
      const rect = Rect.fromLTRB(10, 20, 30, 40);

      when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.addLineHaninCPCL(rect, 3))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.addLineParam(rect, 3), true);
      verify(printerPlatform.addLineHaninCPCL(rect, 3)).called(1);
    });

    test('addImageParams', () async {
      final printer = HaninCPCLPrinter(device)
        ..platformInstance = printerPlatform;

      when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
          .thenAnswer((realInvocation) async => true);
      when(printerPlatform.addImageHaninCPCL(imageParams))
          .thenAnswer((realInvocation) async => true);

      expect(await printer.connect(), true);
      expect(await printer.addImageParams(imageParams), true);
      verify(printerPlatform.addImageHaninCPCL(imageParams)).called(1);
    });
  });

  group('not connected failures', () {
    final printer = HaninCPCLPrinter(device)..platformInstance = printerPlatform;
    final funcs = {
      printer.printTestPage: [],
      printer.print: [],
      printer.getStatus: [],
      printer.setPrintAreaSizeParams: [printAreaSizeParams],
      printer.addTextParams: [textParams],
      printer.setPaperType: [HaninCPCLPaperType.label],
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
      expect(
        () async => Function.apply(func.key, func.value),
        throwsA(isA<InvalidConnectionStateException>()),
      );
    }
  });

  group('printer platform failures', () {
    final printer = HaninCPCLPrinter(device)..platformInstance = printerPlatform;
    final testData = [
      PrinterPlatformFailureData(
        printer.printTestPage,
        printerPlatform.printTestPageHaninTSPL,
        [],
      ),
      PrinterPlatformFailureData(
        printer.print,
        printerPlatform.printHaninCPCL,
        [],
      ),
      PrinterPlatformFailureData(
        printer.getStatus,
        printerPlatform.getStatusHaninCPCL,
        [],
      ),
      PrinterPlatformFailureData(
        printer.setPrintAreaSizeParams,
        printerPlatform.setPrintAreaHaninCPCL,
        [printAreaSizeParams],
      ),
      PrinterPlatformFailureData(
        printer.addTextParams,
        printerPlatform.addTextHaninCPCL,
        [textParams],
      ),
      PrinterPlatformFailureData(
        printer.setPaperType,
        printerPlatform.setPaperTypeHaninCPCL,
        [HaninCPCLPaperType.label],
      ),
      PrinterPlatformFailureData(
        printer.setBold,
        printerPlatform.setBoldHaninCPCL,
        [5],
      ),
      PrinterPlatformFailureData(
        printer.setTextSize,
        printerPlatform.setHaninCPCLTextSize,
        [3, 4],
      ),
      PrinterPlatformFailureData(
        printer.prefeed,
        printerPlatform.addSpaceHaninCPCL,
        [24],
      ),
      PrinterPlatformFailureData(
        printer.setAlign,
        printerPlatform.setAlignHaninCPCL,
        [HMA300LPrinterTextAlign.center],
        [1],
      ),
      PrinterPlatformFailureData(
        printer.addBarcodeParams,
        printerPlatform.addBarcodeHaninCPCL,
        [barcodeParams],
      ),
      PrinterPlatformFailureData(
        printer.addQRCodeParams,
        printerPlatform.addQRCodeHaninCPCL,
        [qrcodeParams],
      ),
      PrinterPlatformFailureData(
        printer.addRectangleParam,
        printerPlatform.addRectangleHaninCPCL,
        [const Rect.fromLTRB(10, 20, 30, 40), 2],
      ),
      PrinterPlatformFailureData(
        printer.addLineParam,
        printerPlatform.addLineHaninCPCL,
        [const Rect.fromLTRB(10, 20, 30, 40), 2],
      ),
      PrinterPlatformFailureData(
        printer.addImageParams,
        printerPlatform.addImageHaninCPCL,
        [imageParams],
      ),
    ];

    for (final data in testData) {
      test('platform failure ${data.functionToTest}', () async {
        when(printerPlatform.connectHaninCPCL('12:34:56:AB:CD:EF'))
            .thenAnswer((realInvocation) async => true);

        when(Function.apply(data.platformFunction, data.args)).thenThrow(
          PlatformException(code: '1006', details: 'Disconnected'),
        );

        expect(await printer.connect(), true);

        if (data.args.isEmpty) {
          expect(
            () async => data.functionToTest(),
            throwsA(
              isA<ConnectionException>(),
            ),
          );
          verify(data.platformFunction()).called(1);
        } else if (data.args.length == 1) {
          expect(
            () async => data.functionToTest(data.args.first),
            throwsA(
              isA<ConnectionException>(),
            ),
          );
          verify(data.platformFunction(data.platformArgs.first)).called(1);
        } else if (data.args.length == 2) {
          expect(
            () async => data.functionToTest(data.args.first, data.args[1]),
            throwsA(
              isA<ConnectionException>(),
            ),
          );
          verify(data.platformFunction(data.platformArgs.first, data.args[1]))
              .called(1);
        }
      });
    }
  });
}
