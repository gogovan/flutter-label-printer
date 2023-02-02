// ignore_for_file: no-magic-number, this file documents all error codes.

import 'package:flutter_label_printer/exception/connection_exception.dart';
import 'package:flutter_label_printer/exception/connection_id_exception.dart';
import 'package:flutter_label_printer/exception/connection_timeout_exception.dart';
import 'package:flutter_label_printer/exception/device_not_connected_exception.dart';
import 'package:flutter_label_printer/exception/invalid_connection_state_exception.dart';
import 'package:flutter_label_printer/exception/label_printer_exception.dart';
import 'package:flutter_label_printer/exception/missing_permission_exception.dart';
import 'package:flutter_label_printer/exception/missing_phone_capability_exception.dart';
import 'package:flutter_label_printer/exception/no_current_activity_exception.dart';
import 'package:flutter_label_printer/exception/search_failed_exception.dart';
import 'package:flutter_label_printer/exception/unknown_label_printer_exception.dart';

LabelPrinterException getExceptionFromCode(
  int code,
  String message,
  String stacktrace,
) {
  switch (code) {
    case 1000:
      return UnknownLabelPrinterException(message, stacktrace);
    case 1001:
      return MissingPhoneCapabilityException(message, stacktrace);
    case 1002:
      return MissingSearchPermissionException(message, stacktrace);
    case 1003:
      return NoCurrentActivityException(message, stacktrace);
    case 1004:
      return SearchFailedException(message, stacktrace);
    case 1005:
      return InvalidConnectionStateException(message, stacktrace);
    case 1006:
      return ConnectionException(message, stacktrace);
    case 1007:
      return ConnectionIdException(message, stacktrace);
    case 1008:
      return ConnectionTimeoutException(message, stacktrace);
    case 1009:
      return DeviceNotConnectedException(message, stacktrace);
  }

  // All codes should be covered. This should not happen. Fallback.
  return UnknownLabelPrinterException(message, stacktrace);
}
