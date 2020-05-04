import 'package:cloud_firestore/cloud_firestore.dart';

class Repository {
  final informationCollection = Firestore.instance.collection("info");

  Future<void> addNewInfo(String face, String answer, String senti) async {
    await informationCollection.document()
      .setData({'face': face, 'answer': answer,'senti': senti});
  }
}