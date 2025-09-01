import 'package:logger/logger.dart';

class Log {
  // Initialize once in main()
  static final _logger  = Logger(printer:
  PrettyPrinter(methodCount: 0, colors: false));
  static final _logTag = '[G-Rhymes]: ';


  // Info
  static void i(String message) {
    _logger.i('$_logTag$message');
  }
  
  // Debug
  static void d(String message) {
    _logger.d('$_logTag$message');
  }

  // Warning
  static void w(String message) {
    _logger.w('$_logTag$message');
  }

  // Error
  static void e(String message) {
    _logger.e('$_logTag$message');
  }
}
