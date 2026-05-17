import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/furniture_model.dart';
import '../models/design_model.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class AppProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  FurnitureItem? _selectedFurniture;
  List<RoomDesign> _savedDesigns = [];
  String? _selectedRoomCategory;
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  // NEW: Track the design currently being edited
  RoomDesign? _editingDesign;

  // Getters
  ThemeMode get themeMode => _themeMode;
  FurnitureItem? get selectedFurniture => _selectedFurniture;
  List<RoomDesign> get savedDesigns => _savedDesigns;
  String? get selectedRoomCategory => _selectedRoomCategory;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  RoomDesign? get editingDesign => _editingDesign; // ✅ getter

  AppProvider() {
    _initializeAuth();
  }

  // ============ AUTHENTICATION ============

  // With this:
  void _initializeAuth() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _currentUser = AppUser(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          createdAt: DateTime.now(),
        );
        _loadFirebaseDesigns();
      } else {
        _currentUser = null;
        _savedDesigns = [];
        _editingDesign = null;
      }
      notifyListeners();
    });
  }
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await FirebaseService.loginUser(
        email: email,
        password: password,
      );
      _currentUser = user;
      await _loadFirebaseDesigns();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> registerUser({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await FirebaseService.registerUser(
        email: email,
        password: password,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logoutUser() async {
    try {
      await FirebaseService.logoutUser();
      _currentUser = null;
      _savedDesigns = [];
      _editingDesign = null; // ✅ clear editing design
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ============ DESIGN OPERATIONS ============

  void toggleTheme() {
    _themeMode =
    _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void selectFurniture(FurnitureItem? item) {
    _selectedFurniture = item;
    notifyListeners();
  }

  void selectRoomCategory(String? categoryId) {
    _selectedRoomCategory = categoryId;
    notifyListeners();
  }

  // ✅ Editing design helpers
  void setEditingDesign(RoomDesign design) {
    _editingDesign = design;
    notifyListeners();
  }

  void clearEditingDesign() {
    _editingDesign = null;
    notifyListeners();
  }

  Future<void> saveDesign(RoomDesign design) async {
    if (_currentUser == null) {
      _error = 'Not logged in';
      notifyListeners();
      return;
    }

    try {
      await FirebaseService.saveDesign(
        userId: _currentUser!.uid,
        design: design,
      );

      final existing = _savedDesigns.indexWhere((d) => d.id == design.id);
      if (existing >= 0) {
        _savedDesigns[existing] = design;
      } else {
        _savedDesigns.insert(0, design);
      }

      _editingDesign = null; // ✅ clear after save
      notifyListeners();
    } catch (e) {
      _error = 'Error saving design: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteDesign(String id) async {
    if (_currentUser == null) {
      _error = 'Not logged in';
      notifyListeners();
      return;
    }

    try {
      await FirebaseService.deleteDesign(
        userId: _currentUser!.uid,
        designId: id,
      );

      _savedDesigns.removeWhere((d) => d.id == id);
      if (_editingDesign?.id == id) {
        _editingDesign = null; // ✅ clear if deleted
      }
      notifyListeners();
    } catch (e) {
      _error = 'Error deleting design: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _loadFirebaseDesigns() async {
    if (_currentUser == null) return;

    try {
      _savedDesigns = await FirebaseService.getUserDesigns(_currentUser!.uid);
      notifyListeners();
    } catch (e) {
      _error = 'Error loading designs: $e';
      notifyListeners();
    }
  }

  Stream<List<RoomDesign>> getDesignsStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }
    return FirebaseService.getUserDesignsStream(_currentUser!.uid);
  }
}
