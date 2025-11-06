import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:granatum/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:zxcvbn/zxcvbn.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _passwordConfirmationController.addListener(_onConfirmationChanged);

    final auth = context.read<AuthProvider>();
    auth.addListener(() {
      if (auth.authenticated) {
        context.go('/login');
      }
      if (auth.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(auth.error!)));
      }
    });
  }

  void _onPasswordChanged() {
    final text = _passwordController.text;
    if (text.isNotEmpty) {
      final passwordStrength = Zxcvbn().evaluate(text);

      print(text);
      print(passwordStrength.score);
    }
  }

  void _onConfirmationChanged() {
    if (_passwordController.text == _passwordConfirmationController.text) {
      print("SON IGUALES");
    } else {
      print("NO SON IGUALES");
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

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
            TextField(
              controller: _passwordConfirmationController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirmar llave maestra",
              ),
            ),
            Column(
              children: [
                Text("La llave debe contener"),
                Text("Al menos 12 caracteres"),
                Text("Al menos una mayúscula"),
                Text("Al menos una minúscula"),
                Text("Al menos un número"),
                Text("Al menos uno símbolo"),
              ],
            ),
            ElevatedButton(
              child: const Text("Crear llave maestra"),
              onPressed: () async {
                // Se vuelve a validar ya completa
                //await auth.signup(_passwordController.text);
              },
            ),
          ],
        ),
      ),
    );
  }
}
