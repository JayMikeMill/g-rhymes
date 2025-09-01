/*
 * Copyright (c) 2025 GWorks
 *
 * Licensed under the GWorks Non-Commercial License.
 * You may view, copy, and modify the source code.
 * You may redistribute the source code under the same terms.
 * You may build and use the code for personal or educational purposes.
 * You may NOT sell or redistribute the built binaries.
 *
 * For the full license text, see LICENSE file in this repository.
 *
 * File: log.dart
 * Description: Simple logging utility wrapping the 'logger' package.
 *              Provides info, debug, warning, and error logging
 *              with a consistent project tag prefix.
 */

import 'package:logger/logger.dart';

// -----------------------------------------------------------------------------
// Class: Log
// Description: Static logging helper for consistent application-wide logging.
//              Wraps the Logger package with a predefined tag and formatting.
// -----------------------------------------------------------------------------
class Log {
  /// Singleton Logger instance, initialized once in main()
  static final _logger = Logger(
      printer: PrettyPrinter(methodCount: 0, colors: false));

  /// Tag prefix added to all log messages
  static final _logTag = '[G-Rhymes]: ';

  // ---------------------------------------------------------------------------
  /// Logs an informational message
  static void i(String message) {
    _logger.i('$_logTag$message');
  }

  // ---------------------------------------------------------------------------
  /// Logs a debug message
  static void d(String message) {
    _logger.d('$_logTag$message');
  }

  // ---------------------------------------------------------------------------
  /// Logs a warning message
  static void w(String message) {
    _logger.w('$_logTag$message');
  }

  // ---------------------------------------------------------------------------
  /// Logs an error message
  static void e(String message) {
    _logger.e('$_logTag$message');
  }

  static Future<dynamic> timeFunc(Future<dynamic> Function() f, String name) async {
    final stopwatch = Stopwatch()..start();
    final ret = await f();
    Log.i('$name took: ${stopwatch.elapsedMilliseconds} ms to complete.');
    return ret;
  }
}
