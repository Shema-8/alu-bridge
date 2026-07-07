import '../models/application_model.dart';
import '../services/firestore_service.dart';

class ApplicationRepository {
  final FirestoreService _firestoreService;
  static const String collectionPath = 'applications';

  ApplicationRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  /// Real-time list of a student's own applications, newest first.
  Stream<List<ApplicationModel>> watchForStudent(String studentId) {
    return _firestoreService
        .collection(collectionPath)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snap) {
      final apps = snap.docs
          .map((d) => ApplicationModel.fromMap(d.id, d.data()))
          .toList();
      apps.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return apps;
    });
  }

  /// Used to disable the "Apply" button if the student already applied.
  Future<bool> hasApplied(String studentId, String internshipId) async {
    final snap = await _firestoreService
        .collection(collectionPath)
        .where('studentId', isEqualTo: studentId)
        .where('internshipId', isEqualTo: internshipId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> submit(ApplicationModel application) {
    return _firestoreService.collection(collectionPath).add(application.toMap());
  }
}
