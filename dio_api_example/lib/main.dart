import 'package:flutter/material.dart';
import 'screens/posts_screen.dart';
import 'services/api_service.dart';

void main() {
  // Inicializar el servicio API
  ApiService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dio API Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PostsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
