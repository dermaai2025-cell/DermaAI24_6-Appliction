import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class MonitorScreen extends StatefulWidget {
  final Map oldScan;

  const MonitorScreen({super.key, required this.oldScan});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  File? newImage;
  String result = "";
  bool isLoading = false;

  final picker = ImagePicker();
  final supabase = Supabase.instance.client;

  // 📷 Capture
  Future pickFromCamera() async {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => newImage = File(picked.path));
    }
  }

  // 🖼 Upload
  Future pickFromGallery() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => newImage = File(picked.path));
    }
  }

  String safeText(dynamic value) {
    if (value == null) return "Unknown error";

    if (value is String) return value;

    if (value is Map) {
      return value['message']?.toString() ??
          value['error']?.toString() ??
          value.toString();
    }

    return value.toString();
  }

  // 🔥 MAIN FUNCTION
  // Future processMonitor() async {
  //   if (newImage == null) {
  //     setState(() => result = "Please select image first");
  //     return;
  //   }

  //   setState(() => isLoading = true);

  //   try {
  //     final user = supabase.auth.currentUser;

  //     if (user == null) {
  //       setState(() => result = "User not logged in");
  //       return;
  //     }

  //     // 🔥 1) Upload new image
  //     final fileName =
  //         "${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg";

  //     await supabase.storage.from('Images').upload(fileName, newImage!);

  //     final newImageUrl = supabase.storage
  //         .from('Images')
  //         .getPublicUrl(fileName);

  //     // 🤖 2) Call compare API (JSON)
  //       const url = "https://lomi21lomi-Test-Seg.hf.space/compare";
  //     // const url = "https://rf3t-skin-disease-backend.hf.space/compare";

  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({
  //         "old_url": widget.oldScan['image_url'],
  //         "new_url": newImageUrl,
  //       }),
  //     );

  //     Map<String, dynamic> data = {};

  //     try {
  //       data = jsonDecode(response.body);
  //     } catch (e) {
  //       setState(() {
  //         result = "Invalid server response";
  //       });
  //       return;
  //     }
  //     if (data['status'] == 'error') {
  //       // ❌ delete uploaded image
  //       await supabase.storage.from('Images').remove([fileName]);
  //       setState(() {
  //         // result = safeText(data['detail'] ?? data['message'] ?? data['error']);
  //         result = safeText(data['message']);
  //       });
  //       return;
  //     }

  //     // 💾 3) Save to DB
  //     await supabase.from('monitors').insert({
  //       'userid': user.id,
  //       'scanid': widget.oldScan['id'],
  //       'oldimageurl': widget.oldScan['image_url'],
  //       'newimageurl': newImageUrl,
  //       'similarity': data['similarity'],
  //       'severity_before': data['severity_before'],
  //       'severity_after': data['severity_after'],
  //       'result': data['result'],
  //       'date': DateTime.now().toIso8601String(),
  //     });

  //     // ✅ Show result
  //     setState(() {
  //       if (response.statusCode == 200 && data.containsKey('similarity')) {
  //         result =
  //             "Result: ${safeText(data['result'])}\nSimilarity: ${data['similarity']}";
  //       } else {
  //         result = result = safeText(
  //           data['detail'] ?? data['message'] ?? data['error'],
  //         );
  //       }
  //     });
  //   } catch (e) {
  //     setState(() => result = "Error: $e");
  //   }

  //   setState(() => isLoading = false);
  // }

  Future processMonitor() async {
    if (newImage == null) {
      setState(() => result = "Please select image first");
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() => result = "User not logged in");
        return;
      }

      final fileName =
          "${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg";

      await supabase.storage.from('Images').upload(fileName, newImage!);

      final newImageUrl = supabase.storage
          .from('Images')
          .getPublicUrl(fileName);

      const url = "https://lomi21lomi-Monitor.hf.space/compare";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "old_url": widget.oldScan['image_url'],
          "new_url": newImageUrl,
        }),
      );

      Map<String, dynamic> data = {};

      try {
        data = jsonDecode(response.body);
      } catch (e) {
        setState(() {
          result = "Invalid server response";
        });
        return;
      }

      if (data['status'] == 'error') {
        await supabase.storage.from('Images').remove([fileName]);

        setState(() {
          result = safeText(data['message']);
        });

        return;
      }

      await supabase.from('monitors').insert({
        'userid': user.id,
        'scanid': widget.oldScan['id'],
        'oldimageurl': widget.oldScan['image_url'],
        'newimageurl': newImageUrl,
        'similarity': data['similarity'],
        'severity_before': data['severity_before'],
        'severity_after': data['severity_after'],
        'result': data['result'],
        'date': DateTime.now().toIso8601String(),
      });

      setState(() {
        if (response.statusCode == 200 && data.containsKey('similarity')) {
          result =
              "Result: ${safeText(data['result'])}\nSimilarity: ${data['similarity']}";
        } else {
          result = safeText(data['detail'] ?? data['message'] ?? data['error']);
        }
      });
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Monitor")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🟤 OLD IMAGE
            const Text(
              "Previous Scan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Image.network(widget.oldScan['image_url'], height: 150),

            const SizedBox(height: 10),

            Text("Disease: ${widget.oldScan['prediction']}"),

            const SizedBox(height: 20),

            // 🆕 NEW IMAGE
            const Text(
              "New Image",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            newImage != null
                ? Image.file(newImage!, height: 150)
                : const Text("No image selected"),

            const SizedBox(height: 20),

            // 🎯 BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pickFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Capture"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pickFromGallery,
                    icon: const Icon(Icons.image),
                    label: const Text("Upload"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔍 COMPARE BUTTON
            ElevatedButton(
              onPressed: isLoading ? null : processMonitor,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Compare"),
            ),

            const SizedBox(height: 30),

            // 📊 RESULT
            Text(
              result,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
