import React, { useState } from 'react';
import {
  SafeAreaView,
  TextInput,
  Button,
  View,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  Text,
} from 'react-native';

const App: React.FC = () => {
  const [numero, setNumero] = useState<string>('');
  const [monto, setMonto] = useState<string>('');
  const [mensaje, setMensaje] = useState<string>('');

  const enviar = () => {
    console.log('Datos enviados:', {
      numero,
      monto,
      mensaje,
    });
    // Aquí podrías agregar lógica para enviar a una API o guardar localmente
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        style={styles.container}
      >
        <Text style={styles.titulo}>Plataformas Emergentes</Text>

        <TextInput
          style={styles.input}
          placeholder="Número"
          keyboardType="phone-pad"
          value={numero}
          onChangeText={setNumero}
        />
        <TextInput
          style={styles.input}
          placeholder="Monto S/"
          keyboardType="decimal-pad"
          value={monto}
          onChangeText={setMonto}
        />
        <TextInput
          style={styles.input}
          placeholder="Mensaje (opcional)"
          value={mensaje}
          onChangeText={setMensaje}
        />

        <View style={styles.buttonContainer}>
          <Button title="ENVIAR" onPress={enviar} color="#225C78" />
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#ffffff',
  },
  container: {
    flex: 1,
    justifyContent: 'center',
    paddingHorizontal: 30,
  },
  titulo: {
    fontSize: 24,
    marginBottom: 30,
    color: '#225C78',
    fontWeight: 'bold',
    textAlign: 'center',
  },
  input: {
    height: 50,
    borderColor: '#225C78',
    borderWidth: 1,
    borderRadius: 12,
    paddingHorizontal: 15,
    marginBottom: 20,
    fontSize: 16,
  },
  buttonContainer: {
    marginTop: 10,
    borderRadius: 12,
    overflow: 'hidden',
  },
});

export default App;
