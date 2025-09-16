import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ErrorPage extends StatelessWidget {
  final String errorMsg;
  const ErrorPage({required this.errorMsg, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Erro')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMsg, style: TextStyle(color: Colors.red)),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Modular.to.navigate('/'),
              child: Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
