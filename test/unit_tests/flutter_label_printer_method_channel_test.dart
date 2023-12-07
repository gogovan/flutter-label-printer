// ignore_for_file: no-magic-number

import 'package:flutter/services.dart';
import 'package:flutter_label_printer/flutter_label_printer_method_channel.dart';
import 'package:flutter_label_printer/printer/common_classes.dart';
import 'package:flutter_label_printer/printer/hanin_cpcl_classes.dart';
import 'package:flutter_label_printer/printer/hanin_tspl_classes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'flutter_label_printer_method_channel_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<MethodChannel>(),
  MockSpec<EventChannel>(),
])
void main() {
  final mockMethodChannel = MockMethodChannel();
  final mockEventChannel = MockEventChannel();
  final printer = MethodChannelFlutterLabelPrinter.mocked(
    mockMethodChannel,
    mockEventChannel,
  );

  test('searchBluetooth', () async {
    when(mockEventChannel.receiveBroadcastStream())
        .thenAnswer((realInvocation) => Stream.value(['AB:CD:EF:12:13:14']));

    expect((await printer.searchBluetooth().first).first, 'AB:CD:EF:12:13:14');
  });

  test('stopSearchBluetooth', () async {
    when(
      mockMethodChannel
          .invokeMethod<bool>('hk.gogovan.label_printer.stopSearchBluetooth'),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.stopSearchBluetooth(), true);
  });

  test('hanin.cpcl.connect', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.cpcl.connect',
        <String, dynamic>{
          'address': 'AB:CD:EF:12:13:14',
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.connectHaninCPCL('AB:CD:EF:12:13:14'), true);
  });

  test('hanin.tspl.connect', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.tspl.connect',
        <String, dynamic>{
          'address': 'AB:CD:EF:12:13:14',
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.connectHaninTSPL('AB:CD:EF:12:13:14'), true);
  });

  test('hanin.cpcl.disconnect', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.cpcl.disconnect',
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.disconnectHaninCPCL(), true);
  });

  test('hanin.tspl.disconnect', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.tspl.disconnect',
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.disconnectHaninTSPL(), true);
  });

  test('hanin.cpcl.printTestPage', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.cpcl.printTestPage',
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.printTestPageHaninCPCL(), true);
  });

  test('hanin.tspl.printTestPage', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.tspl.printTestPage',
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.printTestPageHaninTSPL(), true);
  });

  test('setLogLevel', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.setLogLevel',
        <String, dynamic>{
          'level': 1,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    await printer.setLogLevel(1);
    verify(
      mockMethodChannel.invokeMethod(
        'hk.gogovan.label_printer.setLogLevel',
        <String, dynamic>{
          'level': 1,
        },
      ),
    ).called(1);
  });

  test('hanin.cpcl.setPrintAreaSize', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.cpcl.setPrintAreaSize',
        <String, dynamic>{
          'offset': 0,
          'height': 24,
          'quantity': 1,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(
      await printer.setPrintAreaHaninCPCL(
        const HaninCPCLPrintAreaSizeParams(
          height: 24,
        ),
      ),
      true,
    );
  });

  test('hanin.tspl.setPrintAreaSize', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.tspl.setPrintAreaSize',
        <String, dynamic>{
          'width': 80,
          'height': 60,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(
      await printer.setPrintAreaHaninTSPL(
        const HaninTSPLPrintAreaSizeParams(
          width: 80,
          height: 60,
        ),
      ),
      true,
    );
  });

  test('hanin.cpcl.addText', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.cpcl.addText',
        <String, dynamic>{
          'rotate': 0,
          'font': 0,
          'x': 180,
          'y': 120,
          'text': 'Hello World!',
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(
      await printer.addTextHaninCPCL(
        const HaninCPCLTextParams(
          xPosition: 180,
          yPosition: 120,
          text: 'Hello World!',
        ),
      ),
      true,
    );
  });

  test('hanin.tspl.addText', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.tspl.addText',
        <String, dynamic>{
          'rotate': 0,
          'font': 9,
          'x': 180,
          'y': 120,
          'text': 'Hello World!',
          'alignment': 1,
          'characterWidth': 1,
          'characterHeight': 1,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(
      await printer.addTextHaninTSPL(
        const HaninTSPLTextParams(
          xPosition: 180,
          yPosition: 120,
          text: 'Hello World!',
        ),
      ),
      true,
    );
  });

  test('hanin.cpcl.print', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.cpcl.print',
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.printHaninCPCL(), true);
  });

  test('hanin.tspl.print', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.tspl.print',
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.printHaninTSPL(), true);
  });

  test('hanin.cpcl.setPaperType', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.cpcl.setPaperType',
        <String, dynamic>{
          'paperType': 4,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(
      await printer.setPaperTypeHaninCPCL(HaninCPCLPaperType.blackMark2Inch),
      true,
    );
  });

  test('hanin.cpcl.setBold', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.cpcl.setBold',
        <String, dynamic>{
          'size': 4,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.setBoldHaninCPCL(4), true);
  });

  test('hanin.cpcl.setTextSize', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.cpcl.setTextSize',
        <String, dynamic>{
          'width': 16,
          'height': 24,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.setHaninCPCLTextSize(16, 24), true);
  });

  test('hanin.cpcl.getStatus', () async {
    when(
      mockMethodChannel.invokeMethod<int>(
        'hk.gogovan.label_printer.hanin.cpcl.getStatus',
      ),
    ).thenAnswer((realInvocation) async => 16);

    expect(await printer.getStatusHaninCPCL(), 16);
  });

  test('hanin.tspl.getStatus', () async {
    when(
      mockMethodChannel.invokeMethod<int>(
        'hk.gogovan.label_printer.hanin.tspl.getStatus',
      ),
    ).thenAnswer((realInvocation) async => 4);

    expect(await printer.getStatusHaninTSPL(), 4);
  });

  test('hanin.cpcl.space', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.cpcl.space',
        <String, dynamic>{
          'dot': 18,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.addSpaceHaninCPCL(18), true);
  });

  test('hanin.tspl.space', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.tspl.space',
        <String, dynamic>{
          'mm': 18,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.addSpaceHaninTSPL(18), true);
  });

  test('hanin.cpcl.setPageWidth', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.cpcl.setPageWidth',
        <String, dynamic>{
          'width': 400,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.setPageWidthHaninCPCL(400), true);
  });

  test('hanin.cpcl.setAlign', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.cpcl.setAlign',
        <String, dynamic>{
          'align': 1,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.setAlignHaninCPCL(HaninCPCLTextAlign.center), true);
  });

  test('hanin.cpcl.addBarcode', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.cpcl.addBarcode',
        <String, dynamic>{
          'orientation': 0,
          'type': 4,
          'width': 2,
          'ratio': 2,
          'height': 40,
          'x': 120,
          'y': 60,
          'data': '74892342348',
          'showData': true,
          'dataFont': 20,
          'dataTextSize': 8,
          'dataTextOffset': 18,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(
      await printer.addBarcodeHaninCPCL(
        const HaninCPCLBarcodeParams(
          type: HaninCPCLBarcodeType.code39,
          ratio: HaninCPCLBarcodeRatio.ratio2,
          barWidthUnit: 2,
          height: 40,
          xPosition: 120,
          yPosition: 60,
          data: '74892342348',
          dataTextParams: HaninCPCLBarcodeDataTextParams(
            font: HaninCPCLFont.font20,
            size: 8,
            offset: 18,
          ),
        ),
      ),
      true,
    );
  });

  test('hanin.tspl.addBarcode', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.tspl.addBarcode',
        <String, dynamic>{
          'type': '39',
          'height': 40,
          'x': 120,
          'y': 60,
          'data': '74892342348',
          'rotate': 0,
          'barLineWidth': 1,
          'showData': false,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(
      await printer.addBarcodeHaninTSPL(
        const HaninTSPLBarcodeParams(
          barcodeType: HaninTSPLBarcodeType.code39,
          height: 40,
          xPosition: 120,
          yPosition: 60,
          barLineWidth: 1,
          data: '74892342348',
        ),
      ),
      true,
    );
  });

  test('hanin.cpcl.addQRCode', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.cpcl.addQRCode',
        <String, dynamic>{
          'orientation': 0,
          'x': 240,
          'y': 160,
          'model': 1,
          'unitSize': 8,
          'data': 'https://example.com',
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(
      await printer.addQRCodeHaninCPCL(
        const HaninCPCLQRCodeParams(
          orientation: HaninCPCLOrientation.horizontal,
          xPosition: 240,
          yPosition: 160,
          model: HaninCPCLQRCodeModel.normal,
          unitSize: 8,
          data: 'https://example.com',
        ),
      ),
      true,
    );
  });

  test('hanin.tspl.addQRCode', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.tspl.addQRCode',
        <String, dynamic>{
          'rotate': 0,
          'x': 240,
          'y': 160,
          'eccLevel': 'L',
          'mode': 0,
          'unitSize': 8,
          'data': 'https://example.com',
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(
      await printer.addQRCodeHaninTSPL(
        const HaninTSPLQRCodeParams(
          xPosition: 240,
          yPosition: 160,
          unitSize: 8,
          data: 'https://example.com',
        ),
      ),
      true,
    );
  });

  test('hanin.cpcl.addRectangle', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.cpcl.addRectangle',
        <String, dynamic>{
          'x0': 10,
          'y0': 20,
          'x1': 30,
          'y1': 40,
          'width': 5,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(
      await printer.addRectangleHaninCPCL(
        const Rect.fromLTRB(10, 20, 30, 40),
        5,
      ),
      true,
    );
  });

  test('hanin.tspl.addRectangle', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.tspl.addRectangle',
        <String, dynamic>{
          'x0': 10,
          'y0': 20,
          'x1': 30,
          'y1': 40,
          'width': 5,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(
      await printer.addRectangleHaninTSPL(
        const Rect.fromLTRB(10, 20, 30, 40),
        5,
      ),
      true,
    );
  });

  test('hanin.cpcl.addLine', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.cpcl.addLine',
        <String, dynamic>{
          'x0': 10,
          'y0': 20,
          'x1': 30,
          'y1': 40,
          'width': 5,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(
      await printer.addLineHaninCPCL(const Rect.fromLTRB(10, 20, 30, 40), 5),
      true,
    );
  });

  test('hanin.tspl.addLine', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.tspl.addLine',
        <String, dynamic>{
          'x': 10,
          'y': 20,
          'width': 20,
          'height': 20,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(
      await printer.addLineHaninTSPL(const Rect.fromLTRB(10, 20, 30, 40)),
      true,
    );
  });

  test('hanin.cpcl.addImage', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.cpcl.addImage',
        <String, dynamic>{
          'imagePath': '/sdcard/1.jpg',
          'x': 80,
          'y': 120,
          'mode': 1,
          'compress': true,
          'package': false,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(
      await printer.addImageHaninCPCL(
        const HaninCPCLImageParams(
          imagePath: '/sdcard/1.jpg',
          xPosition: 80,
          yPosition: 120,
          mode: ImageMode.dithering,
        ),
      ),
      true,
    );
  });

  test('hanin.tspl.addImage', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.hanin.tspl.addImage',
        <String, dynamic>{
          'imagePath': '/sdcard/1.jpg',
          'x': 80,
          'y': 120,
          'type': 1,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(
      await printer.addImageHaninTSPL(
        const HaninTSPLImageParams(
          imagePath: '/sdcard/1.jpg',
          xPosition: 80,
          yPosition: 120,
          imageMode: ImageMode.dithering,
        ),
      ),
      true,
    );
  });
}
