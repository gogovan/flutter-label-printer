import 'package:flutter_label_printer/exception/connection_exception.dart';

/// ConnectionAddressException: Unable to connect to the printer due to wrong id format.
class ConnectionIdException extends ConnectionException {
  const ConnectionIdException(super.message, super.cause);
}
