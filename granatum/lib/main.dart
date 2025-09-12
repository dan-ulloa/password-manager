import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/key_service.dart';
import 'services/crypto_service.dart';
import 'repositories/password_repository.dart';
import 'providers/database_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/vault_provider.dart';
import 'pages/login_page.dart';

void main() {
  runApp(MultiProvider(
    providers: [
        Provider<KeyService>(create: (_) => KeyService()),
        
        ProxyProvider<KeyService, CryptoService>(
          update: (_, keyService, __) => CryptoService(keyService),
        ),
        
         ProxyProvider<KeyService, DatabaseProvider>(
          update: (_, keyService, __) => DatabaseProvider(keyService),
        ),
        
        ProxyProvider2<DatabaseProvider, CryptoService, PasswordRepository>(
          update: (_, databaseProvider, cryptoService, __) =>
              PasswordRepository(databaseProvider, cryptoService),
        ),

        ChangeNotifierProxyProvider<PasswordRepository, VaultProvider>(
          create: (_) => VaultProvider(),
          update: (_, repo, provider) => provider!..setRepository(repo),
        ),

        ChangeNotifierProvider(create: (_) => AuthProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
