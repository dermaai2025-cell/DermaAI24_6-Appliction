import 'package:flutter/material.dart';

class AIDisclaimerScreen extends StatelessWidget {
  const AIDisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      appBar: AppBar(
        title: const Text("AI Disclaimer"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [

            Icon(
              Icons.info_outline,
              size: 70,
              color: Colors.orange,
            ),

            SizedBox(height: 20),

            Text(
              "Medical Disclaimer",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            Text(
              "Derma AI provides AI-assisted skin analysis for informational purposes only.",
              style: TextStyle(fontSize: 16, height: 1.7),
            ),

            SizedBox(height: 20),

            Text(
              "The application is not a replacement for professional medical diagnosis or treatment.",
              style: TextStyle(fontSize: 16, height: 1.7),
            ),

            SizedBox(height: 20),

            Text(
              "Always consult a dermatologist or healthcare professional for accurate medical advice.",
              style: TextStyle(fontSize: 16, height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}