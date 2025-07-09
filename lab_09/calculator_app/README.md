# Calculator App - Implementación de MethodChannel

## Descripción del Proyecto

Este proyecto demuestra la implementación de **MethodChannel** en Flutter para realizar operaciones matemáticas básicas (suma, resta, multiplicación y división) utilizando código nativo en Android (Kotlin) e iOS (Swift).

## ¿Qué es MethodChannel?

MethodChannel es una tecnología de Flutter que permite la comunicación bidireccional entre el código Dart y el código nativo de la plataforma. Es ideal para invocar métodos nativos desde Flutter y recibir resultados de vuelta.

## Arquitectura de la Implementación

### 1. Capa de Servicio (Dart)

```dart
// calculator_service.dart
class CalculatorService {
  static const MethodChannel _channel = MethodChannel('com.example.calculator/operations');

  static Future<double> add(double a, double b) async {
    final result = await _channel.invokeMethod('add', {'a': a, 'b': b});
    return result.toDouble();
  }
}
```

**Responsabilidades:**

- Definir el canal de comunicación con identificador único
- Encapsular las llamadas a métodos nativos
- Manejar la serialización de parámetros
- Gestionar errores de comunicación

### 2. Interfaz de Usuario (Flutter)

```dart
// main.dart
Future<void> _performOperation(String operation) async {
  final double a = double.parse(_firstController.text);
  final double b = double.parse(_secondController.text);
  double result = await CalculatorService.add(a, b); // Llamada asíncrona
  setState(() => _result = 'Resultado: $result');
}
```

**Responsabilidades:**

- Capturar entrada del usuario
- Realizar llamadas asíncronas al servicio
- Mostrar resultados y manejar estados de carga
- Gestionar errores de la interfaz

### 3. Implementación Nativa Android (Kotlin)

```kotlin
// MainActivity.kt
override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        .setMethodCallHandler { call, result ->
            when (call.method) {
                "add" -> {
                    val a = call.argument<Double>("a") ?: 0.0
                    val b = call.argument<Double>("b") ?: 0.0
                    result.success(add(a, b))
                }
            }
        }
}
```

**Responsabilidades:**

- Registrar el manejador de métodos
- Extraer argumentos del MethodCall
- Ejecutar la lógica nativa
- Retornar resultados o errores

### 4. Implementación Nativa iOS (Swift)

```swift
// AppDelegate.swift
let calculatorChannel = FlutterMethodChannel(name: "com.example.calculator/operations",
                                           binaryMessenger: controller.binaryMessenger)

calculatorChannel.setMethodCallHandler { (call: FlutterMethodCall, result: FlutterResult) in
    let args = call.arguments as? [String: Any]
    let a = args?["a"] as? Double ?? 0.0
    let b = args?["b"] as? Double ?? 0.0

    switch call.method {
    case "add":
        result(self?.add(a: a, b: b))
    }
}
```

## Casos de Uso Ideales para MethodChannel

- **Operaciones que devuelven un resultado único**
- **Funcionalidades que requieren acceso a APIs nativas**
- **Integraciones con bibliotecas específicas de plataforma**
- **Operaciones computacionalmente intensivas**

## Limitaciones

- No es ideal para streams de datos continuos (usar EventChannel)
- Overhead de serialización para operaciones muy frecuentes
- Requiere implementación en cada plataforma nativa

## Conclusión

MethodChannel proporciona una solución robusta y eficiente para integrar funcionalidades nativas en aplicaciones Flutter. En este proyecto, demuestra cómo implementar operaciones matemáticas básicas manteniendo la simplicidad del código y aprovechando las capacidades nativas de cada plataforma.

---

**Tecnologías utilizadas:**

- Flutter/Dart
- Android (Kotlin)
- iOS (Swift)
- MethodChannel API
