import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';

import '../owner.home.screen.dart';

File? _bHouseImage;

class BHouseEditProfile extends StatefulWidget {
  final String? first;
  final String? middle;
  final String? last;
  final String? email;
  final String? address;
  final String? phoneNum;
  final String? bHouseName;
  final String? rules;
  final String? OwnerUId;
  final double? lat;
  final double? long;

  const BHouseEditProfile(
      {super.key,
      this.first,
      this.middle,
      this.last,
      this.address,
      this.email,
      this.phoneNum,
      this.bHouseName,
      this.rules,
      this.OwnerUId, this.lat, this.long});

  @override
  State<BHouseEditProfile> createState() => _BHouseEditProfileState();
}

class _BHouseEditProfileState extends State<BHouseEditProfile> {
  late TextEditingController _fname;
  late TextEditingController _mname;
  late TextEditingController _lname;
  late TextEditingController _address;
  late TextEditingController _pnumber;
  late TextEditingController _bHouseName;
  late TextEditingController _rules;
  String? message;
  bool _isChanged = false;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();

    // Initialize the controllers with the passed values
    _fname = TextEditingController(text: widget.first);
    _mname = TextEditingController(text: widget.middle);
    _lname = TextEditingController(text: widget.last);
    _address = TextEditingController(text: widget.address);
    _pnumber = TextEditingController(text: widget.phoneNum);
    _bHouseName = TextEditingController(text: widget.bHouseName);
    _rules = TextEditingController(text: widget.rules);

    // Add listeners to detect changes
    _fname.addListener(_checkIfChanged);
    _mname.addListener(_checkIfChanged);
    _lname.addListener(_checkIfChanged);
    _address.addListener(_checkIfChanged);
    _pnumber.addListener(_checkIfChanged);
    _bHouseName.addListener(_checkIfChanged);
    _rules.addListener(_checkIfChanged);
  }

  FirebaseStorage storage = FirebaseStorage.instance;

  Future<List<String>> _loadImages() async {
    ListResult result =
        await storage.ref().child("BHouseImages/${widget.OwnerUId}").listAll();
    List<String> imageUrls = [];

    for (Reference ref in result.items) {
      String imageUrl = await ref.getDownloadURL();
      imageUrls.add(imageUrl);
    }

    return imageUrls;
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed
    _fname.dispose();
    _mname.dispose();
    _lname.dispose();
    _address.dispose();
    _pnumber.dispose();
    _bHouseName.dispose();
    _rules.dispose();
    super.dispose();
  }

  void _checkIfChanged() {
    // Check if any text field value differs from the initial values
    if (_fname.text != (widget.first ?? "") ||
        _mname.text != (widget.middle ?? "") ||
        _lname.text != (widget.last ?? "") ||
        _address.text != (widget.address ?? "") ||
        _pnumber.text != (widget.phoneNum ?? "") ||
        _bHouseName.text != (widget.bHouseName ?? "") ||
        _rules.text != (widget.rules ?? "")) {
      setState(() {
        _isChanged = true;
      });
    } else {
      setState(() {
        _isChanged = false;
      });
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    try {
      Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete(); // Deletes the image from Firebase Storage
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  Future<void> _onRefresh() async {
    setState(() {

    });
    await Future.delayed(Duration(milliseconds: 1000)); // Simulate loading delay
    _refreshController.refreshCompleted(); // Notify that refresh is complete
  }

  @override
  Widget build(BuildContext context) {
    final _picker = ImagePicker();

    final Marker targetMarker = Marker(
      markerId: MarkerId("targetLocation"),
      position: LatLng(widget.lat!, widget.long!),
      infoWindow: InfoWindow(
        title: "Target Location",
        snippet: "Pinned Location",
      ),
    );
    //IDs
    Future<void> _openImagePicker() async {
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          _bHouseImage = File(pickedImage.path);
        });
        // setState(() {
        //   loading = false;
        // });
      }
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: false, // Assuming no pull-up loading is needed
            controller: _refreshController,
            onRefresh: _onRefresh,
            header: WaterDropMaterialHeader(
              distance: 30,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 0.5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            'Edit Boarding House Profile'
                                .text
                                .bold
                                .size(20)
                                .make()
                          ],
                        ),
                        Divider(),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 20),
                          child: TextField(
                            controller: _bHouseName,
                            keyboardType: TextInputType.name,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.1),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelText: 'Boarding House Name',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 20),
                          child: TextField(
                            controller: _fname,
                            keyboardType: TextInputType.name,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.1),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelText: 'First Name',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 20),
                          child: TextField(
                            controller: _mname,
                            keyboardType: TextInputType.name,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.1),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelText: 'Middle',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 20),
                          child: TextField(
                            controller: _lname,
                            keyboardType: TextInputType.name,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.1),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelText: 'Last Name',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 20),
                          child: TextField(
                            controller: _address,
                            keyboardType: TextInputType.name,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.1),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelText: 'Address',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 20),
                          child: TextField(
                            controller: _pnumber,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.1),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelText: 'Contact Number',
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            '    Description'.text.make(),
                          ],
                        ),
                        SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 20),
                          child: TextField(
                            maxLines: 3,
                            controller: _rules,
                            keyboardType: TextInputType.name,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.1),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelText: '',
                            ),
                          ),
                        ),
                        Container(
                          height: 100,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                                target: LatLng(widget.lat!, widget.long!),
                                zoom: 16),
                            myLocationEnabled: true,
                            zoomControlsEnabled: false,
                            zoomGesturesEnabled: true,
                            tiltGesturesEnabled: true,
                            scrollGesturesEnabled: true,
                            rotateGesturesEnabled: true,
                            markers: {targetMarker},
                            mapType: MapType.normal,
                            onMapCreated:
                                (GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              onPressed: () async {
                                Navigator.pushNamed(context, '/BHouseAddress');
                              },
                              child: const Text("PICK LOCATION", style: TextStyle(color: Colors.white),),
                            ),
                          ],
                        ),
                        Container(
                          height: 200,
                          width: double.infinity,
                          child: FutureBuilder<List<String>>(
                            future: _loadImages(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey.shade200,
                                  highlightColor: Colors.white,
                                  child: Container(
                                    height: 200,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text("Error loading images"));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Center(child: Text("No images found"));
                              } else {
                                List<String> images = snapshot.data!;
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: images.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 200,
                                            width: 100,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                image: CachedNetworkImageProvider(
                                                    images[index]),
                                                // Set the image from the network
                                                fit: BoxFit
                                                    .cover, // Ensures the image covers the container
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(5),
                                            height: 200,
                                            width: 100,
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    GestureDetector(
                                                        onTap: () async {
                                                          QuickAlert.show(
                                                            onCancelBtnTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            onConfirmBtnTap:
                                                                () async {
                                                              await _deleteImage(
                                                                  images[
                                                                      index]); // Delete the image
                                                              setState(() {
                                                                images.removeAt(
                                                                    index); // Remove image from list
                                                              });
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            context: context,
                                                            type: QuickAlertType
                                                                .confirm,
                                                            text: 'Delete image',
                                                            titleAlignment:
                                                                TextAlign.center,
                                                            textAlignment:
                                                                TextAlign.center,
                                                            confirmBtnText: 'Yes',
                                                            cancelBtnText: 'No',
                                                            confirmBtnColor:
                                                                Colors.blue,
                                                            backgroundColor:
                                                                Colors.white,
                                                            headerBackgroundColor:
                                                                Colors.grey,
                                                            confirmBtnTextStyle:
                                                                const TextStyle(
                                                              color: Colors.white,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                            titleColor:
                                                                Colors.black,
                                                            textColor:
                                                                Colors.black,
                                                          );
                                                        },
                                                        child: Icon(
                                                          Icons.delete_outline,
                                                          color: Colors.white,
                                                        )),
                                                  ],
                                                ),
                                                Spacer(),
                                                GestureDetector(
                                                  onTap: () async {
                                                    QuickAlert.show(
                                                      onCancelBtnTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      onConfirmBtnTap: () async {
                                                        Navigator.pop(context);
                                                        try{
                                                          QuickAlert.show(
                                                            context: context,
                                                            type: QuickAlertType.loading,
                                                            title: 'Loading',
                                                            text: 'Please wait...',
                                                            confirmBtnText: 'OK',
                                                          );
                                                          String imageUrl = await FirebaseStorage.instance
                                                              .refFromURL(images[index]) // Assuming images[index] is the Firebase storage reference URL
                                                              .getDownloadURL();
                                                          await FirebaseFirestore.instance.collection('BoardingHouses').doc(widget.email).update({
                                                            'Image': imageUrl,
                                                          });
                                                          print("Image URL: $imageUrl");
                                                          Navigator.pop(context);
                                                          setState(() {
                                                          });
                                                          QuickAlert.show(
                                                            context: context,
                                                            type: QuickAlertType.success,
                                                            title: 'Success',
                                                            text: 'Image has been set to main!',
                                                            confirmBtnText: 'OK',
                                                          );
                                                        } catch (e) {
                                                          // Handle errors, e.g., if the image link could not be retrieved
                                                          QuickAlert.show(
                                                            context: context,
                                                            type: QuickAlertType.error,
                                                            title: 'Error',
                                                            text: 'Failed to retrieve image link.',
                                                            confirmBtnText: 'OK',
                                                          );
                                                          print("Error fetching image URL: $e");
                                                        }


                                                      },
                                                      context: context,
                                                      type:
                                                          QuickAlertType.confirm,
                                                      text: 'Set as main',
                                                      titleAlignment:
                                                          TextAlign.center,
                                                      textAlignment:
                                                          TextAlign.center,
                                                      confirmBtnText: 'Yes',
                                                      cancelBtnText: 'No',
                                                      confirmBtnColor:
                                                          Colors.blue,
                                                      backgroundColor:
                                                          Colors.white,
                                                      headerBackgroundColor:
                                                          Colors.grey,
                                                      confirmBtnTextStyle:
                                                          const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      titleColor: Colors.black,
                                                      textColor: Colors.black,
                                                    );
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(10),
                                                    ),
                                                    height: 20,
                                                    child: Center(
                                                      child: 'Set as Main'
                                                          .text.color(Colors.white)
                                                          .make(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        if (_bHouseImage == null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    _openImagePicker();
                                  },
                                  child: 'Add image'.text.make()),
                            ],
                          ),
                        if (_bHouseImage != null)
                          Row(
                            children: [
                              Flexible(
                                  child: '${_bHouseImage?.path}'
                                      .text
                                      .overflow(TextOverflow.ellipsis)
                                      .make()),
                              Spacer(),
                              ElevatedButton(
                                  onPressed: () async {
                                    QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.loading,
                                      title: 'Uploading',
                                      text: 'Please Wait...',
                                    );
                                    try {
                                      // Get the application documents directory
                                      final appDocDir =
                                          await getApplicationDocumentsDirectory();

                                      // Construct the file path for saving the image locally (optional)
                                      final filePath =
                                          "${appDocDir.path}/path/to/${_bHouseName.text}.jpg";

                                      // Get the selected image file (use the path from the selected image)
                                      final file = File(_bHouseImage!.path);

                                      // Create metadata for the image
                                      final metadata = SettableMetadata(
                                          contentType: "image/jpeg");

                                      // Create a reference to Firebase Storage
                                      final storageRef =
                                          FirebaseStorage.instance.ref();

                                      // Upload file and metadata to Firebase Storage
                                      final uploadTask = storageRef
                                          .child(
                                              "BHouseImages/${widget.OwnerUId}/${DateTime.now().toString()}.jpg")
                                          .putFile(file, metadata);

                                      // Listen for state changes, errors, and completion of the upload.
                                      uploadTask.snapshotEvents
                                          .listen((TaskSnapshot taskSnapshot) {
                                        switch (taskSnapshot.state) {
                                          case TaskState.running:
                                            final progress = 100.0 *
                                                (taskSnapshot.bytesTransferred /
                                                    taskSnapshot.totalBytes);
                                            print(
                                                "Upload is $progress% complete.");
                                            break;
                                          case TaskState.paused:
                                            print("Upload is paused.");
                                            break;
                                          case TaskState.canceled:
                                            print("Upload was canceled.");
                                            break;
                                          case TaskState.error:
                                            print("Upload encountered an error.");
                                            break;
                                          case TaskState.success:
                                            print("Upload successful!");
                                            break;
                                        }
                                      });
                                      _bHouseImage = null;
                                      Navigator.pop(context);

                                      // Show a success dialog
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.success,
                                        title: 'Success!',
                                        text: 'Images has been Uploaded',
                                        onConfirmBtnTap: () {
                                          Navigator.pop(
                                              context); // Close the success dialog
                                        },
                                      );
                                    } catch (e) {
                                      print("Error uploading image: $e");
                                    }
                                  },
                                  child: 'Upload image'.text.make()),
                            ],
                          ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  if (_isChanged)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () async {
                              QuickAlert.show(
                                onCancelBtnTap: () {
                                  Navigator.pop(context);
                                },
                                onConfirmBtnTap: () async {
                                  Navigator.pop(context);
                                  await FirebaseFirestore.instance
                                      .collection('BoardingHouses')
                                      .doc(widget.email
                                          .toString()) // Assuming the document is based on user email
                                      .update({
                                    'BoardingHouseName': _bHouseName.text,
                                    'FirstName': _fname.text,
                                    // Use `.text` to update the actual text
                                    'MiddleName': _mname.text,
                                    'LastName': _lname.text,
                                    'address': _address.text,
                                    'PhoneNumber': _pnumber.text,
                                  });
                                  setState(() {
                                    message = 'Save Changes!';
                                  });
                                  _toast();
                                },
                                context: context,
                                type: QuickAlertType.confirm,
                                text: 'Save Changes.',
                                titleAlignment: TextAlign.center,
                                textAlignment: TextAlign.center,
                                confirmBtnText: 'Yes',
                                cancelBtnText: 'No',
                                confirmBtnColor: Colors.blue,
                                backgroundColor: Colors.white,
                                headerBackgroundColor: Colors.grey,
                                confirmBtnTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                titleColor: Colors.black,
                                textColor: Colors.black,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              // Custom background color
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(25), // Rounded corners
                              ),
                            ),
                            child: 'Save Changes'
                                .text
                                .color(Colors.white)
                                .bold // Bold text
                                .make(),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ));
  }

  void _toast() async {
    print('Showing Toast');
    await Future.delayed(const Duration(seconds: 1));
    SmartDialog.showToast(
      displayTime: Duration(seconds: 3),
      maskColor: Colors.green,
      '$message',
      useAnimation: true,
    );
  }
}
