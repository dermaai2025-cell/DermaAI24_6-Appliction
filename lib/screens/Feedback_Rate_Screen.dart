import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackRateScreen extends StatefulWidget {
  const FeedbackRateScreen({super.key});

  @override
  State<FeedbackRateScreen> createState() =>
      _FeedbackRateScreenState();
}

class _FeedbackRateScreenState extends State<FeedbackRateScreen> {
  int selectedStars = 0;

  final TextEditingController feedbackController =
      TextEditingController();

  bool isLoading = false;

  Future<void> submitFeedback() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (selectedStars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select rating")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await Supabase.instance.client.from('feedback').insert({
        'user_id': user?.id,
        'rating': selectedStars,
        'message': feedbackController.text.trim(),
        'app_version': '1.0.0',
        'device': 'flutter',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thanks for your feedback ❤️")),
      );

      feedbackController.clear();

      setState(() {
        selectedStars = 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      appBar: AppBar(
        title: const Text("Feedback & Rate"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 40),

            const Icon(
              Icons.star,
              size: 90,
              color: Colors.amber,
            ),

            const SizedBox(height: 20),

            const Text(
              "Rate Your Experience",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            /// ⭐ Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      selectedStars = index + 1;
                    });
                  },
                  icon: Icon(
                    Icons.star,
                    size: 40,
                    color: selectedStars > index
                        ? Colors.amber
                        : Colors.grey,
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),

            /// 💬 Feedback input
            TextField(
              controller: feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Write your feedback here...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// 🔘 Submit Button
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                onPressed: isLoading ? null : submitFeedback,

                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Submit Feedback",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}