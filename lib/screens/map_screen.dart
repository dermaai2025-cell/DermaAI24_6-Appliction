import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  Set<Polyline> polylines = {};

  String? distanceText;
  String? durationText;
  String? selectedClinicName;
  List<dynamic> routeSteps = [];

  String travelMode = 'driving';
  double? currentDestLat;
  double? currentDestLng;

  bool isLoading = true;
  bool isNavigating = false;

  StreamSubscription<Position>? positionStream;
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    initTts();
    fetchClinics();
  }

  void initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("ar-SA");
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    positionStream?.cancel();
    flutterTts.stop();
    super.dispose();
  }

  String cleanHtmlText(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), "");
  }

  Future<void> fetchClinics() async {
    final url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        "?location=${widget.lat},${widget.lng}"
        "&radius=5000&type=doctor&keyword=dermatologist&key=${widget.apiKey}";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data["results"];
        Set<Marker> newMarkers = {};

        newMarkers.add(
          Marker(
            markerId: const MarkerId("user_location"),
            position: LatLng(widget.lat, widget.lng),
            infoWindow: const InfoWindow(title: "Current location"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );

        for (var clinic in results) {
          var loc = clinic["geometry"]["location"];
          String clinicId = clinic["place_id"];
          String name = clinic["name"];

          newMarkers.add(
            Marker(
              markerId: MarkerId(clinicId),
              position: LatLng(loc["lat"], loc["lng"]),
              // 👇 إضافة InfoWindow لإظهار الاسم 👇
              infoWindow: InfoWindow(
                title: name,
                snippet: "Press to start Direction ",
              ),
              onTap: () {
                // إظهار نافذة الاسم يدوياً عند الضغط
                mapController?.showMarkerInfoWindow(MarkerId(clinicId));
                getDirections(loc["lat"], loc["lng"], name, travelMode);
              },
            ),
          );
        }
        setState(() {
          markers = newMarkers;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> getDirections(
    double destLat,
    double destLng,
    String clinicName,
    String mode,
  ) async {
    setState(() => isLoading = true);

    final url =
        "https://maps.googleapis.com/maps/api/directions/json"
        "?origin=${widget.lat},${widget.lng}"
        "&destination=$destLat,$destLng"
        "&mode=$mode"
        "&language=ar"
        "&key=${widget.apiKey}";

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final route = data['routes'][0];
        final leg = route['legs'][0];

        setState(() {
          currentDestLat = destLat;
          currentDestLng = destLng;
          travelMode = mode;
          selectedClinicName = clinicName;
          distanceText = leg['distance']['text'];
          durationText = leg['duration']['text'];
          routeSteps = leg['steps'];

          polylines = {
            Polyline(
              polylineId: const PolylineId("route"),
              color: mode == 'walking' ? Colors.green : Colors.blue,
              width: 6,
              points: decodePolyline(route['overview_polyline']['points']),
            ),
          };
          isLoading = false;
        });

        mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(
            boundsFromLatLngList(polylines.first.points),
            70,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void startNavigation() async {
    if (routeSteps.isEmpty) return;

    setState(() => isNavigating = true);

    String firstInstruction = cleanHtmlText(routeSteps[0]['html_instructions']);
    flutterTts.speak("direction to $selectedClinicName. $firstInstruction");

    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 2,
          ),
        ).listen((Position position) {
          if (mapController != null && isNavigating) {
            mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 19,
                  tilt: 60,
                  bearing: position.heading,
                ),
              ),
            );

            if (routeSteps.isNotEmpty) {
              var nextStep = routeSteps[0];
              var stepLoc = nextStep['end_location'];
              double distanceToTurn = Geolocator.distanceBetween(
                position.latitude,
                position.longitude,
                stepLoc['lat'],
                stepLoc['lng'],
              );

              if (distanceToTurn < 30) {
                String instruction = cleanHtmlText(
                  nextStep['html_instructions'],
                );
                flutterTts.speak(instruction);
                routeSteps.removeAt(0);
              }
            }
          }
        });
  }

  void stopNavigation() {
    positionStream?.cancel();
    flutterTts.stop();
    setState(() => isNavigating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isNavigating ? null : AppBar(title: const Text("Nearby Clinics")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.lat, widget.lng),
              zoom: 14,
            ),
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: !isNavigating,
            onMapCreated: (controller) => mapController = controller,
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
          if (distanceText != null && !isLoading)
            Positioned(
              bottom: 20,
              left: 15,
              right: 15,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedClinicName ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      if (!isNavigating) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _modeChip("Car", Icons.directions_car, 'driving'),
                            const SizedBox(width: 10),
                            _modeChip(
                              "walking",
                              Icons.directions_walk,
                              'walking',
                            ),
                          ],
                        ),
                      ],
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                durationText!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                distanceText!,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: isNavigating
                                ? stopNavigation
                                : startNavigation,
                            icon: Icon(
                              isNavigating ? Icons.stop : Icons.navigation,
                              color: Colors.white,
                            ),
                            label: Text(
                              isNavigating ? "Exit" : "Start",
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isNavigating
                                  ? Colors.red
                                  : Colors.blueAccent,
                              shape: const StadiumBorder(),
                            ),
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

  Widget _modeChip(String label, IconData icon, String mode) {
    return ChoiceChip(
      label: Text(label),
      avatar: Icon(icon, size: 16),
      selected: travelMode == mode,
      onSelected: (val) {
        if (val)
          getDirections(
            currentDestLat ?? widget.lat,
            currentDestLng ?? widget.lng,
            selectedClinicName ?? "",
            mode,
          );
      },
    );
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
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }
}
