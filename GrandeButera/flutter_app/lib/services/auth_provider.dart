import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  static bool _googleInitialized = false;
  static const String _googleServerClientId = '912344465247-uk3mq5jfbf6u0sceths00s4t6tkggicb.apps.googleusercontent.com';

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      final token = await ApiService.getToken();
      if (token != null) {
        final res = await ApiService.getMe();
        if (res['success'] == true) {
          _user = UserModel.fromJson(res['data']['user']);
        }
      }
    } catch (_) {
      await ApiService.clearToken();
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(serverClientId: _googleServerClientId);
    _googleInitialized = true;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final res = await ApiService.login(email, password);
      if (res['success'] == true) {
        await ApiService.saveToken(res['data']['token']);
        _user = UserModel.fromJson(res['data']['user']);
        _isLoading = false; notifyListeners();
        return true;
      }
    } catch (e) { _error = e.toString(); }
    _isLoading = false; notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password, {String? phone}) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final res = await ApiService.register(name, email, password, phone: phone);
      if (res['success'] == true) {
        await ApiService.saveToken(res['data']['token']);
        _user = UserModel.fromJson(res['data']['user']);
        _isLoading = false; notifyListeners();
        return true;
      }
    } catch (e) { _error = e.toString(); }
    _isLoading = false; notifyListeners();
    return false;
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _ensureGoogleInitialized();

      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final googleIdToken = googleAuth.idToken;

      if (googleIdToken == null || googleIdToken.isEmpty) {
        throw Exception('Google ID token is empty. Check SHA-1 and google-services.json.');
      }

      final credential = GoogleAuthProvider.credential(idToken: googleIdToken);
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw Exception('Firebase ID token is empty');
      }

      final res = await ApiService.loginWithFirebase(firebaseIdToken);

      if (res['success'] == true) {
        await ApiService.saveToken(res['data']['token']);
        _user = UserModel.fromJson(res['data']['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = res['message']?.toString() ?? 'Google login failed';
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try { await FirebaseAuth.instance.signOut(); } catch (_) {}
    try { await GoogleSignIn.instance.signOut(); } catch (_) {}
    await ApiService.clearToken();
    _user = null;
    notifyListeners();
  }

  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearError() { _error = null; notifyListeners(); }
}
