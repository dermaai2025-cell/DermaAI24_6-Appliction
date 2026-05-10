import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  final double lat;
  final double lng;
  final String apiKey;

  const MapScreen({
    Key? key,
    required this.lat,
    required this.lng,
    required this.apiKey,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  
  // Variables for routing and UI
  Set<Polyline> polylines = {};
  String? distanceText;
  String? durationText;
  String? selectedClinicName;

  // 👇 NEW: Variables to track selected mode and destination 👇
  String travelMode = 'driving'; // Default to driving. Options: 'driving', 'walking'
  double? currentDestLat;
  double? currentDestLng;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClinics();
  }

  Future<void> fetchClinics() async {
    final url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        "?location=${widget.lat},${widget.lng}"
        "&radius=5000"
        "&type=doctor"
        "&keyword=dermatologist"
        "&key=${widget.apiKey}";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
          print("PLACES API ERROR: ${data['status']} - ${data['error_message'] ?? ''}");
          if (!mounted) return;
          setState(() => isLoading = false);
          return;
        }

        final results = data["results"];
        Set<Marker> newMarkers = {};

        // Add User location marker
        newMarkers.add(
          Marker(
            markerId: const MarkerId("user_location"),
            position: LatLng(widget.lat, widget.lng),
            infoWindow: const InfoWindow(title: "You are here"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );

        // Add Clinics markers
        for (var clinic in results) {
          var loc = clinic["geometry"]["location"];
          double destLat = loc["lat"];
          double destLng = loc["lng"];
          String clinicName = clinic["name"];

          newMarkers.add(
            Marker(
              markerId: MarkerId(clinic["place_id"] ?? clinicName),
              position: LatLng(destLat, destLng),
              infoWindow: InfoWindow(
                title: clinicName,
                snippet: clinic["vicinity"],
              ),
              onTap: () {
                // Pass the current default travel mode when first tapped
                getDirections(destLat, destLng, clinicName, travelMode);
              },
            ),
          );
        }

        if (!mounted) return;
        setState(() {
          markers = newMarkers;
          isLoading = false;
        });

      } else {
        if (!mounted) return;
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching clinics: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  // 👇 UPDATED: Added 'mode' parameter to the function 👇
  Future<void> getDirections(double destLat, double destLng, String clinicName, String mode) async {
    setState(() {
      isLoading = true;
      // Save the current destination so we can recalculate if the user changes the mode
      currentDestLat = destLat;
      currentDestLng = destLng;
      travelMode = mode;
      selectedClinicName = clinicName;
    });

    // 👇 UPDATED: Added &mode=$mode to the API URL 👇
    final url = 
        "https://maps.googleapis.com/maps/api/directions/json"
        "?origin=${widget.lat},${widget.lng}"
        "&destination=$destLat,$destLng"
        "&mode=$mode" 
        "&key=${widget.apiKey}";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final route = data['routes'][0];
          final leg = route['legs'][0];

          final dist = leg['distance']['text'];
          final dur = leg['duration']['text'];
          final encodedPolyline = route['overview_polyline']['points'];

          List<LatLng> polylineCoordinates = decodePolyline(encodedPolyline);

          if (!mounted) return;
          setState(() {
            distanceText = dist;
            durationText = dur;
            
            // Draw the line (change color slightly based on mode to give visual feedback)
            polylines = {
              Polyline(
                polylineId: const PolylineId("route"),
                color: mode == 'walking' ? Colors.green : Colors.blue,
                width: 5,
                // Make walking lines dotted for better UI context
                patterns: mode == 'walking' 
                    ? [PatternItem.dash(20), PatternItem.gap(10)] 
                    : <PatternItem>[],
                points: polylineCoordinates,
              )
            };
            isLoading = false;
          });
          
          mapController?.animateCamera(
             CameraUpdate.newLatLngBounds(
               boundsFromLatLngList(polylineCoordinates), 50.0)
          );
        } else {
           setState(() => isLoading = false);
        }
      }
    } catch (e) {
      print("Error fetching directions: $e");
      setState(() => isLoading = false);
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Clinics"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.lat, widget.lng),
              zoom: 14,
            ),
            markers: markers,
            polylines: polylines, 
            onMapCreated: (controller) {
              mapController = controller;
            },
            myLocationEnabled: true, 
            myLocationButtonEnabled: true,
          ),
          
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          if (distanceText != null && durationText != null && !isLoading)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedClinicName ?? "Clinic Route",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      
                      // 👇 NEW: Travel Mode Toggles 👇
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: const Text("Car"),
                            avatar: const Icon(Icons.directions_car, size: 18),
                            selected: travelMode == 'driving',
                            selectedColor: Colors.blue.shade100,
                            onSelected: (selected) {
                              if (selected && currentDestLat != null) {
                                getDirections(currentDestLat!, currentDestLng!, selectedClinicName!, 'driving');
                              }
                            },
                          ),
                          const SizedBox(width: 15),
                          ChoiceChip(
                            label: const Text("Walk"),
                            avatar: const Icon(Icons.directions_walk, size: 18),
                            selected: travelMode == 'walking',
                            selectedColor: Colors.green.shade100,
                            onSelected: (selected) {
                              if (selected && currentDestLat != null) {
                                getDirections(currentDestLat!, currentDestLng!, selectedClinicName!, 'walking');
                              }
                            },
                          ),
                        ],
                      ),
                      const Divider(),

                      // Duration and Distance Display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              Icon(
                                travelMode == 'driving' ? Icons.directions_car : Icons.directions_walk, 
                                color: travelMode == 'driving' ? Colors.blue : Colors.green
                              ),
                              const SizedBox(width: 8),
                              Text(durationText!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.route, color: Colors.black54),
                              const SizedBox(width: 8),
                              Text(distanceText!, style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}