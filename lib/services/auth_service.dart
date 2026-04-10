import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email, password: password,
    );
    await credential.user?.updateDisplayName(name);
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'createdAt': Timestamp.now(),
      'issuesReported': 0,
    });
    return credential;
  }
 

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email, password: password,
    );
  }

  Future<void> signOut() async => await _auth.signOut();

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<bool> isAdmin() async {
    if (currentUser == null) return false;
    final profile = await getUserProfile(currentUser!.uid);
    return profile?['role'] == 'admin';
  }
}