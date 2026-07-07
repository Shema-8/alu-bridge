import '../models/internship_model.dart';
import '../services/firestore_service.dart';

class InternshipRepository {
  final FirestoreService _firestoreService;
  static const String collectionPath = 'internships';

  InternshipRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<InternshipModel>> watchAll() {
    return _firestoreService
        .collection(collectionPath)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => InternshipModel.fromMap(d.id, d.data()))
            .toList());
  }

  Stream<InternshipModel?> watchById(String id) {
    return _firestoreService.watchDoc(collectionPath, id).map(
        (doc) => doc.exists ? InternshipModel.fromMap(doc.id, doc.data()!) : null);
  }

  Future<void> create(InternshipModel internship) {
    return _firestoreService.collection(collectionPath).add(internship.toMap());
  }

  Stream<List<InternshipModel>> watchByStartup(String startupId) {
    return _firestoreService
        .collection(collectionPath)
        .where('startupId', isEqualTo: startupId)
        .snapshots()
        .map((snap) {
      final items =
          snap.docs.map((d) => InternshipModel.fromMap(d.id, d.data())).toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  Future<void> delete(String internshipId) {
    return _firestoreService.deleteDoc(collectionPath, internshipId);
  }
}
