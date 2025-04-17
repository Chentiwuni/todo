import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get userChanges => _auth.authStateChanges();

  Future<User?> signIn(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    await FirestoreService().ensureDefaultCategory(); // Ensures 'Personal' exists
    return userCredential.user;
  }

  Future<User?> register(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await FirestoreService().ensureDefaultCategory();
    return userCredential.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
