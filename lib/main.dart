import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/ResetPasswod_Screen.dart';
import 'screens/home_screen.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    debugPrint(" .env loaded successfully");
  } catch (e) {
    debugPrint("Error loading .env file: $e");
  }
  

    await Supabase.initialize(
    url: 'https://fqswccltpvgyfqqlmbyt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxc3djY2x0cHZneWZxcWxtYnl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYxOTY5MzEsImV4cCI6MjA5MTc3MjkzMX0.g9jJ4OwNSseAXxql1X50QRibMEhSlMUk_oDmZ3d_MVQ',
  );
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
  final event = data.event;

if (event == AuthChangeEvent.signedIn) {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }
  if (event == AuthChangeEvent.passwordRecovery) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => const ResetPasswordScreen(),
      ),
    );
    }
    });

  runApp(const DermaAIApp());
}


 final GlobalKey<NavigatorState> navigatorKey =
     GlobalKey<NavigatorState>();

class DermaAIApp extends StatefulWidget {
  const DermaAIApp({super.key});

  @override
  State<DermaAIApp> createState() => _DermaAIAppState();
}

class _DermaAIAppState extends State<DermaAIApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();

    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        print("🔗 Incoming link: $uri");

        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => const ResetPasswordScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 👈 هنا
      title: 'DermaAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0056D2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0056D2),
          primary: const Color(0xFF0056D2),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}