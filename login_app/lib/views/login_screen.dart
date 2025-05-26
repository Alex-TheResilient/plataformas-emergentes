import 'package:flutter/material.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginViewModel viewModel = LoginViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => viewModel.email = value,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            TextField(
              onChanged: (value) => viewModel.password = value,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (viewModel.validateCredentials()) {
                  final user = viewModel.getUser();
                  // Aquí podés hacer navegación o lógica con el user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bienvenido ${user.email}')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Credenciales inválidas')),
                  );
                }
              },
              child: Text('Ingresar'),
            ),
          ],
        ),
      ),
    );
  }
}
