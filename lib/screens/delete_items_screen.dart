import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteItemsScreen extends StatefulWidget {
  final String table;

  const DeleteItemsScreen({super.key, required this.table});

  @override
  State<DeleteItemsScreen> createState() => _DeleteItemsScreenState();
}

class _DeleteItemsScreenState extends State<DeleteItemsScreen> {
  final supabase = Supabase.instance.client;

  List<dynamic> items = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  /// LOAD ITEMS
  // Future<void> loadItems() async {

  //   final user = supabase.auth.currentUser;

  //   try {

  //     final data = await supabase
  //         .from(widget.table)
  //         .select()
  //         .eq('userid', user!.id)
  //         .order(
  //           'date',
  //           ascending: false,
  //         );

  //     setState(() {
  //       items = data;
  //       isLoading = false;
  //     });

  //   } catch (e) {

  //     setState(() {
  //       isLoading = false;
  //     });

  //     print(e);
  //   }
  // }

  Future<void> loadItems() async {
    final user = supabase.auth.currentUser;

    try {
      final data = await supabase
          .from(widget.table)
          .select()
          .eq('userid', user!.id)
          .order('date', ascending: false);

      /// FILTER INVALID DATA
      final validItems = data.where((item) {
        if (widget.table == 'scans') {
          return item['image_url'] != null &&
              item['prediction'] != null &&
              item['date'] != null;
        }

        if (widget.table == 'monitors') {
          return item['newimageurl'] != null &&
              item['severity_after'] != null &&
              item['date'] != null;
        }

        return false;
      }).toList();

      setState(() {
        items = validItems;

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      print(e);
    }
  }

  /// DELETE ONE ITEM
  Future<void> deleteItem(dynamic item) async {
    try {
      /// DELETE SCAN IMAGE
      if (widget.table == 'scans') {
        final imageUrl = item['image_url'];

        if (imageUrl != null) {
          final path = imageUrl
              .toString()
              .split('/storage/v1/object/public/scans/')
              .last;

          await supabase.storage.from('scans').remove([path]);
        }
      }

      /// DELETE MONITOR IMAGE
      if (widget.table == 'monitors') {
        final imageUrl = item['newimageurl'];

        if (imageUrl != null) {
          final path = imageUrl
              .toString()
              .split('/storage/v1/object/public/monitors/')
              .last;

          await supabase.storage.from('monitors').remove([path]);
        }
      }

      /// DELETE DATABASE ROW
      await supabase.from(widget.table).delete().eq('id', item['id']);

      await loadItems();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Deleted successfully")));
    } catch (e) {
      print(e);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  /// DELETE ALL
  Future<void> deleteAll() async {
    final user = supabase.auth.currentUser;

    try {
      final data = await supabase
          .from(widget.table)
          .select()
          .eq('userid', user!.id);

      /// DELETE STORAGE IMAGES
      for (var item in data) {
        /// SCANS
        if (widget.table == 'scans') {
          final imageUrl = item['image_url'];

          if (imageUrl != null) {
            final path = imageUrl
                .toString()
                .split('/storage/v1/object/public/scans/')
                .last;

            await supabase.storage.from('scans').remove([path]);
          }
        }

        /// MONITORS
        if (widget.table == 'monitors') {
          final imageUrl = item['newimageurl'];

          if (imageUrl != null) {
            final path = imageUrl
                .toString()
                .split('/storage/v1/object/public/monitors/')
                .last;

            await supabase.storage.from('monitors').remove([path]);
          }
        }
      }

      /// DELETE DATABASE ROWS
      await supabase.from(widget.table).delete().eq('userid', user.id);

      setState(() {
        items.clear();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All data deleted")));
    } catch (e) {
      print(e);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      appBar: AppBar(
        title: Text("Delete ${widget.table}"),
        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),

            onPressed: () {
              showDialog(
                context: context,

                builder: (_) => AlertDialog(
                  title: const Text("Delete All"),

                  content: const Text(
                    "Are you sure you want to delete all data?",
                  ),

                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      child: const Text("Cancel"),
                    ),

                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        await deleteAll();
                      },

                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(child: Text("No data found"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),

              itemCount: items.length,

              itemBuilder: (context, index) {
                final item = items[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(12),

                    child: Row(
                      children: [
                        /// IMAGE
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),

                          child: Image.network(
                            widget.table == 'scans'
                                ? item['image_url']
                                : item['newimageurl'],

                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 15),

                        /// TEXT
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                widget.table == 'scans'
                                    ? item['prediction']
                                    : item['severity_after'],

                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                item['date'].toString().substring(0, 10),

                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),

                        /// DELETE BUTTON
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),

                          onPressed: () {
                            showDialog(
                              context: context,

                              builder: (_) => AlertDialog(
                                title: const Text("Delete Item"),

                                content: const Text(
                                  "Are you sure you want to delete this item?",
                                ),

                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },

                                    child: const Text("Cancel"),
                                  ),

                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);

                                      await deleteItem(item);
                                    },

                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
