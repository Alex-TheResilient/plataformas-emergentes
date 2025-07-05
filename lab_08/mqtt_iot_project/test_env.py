import os
from dotenv import load_dotenv

load_dotenv()

print("🔍 Verificando configuración:")
print(f"Host: {os.getenv('MQTT_BROKER_HOST')}")
print(f"Port: {os.getenv('MQTT_BROKER_PORT')}")
print(f"Username: {os.getenv('MQTT_USERNAME')}")
password = os.getenv('MQTT_PASSWORD')
print(f"Password: {'✅ Configurada' if password else '❌ Falta'}")
