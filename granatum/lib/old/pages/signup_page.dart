import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:granatum/old/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:zxcvbn/zxcvbn.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _pwdController = TextEditingController();
  final _pwdConfirmationController = TextEditingController();

  @override
  void dispose() {
    _pwdController.dispose();
    _pwdConfirmationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pwdController.addListener(_onPasswordChanged);
    _pwdConfirmationController.addListener(_onConfirmationChanged);

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
    final text = _pwdController.text;
    if (text.isNotEmpty) {
      if (text.length < 12) {
        // Debe tener al menos 12 caracteres
        print('Debe tener al menos 12 caracteres');
      } else {
        print('YA CUMPLE LONGITUD');
      }

      // validar con REGEXP
      // Mayusculas
      var mayusRegExp = RegExp(r'(?=.*[A-Z])');
      if (!mayusRegExp.hasMatch(text)) {
        print('Debe tener al menos una mayuscula');
      } else {
        print('YA CUMPLE MAYUSCULA');
      }

      // Minusculas
      var minusRegExp = RegExp(r'(?=.*[a-z])');
      if (!minusRegExp.hasMatch(text)) {
        print('Debe tener al menos una minuscula');
      } else {
        print('YA CUMPLE MINUSCULA');
      }

      // Numeros
      var numberRegExp = RegExp(r'(?=.*\d)');
      if (!numberRegExp.hasMatch(text)) {
        print('Debe tener al menos un numero');
      } else {
        print('YA CUMPLE NUMERO');
      }

      // Simbolos
      var symbolRegExp = RegExp(
        r'''(?=.*[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>/?`~]).+''',
      );
      if (!symbolRegExp.hasMatch(text)) {
        print('Debe tener al menos uno de caracter especial');
      } else {
        print('YA CUMPLE SIMBOLO');
      }

      final passwordStrength = Zxcvbn().evaluate(text);

      print(text);
      print(passwordStrength.score);
    }
  }

  void _onConfirmationChanged() {
    if (_pwdController.text == _pwdConfirmationController.text) {
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
              controller: _pwdController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Llave maestra"),
            ),
            TextField(
              controller: _pwdConfirmationController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirmar llave maestra",
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: LinearProgressIndicator(
                    value: .20,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
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
