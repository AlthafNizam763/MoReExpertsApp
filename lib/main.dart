import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/provider/auth_provider.dart';
import 'features/chat/presentation/providers/chat_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Environment Variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MoreExpertsApp(),
    ),
  );
}

class MoreExpertsApp extends StatelessWidget {
  const MoreExpertsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoreExperts',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          switch (auth.status) {
            case AuthStatus.authenticated:
              return const HomePage();
            case AuthStatus.initial:
            case AuthStatus.unauthenticated:
            default:
              return const LoginPage();
          }
        },
      ),
    );
  }
}
