import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:granatum/pages/home_page.dart';
import 'package:granatum/pages/signup_page.dart';
import 'package:granatum/providers/vault_provider.dart';
import 'package:granatum/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'services/key_service.dart';
import 'services/crypto_service.dart';
import 'repositories/password_repository.dart';
import 'providers/database_provider.dart';
import 'providers/auth_provider.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyService = KeyService();
  final secureStorage = const FlutterSecureStorage();
  final dbProvider = DatabaseProvider();
  final cryptoService = new CryptoService();
  final authService = AuthService(
    keyService,
    dbProvider,
    cryptoService,
    secureStorage,
  );
  final passwordRepository = new PasswordRepository(dbProvider);

  runApp(
    MultiProvider(
      providers: [
        Provider<KeyService>.value(value: keyService),
        Provider<FlutterSecureStorage>.value(value: secureStorage),
        Provider<DatabaseProvider>.value(value: dbProvider),
        Provider<AuthService>.value(value: authService),
        Provider<PasswordRepository>.value(value: passwordRepository),
        Provider<CryptoService>.value(value: cryptoService),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProxyProvider2<
          PasswordRepository,
          CryptoService,
          VaultProvider
        >(
          create: (_) => VaultProvider(),
          update: (_, repo, crypto, provider) =>
              provider!..setDependencies(repo, crypto),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// The route configuration.
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(path: '/login', builder: (_, __) => LoginPage()),
    GoRoute(path: '/signup', builder: (_, __) => SignUpPage()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Password Manager',
      routerConfig: _router,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
