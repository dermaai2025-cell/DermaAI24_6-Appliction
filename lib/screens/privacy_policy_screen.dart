import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      appBar: AppBar(
        title: const Text("Privacy Policy"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: const [

              Text(
                "Your Privacy Matters",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 20),

              Text(
                "Derma AI is committed to protecting your personal information and medical scan data.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),

              SizedBox(height: 20),

              Text(
                "• Your uploaded skin images are securely stored.\n\n"
                "• We do not share your personal data with third parties.\n\n"
                "• Your scan results are private and visible only to you.\n\n"
                "• The AI analysis is for assistance purposes only and does not replace professional medical advice.\n\n"
                "• You can request deletion of your data at any time.",
                style: TextStyle(
                  fontSize: 15,
                  height: 1.8,
                ),
              ),

              SizedBox(height: 30),

              Text(
                "By using Derma AI, you agree to our privacy and data protection policies.",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}