import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._api);

  static const bool useFirebaseAuth = bool.fromEnvironment('USE_FIREBASE_AUTH', defaultValue: false);
  static const bool useFirebaseMessaging = bool.fromEnvironment('USE_FIREBASE_MESSAGING', defaultValue: false);

  final ApiClient _api;
  bool booting = true;
  bool loading = false;
  String? token;
  AppUser? user;
  String? error;

  bool get isLoggedIn => token != null && user != null;

  Future<void> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedUser = prefs.getString('user');
      if (cachedUser != null && cachedUser.isNotEmpty) {
        user = AppUser.fromJson(Map<String, dynamic>.from(jsonDecode(cachedUser)));
      }

      if (useFirebaseAuth) {
        final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
        if (firebaseUser == null) {
          await logout(silent: true);
          return;
        }
        token = await firebaseUser.getIdToken(true);
      } else {
        token = prefs.getString('token');
      }

      if (token != null) {
        _api.setToken(token);
        final fresh = await _api.get('/auth/me');
        user = AppUser.fromJson(Map<String, dynamic>.from(fresh['user']));
        await _saveSession();
        await syncFcmToken();
      }
    } catch (_) {
      await logout(silent: true);
    } finally {
      booting = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      if (useFirebaseAuth) {
        final credential = await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        token = await credential.user!.getIdToken(true);
        _api.setToken(token);
        final data = await _api.get('/auth/me');
        user = AppUser.fromJson(Map<String, dynamic>.from(data['user']));
      } else {
        final data = await _api.post('/auth/login', body: {'email': email, 'password': password});
        token = data['token'];
        user = AppUser.fromJson(Map<String, dynamic>.from(data['user']));
        _api.setToken(token);
      }
      await _saveSession();
      await syncFcmToken();
    } catch (e) {
      error = _friendlyFirebaseError(e);
      throw Exception(error);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      if (useFirebaseAuth) {
        final credential = await firebase_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        await credential.user!.updateDisplayName(name.trim());
        await credential.user!.reload();
        final current = firebase_auth.FirebaseAuth.instance.currentUser!;
        token = await current.getIdToken(true);
        _api.setToken(token);
        final data = await _api.get('/auth/me');
        user = AppUser.fromJson(Map<String, dynamic>.from(data['user']));
      } else {
        final data = await _api.post('/auth/register', body: {'name': name, 'email': email, 'password': password});
        token = data['token'];
        user = AppUser.fromJson(Map<String, dynamic>.from(data['user']));
        _api.setToken(token);
      }
      await _saveSession();
      await syncFcmToken();
    } catch (e) {
      error = _friendlyFirebaseError(e);
      throw Exception(error);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> updateLocation(double lat, double lng) async {
    if (!isLoggedIn) return;
    final data = await _api.patch('/auth/me', body: {'latitude': lat, 'longitude': lng});
    user = AppUser.fromJson(Map<String, dynamic>.from(data['user']));
    await _saveSession();
    notifyListeners();
  }

  Future<void> syncFcmToken() async {
    if (!useFirebaseAuth || !useFirebaseMessaging || !isLoggedIn) return;
    try {
      await FirebaseMessaging.instance.requestPermission();
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await _api.post('/device/fcm-token', body: {'fcm_token': fcmToken});
      }
    } catch (_) {
      // FCM should never block login. In-app notifications still work through PostgreSQL.
    }
  }

  Future<void> logout({bool silent = false}) async {
    if (useFirebaseAuth) {
      try {
        await firebase_auth.FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
    token = null;
    user = null;
    _api.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    if (!silent) notifyListeners();
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (token != null) await prefs.setString('token', token!);
    if (user != null) {
      await prefs.setString('user', jsonEncode({
        'id': user!.id,
        'name': user!.name,
        'email': user!.email,
        'avatar_url': user!.avatarUrl,
        'radius_km': user!.radiusKm,
        'latitude': user!.latitude,
        'longitude': user!.longitude,
      }));
    }
  }

  String _friendlyFirebaseError(Object e) {
    if (e is firebase_auth.FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'Format email tidak valid.';
        case 'user-disabled':
          return 'Akun ini dinonaktifkan.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email atau password salah.';
        case 'email-already-in-use':
          return 'Email sudah terdaftar.';
        case 'weak-password':
          return 'Password terlalu lemah.';
        case 'network-request-failed':
          return 'Koneksi internet bermasalah.';
        default:
          return e.message ?? e.code;
      }
    }
    return e.toString().replaceFirst('Exception: ', '');
  }
}
