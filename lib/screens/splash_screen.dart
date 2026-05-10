import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  // Medical Theme Colors
  final Color primaryBlue = const Color(0xFF0056D2);
  final Color dermaTeal = const Color(0xff5F9EA0); // Your specific AI color

  @override
  void initState() {
    super.initState();

    // 1. Setup Smooth Fade Animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // 2. Navigation Logic
    _handleNavigation();
  }

  void _handleNavigation() async {
  await Future.delayed(const Duration(milliseconds: 3500));

  final user = Supabase.instance.client.auth.currentUser;

  if (!mounted) return;

  if (user != null) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Professional clean background
      body: Stack(
        children: [
          // Background Aesthetic (Optional: Subtle gradient or very light image)
          Positioned.fill(
            child: Opacity(
              opacity: 0.05, // Make it very subtle so it doesn't distract from the logo
              child: Image.asset(
                "assets/splash_capsules.jpeg",
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Central Branding
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon/Logo Container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.health_and_safety, size: 80, color: primaryBlue),
                  ),
                  const SizedBox(height: 25),

                  // Branded Text (DermaAI)
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2
                      ),
                      children: [
                        const TextSpan(
                          text: "Derma",
                          style: TextStyle(color: Color(0xFF1E293B)),
                        ),
                        TextSpan(
                          text: "AI",
                          style: TextStyle(color: dermaTeal),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Advanced Skin Analysis System",
                    style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Loading & Versioning
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0056D2)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "v1.0.2 - SwinV2 Optimized",
                  style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 11,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}