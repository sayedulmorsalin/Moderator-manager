import 'package:cloud_firestore/cloud_firestore.dart';

class database {
  Future addcpdetails(Map<String, dynamic> customerinfomap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Cpdetails")
        .doc(id)
        .set(customerinfomap);
  }

  Future moderatordetails(Map<String, dynamic> modinfomap, String id) async {
    return await FirebaseFirestore.instance
        .collection("moderatordetails")
        .doc(id)
        .set(modinfomap);
  }

  Future<Stream<QuerySnapshot>> getCpdetails() async {
    return FirebaseFirestore.instance
        .collection('Cpdetails')
        .orderBy('Serial_number', descending: true)
        .snapshots();
  }


  Future<Stream<QuerySnapshot>> getpending() async {
    return FirebaseFirestore.instance
        .collection("Cpdetails")
        .where("Admin_approval", isEqualTo: false)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getcancel() async {
    return FirebaseFirestore.instance
        .collection("Cpdetails")
        .where("Delivery_status", isEqualTo: "Canceled")
        .snapshots();
  }

// Add to database.dart
  Future<Stream<QuerySnapshot>> getGetback() async{
    return FirebaseFirestore.instance
        .collection('getback')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> deleteCpDetails(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Cpdetails')
          .doc(orderId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  Future<int> getserialnumber() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('Cpdetails')
        .orderBy('Serial_number', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['Serial_number'];  // Return the highest Serial_number value
    }
    return 0;  // Return a default value if no data is found
  }


  Future<Stream<QuerySnapshot>> getmoddetails() async {
    return await FirebaseFirestore.instance
        .collection("moderatordetails")
        .snapshots();
  }

  Stream<DocumentSnapshot> getonemoddetails(String id) {
    return FirebaseFirestore.instance
        .collection("moderatordetails")
        .doc(id)
        .snapshots();
  }


  Future updatecpdetails(String id, Map<String, dynamic> updateinfo) async {
    return await FirebaseFirestore.instance
        .collection("Cpdetails")
        .doc(id)
        .update(updateinfo);
  }
  Future<void> updateModeratorDetails(String moderatorId, {int? withdrawAmount, bool? withdrawRequest}) async {
    try {
      // Reference to the 'moderatordetails' collection and the specific document
      var moderatorRef = FirebaseFirestore.instance.collection('moderatordetails').doc(moderatorId);

      // Map to hold fields that need to be updated
      Map<String, dynamic> updatedFields = {};

      // Add fields to the map if they are non-null
      if (withdrawAmount != null) {
        updatedFields['Withdraw_amount'] = withdrawAmount;
      }
      if (withdrawRequest != null) {
        updatedFields['Withdraw_request'] = withdrawRequest;
      }

      // Update the document with the specified fields
      await moderatorRef.update(updatedFields);

      print("Moderator details updated successfully!");
    } catch (e) {
      print("Error updating moderator details: $e");
    }
  }
  Future<String?> getUserName(String email) async {
    var userDoc = await FirebaseFirestore.instance
        .collection('moderatordetails') // Your first collection
        .doc(email) // Email is the primary key
        .get();

    if (userDoc.exists) {
      return userDoc.data()?['Mod_name']; // Assuming the field name is 'name'
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getUserDataByName(String name) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('Cpdetails') // Your second collection
        .where('Mod_name', isEqualTo: name)
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
  Future<void> deletecpdetails(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Cpdetails') // Replace with your collection name
          .doc(orderId)
          .delete();
    } catch (e) {
      throw e.toString();
    }
  }
  Future<void> updateData(String docId, Map<String, dynamic> updatedData) async {
    try {
      await FirebaseFirestore.instance
          .collection('moderatordetails')
          .doc(docId)
          .update(updatedData);
      print("Document updated successfully!");
    } catch (e) {
      print("Error updating document: $e");
    }
  }
  Future<Stream<QuerySnapshot>> getUpdateRequests() async {
    return FirebaseFirestore.instance
        .collection('update_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

}
