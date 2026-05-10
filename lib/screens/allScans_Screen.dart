import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'monitor_screen.dart';
import 'scan_screen.dart';
import 'TrackingScreen.dart';

class AllScansScreen extends StatefulWidget {
  @override
  _AllScansScreenState createState() => _AllScansScreenState();
}

class _AllScansScreenState extends State<AllScansScreen> {
  final supabase = Supabase.instance.client;

  Future<List<dynamic>> getScans() async {
    final user = supabase.auth.currentUser;

    final data = await supabase
        .from('scans')
        .select()
        .eq('userid', user!.id)
        .order('date', ascending: false);

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Scans")),

      body: FutureBuilder(
        future: getScans(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading scans"));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No data found"));
          }

          final scans = snapshot.data as List;

          // 🔴 Empty State
          if (scans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image_not_supported,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text(
                    "No scans yet",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text("Start by scanning your skin"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ScanScreen()),
                      );
                    },
                    child: const Text("Go to Scan"),
                  ),
                ],
              ),
            );
          }

          // ✅ Grid
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75, // 🔥 يخلي الكارد أطول
            ),
            itemCount: scans.length,
            itemBuilder: (context, index) {
              final scan = scans[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MonitorScreen(oldScan: scan),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // 🖼️ Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            scan['image_url'],
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // 🧾 Prediction + Date
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                scan['prediction'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 2),

                              Text(
                                scan['date'] != null
                                    ? scan['date'].toString().substring(0, 10)
                                    : "No date",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // 🔘 Buttons
                        Row(
                          children: [

                            Expanded(
                              child: SizedBox(
                                height: 35,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            MonitorScreen(oldScan: scan),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Monitor",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 5),

                            Expanded(
                              child: SizedBox(
                                height: 35,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            TrackingScreen(scan: scan),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Tracking",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}