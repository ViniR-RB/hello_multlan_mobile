import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'E-mail',
            ),
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
          ),

          ElevatedButton(onPressed: () {}, child: Text("Login")),
        ],
      ),
    );
  }
}
