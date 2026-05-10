import 'package:flutter/material.dart';

class FAQsScreen extends StatelessWidget {
  const FAQsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      appBar: AppBar(
        title: const Text("FAQs"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

       body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [

          ExpansionTile(
            title: Text("How do I scan my skin?"),
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "Open the camera and take a clear picture of the affected skin area.",
                ),
              ),
            ],
          ),

          ExpansionTile(
            title: Text("Is the AI diagnosis accurate?"),
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "Derma AI provides AI-assisted predictions but should not replace professional medical advice.",
                ),
              ),
            ],
          ),

           ExpansionTile(
            title: Text("Can I save my scan history?"),
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "Yes, your previous scans are saved in your account unless you delete them.",
                ),
              ),
            ],
          ),

          ExpansionTile(
            title: Text("Can I delete my account data?"),
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "Yes, you can permanently delete your data from the Privacy & Security section.",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

