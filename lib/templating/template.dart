import 'package:flutter/foundation.dart';

@immutable
class Template {
  const Template(this.commands);
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

enum CommandType { setSize, text, barcode, qrcode, rectangle, line, image }

/// Marker interface to indicate that the class is a CommandParameter.
abstract class CommandParameter {}
