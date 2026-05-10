import 'package:flutter/material.dart';

class EmergencyAdviceScreen extends StatelessWidget {
  const EmergencyAdviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      appBar: AppBar(
        title: const Text("Emergency Advice"),
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
              Icons.local_hospital,
              size: 80,
              color: Colors.red,
            ),

            SizedBox(height: 20),

            Text(
              "Seek Medical Attention Immediately If:",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 25),

            Text(
              "• Your skin condition spreads rapidly.\n\n"
              "• You experience severe pain or bleeding.\n\n"
              "• You have fever with skin symptoms.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}