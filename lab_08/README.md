# 🏠 Sistema IoT de Control de Temperatura con MQTT

## 📋 Descripción

Sistema completo de Internet de las Cosas (IoT) que implementa el paradigma **publicador/subscriptor** usando el protocolo **MQTT**. Simula un ambiente inteligente donde sensores de temperatura, un controlador automático y actuadores (calefactor) se comunican en tiempo real para mantener una temperatura objetivo.

### 🎯 Objetivo Académico

Demostrar la implementación práctica del patrón pub/sub en sistemas IoT, incluyendo:

- Comunicación asíncrona entre dispositivos
- Calidad de servicio (QoS) en mensajería
- Control automático basado en sensores
- Simulación realista sin hardware físico

---

## 🏗️ Arquitectura del Sistema

```
┌─────────────┐    📡 MQTT Topics    ┌─────────────────┐    📡 MQTT Topics    ┌─────────────┐
│   SENSOR    │ ──────────────────►   │   CONTROLADOR   │ ──────────────────►  │ ACTUADOR    │
│ Temperatura │   hogar/salon/        │   (Lógica de    │   hogar/salon/       │ (Calefactor)│
│ (Simulado)  │   temperatura         │    Control)     │   calefactor/cmd     │ (Simulado)  │
└─────────────┘                       └─────────────────┘                      └─────────────┘
                                            │                                        │
                                            │                                        ▼
                                            │                              📡 hogar/salon/
                                            │                              calefactor/estado
                                            ▼
                                    ┌─────────────────┐
                                    │  MQTT BROKER    │
                                    │   (HiveMQ)      │
                                    └─────────────────┘
```

### 📊 Tópicos MQTT Utilizados

- `hogar/salon/temperatura` - Datos del sensor (JSON)
- `hogar/salon/calefactor/comando` - Comandos de control (JSON)
- `hogar/salon/calefactor/estado` - Estado del actuador (JSON)

---

## 🛠️ Requisitos Previos

### Software Necesario

- **Python 3.7+**
- **pip3** (gestor de paquetes de Python)
- **Git** (opcional, para clonar)

### Cuenta en HiveMQ Cloud

- Registro gratuito en: https://www.hivemq.com/mqtt-cloud-broker/
- Límite: 100 conexiones concurrentes (suficiente para el laboratorio)

---

## 🚀 Instalación y Configuración

### 1. Clonar o Descargar el Proyecto

```bash
# Opción A: Clonar repositorio
git clone <URL_DEL_REPOSITORIO>
cd mqtt_iot_project

# Opción B: Crear carpeta y copiar archivos
mkdir mqtt_iot_project
cd mqtt_iot_project
# Copiar sistema_iot.py aquí
```

### 2. Crear Entorno Virtual (Recomendado)

```bash
# Crear entorno virtual
python3 -m venv mqtt_project

# Activar entorno virtual
# En Linux/macOS:
source mqtt_project/bin/activate

# En Windows:
# mqtt_project\Scripts\activate
```

### 3. Instalar Dependencias

```bash
pip install paho-mqtt python-dotenv
```

### 4. Configurar Credenciales

Crear archivo `.env` en la carpeta del proyecto:

```bash
# Archivo .env
MQTT_BROKER_HOST=tu-cluster.s1.eu.hivemq.cloud
MQTT_BROKER_PORT=8883
MQTT_USERNAME=tu_usuario_hivemq
MQTT_PASSWORD=tu_contraseña_hivemq
```

**⚠️ IMPORTANTE**: Reemplazar con las credenciales reales de HiveMQ Cloud.

### 5. Verificar Configuración (Opcional)

```bash
python3 -c "
import os
from dotenv import load_dotenv
load_dotenv()
print('Host:', os.getenv('MQTT_BROKER_HOST'))
print('Usuario:', os.getenv('MQTT_USERNAME'))
print('Configuración:', 'OK' if os.getenv('MQTT_PASSWORD') else 'ERROR')
"
```

---

## 🎮 Ejecución del Sistema

### Método 1: Ejecución Completa (3 Terminales)

**Terminal 1 - Controlador:**

```bash
source mqtt_project/bin/activate  # Si usas entorno virtual
python3 sistema_iot.py
# Seleccionar opción: 2
```

**Terminal 2 - Actuador (Calefactor):**

```bash
source mqtt_project/bin/activate
python3 sistema_iot.py
# Seleccionar opción: 3
```

**Terminal 3 - Sensor:**

```bash
source mqtt_project/bin/activate
python3 sistema_iot.py
# Seleccionar opción: 1
```

### Método 2: Prueba Individual

```bash
python3 sistema_iot.py
# Elegir 1, 2 o 3 según el componente a probar
```

### 🛑 Detener el Sistema

- Presionar `Ctrl + C` en cada terminal

---

## 📊 Comportamiento Esperado

### 🌡️ Sensor de Temperatura

```
🚀 Iniciando sensor de temperatura...
🌡️ Temperatura: 19.5°C
📤 Mensaje publicado (ID: 1)
🌡️ Temperatura: 20.2°C
📤 Mensaje publicado (ID: 2)
```

### 🧠 Controlador

```
✅ Controlador conectado al broker MQTT
📊 Recibido: 19.5°C a las 2025-01-05T11:40:30
🔥 COMANDO: Encender calefactor (Temp: 19.5°C < 21°C)
```

### 🔥 Actuador (Calefactor)

```
✅ Calefactor conectado al broker MQTT
📨 Comando recibido: encender a las 2025-01-05T11:40:31
🔥 CALEFACTOR ENCENDIDO - Potencia: 78%
```

### 🎯 Lógica de Control

- **Temperatura Objetivo**: 22°C
- **Margen de Tolerancia**: ±1°C
- **Enciende calefactor**: Temperatura < 21°C
- **Apaga calefactor**: Temperatura > 23°C

---

## 🔍 Monitoreo Visual (Opcional)

### MQTT Explorer

1. Descargar desde: http://mqtt-explorer.com/
2. Configurar conexión:
   - Protocol: `mqtts://`
   - Host: `tu-cluster.s1.eu.hivemq.cloud`
   - Port: `8883`
   - Username/Password: Mismas credenciales del `.env`
3. Observar tópicos en tiempo real

### Cliente Web HiveMQ

- Alternativa: http://www.hivemq.com/demos/websocket-client/

---

## 🧪 Experimentos Sugeridos

### 1. Modificar Parámetros de Control

Editar en `ControladorTemperatura.__init__()`:

```python
self.temperatura_objetivo = 25.0  # Cambiar objetivo
self.margen = 2.0                 # Cambiar tolerancia
```

### 2. Simular Condiciones Extremas

Usar MQTT Explorer para publicar en `hogar/salon/temperatura`:

```json
{
  "timestamp": "2025-01-05T12:00:00",
  "temperatura": 15.0,
  "sensor_id": "manual"
}
```

### 3. Análisis de Latencia

Medir tiempo entre:

1. Publicación del sensor
2. Decisión del controlador
3. Respuesta del actuador

---

## 🐛 Resolución de Problemas

### Error: "No module named 'paho'"

```bash
# Verificar que el entorno virtual esté activado
source mqtt_project/bin/activate
pip install paho-mqtt python-dotenv
```

### Error: "externally-managed-environment"

```bash
# Usar entorno virtual obligatoriamente
python3 -m venv mqtt_project
source mqtt_project/bin/activate
pip install paho-mqtt python-dotenv
```

### Error de Conexión MQTT

1. Verificar credenciales en `.env`
2. Comprobar conectividad a internet
3. Verificar que el cluster de HiveMQ esté activo

### Puerto/Host Incorrecto

- HiveMQ Cloud usa puerto **8883** (TLS)
- Host debe ser formato: `cluster-id.s1.eu.hivemq.cloud`

---

## 📝 Evaluación y Análisis

### Métricas a Observar

1. **Latencia de comunicación** (sensor → actuador)
2. **Frecuencia de mensajes** (5 segundos por defecto)
3. **Eficiencia del control** (evita oscilaciones)
4. **Calidad de servicio** (QoS 1 - al menos una vez)

### Preguntas de Análisis

1. ¿Cómo afecta el QoS al rendimiento del sistema?
2. ¿Qué ventajas ofrece MQTT vs HTTP para IoT?
3. ¿Cómo escalarías el sistema para múltiples habitaciones?
4. ¿Qué mejoras implementarías para un entorno productivo?

---

## 📚 Tecnologías Utilizadas

- **MQTT 3.1.1**: Protocolo de mensajería IoT
- **Python 3**: Lenguaje de programación
- **paho-mqtt**: Cliente MQTT para Python
- **HiveMQ Cloud**: Broker MQTT managed
- **JSON**: Formato de intercambio de datos
- **TLS/SSL**: Seguridad en comunicaciones

---

## 👨‍🎓 Información del Estudiante

- **Curso**: Recepción y envío de mensajes con paradigma publicador/subscriptor
- **Plataforma Seleccionada**: MQTT
- **Broker**: HiveMQ Cloud
- **Fecha**: Enero 2025

---

## 📞 Soporte

Para dudas técnicas o problemas de ejecución:

1. Verificar que todas las dependencias están instaladas
2. Comprobar configuración del archivo `.env`
3. Revisar logs de error en las terminales
4. Consultar documentación de HiveMQ Cloud

**¡El sistema está listo para demostrar el paradigma pub/sub en acción!** 🚀
