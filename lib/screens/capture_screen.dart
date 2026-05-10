import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';


class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  File? _imageFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<String?> uploadImage(File imageFile) async {
  try {
    final user = Supabase.instance.client.auth.currentUser;

    final fileName =
        "${user!.id}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final bytes = await imageFile.readAsBytes();

    await Supabase.instance.client.storage
        .from('Images') // ✅ lowercase
        .uploadBinary(fileName, bytes);

    final imageUrl = Supabase.instance.client.storage
        .from('Images')
        .getPublicUrl(fileName);

    return imageUrl;
  } catch (e) {
    print("❌ Upload error: $e"); // مهم جدًا
    _showSnackBar("Image upload failed");
    return null;
  }
}

Future<void> saveScan({
  required String imageUrl,
  required String prediction,
  required double confidence,
}) async {
  try {
    final user = Supabase.instance.client.auth.currentUser;

    await Supabase.instance.client.from('scans').insert({
      'userid': user!.id,
      'image_url': imageUrl,
      'prediction': prediction,
      'confidence': confidence,
      'date': DateTime.now().toIso8601String(),
    });
  } catch (e) {
    _showSnackBar("Failed to save scan");
  }
}

  // Professional Medical Color Palette
  final Color primaryBlue = const Color(0xFF0056D2);
  final Color surfaceWhite = const Color(0xFFF8FAFC);

  // 📷 Capture image from camera
  Future<void> _captureImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 95,
    );

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  // 📤 Send image to AI Analysis Server
  Future<void> _analyzeImage() async {
    if (_imageFile == null) return;

    setState(() => _isLoading = true);

    const url = "https://rf3t-skin-disease-backend.hf.space/predict";

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));

      // Standard timeout for deep analysis
      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _handleServerResponse(data);
      } else {
        _showSnackBar("Service busy. Please try again in a moment.");
      }
    } catch (e) {
      _showSnackBar("Connection failed. Please check your internet.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

 void _handleServerResponse(Map<String, dynamic> data) async {
  String status = data['status'];

  if (status == "success") {
    final prediction = data['disease_name'];
    final confidence = double.parse(data['confidence'].toString());

    // 🔥 1. uplload image 
    final imageUrl = await uploadImage(_imageFile!);

    if (imageUrl != null) {
      // 🔥 2.  store in database
      await saveScan(
        imageUrl: imageUrl,
        prediction: prediction,
        confidence: confidence,
      );
    }

    // UI زي ما هو
    _showResultSheet(
      title: "Analysis Complete",
      disease: prediction,
      confidence: confidence.toString(),
      isError: false,
    );

  } else {
    _showResultSheet(
      title: status == "invalid" ? "Object Not Recognized" : "Uncertain Analysis",
      message: data['message'],
      suggestion: data['suggestion'],
      isError: true,
    );
  }
}

  void _showResultSheet({
    required String title,
    String? disease,
    String? confidence,
    String? message,
    String? suggestion,
    required bool isError,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isError ? Colors.orange[800] : primaryBlue
                )
            ),
            const Divider(height: 30),
            if (!isError) ...[
              Text("Detected Condition:", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 5),
              Text(disease!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text("AI Accuracy: $confidence%", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ),
            ] else ...[
              Text(message!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3))
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                          "Suggestion: $suggestion",
                          style: const TextStyle(color: Colors.black87, fontSize: 14)
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceWhite,
      appBar: AppBar(
        title: const Text("DermaAI Scanner", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Instruction Card
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.grey.shade200)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: primaryBlue),
                            const SizedBox(width: 10),
                            const Text("Capture Guidelines", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildStep("Hold camera 10-15cm from skin"),
                        _buildStep("Ensure bright, natural lighting"),
                        _buildStep("Center the area in the frame"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Image Preview Area
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(_imageFile!, fit: BoxFit.cover)
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 10),
                      Text("No Image Captured", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: primaryBlue)
                        ),
                        onPressed: _captureImage,
                        icon: Icon(Icons.camera_alt, color: primaryBlue),
                        label: Text("Take Picture", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        onPressed: (_imageFile == null || _isLoading) ? null : _analyzeImage,
                        child: const Text("Analyze Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Professional Loading Overlay (Updated Text)
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: Center(
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(35),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: primaryBlue),
                        const SizedBox(height: 25),
                        const Text("AI Health Analysis", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 5),
                        Text("Analyzing skin features...", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: Colors.green),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }
}