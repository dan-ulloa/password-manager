import 'package:flutter/material.dart';
import 'package:granatum/pages/signup_page.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'services/key_service.dart';
import 'services/crypto_service.dart';
import 'repositories/password_repository.dart';
import 'providers/database_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/vault_provider.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*
  final keyService = KeyService();
  final cryptoService = CryptoService(keyService);
  final dbProvider = DatabaseProvider(keyService);
  */
  runApp(
    MultiProvider(
      providers: [
        // Servicios pre-creados
        Provider(create: (_) => KeyService()),
        ProxyProvider<KeyService, DatabaseProvider>(
          update: (_, keyService, __) => DatabaseProvider(keyService),
        ),
        /*ProxyProvider<KeyService, CryptoService>(
          update: (_, keyService, cryptoService) => CryptoService(keyService),
        ),
        */
        //Provider<CryptoService>.value(value: cryptoService),
        //Provider<KeyService>.value(value: keyService),
        //Provider<DatabaseProvider>.value(value: dbProvider),
        /*
        ProxyProvider<DatabaseProvider, PasswordRepository>(
          update: (_, databaseProvider, __) =>
              PasswordRepository(databaseProvider),
        ),
        ChangeNotifierProxyProvider2<PasswordRepository, CryptoService, VaultProvider>(
          create: (_) => VaultProvider(),
          update: (_, repo, crypto, provider) => provider!..setDependencies(repo, crypto),
        ),
        */
        // ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkIfRegistered(context) async {
    final _dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
    // Queda pendiente validar con el AuthService que exista la salt id
    return await _dbProvider.dbExists();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<bool>(
        future: _checkIfRegistered(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          /*
          if (snapshot.hasError) {
            return ErrorPage(error: snapshot.error.toString());
          }
          */
          final registered = snapshot.data ?? false;
          return registered ? LoginPage() : SignUpPage();
        },
      ),
    );
  }
}
