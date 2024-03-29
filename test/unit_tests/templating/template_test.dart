import 'dart:ui';

import 'package:flutter_label_printer/templating/command_parameters/print_area_size.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_barcode.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_image.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_qr_code.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_rect.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text_align.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text_style.dart';
import 'package:flutter_label_printer/templating/template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromYaml', () {
    const yaml = r'''
# yaml-language-server: $schema=template_schema.json
size:
  paperType: label
  originX: 0
  originY: 0
  width: 300
  height: 400
commands:
  - command: text
    text: Hello {{world}}!
    xPosition: 300
    yPosition: 100
    style:
      width: 2
      height: 3
      align: right
  - command: barcode
    type: code128
    xPosition: 0
    yPosition: 50
    data: ABC-123-456789
    height: 50
  - command: qrcode
    xPosition: 0
    yPosition: 100
    unitSize: 4
    data: https://www.example.com
  - command: line
    left: 160
    right: 290
    top: 210
    bottom: 260
    strokeWidth: 4
  - command: rectangle
    left: 170
    right: 300
    top: 220
    bottom: 270
    strokeWidth: 2
  - command: image
    path: /sdcard/one.jpg
    xPosition: 200
    yPosition: 150
    ''';

    final template = Template.fromYaml(yaml);
    expect(
      template.size,
      const PrintAreaSize(
        paperType: PrintPaperType.label,
        width: 300,
        height: 400,
        originX: 0,
        originY: 0,
      ),
    );
    expect(template.commands, [
      const Command(
        CommandType.text,
        PrintText(
          text: 'Hello {{world}}!',
          xPosition: 300,
          yPosition: 100,
          style: PrintTextStyle(
            bold: 0,
            width: 2,
            height: 3,
            align: PrintTextAlign.right,
          ),
        ),
      ),
      const Command(
        CommandType.barcode,
        PrintBarcode(
          type: PrintBarcodeType.code128,
          xPosition: 0,
          yPosition: 50,
          data: 'ABC-123-456789',
          height: 50,
        ),
      ),
      const Command(
        CommandType.qrcode,
        PrintQRCode(
          xPosition: 0,
          yPosition: 100,
          data: 'https://www.example.com',
          unitSize: 4,
        ),
      ),
      const Command(
        CommandType.line,
        PrintRect(rect: Rect.fromLTRB(160, 210, 290, 260), strokeWidth: 4),
      ),
      const Command(
        CommandType.rectangle,
        PrintRect(rect: Rect.fromLTRB(170, 220, 300, 270), strokeWidth: 2),
      ),
      const Command(
        CommandType.image,
        PrintImage(
          path: '/sdcard/one.jpg',
          xPosition: 200,
          yPosition: 150,
        ),
      ),
    ]);
  });
}
