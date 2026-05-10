import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'map_screen.dart';
import 'home_screen.dart';
import 'package:geocoding/geocoding.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController controller = TextEditingController();
  final String apiKey = "AIzaSyDy3FbOcQgvKwdZkwKhKPlyYdkj6cpLPEc";

  Future<void> getLocation() async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      openMap(position.latitude, position.longitude);
    } else {
      showMessage("Permission denied");
    }
  }

  Future<void> manualSearch() async {
    try {
      if (controller.text.isEmpty) {
        showMessage("Please enter a location");
        return;
      }

      // Convert text → coordinates
      List<Location> locations = await locationFromAddress(
        "${controller.text}, Egypt",
      );

      if (locations.isNotEmpty) {
        double lat = locations.first.latitude;
        double lng = locations.first.longitude;

        openMap(lat, lng);
      } else {
        showMessage("Location not found");
      }
    } catch (e) {
      showMessage("Error: Unable to find location");
    }
  }

  void openMap(double lat, double lng) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapScreen(
          lat: lat,
          lng: lng,
          apiKey: "AIzaSyDy3FbOcQgvKwdZkwKhKPlyYdkj6cpLPEc",
        ),
      ),
    );
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌍 Background (map-like gradient)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 135, 185, 201),
                  const Color.fromARGB(255, 255, 255, 255),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 📍 Content
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 20),

                /// Back arrow
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.blueGrey),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                  ),
                ),
                // Title
                Text(
                  "Find Dermatology Clinics",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),

                SizedBox(height: 20),

                // 📦 Glass-style card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.location_city),
                            labelText: "Enter city",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),

                        ElevatedButton.icon(
                          onPressed: () async {
                            await manualSearch();
                          },
                          icon: Icon(Icons.search),
                          label: Text("Search Location"),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 📍 Floating GPS button
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: getLocation,
              icon: Icon(Icons.my_location),
              label: Text("Use My Location"),
            ),
          ),
        ],
      ),
    );
  }
}
