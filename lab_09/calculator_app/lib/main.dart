import 'package:flutter/material.dart';
import 'calculator_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Nativa',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  String _result = '';
  bool _isLoading = false;

  Future<void> _performOperation(String operation) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final double a = double.parse(_firstController.text);
      final double b = double.parse(_secondController.text);
      double result;

      switch (operation) {
        case 'add':
          result = await CalculatorService.add(a, b);
          break;
        case 'subtract':
          result = await CalculatorService.subtract(a, b);
          break;
        case 'multiply':
          result = await CalculatorService.multiply(a, b);
          break;
        case 'divide':
          result = await CalculatorService.divide(a, b);
          break;
        default:
          throw Exception('Operación no válida');
      }

      setState(() {
        _result = 'Resultado: $result';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calculadora Nativa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _firstController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Primer número',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _secondController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Segundo número',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            if (_isLoading)
              CircularProgressIndicator()
            else
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _performOperation('add'),
                        child: Text('Sumar'),
                      ),
                      ElevatedButton(
                        onPressed: () => _performOperation('subtract'),
                        child: Text('Restar'),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _performOperation('multiply'),
                        child: Text('Multiplicar'),
                      ),
                      ElevatedButton(
                        onPressed: () => _performOperation('divide'),
                        child: Text('Dividir'),
                      ),
                    ],
                  ),
                ],
              ),
            SizedBox(height: 24),
            Text(
              _result,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _result.startsWith('Error') ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    super.dispose();
  }
}
