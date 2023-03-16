import 'package:flutter/foundation.dart';

@immutable
class PrintImage {
  const PrintImage({
    required this.path,
    required this.xPosition,
    required this.yPosition,
  });

  final String path;
  final double xPosition;
  final double yPosition;

  @override
  String toString() => 'PrintImage{path: $path, xPosition: $xPosition, yPosition: $yPosition}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintImage &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          xPosition == other.xPosition &&
          yPosition == other.yPosition;

  @override
  int get hashCode => path.hashCode ^ xPosition.hashCode ^ yPosition.hashCode;
}
