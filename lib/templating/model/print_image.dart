import 'package:flutter/foundation.dart';

@immutable
class PrintImage {
  const PrintImage({
    required this.path,
    required this.xPosition,
    required this.yPosition,
    this.monochromizationAlgorithm,
  });

  final String path;
  final double xPosition;
  final double yPosition;
  final MonochromizationAlgorithm? monochromizationAlgorithm;

  @override
  String toString() =>
      'PrintImage{path: $path, xPosition: $xPosition, yPosition: $yPosition, monochromizationAlgorithm: $monochromizationAlgorithm}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintImage &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          xPosition == other.xPosition &&
          yPosition == other.yPosition &&
          monochromizationAlgorithm == other.monochromizationAlgorithm;

  @override
  int get hashCode =>
      path.hashCode ^
      xPosition.hashCode ^
      yPosition.hashCode ^
      monochromizationAlgorithm.hashCode;
}

/// If your printer support algorithms for converting colored images onto monochrome, use the arguments here.
enum MonochromizationAlgorithm { binary, dithering, cluster }
