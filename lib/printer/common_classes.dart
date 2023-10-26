// ignore_for_file: no-magic-number, for enum codes and some default values.

import 'package:flutter_label_printer/templating/command_parameters/print_image.dart';

/// Rotation settings for Hanin HM-A300L: values are angles in counterclockwise direction.
enum Rotation90 {
  text(0),
  text90(90),
  text180(180),
  text270(270);

  const Rotation90(this.rot);

  final int rot;

  static Rotation90 fromAngle(double angle) {
    final roundedRotation = (angle / 90).round() * 90 % 360;
    switch (roundedRotation) {
      case 0:
        return Rotation90.text;
      // ignore: no-magic-number, well-formed angles.
      case 90:
        return Rotation90.text90;
      // ignore: no-magic-number, well-formed angles.
      case 180:
        return Rotation90.text180;
      // ignore: no-magic-number, well-formed angles.
      case 270:
        return Rotation90.text270;
      default:
        return Rotation90.text;
    }
  }
}

/// Algorithm to monochromize image when printing.
enum ImageMode {
  binary(0),
  dithering(1),
  cluster(2);

  const ImageMode(this.code);

  final int code;

  static ImageMode fromMonochromizationAlgorithm(
    MonochromizationAlgorithm algorithm,
  ) {
    switch (algorithm) {
      case MonochromizationAlgorithm.binary:
        return ImageMode.binary;
      case MonochromizationAlgorithm.dithering:
        return ImageMode.dithering;
      case MonochromizationAlgorithm.cluster:
        return ImageMode.cluster;
    }
  }
}
