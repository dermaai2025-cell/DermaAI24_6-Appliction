import 'package:derma_ai/screens/capture_screen.dart';
import 'package:derma_ai/screens/upload_screen.dart';
import 'package:flutter/material.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  // Consistency Colors
  final Color primaryBlue = const Color(0xFF0056D2);
  final Color surfaceWhite = const Color(0xFFF8FAFC);
  final Color textDark = const Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceWhite,
      appBar: AppBar(
        title: const Text("Skin Analysis", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // 🛡️ Proper navigation
        ),
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Intro
            Text(
              "Start your diagnosis",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 8),
            Text(
              "Choose how you'd like to provide a photo for your AI skin analysis.",
              style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
            ),

            const SizedBox(height: 30),

            // Option 1: Live Camera Scan
            _buildSelectionCard(
              context,
              title: "Live Camera Scan",
              description: "Best for immediate results. Use your camera to capture a clear, well-lit photo of the lesion.",
              icon: Icons.camera_enhance_outlined,
              buttonText: "Open Camera",
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CaptureScreen())),
            ),

            const SizedBox(height: 20),

            // Option 2: Gallery Upload
            _buildSelectionCard(
              context,
              title: "Upload from Gallery",
              description: "Use a previously taken high-resolution photo from your device storage.",
              icon: Icons.photo_library_outlined,
              buttonText: "Open Gallery",
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadScreen())),
            ),

            const SizedBox(height: 40),

            // Pro-Tip Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: primaryBlue.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates_outlined, color: primaryBlue),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "Tip: For the highest accuracy, ensure the skin area is clean and free of shadows.",
                      style: TextStyle(fontSize: 13, color: primaryBlue, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(
      BuildContext context, {
        required String title,
        required String description,
        required IconData icon,
        required String buttonText,
        required VoidCallback onPressed,
      }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: primaryBlue, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}