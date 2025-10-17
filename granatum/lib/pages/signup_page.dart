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
    // Clean up the controller when the widget is disposed.
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
    // Aquí validas en tiempo real:
    // 1. Longitud mínima
    // 2. Mayúsculas
    // 3. Números
    // 4. Símbolos
    // Y actualizas un indicador visual.
    print(text);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

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
