# Comunicación entre Flutter y código nativo (Kotlin/Swift)

En la implementación de una aplicación en Flutter (DART), en muchas situaciones es necesario implementar funcionalidades en código nativo Kotlin/Swift. Entonces, investigar las siguientes tecnologías:

1. **MethodChannel**
2. **EventChannel**
3. **BasicMessageChannel**
4. **Pigeon**
5. **FFI**

Para el Laboratorio se uso **MethodChannel** que esta en la carpeta _calculator_app_

---

## 1. MethodChannel

MethodChannel es la forma más común de comunicación entre Flutter y código nativo. Permite invocar métodos nativos desde Dart y recibir resultados.

**Características:**

- Comunicación bidireccional pero asíncrona
- Ideal para operaciones que devuelven un resultado único
- Maneja automáticamente la serialización/deserialización de datos básicos
- Soporte para tipos primitivos, listas, mapas y ByteData

**Uso típico:**

```dart
static const platform = MethodChannel('samples.flutter.dev/battery');
final int result = await platform.invokeMethod('getBatteryLevel');
```

---

## 2. EventChannel

EventChannel está diseñado para streams de datos desde el código nativo hacia Flutter.

**Características:**

- Comunicación unidireccional (nativo → Flutter)
- Perfecto para eventos continuos o streams de datos
- Maneja automáticamente la suscripción y cancelación
- Ideal para sensores, ubicación, notificaciones push

**Uso típico:**

```dart
static const eventChannel = EventChannel('samples.flutter.dev/charging');
Stream<bool> get chargingStateStream => eventChannel.receiveBroadcastStream().cast<bool>();
```

---

## 3. BasicMessageChannel

BasicMessageChannel proporciona comunicación bidireccional más flexible que MethodChannel.

**Características:**

- Comunicación bidireccional asíncrona
- Más control sobre el formato de mensajes
- Permite codificación personalizada de mensajes
- Útil cuando necesitas un protocolo de comunicación más específico

**Uso típico:**

```dart
static const messageChannel = BasicMessageChannel('samples.flutter.dev/messages', StandardMethodCodec());
final reply = await messageChannel.send('Hello from Flutter');
```

---

## 4. Pigeon

Pigeon es una herramienta de generación de código que crea interfaces type-safe entre Flutter y código nativo.

**Características:**

- Genera código automáticamente para Dart, Kotlin/Java y Swift/Objective-C
- Type-safety completa en tiempo de compilación
- Reduce errores de serialización manual
- Maneja tipos complejos y estructuras de datos personalizadas
- Ideal para APIs complejas con múltiples métodos

**Flujo de trabajo:**

1. Defines interfaces en un archivo `.dart`
2. Pigeon genera el código nativo y Dart
3. Implementas la lógica en el lado nativo

---

## 5. FFI (Foreign Function Interface)

FFI permite llamar directamente a funciones de bibliotecas nativas (C/C++) desde Dart.

**Características:**

- Comunicación directa con bibliotecas C/C++
- Mejor rendimiento al evitar la capa de serialización
- Ideal para código computacionalmente intensivo
- Soporte para punteros, structs y callbacks
- Disponible en dispositivos móviles y desktop

**Uso típico:**

```dart
import 'dart:ffi';
import 'package:ffi/ffi.dart';

final DynamicLibrary nativeLib = DynamicLibrary.open('native_lib.so');
final int Function(int, int) nativeAdd = nativeLib
  .lookup<NativeFunction<Int32 Function(Int32, Int32)>>('add')
  .asFunction();
```

---

## Comparación y Recomendaciones

**Cuándo usar cada uno:**

- **MethodChannel:** Para la mayoría de casos simples de comunicación bidireccional
- **EventChannel:** Para streams de datos continuos desde nativo
- **BasicMessageChannel:** Para protocolos de comunicación personalizados
- **Pigeon:** Para APIs complejas que requieren type-safety
- **FFI:** Para máximo rendimiento con bibliotecas C/C++

**Consideraciones de rendimiento:**

- FFI > MethodChannel > EventChannel > BasicMessageChannel
- FFI evita serialización pero requiere más cuidado con la gestión de memoria
- Los channels tienen overhead de serialización pero son más seguros

**Facilidad de uso:**

- MethodChannel/EventChannel > Pigeon > BasicMessageChannel > FFI
- Los channels estándar son más fáciles de implementar
- FFI requiere conocimiento profundo

---

# Cuestionario

Si quisieras desarrollar un plugin para acceder a sensores del teléfono **¿Qué tecnología de la sección anterior emplearías? Justificar la respuesta**

EventChannel es la tecnología ideal para sensores porque:

### Ventajas clave:

Stream de datos continuos: Los sensores (acelerómetro, giroscopio, GPS) generan datos constantemente
Comunicación unidireccional: Los sensores envían datos desde nativo → Flutter sin necesidad de respuesta
Manejo automático de suscripciones: Se suscribe/desuscribe automáticamente cuando se escucha/cancela el stream
Eficiencia: Optimizado para flujos de datos en tiempo real

### Por qué no las otras:

MethodChannel: Inadecuado para datos continuos, cada lectura requeriría una llamada separada
BasicMessageChannel: Más complejo sin beneficios adicionales para este caso
Pigeon: Overkill para streams simples, mejor para APIs complejas
FFI: Innecesario, los sensores ya tienen APIs nativas bien definidas

## Ejemplo práctico:

```dart
// Perfecto para sensores
Stream<AccelerometerEvent> get accelerometerEvents =>
    _eventChannel.receiveBroadcastStream().cast<AccelerometerEvent>();

// Los datos llegan continuamente sin bloquear la UI
accelerometerEvents.listen((event) {
    // Procesar datos del sensor en tiempo real
});
```

EventChannel es la elección natural para cualquier funcionalidad que produzca streams de datos en tiempo real, especialmente sensores móviles.
