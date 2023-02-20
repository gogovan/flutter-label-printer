import 'package:flutter_label_printer/exception/label_printer_exception.dart';

/// ImageIOException: The image file is not found, not a supported image file,
/// or otherwise unable to be loaded as a proper image.
class ImageIOException extends LabelPrinterException {
  const ImageIOException(super.message, super.cause);
}
