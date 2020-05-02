import 'package:cloud_firestore/cloud_firestore.dart';

class Repository {
  final informationCollection = Firestore.instance.collection("info");

  Future<void> addNewInfo(String face, String senti) async {
    final Map data = {
      'faceInfo': face,
      'sentInfo': senti
    };
    await informationCollection.add(data);
  }
}