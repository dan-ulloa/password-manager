import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bienvenido a Granatum")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Para comenzar a guardar tus contraseñas necesitas primero crear una llave maestra",
            ),
            TextField(
              controller: _controller,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Llave maestra"),
            ),
            ElevatedButton(
              onPressed: () => {},
              child: const Text("Crear llave maestra"),
            ),
          ],
        ),
      ),
    );
  }
}
