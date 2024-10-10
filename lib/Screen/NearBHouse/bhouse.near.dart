import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../cons.dart';
import '../Home/home.screen.dart';

class BHouseNearMe extends StatefulWidget {
  @override
  _BHouseNearMeState createState() => _BHouseNearMeState();
}

class _BHouseNearMeState extends State<BHouseNearMe> {
  late google_maps.GoogleMapController _googleMapController;
  Set<google_maps.Marker> _markers = {};
  Set<google_maps.Polyline> _polylines = {};  // To store polylines
  static LatLng _center = LatLng(userLat!, userLong!); // Example center

  @override
  void initState() {
    super.initState();
    _fetchMarkersFromFirestore();
  }

  // Fetch markers from Firestore
  Future<void> _fetchMarkersFromFirestore() async {
    FirebaseFirestore.instance.collection('BoardingHouses').get().then((snapshot) {
      snapshot.docs.forEach((doc) async {
        var data = doc.data();
        LatLng position = LatLng(data['Lat'], data['Long']);
        String name = data['BoardingHouseName'];

        BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: Size(1, 1)), // Icon size
          'assets/BhouseMapPin.png',
        );

        // Add marker to the set
        setState(() {
          _markers.add(
            google_maps.Marker(
              markerId: google_maps.MarkerId(doc.id),
              icon: customIcon,
              position: position,
              infoWindow: google_maps.InfoWindow(title: name),
              onTap: () {
                _addPolyline(position);  // Add polyline when the marker is tapped
              },
            ),
          );
        });
      });
    }).catchError((error) {
      print('Error fetching locations: $error');
    });
  }

  // Function to add a polyline from the user's location to the marker's position
  void _addPolyline(LatLng markerPosition) {
    setState(() {
      _polylines.clear(); // Clear any existing polylines

      _polylines.add(
        google_maps.Polyline(
          polylineId: google_maps.PolylineId('route'),
          points: [_center, markerPosition], // Draw from user location to marker
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(_toFront(), (Route<dynamic> route) => false);
              },
              child: Icon(Icons.arrow_back_ios),
            ),
            Text(''),
          ],
        ),
      ),
      body: google_maps.GoogleMap(
        myLocationEnabled: true,
        initialCameraPosition: google_maps.CameraPosition(
          target: _center,
          zoom: 12.0,
        ),
        markers: _markers, // Markers from Firestore
        polylines: _polylines, // Display polylines
        onMapCreated: (google_maps.GoogleMapController controller) {
          _googleMapController = controller;
        },
      ),
    );
  }

  Route _toFront() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) => HomeScreen(),
      transitionDuration: Duration(milliseconds: 1000),
      reverseTransitionDuration: Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, anotherAnimation, child) {
        animation = CurvedAnimation(
          parent: animation,
          reverseCurve: Curves.fastOutSlowIn,
          curve: Curves.fastLinearToSlowEaseIn,
        );

        return SlideTransition(
          position: Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0)).animate(animation),
          textDirection: TextDirection.rtl,
          child: HomeScreen(),
        );
      },
    );
  }
}
