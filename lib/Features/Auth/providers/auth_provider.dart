import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

final authProvider = NotifierProvider<AuthController, bool>(AuthController.new);

class AuthController extends Notifier<bool> {
  @override
  bool build() {
    return Hive.box('settings').get('isLoggedIn', defaultValue: false) as bool;
  }

  Box get _usersBox => Hive.box('users');
  Box get _settingsBox => Hive.box('settings');

  String _hashPassword(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();

    return sha256.convert(utf8.encode('$normalizedEmail:$password')).toString();
  }

  Future<void> signup(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (_usersBox.containsKey(normalizedEmail)) {
      throw Exception('An account with this email already exists.');
    }

    await _usersBox.put(normalizedEmail, {
      'email': normalizedEmail,
      'passwordHash': _hashPassword(normalizedEmail, password),
    });

    await _createSession(normalizedEmail);
  }

  Future<void> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final user = _usersBox.get(normalizedEmail);

    if (user == null) {
      throw Exception('No account found with this email.');
    }

    final savedHash = user['passwordHash'] as String;
    final enteredHash = _hashPassword(normalizedEmail, password);

    if (savedHash != enteredHash) {
      throw Exception('Incorrect password.');
    }

    await _createSession(normalizedEmail);
  }

  // ADD THIS METHOD INSIDE AuthController
  Future<void> _createSession(String email) async {
    await _settingsBox.put('isLoggedIn', true);
    await _settingsBox.put('email', email);

    state = true;
  }

  Future<void> logout() async {
    await _settingsBox.put('isLoggedIn', false);
    await _settingsBox.delete('email');

    state = false;
  }
}
