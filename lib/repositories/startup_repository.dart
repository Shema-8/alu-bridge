import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/startup_model.dart';
import '../services/firestore_service.dart';

class StartupRepository {
  final FirestoreService _firestoreService;
  static const String collectionPath = 'startups';

  StartupRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<void> createOrUpdateProfile(StartupModel startup) async {
    final data = startup.toMap();
  
    final existing = await _firestoreService.getDoc(collectionPath, startup.startupId);
    if (!existing.exists) {
      data['createdAt'] = startup.createdAt.toIso8601String();
    }
    await _firestoreService.setDoc(collectionPath, startup.startupId, data);
  }

  /// Real-time profile for the CURRENT founder's own startup.
  Stream<StartupModel?> watchByfounderId(String uid) {
    return _firestoreService.watchDoc(collectionPath, uid).map(
        (doc) => doc.exists ? StartupModel.fromMap(doc.id, doc.data()!) : null);
  }

  /// All startups awaiting admin review — used by the verification screen.
  Stream<List<StartupModel>> watchPending() {
    return _firestoreService
        .collection(collectionPath)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => StartupModel.fromMap(d.id, d.data())).toList());
  }

  Future<void> setStatus(String startupId, VerificationStatus status) {
    return _firestoreService.collection(collectionPath).doc(startupId).update({
      'status': status.name,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }
}
