import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory FirebaseAuthService() {
    return _instance;
  }

  FirebaseAuthService._internal();

  firebase_auth.User? get currentUser => _auth.currentUser;

  Future<String?> signup(String name, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'uid': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'itemsListed': 0,
        'itemsSold': 0,
        'itemsBought': 0,
      });

      return null; // Success
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'Password is too weak';
      } else if (e.code == 'email-already-in-use') {
        return 'Email already registered';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email format';
      }
      return e.message ?? 'Signup failed';
    } catch (e) {
      return 'Signup failed: ${e.toString()}';
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'Email not registered';
      } else if (e.code == 'wrong-password') {
        return 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email format';
      }
      return e.message ?? 'Login failed';
    } catch (e) {
      return 'Login failed: ${e.toString()}';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel(
          id: uid,
          name: doc['name'] ?? 'Unknown',
          email: doc['email'] ?? '',
          itemsListed: doc['itemsListed'] ?? 0,
          itemsSold: doc['itemsSold'] ?? 0,
          itemsBought: doc['itemsBought'] ?? 0,
          createdAt: (doc['createdAt'] as Timestamp).toDate(),
        );
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Stream<UserModel?> getUserProfileStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel(
          id: uid,
          name: doc['name'] ?? 'Unknown',
          email: doc['email'] ?? '',
          itemsListed: doc['itemsListed'] ?? 0,
          itemsSold: doc['itemsSold'] ?? 0,
          itemsBought: doc['itemsBought'] ?? 0,
          createdAt: (doc['createdAt'] as Timestamp).toDate(),
        );
      }
      return null;
    });
  }
}
