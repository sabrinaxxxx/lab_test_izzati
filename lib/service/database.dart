import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future<void> addStaffDetails(
      Map<String, dynamic> staffInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Staff")
        .doc(id)
        .set(staffInfoMap);
  }

  Stream<QuerySnapshot> getStaffDetails() {
    return FirebaseFirestore.instance.collection("Staff").snapshots();
  }

  Future<void> updateStaffDetails(String id, Map<String, dynamic> newData) async {
    return await FirebaseFirestore.instance
        .collection("Staff")
        .doc(id)
        .update(newData);
  }

  Future<void> deleteStaff(String id) async {
    return await FirebaseFirestore.instance
        .collection("Staff")
        .doc(id)
        .delete();
  }
  
}
