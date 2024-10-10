import 'package:cloud_firestore/cloud_firestore.dart';

import 'cons.dart';

Future<int> fetchRoomsWithOwnersID() async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('Rooms')
      .where('ownerUid', isEqualTo: OwnerUuId)
      .get();

  return querySnapshot.docs.length; // Return the count of matching documents
}

Future<int> fetchRoomsAvailable() async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('Rooms')
      .where('ownerUid', isEqualTo: OwnerUuId)
      .where('roomStatus', isEqualTo: 'available')
      .get();

  return querySnapshot.docs.length; // Return the count of matching documents
}

Future<int> fetchRoomsUnavailable() async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('Rooms')
      .where('ownerUid', isEqualTo: OwnerUuId)
      .where('roomStatus', isEqualTo: 'unavailable')
      .get();

  return querySnapshot.docs.length; // Return the count of matching documents
}

Future<void> fetchBoarderData(Function setState) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentEmail)
        .get();

    setState(() {
      userRole = snapshot.data()?['role'];
      fName = snapshot.data()?['FirstName'];
      mName = snapshot.data()?['MiddleName'];
      lName = snapshot.data()?['LastName'];
      bUuId = snapshot.data()?['UuId'];
      bAddress = snapshot.data()?['Address'];
      bPhoneNumber = snapshot.data()?['PhoneNumber'];
      print('$fName, $mName, $lName - $bUuId - $bPhoneNumber - $bAddress');
      // fetchRoleError = false;
    });
    checkUserInRooms();
  } catch (e) {
    setState(() {
      // fetchRoleError = true;
    });
  }
}

Future<void> fetchViewReservation(Function setState) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('Rooms')
        .doc(rBHouseDocId)
        .get();

    setState(() {
      rBHouseDocId = snapshot.data()?['docID'];
      rCheckIn = snapshot.data()?['checkIn'];
      rCheckOut = snapshot.data()?['checkOut'];
      print('$rBHouseDocId, $rCheckIn, $rCheckOut');
      // fetchRoleError = false;
    });
    checkUserInRooms();
  } catch (e) {
    setState(() {
      // fetchRoleError = true;
    });
  }
}

void checkUserInRooms() async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Rooms')
      .where('boarderID', isEqualTo: bUuId)
      .get();

  // Check if any documents were found
  if (querySnapshot.docs.isNotEmpty) {
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic>? roomData = doc.data() as Map<String, dynamic>?;

      if (roomData != null) {
        print("Room Data: $roomData");
        cBHouseName = roomData['bHouseName'];
        cRoom = roomData['roomNameNumber'];
      }
    }
  } else {
    print("No rooms found for user with name: $bUuId");
  }
}

Future<void> fetchOwnerData(Function setState) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentEmail)
        .get();

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
    final snapshot = await FirebaseFirestore.instance
        .collection('BoardingHouses')
        .doc(currentEmail)
        .get();
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

Future<void> fetchRoomData(Function setState) async {
  try {
    final snapshot =
        await FirebaseFirestore.instance.collection('Rooms').doc(roomId).get();
    setState(() {
      roomNumber = snapshot.data()?['roomNameNumber'];
      roomDescriptions = snapshot.data()?['rules'];
      roomPrice = snapshot.data()?['price'];
      print('$roomNumber');
      // fetchRoleError = false;
    });
  } catch (e) {
    setState(() {
      // fetchRoleError = true;
    });
  }
}

Future<void> fetchBhouseData(Function setState) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('BoardingHouses')
        .where('OwnerUId', isEqualTo: OwnerUuId)
        .get();

    // Assuming you're expecting only one document for the specific owner
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      setState(() {
        BhouseName = doc['BoardingHouseName'];
        bHouseRules = doc['Rules'];
        print('$BhouseName');
        // fetchRoleError = false;
      });
    } else {
      print('No boarding house found for this owner.');
    }
  } catch (e) {
    setState(() {
      print('Error fetching boarding house: $e');
      // fetchRoleError = true;
    });
  }
}

Future<int> countAllRoom(Function setState) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Rooms')
      .where('ownerUid', isEqualTo: OwnerUuId)
      .get();
  setState(() {
    allRooms = querySnapshot.size;
  });
  print(querySnapshot.size);
  return querySnapshot.size; // Returns the number of matching documents
}

Future<int> countAvailableRoom(Function setState) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Rooms')
      .where('roomStatus', isEqualTo: 'available')
      .where('ownerUid', isEqualTo: OwnerUuId)
      .get();
  setState(() {
    roomAvailable = querySnapshot.size;
  });
  print(querySnapshot.size);
  return querySnapshot.size; // Returns the number of matching documents
}

Future<int> countUnavailableRoom(Function setState) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Rooms')
      .where('roomStatus', isEqualTo: 'unavailable')
      .where('ownerUid', isEqualTo: OwnerUuId)
      .get();
  setState(() {
    roomUnavailable = querySnapshot.size;
  });
  print(querySnapshot.size);
  return querySnapshot.size; // Returns the number of matching documents
}
