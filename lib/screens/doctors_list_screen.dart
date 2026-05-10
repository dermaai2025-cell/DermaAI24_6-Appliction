import 'package:flutter/material.dart';
import 'doctor_data.dart';
import 'doctor_details.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  final TextEditingController _listSearchController = TextEditingController();
  final FocusNode _listFocusNode = FocusNode();
  List<Doctor> filteredList = List.from(allDoctors);

  @override
  void dispose() {
    _listSearchController.dispose();
    _listFocusNode.dispose();
    super.dispose();
  }

  void _filterList(String query) {
    setState(() {
      filteredList = allDoctors.where((doc) {
        final input = query.toLowerCase();
        return doc.name.toLowerCase().contains(input) ||
            doc.specialty.toLowerCase().contains(input) ||
            doc.district.toLowerCase().contains(input);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color textDark = Color(0xFF1E293B);

    return GestureDetector(
      onTap: () => _listFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text("Certified Specialists",
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: textDark,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // ✅ Kill focus before popping to prevent keyboard flicker on Home
              _listFocusNode.unfocus();
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.03), blurRadius: 10)
                    ]),
                child: TextField(
                  controller: _listSearchController,
                  focusNode: _listFocusNode,
                  onChanged: _filterList,
                  style: const TextStyle(color: textDark),
                  decoration: InputDecoration(
                    hintText: "Search doctor, district, or specialty...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    icon: const Icon(Icons.search, size: 20, color: Colors.grey),
                    suffixIcon: _listSearchController.text.isNotEmpty
                        ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() {
                            _listSearchController.clear();
                            _filterList("");
                          });
                        })
                        : null,
                  ),
                ),
              ),
            ),
            Expanded(
              child: filteredList.isEmpty
                  ? const Center(
                  child: Text("No specialists found.",
                      style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final doctor = filteredList[index];
                  return _buildDoctorListItem(context, doctor, textDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorListItem(BuildContext context, Doctor doctor, Color textDark) {
    return GestureDetector(
      onTap: () {
        _listFocusNode.unfocus();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DoctorDetails(doctor: doctor)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100)),
        child: Row(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(doctor.image,
                    width: 70, height: 70, fit: BoxFit.cover)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textDark)),
                    Text(doctor.specialty,
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.location_on,
                          color: Colors.blue, size: 14),
                      const SizedBox(width: 4),
                      // ✅ Expanded prevents text overflow on smaller screens
                      Expanded(
                        child: Text(
                          "${doctor.district} • ${doctor.distance}",
                          style:
                          const TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ]),
                  ]),
            ),
            const SizedBox(width: 10),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(doctor.rating,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12))
                ])),
          ],
        ),
      ),
    );
  }
}