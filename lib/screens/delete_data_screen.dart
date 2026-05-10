import 'package:flutter/material.dart';
import 'delete_items_screen.dart';

class DeleteDataScreen extends StatefulWidget {
  const DeleteDataScreen({super.key});

  @override
  State<DeleteDataScreen> createState() =>
      _DeleteDataScreenState();
}

class _DeleteDataScreenState
    extends State<DeleteDataScreen> {

  bool scans = false;
  bool monitors = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      appBar: AppBar(
        title: const Text("Delete My Data"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
              ),

              child: const Column(
                children: [

                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 60,
                  ),

                  SizedBox(height: 15),

                  Text(
                    "Warning",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Deleting your data will permanently remove your scans and monitoring history.",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            CheckboxListTile(
              value: scans,
              onChanged: (v) {
                setState(() {
                  scans = v!;
                });
              },
              title: const Text("Delete Scans"),
            ),

            CheckboxListTile(
              value: monitors,
              onChanged: (v) {
                setState(() {
                  monitors = v!;
                });
              },
              title: const Text("Delete Monitors"),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),

                onPressed: () {

                  if (scans) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const DeleteItemsScreen(
                              table: 'scans',
                            ),
                      ),
                    );
                  }

                  else if (monitors) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const DeleteItemsScreen(
                              table: 'monitors',
                            ),
                      ),
                    );
                  }
                },

                child: const Text(
                  "Continue",
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