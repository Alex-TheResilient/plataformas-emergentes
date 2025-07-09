package com.example.calculator_app

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.calculator/operations"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "add" -> {
                    val a = call.argument<Double>("a") ?: 0.0
                    val b = call.argument<Double>("b") ?: 0.0
                    result.success(add(a, b))
                }
                "subtract" -> {
                    val a = call.argument<Double>("a") ?: 0.0
                    val b = call.argument<Double>("b") ?: 0.0
                    result.success(subtract(a, b))
                }
                "multiply" -> {
                    val a = call.argument<Double>("a") ?: 0.0
                    val b = call.argument<Double>("b") ?: 0.0
                    result.success(multiply(a, b))
                }
                "divide" -> {
                    val a = call.argument<Double>("a") ?: 0.0
                    val b = call.argument<Double>("b") ?: 0.0
                    if (b == 0.0) {
                        result.error("DIVISION_BY_ZERO", "No se puede dividir por cero", null)
                    } else {
                        result.success(divide(a, b))
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun add(a: Double, b: Double): Double {
        return a + b
    }

    private fun subtract(a: Double, b: Double): Double {
        return a - b
    }

    private fun multiply(a: Double, b: Double): Double {
        return a * b
    }

    private fun divide(a: Double, b: Double): Double {
        return a / b
    }
}