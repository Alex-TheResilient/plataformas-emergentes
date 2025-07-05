# =============================================================================
# CONFIGURACIÓN CON VARIABLES DE ENTORNO
# =============================================================================

from datetime import datetime
import ssl
import random
import time
import json
import paho.mqtt.client as mqtt
import os
from dotenv import load_dotenv

# Cargar variables de entorno desde archivo .env (opcional)
load_dotenv()

# Obtener credenciales desde variables de entorno
BROKER_HOST = os.getenv('MQTT_BROKER_HOST', 'localhost')
BROKER_PORT = int(os.getenv('MQTT_BROKER_PORT', '8883'))
USERNAME = os.getenv('MQTT_USERNAME')
PASSWORD = os.getenv('MQTT_PASSWORD')

# Validar que las credenciales estén configuradas
if not USERNAME or not PASSWORD:
    print("❌ ERROR: Configura las variables de entorno MQTT_USERNAME y MQTT_PASSWORD")
    print("💡 Ejemplo: export MQTT_USERNAME='tu_usuario'")
    exit(1)

# Tópicos MQTT
TOPIC_TEMPERATURA = "hogar/salon/temperatura"
TOPIC_CALEFACTOR_COMANDO = "hogar/salon/calefactor/comando"
TOPIC_CALEFACTOR_ESTADO = "hogar/salon/calefactor/estado"

# =============================================================================
# 1. SENSOR DE TEMPERATURA SIMULADO (PUBLICADOR)
# =============================================================================


class SensorTemperatura:
    def __init__(self):
        self.client = mqtt.Client(client_id="sensor_temp_001")
        self.client.username_pw_set(USERNAME, PASSWORD)

        # Configuración TLS para HiveMQ Cloud
        context = ssl.create_default_context(ssl.Purpose.SERVER_AUTH)
        self.client.tls_set_context(context)

        # Callbacks
        self.client.on_connect = self.on_connect
        self.client.on_publish = self.on_publish

        self.temperatura_base = 20.0  # Temperatura ambiente inicial

    def on_connect(self, client, userdata, flags, rc):
        if rc == 0:
            print("✅ Sensor conectado al broker MQTT")
        else:
            print(f"❌ Error de conexión: {rc}")

    def on_publish(self, client, userdata, mid):
        print(f"📤 Mensaje publicado (ID: {mid})")

    def simular_temperatura(self):
        """Simula lecturas realistas de temperatura"""
        # Variación natural (-3 a +5 grados)
        variacion = random.uniform(-3, 5)
        # Ruido del sensor (-0.3 a +0.3)
        ruido = random.uniform(-0.3, 0.3)

        nueva_temp = self.temperatura_base + variacion + ruido
        # Actualizar base gradualmente (simula cambios ambientales)
        self.temperatura_base += random.uniform(-0.1, 0.1)

        return round(nueva_temp, 2)

    def publicar_temperatura(self):
        """Publica datos de temperatura"""
        temperatura = self.simular_temperatura()

        datos = {
            "timestamp": datetime.now().isoformat(),
            "temperatura": temperatura,
            "sensor_id": "temp_001",
            "ubicacion": "salon_principal",
            "unidad": "°C"
        }

        mensaje = json.dumps(datos)
        result = self.client.publish(TOPIC_TEMPERATURA, mensaje, qos=1)

        print(f"🌡️  Temperatura: {temperatura}°C")
        return result

    def ejecutar(self):
        """Ejecuta el sensor continuamente"""
        try:
            self.client.connect(BROKER_HOST, BROKER_PORT, 60)
            self.client.loop_start()

            print("🚀 Iniciando sensor de temperatura...")
            print("⏹️  Presiona Ctrl+C para detener\n")

            while True:
                self.publicar_temperatura()
                time.sleep(5)  # Envía cada 5 segundos

        except KeyboardInterrupt:
            print("\n🛑 Deteniendo sensor...")
        except Exception as e:
            print(f"❌ Error: {e}")
        finally:
            self.client.loop_stop()
            self.client.disconnect()

# =============================================================================
# 2. CONTROLADOR (SUBSCRIPTOR Y LÓGICA DE CONTROL)
# =============================================================================


class ControladorTemperatura:
    def __init__(self):
        self.client = mqtt.Client(client_id="controlador_001")
        self.client.username_pw_set(USERNAME, PASSWORD)

        # Configuración TLS
        context = ssl.create_default_context(ssl.Purpose.SERVER_AUTH)
        self.client.tls_set_context(context)

        # Callbacks
        self.client.on_connect = self.on_connect
        self.client.on_message = self.on_message

        # Configuración de control
        self.temperatura_objetivo = 22.0  # Temperatura deseada
        self.margen = 1.0  # Margen de tolerancia
        self.calefactor_encendido = False

    def on_connect(self, client, userdata, flags, rc):
        if rc == 0:
            print("✅ Controlador conectado al broker MQTT")
            # Suscribirse a temperatura
            client.subscribe(TOPIC_TEMPERATURA, qos=1)
            print(f"📥 Suscrito a: {TOPIC_TEMPERATURA}")
        else:
            print(f"❌ Error de conexión: {rc}")

    def on_message(self, client, userdata, msg):
        """Procesa mensajes de temperatura recibidos"""
        try:
            datos = json.loads(msg.payload.decode())
            temperatura = datos['temperatura']
            timestamp = datos['timestamp']

            print(f"📊 Recibido: {temperatura}°C a las {timestamp}")

            # Lógica de control
            self.controlar_calefactor(temperatura)

        except Exception as e:
            print(f"❌ Error procesando mensaje: {e}")

    def controlar_calefactor(self, temperatura_actual):
        """Lógica de control del calefactor"""
        temp_min = self.temperatura_objetivo - self.margen
        temp_max = self.temperatura_objetivo + self.margen

        if temperatura_actual < temp_min and not self.calefactor_encendido:
            # Hace frío -> encender calefactor
            self.enviar_comando("encender")
            self.calefactor_encendido = True
            print(
                f"🔥 COMANDO: Encender calefactor (Temp: {temperatura_actual}°C < {temp_min}°C)")

        elif temperatura_actual > temp_max and self.calefactor_encendido:
            # Hace calor -> apagar calefactor
            self.enviar_comando("apagar")
            self.calefactor_encendido = False
            print(
                f"❄️  COMANDO: Apagar calefactor (Temp: {temperatura_actual}°C > {temp_max}°C)")

        else:
            print(
                f"✅ Temperatura OK: {temperatura_actual}°C (objetivo: {self.temperatura_objetivo}°C)")

    def enviar_comando(self, accion):
        """Envía comando al calefactor"""
        comando = {
            "timestamp": datetime.now().isoformat(),
            "accion": accion,
            "controlador_id": "ctrl_001"
        }

        mensaje = json.dumps(comando)
        self.client.publish(TOPIC_CALEFACTOR_COMANDO, mensaje, qos=1)

    def ejecutar(self):
        """Ejecuta el controlador continuamente"""
        try:
            self.client.connect(BROKER_HOST, BROKER_PORT, 60)
            print("🚀 Iniciando controlador de temperatura...")
            print(
                f"🎯 Temperatura objetivo: {self.temperatura_objetivo}°C ± {self.margen}°C")
            print("⏹️  Presiona Ctrl+C para detener\n")

            self.client.loop_forever()

        except KeyboardInterrupt:
            print("\n🛑 Deteniendo controlador...")
        except Exception as e:
            print(f"❌ Error: {e}")
        finally:
            self.client.disconnect()

# =============================================================================
# 3. ACTUADOR CALEFACTOR SIMULADO (SUBSCRIPTOR)
# =============================================================================


class CalefactorSimulado:
    def __init__(self):
        self.client = mqtt.Client(client_id="calefactor_001")
        self.client.username_pw_set(USERNAME, PASSWORD)

        # Configuración TLS
        context = ssl.create_default_context(ssl.Purpose.SERVER_AUTH)
        self.client.tls_set_context(context)

        # Callbacks
        self.client.on_connect = self.on_connect
        self.client.on_message = self.on_message

        # Estado del calefactor
        self.encendido = False
        self.potencia = 0  # 0-100%

    def on_connect(self, client, userdata, flags, rc):
        if rc == 0:
            print("✅ Calefactor conectado al broker MQTT")
            # Suscribirse a comandos
            client.subscribe(TOPIC_CALEFACTOR_COMANDO, qos=1)
            print(f"📥 Suscrito a: {TOPIC_CALEFACTOR_COMANDO}")
        else:
            print(f"❌ Error de conexión: {rc}")

    def on_message(self, client, userdata, msg):
        """Procesa comandos recibidos"""
        try:
            comando = json.loads(msg.payload.decode())
            accion = comando['accion']
            timestamp = comando['timestamp']

            print(f"📨 Comando recibido: {accion} a las {timestamp}")

            # Ejecutar comando
            self.ejecutar_comando(accion)

        except Exception as e:
            print(f"❌ Error procesando comando: {e}")

    def ejecutar_comando(self, accion):
        """Ejecuta el comando en el calefactor"""
        if accion == "encender":
            self.encendido = True
            self.potencia = random.randint(70, 85)  # Potencia aleatoria
            print(f"🔥 CALEFACTOR ENCENDIDO - Potencia: {self.potencia}%")

        elif accion == "apagar":
            self.encendido = False
            self.potencia = 0
            print(f"❄️  CALEFACTOR APAGADO")

        # Reportar estado
        self.reportar_estado()

    def reportar_estado(self):
        """Reporta el estado actual del calefactor"""
        estado = {
            "timestamp": datetime.now().isoformat(),
            "encendido": self.encendido,
            "potencia": self.potencia,
            "dispositivo_id": "calefactor_001"
        }

        mensaje = json.dumps(estado)
        self.client.publish(TOPIC_CALEFACTOR_ESTADO, mensaje, qos=1)
        print(f"📤 Estado reportado: {estado}")

    def ejecutar(self):
        """Ejecuta el calefactor continuamente"""
        try:
            self.client.connect(BROKER_HOST, BROKER_PORT, 60)
            print("🚀 Iniciando calefactor simulado...")
            print("⏹️  Presiona Ctrl+C para detener\n")

            self.client.loop_forever()

        except KeyboardInterrupt:
            print("\n🛑 Deteniendo calefactor...")
        except Exception as e:
            print(f"❌ Error: {e}")
        finally:
            self.client.disconnect()

# =============================================================================
# 4. SCRIPT PRINCIPAL PARA EJECUTAR
# =============================================================================


if __name__ == "__main__":
    print("🏠 Sistema de Control de Temperatura IoT")
    print("=" * 50)
    print("1. Sensor de temperatura")
    print("2. Controlador automático")
    print("3. Calefactor simulado")
    print("=" * 50)

    opcion = input("Selecciona componente (1/2/3): ")

    if opcion == "1":
        sensor = SensorTemperatura()
        sensor.ejecutar()
    elif opcion == "2":
        controlador = ControladorTemperatura()
        controlador.ejecutar()
    elif opcion == "3":
        calefactor = CalefactorSimulado()
        calefactor.ejecutar()
    else:
        print("❌ Opción inválida")
