import 'package:flutter/material.dart';
import 'doctor_data.dart';

class DoctorDetails extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetails({super.key, required this.doctor});

  // Consistency Colors
  final Color primaryBlue = const Color(0xFF0056D2);
  final Color surfaceWhite = const Color(0xFFF8FAFC);
  final Color textDark = const Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceWhite,
      appBar: AppBar(
        title: const Text("Doctor Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Professional Doctor Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Dynamic Doctor Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      doctor.image,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Doctor Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          doctor.specialty,
                          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 5),
                            Text(
                                doctor.rating,
                                style: TextStyle(fontWeight: FontWeight.bold, color: textDark)
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.location_on, color: Colors.grey, size: 18),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                "${doctor.district} (${doctor.distance})",
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ✅ Dynamic Address Section
            _buildInfoSection("Address", doctor.address, Icons.map_outlined),

            // ✅ Dynamic About Section related to specialty
            _buildInfoSection(
                "About",
                "Dr. ${doctor.name.split(' ').last} is a prestigious ${doctor.specialty.toLowerCase()} with over 10 years of experience in clinical skin analysis and AI-assisted diagnostics.",
                Icons.info_outline
            ),

            _buildInfoSection("Working Hours", "Monday to Friday, 08:00 AM – 07:00 PM", Icons.access_time),

            const SizedBox(height: 40),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
                onPressed: () {
                  // TODO: Implement Booking Logic
                },
                child: const Text(
                  "Book Appointment",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: primaryBlue),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textDark),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(
              content,
              style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}