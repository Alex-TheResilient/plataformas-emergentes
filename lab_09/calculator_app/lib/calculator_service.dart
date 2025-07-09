import 'package:flutter/services.dart';

class CalculatorService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.calculator/operations',
  );

  /// Suma dos números
  static Future<double> add(double a, double b) async {
    try {
      final result = await _channel.invokeMethod('add', {'a': a, 'b': b});
      return result.toDouble();
    } on PlatformException catch (e) {
      throw Exception('Error en suma: ${e.message}');
    }
  }

  /// Resta dos números
  static Future<double> subtract(double a, double b) async {
    try {
      final result = await _channel.invokeMethod('subtract', {'a': a, 'b': b});
      return result.toDouble();
    } on PlatformException catch (e) {
      throw Exception('Error en resta: ${e.message}');
    }
  }

  /// Multiplica dos números
  static Future<double> multiply(double a, double b) async {
    try {
      final result = await _channel.invokeMethod('multiply', {'a': a, 'b': b});
      return result.toDouble();
    } on PlatformException catch (e) {
      throw Exception('Error en multiplicación: ${e.message}');
    }
  }

  /// Divide dos números
  static Future<double> divide(double a, double b) async {
    try {
      final result = await _channel.invokeMethod('divide', {'a': a, 'b': b});
      return result.toDouble();
    } on PlatformException catch (e) {
      throw Exception('Error en división: ${e.message}');
    }
  }
}
