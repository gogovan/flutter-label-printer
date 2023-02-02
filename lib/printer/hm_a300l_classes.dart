// ignore_for_file: no-magic-number, for enum codes and some default values.

enum LabelResolution {
  res100(100),
  res200(200);

  const LabelResolution(this.res);
  final int res;
}

class PrintAreaSizeParamsHMA300L {
  PrintAreaSizeParamsHMA300L({
    this.offset = 0,
    this.horizontalRes = LabelResolution.res200,
    this.verticalRes = LabelResolution.res200,
    required this.height,
    this.quantity = 1,
  });

  int offset;
  LabelResolution horizontalRes;
  LabelResolution verticalRes;
  int height;
  int quantity;
}
