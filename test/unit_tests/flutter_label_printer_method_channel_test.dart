// ignore_for_file: no-magic-number

import 'package:flutter/services.dart';
import 'package:flutter_label_printer/flutter_label_printer_method_channel.dart';
import 'package:flutter_label_printer/printer/hm_a300l_classes.dart';
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

  test('searchHMA300L', () async {
    when(mockEventChannel.receiveBroadcastStream())
        .thenAnswer((realInvocation) => Stream.value(['AB:CD:EF:12:13:14']));

    expect((await printer.searchHMA300L().first).first, 'AB:CD:EF:12:13:14');
  });

  test('stopSearchHMA300L', () async {
    when(
      mockMethodChannel
          .invokeMethod<bool>('hk.gogovan.label_printer.stopSearchHMA300L'),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.stopSearchHMA300L(), true);
  });

  test('connectHMA300L', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.connectHMA300L',
        <String, dynamic>{
          'address': 'AB:CD:EF:12:13:14',
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.connectHMA300L('AB:CD:EF:12:13:14'), true);
  });

  test('disconnectHMA300L', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.disconnectHMA300L',
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.disconnectHMA300L(), true);
  });

  test('printTestPageHMA300L', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.printTestPageHMA300L',
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.printTestPageHMA300L(), true);
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

  test('setPrintAreaSizeHMA300L', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.setPrintAreaSizeHMA300L',
        <String, dynamic>{
          'offset': 0,
          'height': 24,
          'quantity': 1,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(
      await printer.setPrintAreaSizeHMA300L(
        const HMA300LPrintAreaSizeParams(
          height: 24,
        ),
      ),
      true,
    );
  });

  test('addTextHMA300L', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.addTextHMA300L',
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
      await printer.addTextHMA300L(
        const HMA300LTextParams(
          xPosition: 180,
          yPosition: 120,
          text: 'Hello World!',
        ),
      ),
      true,
    );
  });

  test('printHMA300L', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.printHMA300L',
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.printHMA300L(), true);
  });

  test('setPaperTypeHMA300L', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.setPaperTypeHMA300L',
        <String, dynamic>{
          'paperType': 4,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.setPaperTypeHMA300L(HMA300LPaperType.blackMark2Inch),
        true);
  });

  test('setBoldHMA300L', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.setBoldHMA300L',
        <String, dynamic>{
          'size': 4,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.setBoldHMA300L(4), true);
  });

  test('setTextSizeHMA300L', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.setTextSizeHMA300L',
        <String, dynamic>{
          'width': 16,
          'height': 24,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.setTextSizeHMA300L(16, 24), true);
  });

  test('getStatusHMA300L', () async {
    when(
      mockMethodChannel.invokeMethod<int>(
        'hk.gogovan.label_printer.getStatusHMA300L',
      ),
    ).thenAnswer((realInvocation) async => 16);

    expect(await printer.getStatusHMA300L(), 16);
  });

  test('prefeedHMA300L', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.prefeedHMA300L',
        <String, dynamic>{
          'dot': 18,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.prefeedHMA300L(18), true);
  });

  test('setPageWidthHMA300L', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.setPageWidthHMA300L',
        <String, dynamic>{
          'width': 400,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.setPageWidthHMA300L(400), true);
  });

  test('setAlignHMA300L', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.setAlignHMA300L',
        <String, dynamic>{
          'align': 2,
        },
      ),
    ).thenAnswer((realInvocation) async => true);

    expect(await printer.setAlignHMA300L(2), true);
  });

  test('addBarcode', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.addBarcode',
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
      await printer.addBarcode(
        const HMA300LBarcodeParams(
          type: HMA300LBarcodeType.code39,
          ratio: HMA300LBarcodeRatio.ratio2,
          barWidthUnit: 2,
          height: 40,
          xPosition: 120,
          yPosition: 60,
          data: '74892342348',
          dataTextParams: HMA300LBarcodeDataTextParams(
            font: HMA300LFont.font20,
            size: 8,
            offset: 18,
          ),
        ),
      ),
      true,
    );
  });

  test('addQRCode', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.addQRCode',
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
      await printer.addQRCode(
        const HMA300LQRCodeParams(
          orientation: HMA300LPrintOrientation.horizontal,
          xPosition: 240,
          yPosition: 160,
          model: HMA300LQRCodeModel.normal,
          unitSize: 8,
          data: 'https://example.com',
        ),
      ),
      true,
    );
  });

  test('addRectangle', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.addRectangle',
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
      await printer.addRectangle(const Rect.fromLTRB(10, 20, 30, 40), 5),
      true,
    );
  });

  test('addLine', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.addLine',
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
      await printer.addLine(const Rect.fromLTRB(10, 20, 30, 40), 5),
      true,
    );
  });

  test('addImage', () async {
    when(
      mockMethodChannel.invokeMethod<bool>(
        'hk.gogovan.label_printer.addImage',
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
      await printer.addImage(
        const HMA300LPrintImageParams(
          imagePath: '/sdcard/1.jpg',
          xPosition: 80,
          yPosition: 120,
          mode: HMA300LPrintImageMode.dithering,
        ),
      ),
      true,
    );
  });
}
