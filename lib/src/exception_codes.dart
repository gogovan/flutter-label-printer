// ignore_for_file: no-magic-number, this file documents all error codes.

import 'package:flutter/services.dart';
import 'package:flutter_label_printer/exception/label_printer_exception.dart';
import 'package:flutter_label_printer/exception/missing_permission_exception.dart';
import 'package:flutter_label_printer/exception/missing_phone_capability_exception.dart';
import 'package:flutter_label_printer/exception/no_current_activity_exception.dart';
import 'package:flutter_label_printer/exception/search_failed_exception.dart';
import 'package:flutter_label_printer/exception/unknown_label_printer_exception.dart';

LabelPrinterException getExceptionFromCode(
  int code,
  String message,
  PlatformException cause,
) {
  switch (code) {
    case 1000:
      return UnknownLabelPrinterException(message, cause);
    case 1001:
      return MissingPhoneCapabilityException(message, cause);
    case 1002:
      return MissingSearchPermissionException(message, cause);
    case 1003:
      return NoCurrentActivityException(message, cause);
    case 1004:
      return SearchFailedException(message, cause);
  }

  // All codes should be covered. This should not happen. Fallback.
  return UnknownLabelPrinterException(message, cause);
}
