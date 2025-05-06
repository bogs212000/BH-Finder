import 'dart:async';

import 'package:bh_finder/Screen/Owner/owner.home.screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../../cons.dart';
import '../new/new.nav.owner.dart';

class BHouseAddress extends StatefulWidget {
  const BHouseAddress({super.key});

  @override
  State<BHouseAddress> createState() => _BHouseAddressState();
}

class _BHouseAddressState extends State<BHouseAddress> {
  final Completer<GoogleMapController> _controller = Completer();
  late LatLng cam;
  Set<Marker> _markers = {};

  void _onCameraMove(CameraPosition position) {
    setState(() {
      cam = position.target;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('picked_location'),
          position: cam,
        ),
      );
    });
  }

  Future<void> _pickLocation() async {
    setState(() {
      addressLat = cam.latitude;
      addressLong = cam.longitude;
    });
    print('${addressLat}, ${addressLong}');
    await FirebaseFirestore.instance
        .collection('BoardingHouses')
        .doc(currentEmail)
        .update({
      'Lat': addressLat,
      'Long': addressLong,
    });
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Success!',
      text: 'Location has been updated.',
      confirmBtnText: 'OK',
    );
    Future.delayed(Duration(seconds: 2),(){ Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => NewOwnerNav()),
      // Define your CheckoutPage widget here
          (Route<dynamic> route) =>
      false, // This condition removes all the previous routes
    );});

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Change'),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              initialCameraPosition: CameraPosition(
                target: LatLng(addressLat!, addressLong!),
                zoom: 18.0,
              ),
              onCameraMove: _onCameraMove,
              markers: _markers,
            ),
            Positioned(
              bottom: 16.0,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: 200,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () async {
                      _pickLocation();
                    },
                    child: const Text("PICK LOCATION", style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
