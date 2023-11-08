import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_area_size.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_barcode.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_image.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_qr_code.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_rect.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text_align.dart';
import 'package:flutter_label_printer/templating/command_parameters/print_text_style.dart';
import 'package:yaml/yaml.dart';

double _toDouble(x, {double? defValue}) {
  if (x is num) {
    return x.toDouble();
  } else if (x is String) {
    return double.parse(x);
  } else if (defValue != null) {
    return defValue;
  } else {
    throw ArgumentError('Unable to convert $x to double.');
  }
}

/// Template represents a parsed template.
@immutable
class Template {
  const Template(this.commands);

  /// Create a Template from YAML data.
  factory Template.fromYaml(String data) {
    final obj = loadYamlNode(data);
    final cmds = (obj.value as YamlMap)['commands'] as YamlList;

    final result = <Command>[];
    for (final rawCmd in cmds) {
      final cmdMap = rawCmd as YamlMap;
      final type = CommandType.values.byName(cmdMap['command']);

      final paramMap = cmdMap['parameters'] as YamlMap;
      final CommandParameter params;

      switch (type) {
        case CommandType.size:
          params = _getPrintAreaSize(paramMap);
          break;
        case CommandType.text:
          final styleN = paramMap['style'];
          final style = styleN is YamlMap ? styleN : null;
          params = _getPrintText(paramMap, style);
          break;
        case CommandType.barcode:
          final type =
              PrintBarcodeType.values.asNameMap()[paramMap['type'].toString()];
          if (type == null) {
            throw ArgumentError('Barcode type cannot be null');
          }
          params = _getPrintBarcode(type, paramMap);
          break;
        case CommandType.qrcode:
          params = _getPrintQRCode(paramMap);
          break;
        case CommandType.line:
          params = _getPrintRect(paramMap);
          break;
        case CommandType.rectangle:
          params = _getPrintRect(paramMap);
          break;
        case CommandType.image:
          params = _getPrintImage(paramMap);
          break;
      }

      result.add(Command(type, params));
    }

    return Template(result);
  }

  static PrintImage _getPrintImage(YamlMap paramMap) => PrintImage(
        path: paramMap['path'].toString(),
        xPosition: _toDouble(paramMap['xPosition']),
        yPosition: _toDouble(paramMap['yPosition']),
      );

  static PrintRect _getPrintRect(YamlMap paramMap) => PrintRect(
        rect: Rect.fromLTRB(
          _toDouble(paramMap['left']),
          _toDouble(paramMap['top']),
          _toDouble(paramMap['right']),
          _toDouble(paramMap['bottom']),
        ),
        strokeWidth: _toDouble(paramMap['strokeWidth'], defValue: 1),
      );

  static PrintQRCode _getPrintQRCode(YamlMap paramMap) => PrintQRCode(
        xPosition: _toDouble(paramMap['xPosition']),
        yPosition: _toDouble(paramMap['yPosition']),
        data: paramMap['data'].toString(),
        unitSize: _toDouble(paramMap['unitSize']),
      );

  static PrintBarcode _getPrintBarcode(
    PrintBarcodeType type,
    YamlMap paramMap,
  ) =>
      PrintBarcode(
        type: type,
        xPosition: _toDouble(paramMap['xPosition']),
        yPosition: _toDouble(paramMap['yPosition']),
        data: paramMap['data'].toString(),
        height: _toDouble(paramMap['height']),
      );

  static PrintText _getPrintText(YamlMap paramMap, YamlMap? style) => PrintText(
        text: paramMap['text'].toString(),
        xPosition: _toDouble(paramMap['xPosition']),
        yPosition: _toDouble(paramMap['yPosition']),
        rotation: _toDouble(paramMap['rotation'], defValue: 0),
        style: style == null
            ? null
            : PrintTextStyle(
                bold: _toDouble(style['bold'], defValue: 0),
                width: _toDouble(style['width'], defValue: 1),
                height: _toDouble(style['height'], defValue: 1),
                align: PrintTextAlign.values
                    .asNameMap()[style['align'].toString()],
              ),
      );

  static PrintAreaSize _getPrintAreaSize(YamlMap paramMap) => PrintAreaSize(
        paperType:
            PrintPaperType.values.byName(paramMap['paperType'].toString()),
        originX: _toDouble(paramMap['originX'], defValue: 0),
        originY: _toDouble(paramMap['originY'], defValue: 0),
        width: _toDouble(paramMap['width']),
        height: _toDouble(paramMap['height']),
      );

  final List<Command> commands;

  @override
  String toString() => 'Template{commands: $commands}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Template &&
          runtimeType == other.runtimeType &&
          commands == other.commands;

  @override
  int get hashCode => commands.hashCode;
}

@immutable
class Command {
  const Command(this.type, this.params);

  final CommandType type;
  final CommandParameter params;

  @override
  String toString() => 'Command{type: $type, params: $params}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Command &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          params == other.params;

  @override
  int get hashCode => type.hashCode ^ params.hashCode;
}

enum CommandType { size, text, barcode, qrcode, rectangle, line, image }

/// Marker interface to indicate that the class is a CommandParameter.
abstract class CommandParameter {}
