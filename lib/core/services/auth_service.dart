import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickride/core/models/ride_model.dart';
import 'package:quickride/core/models/user_model.dart';
import 'package:quickride/core/services/local_storage_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<AppUser?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user == null) return null;

      // Create user document in Firestore
      final appUser = AppUser(
        id: user.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
        totalRides: 0,
        rating: 5.0,
        isOnline: false,
      );

      await _firestore.collection('users').doc(user.uid).set(appUser.toJson());

      // Save session locally
      await _localStorage.saveUserSession(
        userId: user.uid,
        role: role.name,
      );

      return appUser;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      final userData = await getUserData(_auth.currentUser!.uid);
      if (userData != null) {
        // Save session locally
        await _localStorage.saveUserSession(
          userId: userData.id,
          role: userData.role.name,
        );
      }

      return userData;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<AppUser?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Get user data error: $e');
      return null;
    }
  }

  // Update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Update user data error: $e');
      rethrow;
    }
  }

  // Update driver online status
  Future<void> updateDriverStatus(String uid, bool isOnline) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isOnline': isOnline,
      });
    } catch (e) {
      print('Update driver status error: $e');
      rethrow;
    }
  }

  // Update driver location
  Future<void> updateDriverLocation(String uid, LocationData location) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLocation': location.toJson(),
      });
    } catch (e) {
      print('Update driver location error: $e');
      throw e;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // If driver, set offline
      if (_auth.currentUser != null) {
        final userData = await getUserData(_auth.currentUser!.uid);
        if (userData?.role == UserRole.driver) {
          await updateDriverStatus(_auth.currentUser!.uid, false);
        }
      }
      await _localStorage.clearSession();
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }
}
