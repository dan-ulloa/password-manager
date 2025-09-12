import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'vault_page.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: AppBar(title: const Text("Password Manager")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Master Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final provider = context.read<AuthProvider>();
                await provider.login(_controller.text);
                if (provider.authenticated) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VaultPage()));
                }
              },
              child: const Text("Login"),
            ),
            ElevatedButton(
              onPressed: () async {
                final provider = context.read<AuthProvider>();
                await provider.register(_controller.text);
                if (provider.authenticated) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VaultPage()));
                }
              },
              child: const Text("Register"),
            ),
            ElevatedButton(
              onPressed: () async {
                final provider = context.read<AuthProvider>();
                await provider.loginBiometric();
                if (provider.authenticated) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VaultPage()));
                }
              },
              child: const Text("Login Biometric"),
            ),
          ],
        ),
      ),
    );
  }
}
