import 'package:cloud_firestore/cloud_firestore.dart';

import 'cons.dart';

Future<void> fetchOwnerData(Function setState) async {
  try {
    final snapshot =
    await FirebaseFirestore.instance.collection('Users').doc(currentEmail).get();

    setState(() {
      userRole = snapshot.data()?['role'];
      OwnerUuId = snapshot.data()?['OwnerUId'];
      OwnerPhone = snapshot.data()?['PhoneNumber'];
      print('$userRole, $OwnerUuId, $OwnerPhone');
      // fetchRoleError = false;
    });
  } catch (e) {
    setState(() {
      // fetchRoleError = true;
    });
  }
}

Future<void> fetchOwnerBhouseData(Function setState) async {
  try {
    final snapshot =
    await FirebaseFirestore.instance.collection('BoardingHouses').doc(currentEmail).get();
    setState(() {
      BhouseName = snapshot.data()?['BoardingHouseName'];
      print('$BhouseName');
      // fetchRoleError = false;
    });
  } catch (e) {
    setState(() {
      // fetchRoleError = true;
    });
  }
}

Future<int> countAllRoom(Function setState) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Rooms')
      .where('ownerUid', isEqualTo: OwnerUuId)
      .get();
  setState((){
    allRooms = querySnapshot.size;
  });
  print(querySnapshot.size);
  return querySnapshot.size;  // Returns the number of matching documents
}

Future<int> countAvailableRoom(Function setState) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Rooms')
      .where('roomStatus', isEqualTo: 'available')
      .where('ownerUid', isEqualTo: OwnerUuId)
      .get();
  setState((){
    roomAvailable = querySnapshot.size;
  });
  print(querySnapshot.size);
  return querySnapshot.size;  // Returns the number of matching documents
}

Future<int> countUnavailableRoom(Function setState) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Rooms')
      .where('roomStatus', isEqualTo: 'unavailable')
      .where('ownerUid', isEqualTo: OwnerUuId)
      .get();
  setState((){
    roomUnavailable = querySnapshot.size;
  });
  print(querySnapshot.size);
  return querySnapshot.size;  // Returns the number of matching documents
}