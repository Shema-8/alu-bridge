import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _db.collection(path);

  Future<void> setDoc(String collectionPath, String docId, Map<String, dynamic> data) {
    return _db.collection(collectionPath).doc(docId).set(data, SetOptions(merge: true));
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDoc(
      String collectionPath, String docId) {
    return _db.collection(collectionPath).doc(docId).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDoc(
      String collectionPath, String docId) {
    return _db.collection(collectionPath).doc(docId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollection(
      String collectionPath) {
    return _db.collection(collectionPath).snapshots();
  }

  Future<void> deleteDoc(String collectionPath, String docId) {
    return _db.collection(collectionPath).doc(docId).delete();
  }
}
