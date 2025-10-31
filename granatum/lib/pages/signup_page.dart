import 'package:flutter/material.dart';
import 'package:granatum/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    final text = _passwordController.text;
    print(text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

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
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Llave maestra"),
            ),
            ElevatedButton(
              child: const Text("Crear llave maestra"),
              onPressed: () async {
                // Se vuelve a validar ya completa
                //await authProvider.signup(_passwordController.text);
              },
            ),
          ],
        ),
      ),
    );
  }
}
