import 'package:flutter_label_printer/exception/connection_exception.dart';

/// ConnectionTimeoutException: When connecting to the printer timed out.
class ConnectionTimeoutException extends ConnectionException {
  const ConnectionTimeoutException(super.message, super.cause);
}
