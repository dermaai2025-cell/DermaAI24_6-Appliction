import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'monitor_screen.dart';

class TrackingScreen extends StatefulWidget {
  final Map scan;

  const TrackingScreen({super.key, required this.scan});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final supabase = Supabase.instance.client;

  Future<List<dynamic>> getTracking() async {
    final data = await supabase
        .from('monitors')
        .select()
        .eq('scanid', widget.scan['id'])
        .order('date', ascending: false);

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tracking History")),

      body: FutureBuilder(
        future: getTracking(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Error loading data"));
          }

          final tracks = snapshot.data as List;

          // 🔴 EMPTY STATE
          if (tracks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Icon(Icons.timeline, size: 80, color: Colors.grey),
                  const SizedBox(height: 10),

                  const Text(
                    "No tracking yet",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  const Text("Start monitoring your condition"),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MonitorScreen(
                            oldScan: widget.scan,
                          ),
                        ),
                      );
                    },
                    child: const Text("Start Monitoring"),
                  ),
                ],
              ),
            );
          }

          // ✅ لو فيه tracking
          return ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final t = tracks[index];

    return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // 🖼 IMAGE SAFE
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15)),
                      child: (t['newimageurl'] != null)
                          ? Image.network(
                              t['newimageurl'],
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                height: 180,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image),
                              ),
                            )
                          : Container(
                              height: 180,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image),
                            ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            "Result: ${t['result'] ?? 'N/A'}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text("Similarity: ${t['similarity'] ?? '-'}"),
                          Text("Before: ${t['severity_before'] ?? '-'}"),
                          Text("After: ${t['severity_after'] ?? '-'}"),

                          const SizedBox(height: 5),

                          Text(
                            "Date: ${t['date']?.toString().substring(0, 10) ?? ''}",
                            style: const TextStyle(color: Colors.grey),
                          ),
          ],
        ),
      ),
    ],
  ),
);
            },
          );
        },
      ),
    );
  }
}