// ignore_for_file: no-magic-number, for enum codes and some default values.

/// Rotation settings for Hanin HM-A300L: values are angles in counterclockwise direction.
enum Rotation90 {
  text(0),
  text90(90),
  text180(180),
  text270(270);

  const Rotation90(this.rot);

  final int rot;
}