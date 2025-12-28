import 'package:flutter/material.dart';
import 'package:granatum/old/pages/login_page.dart';
import 'package:granatum/old/pages/signup_page.dart';
import 'package:granatum/old/services/auth_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return FutureBuilder<AuthInitState>(
      future: authService.checkInitialState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Placeholder(color: Colors.red);
          //return ErrorPage(error: snapshot.error.toString());
        }

        if (snapshot.data == AuthInitState.firstRun) {
          return SignUpPage();
        }

        if (snapshot.data == AuthInitState.inconsistent) {
          // Borra BD y secure storage,
          return Placeholder(color: Colors.orange);
        }
        return LoginPage();
      },
    );
  }
}
