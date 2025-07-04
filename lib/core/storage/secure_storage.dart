import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';
import '../utils/logger.dart';

@singleton
class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage(this._storage);

  // Authentication tokens
  Future<void> setToken(String token) async {
    try {
      await _storage.write(key: AppConstants.userTokenKey, value: token);
      AppLogger.debug('Token stored securely');
    } catch (e) {
      AppLogger.error('Error storing token', error: e);
      rethrow;
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: AppConstants.userTokenKey);
    } catch (e) {
      AppLogger.error('Error retrieving token', error: e);
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: AppConstants.userTokenKey);
      AppLogger.debug('Token deleted');
    } catch (e) {
      AppLogger.error('Error deleting token', error: e);
    }
  }

  // Refresh token
  Future<void> setRefreshToken(String refreshToken) async {
    try {
      await _storage.write(key: '${AppConstants.userTokenKey}_refresh', value: refreshToken);
      AppLogger.debug('Refresh token stored securely');
    } catch (e) {
      AppLogger.error('Error storing refresh token', error: e);
      rethrow;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: '${AppConstants.userTokenKey}_refresh');
    } catch (e) {
      AppLogger.error('Error retrieving refresh token', error: e);
      return null;
    }
  }

  Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: '${AppConstants.userTokenKey}_refresh');
      AppLogger.debug('Refresh token deleted');
    } catch (e) {
      AppLogger.error('Error deleting refresh token', error: e);
    }
  }

  // User ID
  Future<void> setUserId(String userId) async {
    try {
      await _storage.write(key: AppConstants.userIdKey, value: userId);
      AppLogger.debug('User ID stored securely');
    } catch (e) {
      AppLogger.error('Error storing user ID', error: e);
      rethrow;
    }
  }

  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: AppConstants.userIdKey);
    } catch (e) {
      AppLogger.error('Error retrieving user ID', error: e);
      return null;
    }
  }

  Future<void> deleteUserId() async {
    try {
      await _storage.delete(key: AppConstants.userIdKey);
      AppLogger.debug('User ID deleted');
    } catch (e) {
      AppLogger.error('Error deleting user ID', error: e);
    }
  }

  // Biometric settings
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(key: AppConstants.biometricKey, value: enabled.toString());
      AppLogger.debug('Biometric setting stored: $enabled');
    } catch (e) {
      AppLogger.error('Error storing biometric setting', error: e);
      rethrow;
    }
  }

  Future<bool> getBiometricEnabled() async {
    try {
      final value = await _storage.read(key: AppConstants.biometricKey);
      return value?.toLowerCase() == 'true';
    } catch (e) {
      AppLogger.error('Error retrieving biometric setting', error: e);
      return false;
    }
  }

  Future<void> deleteBiometricEnabled() async {
    try {
      await _storage.delete(key: AppConstants.biometricKey);
      AppLogger.debug('Biometric setting deleted');
    } catch (e) {
      AppLogger.error('Error deleting biometric setting', error: e);
    }
  }

  // Generic secure storage methods
  Future<void> setString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      AppLogger.debug('String stored securely: $key');
    } catch (e) {
      AppLogger.error('Error storing string: $key', error: e);
      rethrow;
    }
  }

  Future<String?> getString(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      AppLogger.error('Error retrieving string: $key', error: e);
      return null;
    }
  }

  Future<void> setBool(String key, bool value) async {
    try {
      await _storage.write(key: key, value: value.toString());
      AppLogger.debug('Bool stored securely: $key = $value');
    } catch (e) {
      AppLogger.error('Error storing bool: $key', error: e);
      rethrow;
    }
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    try {
      final value = await _storage.read(key: key);
      return value?.toLowerCase() == 'true';
    } catch (e) {
      AppLogger.error('Error retrieving bool: $key', error: e);
      return defaultValue;
    }
  }

  Future<void> setInt(String key, int value) async {
    try {
      await _storage.write(key: key, value: value.toString());
      AppLogger.debug('Int stored securely: $key = $value');
    } catch (e) {
      AppLogger.error('Error storing int: $key', error: e);
      rethrow;
    }
  }

  Future<int?> getInt(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null ? int.tryParse(value) : null;
    } catch (e) {
      AppLogger.error('Error retrieving int: $key', error: e);
      return null;
    }
  }

  Future<void> setDouble(String key, double value) async {
    try {
      await _storage.write(key: key, value: value.toString());
      AppLogger.debug('Double stored securely: $key = $value');
    } catch (e) {
      AppLogger.error('Error storing double: $key', error: e);
      rethrow;
    }
  }

  Future<double?> getDouble(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null ? double.tryParse(value) : null;
    } catch (e) {
      AppLogger.error('Error retrieving double: $key', error: e);
      return null;
    }
  }

  Future<void> deleteKey(String key) async {
    try {
      await _storage.delete(key: key);
      AppLogger.debug('Key deleted: $key');
    } catch (e) {
      AppLogger.error('Error deleting key: $key', error: e);
    }
  }

  // Get all keys
  Future<Map<String, String>> getAllKeys() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      AppLogger.error('Error retrieving all keys', error: e);
      return {};
    }
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      AppLogger.error('Error checking key existence: $key', error: e);
      return false;
    }
  }

  // Clear all stored data
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      AppLogger.info('All secure storage cleared');
    } catch (e) {
      AppLogger.error('Error clearing all secure storage', error: e);
    }
  }

  // Clear authentication data
  Future<void> clearAuthData() async {
    try {
      await deleteToken();
      await deleteRefreshToken();
      await deleteUserId();
      AppLogger.info('Authentication data cleared');
    } catch (e) {
      AppLogger.error('Error clearing authentication data', error: e);
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final userId = await getUserId();
      return token != null && token.isNotEmpty && userId != null && userId.isNotEmpty;
    } catch (e) {
      AppLogger.error('Error checking login status', error: e);
      return false;
    }
  }

  // Store user credentials
  Future<void> storeCredentials({
    required String token,
    required String userId,
    String? refreshToken,
  }) async {
    try {
      await setToken(token);
      await setUserId(userId);
      if (refreshToken != null) {
        await setRefreshToken(refreshToken);
      }
      AppLogger.info('Credentials stored successfully');
    } catch (e) {
      AppLogger.error('Error storing credentials', error: e);
      rethrow;
    }
  }

  // Retrieve user credentials
  Future<Map<String, String?>> getCredentials() async {
    try {
      final token = await getToken();
      final userId = await getUserId();
      final refreshToken = await getRefreshToken();
      
      return {
        'token': token,
        'userId': userId,
        'refreshToken': refreshToken,
      };
    } catch (e) {
      AppLogger.error('Error retrieving credentials', error: e);
      return {
        'token': null,
        'userId': null,
        'refreshToken': null,
      };
    }
  }

  // Backup and restore functionality
  Future<Map<String, String>> backup() async {
    try {
      final allData = await getAllKeys();
      AppLogger.info('Secure storage backup created');
      return allData;
    } catch (e) {
      AppLogger.error('Error creating backup', error: e);
      return {};
    }
  }

  Future<void> restore(Map<String, String> data) async {
    try {
      await clearAll();
      for (final entry in data.entries) {
        await setString(entry.key, entry.value);
      }
      AppLogger.info('Secure storage restored from backup');
    } catch (e) {
      AppLogger.error('Error restoring from backup', error: e);
      rethrow;
    }
  }
}