// ignore_for_file: no-magic-number

import 'dart:ui';

import 'package:flutter_label_printer/templating/command_parameters/print_area_size.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_barcode.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_image.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_qr_code.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_rect.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text.dart';
import 'package:flutter_label_printer/templating/templatable_printer_interface.dart';
import 'package:flutter_label_printer/templating/template.dart';
import 'package:flutter_label_printer/templating/template_printer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'template_printer_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<TemplatablePrinterInterface>(),
])
void main() {
  group('test printTemplate', () {
    const template = Template([
      Command(
        CommandType.size,
        PrintAreaSize(
          paperType: PrintPaperType.continuous,
        ),
      ),
      Command(
        CommandType.text,
        PrintText(
          text: 'Hello World!',
          xPosition: 80,
          yPosition: 20,
        ),
      ),
      Command(
        CommandType.barcode,
        PrintBarcode(
          type: PrintBarcodeType.code39,
          xPosition: 40,
          yPosition: 20,
          data: 'VP93751',
          height: 100,
        ),
      ),
      Command(
        CommandType.qrcode,
        PrintQRCode(
          xPosition: 60,
          yPosition: 30,
          data: 'https://example.com',
        ),
      ),
      Command(
        CommandType.line,
        PrintRect(rect: Rect.fromLTRB(10, 20, 30, 40)),
      ),
      Command(
        CommandType.rectangle,
        PrintRect(rect: Rect.fromLTRB(10, 20, 30, 40)),
      ),
      Command(
        CommandType.image,
        PrintImage(
          path: '/sdcard/1.jpg',
          xPosition: 50,
          yPosition: 30,
        ),
      ),
    ]);

    test('printTemplate failure', () async {
      final printer = MockTemplatablePrinterInterface();
      final templatePrinter = TemplatePrinter(printer, template);
      final result = await templatePrinter.printTemplate();
      expect(result, false);
    });

    test('printTemplate success', () async {
      final printer = MockTemplatablePrinterInterface();
      final templatePrinter = TemplatePrinter(printer, template);
      when(printer.print()).thenAnswer((realInvocation) async => true);
      when(printer.setPrintAreaSize(any))
          .thenAnswer((realInvocation) async => true);
      when(printer.addText(any)).thenAnswer((realInvocation) async => true);
      when(printer.addBarcode(any)).thenAnswer((realInvocation) async => true);
      when(printer.addQRCode(any)).thenAnswer((realInvocation) async => true);
      when(printer.addLine(any)).thenAnswer((realInvocation) async => true);
      when(printer.addRectangle(any))
          .thenAnswer((realInvocation) async => true);
      when(printer.addImage(any)).thenAnswer((realInvocation) async => true);

      final result = await templatePrinter.printTemplate();
      expect(result, true);

      verify(
        printer.setPrintAreaSize(
          const PrintAreaSize(
            paperType: PrintPaperType.continuous,
          ),
        ),
      ).called(1);
      verify(
        printer.addText(
          const PrintText(
            text: 'Hello World!',
            xPosition: 80,
            yPosition: 20,
          ),
        ),
      ).called(1);
      verify(
        printer.addBarcode(
          const PrintBarcode(
            type: PrintBarcodeType.code39,
            xPosition: 40,
            yPosition: 20,
            data: 'VP93751',
            height: 100,
          ),
        ),
      ).called(1);
      verify(
        printer.addQRCode(
          const PrintQRCode(
            xPosition: 60,
            yPosition: 30,
            data: 'https://example.com',
          ),
        ),
      ).called(1);
      verify(
        printer.addLine(
          const PrintRect(rect: Rect.fromLTRB(10, 20, 30, 40)),
        ),
      ).called(1);
      verify(
        printer.addRectangle(
          const PrintRect(rect: Rect.fromLTRB(10, 20, 30, 40)),
        ),
      ).called(1);
    });
  });

  group('test template with string replacement', () {
    const template = Template([
      Command(
        CommandType.text,
        PrintText(
          text: 'Hello {{name}}!',
          xPosition: 80,
          yPosition: 20,
        ),
      ),
      Command(
        CommandType.barcode,
        PrintBarcode(
          type: PrintBarcodeType.code39,
          xPosition: 40,
          yPosition: 20,
          data: '{{barcode}}',
          height: 100,
        ),
      ),
      Command(
        CommandType.qrcode,
        PrintQRCode(
          xPosition: 60,
          yPosition: 30,
          data: 'https://{{site}}',
        ),
      ),
    ]);

    test('printTemplate success', () async {
      final printer = MockTemplatablePrinterInterface();
      final templatePrinter = TemplatePrinter(
        printer,
        template,
        replaceStrings: {
          'name': 'Alice',
          'barcode': 'HP2901',
          'site': 'example.com',
        },
      );

      when(printer.print()).thenAnswer((realInvocation) async => true);
      when(printer.addText(any)).thenAnswer((realInvocation) async => true);
      when(printer.addBarcode(any)).thenAnswer((realInvocation) async => true);
      when(printer.addQRCode(any)).thenAnswer((realInvocation) async => true);

      final result = await templatePrinter.printTemplate();
      expect(result, true);

      verify(
        printer.addText(
          const PrintText(
            text: 'Hello Alice!',
            xPosition: 80,
            yPosition: 20,
          ),
        ),
      ).called(1);
      verify(
        printer.addBarcode(
          const PrintBarcode(
            type: PrintBarcodeType.code39,
            xPosition: 40,
            yPosition: 20,
            data: 'HP2901',
            height: 100,
          ),
        ),
      ).called(1);
      verify(
        printer.addQRCode(
          const PrintQRCode(
            xPosition: 60,
            yPosition: 30,
            data: 'https://example.com',
          ),
        ),
      ).called(1);
    });
  });
}
