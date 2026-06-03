import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/app_theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/listing_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_shell.dart';

const bool kUseFirebaseAuth = bool.fromEnvironment('USE_FIREBASE_AUTH', defaultValue: false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kUseFirebaseAuth) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  runApp(const EcoShareApp());
}

class EcoShareApp extends StatelessWidget {
  const EcoShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiClient();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(api)..loadSession()),
        ChangeNotifierProxyProvider<AuthProvider, ListingProvider>(
          create: (_) => ListingProvider(api),
          update: (_, auth, provider) => provider!..setToken(auth.token),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EcoShare',
        theme: AppTheme.light,
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.booting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return auth.isLoggedIn ? const MainShell() : const LoginScreen();
          },
        ),
      ),
    );
  }
}
