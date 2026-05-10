// lib/doctor_data.dart

class Doctor {
  final String name;
  final String image;
  final String rating;
  final String distance;
  final String specialty;
  final String district;
  final String address; // ✅ Added this field

  Doctor({
    required this.name,
    required this.image,
    required this.rating,
    required this.distance,
    required this.specialty,
    required this.district,
    required this.address, // ✅ Added this field
  });
}

final List<Doctor> allDoctors = [
  Doctor(
    name: "Dr. Ahmed Ali",
    image: "assets/doc1.jpeg",
    rating: "4.9",
    distance: "1.2 km",
    specialty: "Clinical Dermatologist",
    district: "Gleem",
    address: "123 El-Gaish Rd, Gleem, Alexandria",
  ),
  Doctor(
    name: "Dr. Salim Khaled",
    image: "assets/doc2.jpeg",
    rating: "4.8",
    distance: "2.5 km",
    specialty: "Pediatric Skin Specialist",
    district: "Smouha",
    address: "Victor Hamman St, Smouha, Alexandria",
  ),
  Doctor(
    name: "Dr. Sara Hassan",
    image: "assets/fdoc1.png",
    rating: "4.7",
    distance: "3.1 km",
    specialty: "Cosmetic Dermatology",
    district: "Loran",
    address: "El-Horreya Rd, Loran, Alexandria",
  ),
  Doctor(
    name: "Dr. Menna Fawzy",
    image: "assets/fdoc2.png",
    rating: "4.9",
    distance: "0.8 km",
    specialty: "Dermatopathologist",
    district: "Kafr Abdou",
    address: "Saint Geni St, Kafr Abdou, Alexandria",
  ),
  Doctor(
    name: "Dr. Omar Ziad",
    image: "assets/doc3.png",
    rating: "4.6",
    distance: "4.2 km",
    specialty: "Skin Cancer Specialist",
    district: "Roushdy",
    address: "Abou Qir St, Roushdy, Alexandria",
  ),
  Doctor(
    name: "Dr. Laila Mahmoud",
    image: "assets/fdoc3.PNG",
    rating: "4.8",
    distance: "1.9 km",
    specialty: "General Dermatology",
    district: "Sidi Gaber",
    address: "Sidi Gaber Station Plaza, Alexandria",
  ),
];