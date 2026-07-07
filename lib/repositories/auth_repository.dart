import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

class AuthRepository {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  static const String usersCollection = 'users';

  AuthRepository({
    FirebaseAuthService? authService,
    FirestoreService? firestoreService,
  })  : _authService = authService ?? FirebaseAuthService(),
        _firestoreService = firestoreService ?? FirestoreService();

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _authService.registerWithEmail(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    final newUser = UserModel(
      uid: uid,
      email: email,
      name: name,
      role: UserRole.student, // placeholder until role selection
      onboardingComplete: false,
      createdAt: DateTime.now(),
    );

    await _firestoreService.setDoc(usersCollection, uid, newUser.toMap());
    await _authService.sendEmailVerification();
    return newUser;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.loginWithEmail(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    return fetchUserProfile(uid);
  }

  Future<UserModel> fetchUserProfile(String uid) async {
    final doc = await _firestoreService.getDoc(usersCollection, uid);
    if (!doc.exists) {
      throw Exception('No profile found for this account.');
    }
    return UserModel.fromMap(uid, doc.data()!);
  }

  Future<void> setRole(String uid, UserRole role) async {
    await _firestoreService.setDoc(usersCollection, uid, {
      'role': roleToString(role),
      'onboardingComplete': true,
    });
  }

  Future<void> sendPasswordReset(String email) =>
      _authService.sendPasswordResetEmail(email);

  Future<void> signOut() => _authService.signOut();

  String mapError(Object e) => _authService.mapAuthError(e);
}
