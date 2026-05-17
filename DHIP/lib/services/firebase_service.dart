import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/design_model.dart';
import '../models/user_model.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ AUTHENTICATION ============

  /// Register user with email and password
  static Future<AppUser?> registerUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await Future.delayed(const Duration(milliseconds: 500));

      final appUser = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        displayName: userCredential.user?.displayName,
        createdAt: DateTime.now(),
      );

      // Save user to Firestore
      await _firestore
          .collection('users')
          .doc(appUser.uid)
          .set(appUser.toJson());

      return appUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'Password is too weak';
      } else if (e.code == 'email-already-in-use') {
        throw 'Email already exists';
      } else {
        throw e.message ?? 'Registration failed';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  /// Login user with email and password
  static Future<AppUser?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return AppUser.fromJson(doc.data()!);
      } else {
        // fallback: build AppUser directly from FirebaseAuth
        final user = userCredential.user!;
        return AppUser(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          createdAt: DateTime.now(),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password';
      } else {
        throw e.message ?? 'Login failed';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }


  /// Logout user
  static Future<void> logoutUser() async {
    await _auth.signOut();
  }

  /// Get current user
  static User? getCurrentUser() => _auth.currentUser;

  /// Get current user stream
  static Stream<User?> getUserStream() => _auth.authStateChanges();

  // ============ DESIGN OPERATIONS ============

  /// Save design to Firestore
  static Future<void> saveDesign({
    required String userId,
    required RoomDesign design,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('designs')
          .doc(design.id)
          .set(design.toJson());
    } catch (e) {
      throw 'Error saving design: $e';
    }
  }

  /// Get all designs for user
  static Future<List<RoomDesign>> getUserDesigns(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('designs')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RoomDesign.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Error fetching designs: $e';
    }
  }

  /// Stream of user designs (real-time updates)
  static Stream<List<RoomDesign>> getUserDesignsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('designs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RoomDesign.fromJson(doc.data()))
        .toList());
  }

  /// Delete design
  static Future<void> deleteDesign({
    required String userId,
    required String designId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('designs')
          .doc(designId)
          .delete();
    } catch (e) {
      throw 'Error deleting design: $e';
    }
  }

  /// Update design
  static Future<void> updateDesign({
    required String userId,
    required RoomDesign design,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('designs')
          .doc(design.id)
          .update(design.toJson());
    } catch (e) {
      throw 'Error updating design: $e';
    }
  }
}