import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../utils/logger.dart';

@singleton
class PreferencesStorage {
  final SharedPreferences _prefs;

  PreferencesStorage(this._prefs);

  // Theme settings
  Future<void> setThemeMode(String themeMode) async {
    try {
      await _prefs.setString(AppConstants.themeKey, themeMode);
      AppLogger.debug('Theme mode saved: $themeMode');
    } catch (e) {
      AppLogger.error('Error saving theme mode', error: e);
      rethrow;
    }
  }

  String getThemeMode() {
    try {
      return _prefs.getString(AppConstants.themeKey) ?? 'system';
    } catch (e) {
      AppLogger.error('Error retrieving theme mode', error: e);
      return 'system';
    }
  }

  // Language settings
  Future<void> setLanguage(String language) async {
    try {
      await _prefs.setString(AppConstants.languageKey, language);
      AppLogger.debug('Language saved: $language');
    } catch (e) {
      AppLogger.error('Error saving language', error: e);
      rethrow;
    }
  }

  String getLanguage() {
    try {
      return _prefs.getString(AppConstants.languageKey) ?? 'es';
    } catch (e) {
      AppLogger.error('Error retrieving language', error: e);
      return 'es';
    }
  }

  // Onboarding status
  Future<void> setOnboardingCompleted(bool completed) async {
    try {
      await _prefs.setBool(AppConstants.onboardingKey, completed);
      AppLogger.debug('Onboarding completed: $completed');
    } catch (e) {
      AppLogger.error('Error saving onboarding status', error: e);
      rethrow;
    }
  }

  bool getOnboardingCompleted() {
    try {
      return _prefs.getBool(AppConstants.onboardingKey) ?? false;
    } catch (e) {
      AppLogger.error('Error retrieving onboarding status', error: e);
      return false;
    }
  }

  // Location permission
  Future<void> setLocationEnabled(bool enabled) async {
    try {
      await _prefs.setBool(AppConstants.locationKey, enabled);
      AppLogger.debug('Location enabled: $enabled');
    } catch (e) {
      AppLogger.error('Error saving location setting', error: e);
      rethrow;
    }
  }

  bool getLocationEnabled() {
    try {
      return _prefs.getBool(AppConstants.locationKey) ?? false;
    } catch (e) {
      AppLogger.error('Error retrieving location setting', error: e);
      return false;
    }
  }

  // Notification settings
  Future<void> setNotificationEnabled(bool enabled) async {
    try {
      await _prefs.setBool(AppConstants.notificationKey, enabled);
      AppLogger.debug('Notifications enabled: $enabled');
    } catch (e) {
      AppLogger.error('Error saving notification setting', error: e);
      rethrow;
    }
  }

  bool getNotificationEnabled() {
    try {
      return _prefs.getBool(AppConstants.notificationKey) ?? true;
    } catch (e) {
      AppLogger.error('Error retrieving notification setting', error: e);
      return true;
    }
  }

  // Map settings
  Future<void> setMapLatitude(double latitude) async {
    try {
      await _prefs.setDouble('map_latitude', latitude);
      AppLogger.debug('Map latitude saved: $latitude');
    } catch (e) {
      AppLogger.error('Error saving map latitude', error: e);
      rethrow;
    }
  }

  double getMapLatitude() {
    try {
      return _prefs.getDouble('map_latitude') ?? AppConstants.defaultLatitude;
    } catch (e) {
      AppLogger.error('Error retrieving map latitude', error: e);
      return AppConstants.defaultLatitude;
    }
  }

  Future<void> setMapLongitude(double longitude) async {
    try {
      await _prefs.setDouble('map_longitude', longitude);
      AppLogger.debug('Map longitude saved: $longitude');
    } catch (e) {
      AppLogger.error('Error saving map longitude', error: e);
      rethrow;
    }
  }

  double getMapLongitude() {
    try {
      return _prefs.getDouble('map_longitude') ?? AppConstants.defaultLongitude;
    } catch (e) {
      AppLogger.error('Error retrieving map longitude', error: e);
      return AppConstants.defaultLongitude;
    }
  }

  Future<void> setMapZoom(double zoom) async {
    try {
      await _prefs.setDouble('map_zoom', zoom);
      AppLogger.debug('Map zoom saved: $zoom');
    } catch (e) {
      AppLogger.error('Error saving map zoom', error: e);
      rethrow;
    }
  }

  double getMapZoom() {
    try {
      return _prefs.getDouble('map_zoom') ?? AppConstants.defaultZoom;
    } catch (e) {
      AppLogger.error('Error retrieving map zoom', error: e);
      return AppConstants.defaultZoom;
    }
  }

  // Map layer settings
  Future<void> setMapLayer(String layer) async {
    try {
      await _prefs.setString('map_layer', layer);
      AppLogger.debug('Map layer saved: $layer');
    } catch (e) {
      AppLogger.error('Error saving map layer', error: e);
      rethrow;
    }
  }

  String getMapLayer() {
    try {
      return _prefs.getString('map_layer') ?? 'osm';
    } catch (e) {
      AppLogger.error('Error retrieving map layer', error: e);
      return 'osm';
    }
  }

  // Crime data filters
  Future<void> setCrimeFilters(List<String> filters) async {
    try {
      await _prefs.setStringList('crime_filters', filters);
      AppLogger.debug('Crime filters saved: $filters');
    } catch (e) {
      AppLogger.error('Error saving crime filters', error: e);
      rethrow;
    }
  }

  List<String> getCrimeFilters() {
    try {
      return _prefs.getStringList('crime_filters') ?? [];
    } catch (e) {
      AppLogger.error('Error retrieving crime filters', error: e);
      return [];
    }
  }

  // Data sources
  Future<void> setDataSources(List<String> sources) async {
    try {
      await _prefs.setStringList('data_sources', sources);
      AppLogger.debug('Data sources saved: $sources');
    } catch (e) {
      AppLogger.error('Error saving data sources', error: e);
      rethrow;
    }
  }

  List<String> getDataSources() {
    try {
      return _prefs.getStringList('data_sources') ?? [
        AppConstants.sourceSecretariado,
        AppConstants.sourceAnerpv,
        AppConstants.sourceSkyAngel,
      ];
    } catch (e) {
      AppLogger.error('Error retrieving data sources', error: e);
      return [
        AppConstants.sourceSecretariado,
        AppConstants.sourceAnerpv,
        AppConstants.sourceSkyAngel,
      ];
    }
  }

  // Cache settings
  Future<void> setCacheEnabled(bool enabled) async {
    try {
      await _prefs.setBool('cache_enabled', enabled);
      AppLogger.debug('Cache enabled: $enabled');
    } catch (e) {
      AppLogger.error('Error saving cache setting', error: e);
      rethrow;
    }
  }

  bool getCacheEnabled() {
    try {
      return _prefs.getBool('cache_enabled') ?? true;
    } catch (e) {
      AppLogger.error('Error retrieving cache setting', error: e);
      return true;
    }
  }

  Future<void> setCacheSize(int size) async {
    try {
      await _prefs.setInt('cache_size', size);
      AppLogger.debug('Cache size saved: $size');
    } catch (e) {
      AppLogger.error('Error saving cache size', error: e);
      rethrow;
    }
  }

  int getCacheSize() {
    try {
      return _prefs.getInt('cache_size') ?? AppConstants.maxCacheSize;
    } catch (e) {
      AppLogger.error('Error retrieving cache size', error: e);
      return AppConstants.maxCacheSize;
    }
  }

  // Last update timestamps
  Future<void> setLastUpdateTime(String key, DateTime time) async {
    try {
      await _prefs.setString('last_update_$key', time.toIso8601String());
      AppLogger.debug('Last update time saved for $key: $time');
    } catch (e) {
      AppLogger.error('Error saving last update time for $key', error: e);
      rethrow;
    }
  }

  DateTime? getLastUpdateTime(String key) {
    try {
      final timeString = _prefs.getString('last_update_$key');
      return timeString != null ? DateTime.tryParse(timeString) : null;
    } catch (e) {
      AppLogger.error('Error retrieving last update time for $key', error: e);
      return null;
    }
  }

  // User preferences
  Future<void> setUserPreference(String key, dynamic value) async {
    try {
      if (value is String) {
        await _prefs.setString('user_pref_$key', value);
      } else if (value is bool) {
        await _prefs.setBool('user_pref_$key', value);
      } else if (value is int) {
        await _prefs.setInt('user_pref_$key', value);
      } else if (value is double) {
        await _prefs.setDouble('user_pref_$key', value);
      } else if (value is List<String>) {
        await _prefs.setStringList('user_pref_$key', value);
      } else {
        throw ArgumentError('Unsupported preference type: ${value.runtimeType}');
      }
      AppLogger.debug('User preference saved: $key = $value');
    } catch (e) {
      AppLogger.error('Error saving user preference: $key', error: e);
      rethrow;
    }
  }

  T? getUserPreference<T>(String key) {
    try {
      final prefKey = 'user_pref_$key';
      
      if (T == String) {
        return _prefs.getString(prefKey) as T?;
      } else if (T == bool) {
        return _prefs.getBool(prefKey) as T?;
      } else if (T == int) {
        return _prefs.getInt(prefKey) as T?;
      } else if (T == double) {
        return _prefs.getDouble(prefKey) as T?;
      } else if (T == List<String>) {
        return _prefs.getStringList(prefKey) as T?;
      } else {
        throw ArgumentError('Unsupported preference type: $T');
      }
    } catch (e) {
      AppLogger.error('Error retrieving user preference: $key', error: e);
      return null;
    }
  }

  // Generic methods
  Future<void> setString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
      AppLogger.debug('String saved: $key');
    } catch (e) {
      AppLogger.error('Error saving string: $key', error: e);
      rethrow;
    }
  }

  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      AppLogger.error('Error retrieving string: $key', error: e);
      return null;
    }
  }

  Future<void> setBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
      AppLogger.debug('Bool saved: $key = $value');
    } catch (e) {
      AppLogger.error('Error saving bool: $key', error: e);
      rethrow;
    }
  }

  bool getBool(String key, {bool defaultValue = false}) {
    try {
      return _prefs.getBool(key) ?? defaultValue;
    } catch (e) {
      AppLogger.error('Error retrieving bool: $key', error: e);
      return defaultValue;
    }
  }

  Future<void> setInt(String key, int value) async {
    try {
      await _prefs.setInt(key, value);
      AppLogger.debug('Int saved: $key = $value');
    } catch (e) {
      AppLogger.error('Error saving int: $key', error: e);
      rethrow;
    }
  }

  int getInt(String key, {int defaultValue = 0}) {
    try {
      return _prefs.getInt(key) ?? defaultValue;
    } catch (e) {
      AppLogger.error('Error retrieving int: $key', error: e);
      return defaultValue;
    }
  }

  Future<void> setDouble(String key, double value) async {
    try {
      await _prefs.setDouble(key, value);
      AppLogger.debug('Double saved: $key = $value');
    } catch (e) {
      AppLogger.error('Error saving double: $key', error: e);
      rethrow;
    }
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    try {
      return _prefs.getDouble(key) ?? defaultValue;
    } catch (e) {
      AppLogger.error('Error retrieving double: $key', error: e);
      return defaultValue;
    }
  }

  Future<void> setStringList(String key, List<String> value) async {
    try {
      await _prefs.setStringList(key, value);
      AppLogger.debug('String list saved: $key');
    } catch (e) {
      AppLogger.error('Error saving string list: $key', error: e);
      rethrow;
    }
  }

  List<String> getStringList(String key) {
    try {
      return _prefs.getStringList(key) ?? [];
    } catch (e) {
      AppLogger.error('Error retrieving string list: $key', error: e);
      return [];
    }
  }

  Future<void> remove(String key) async {
    try {
      await _prefs.remove(key);
      AppLogger.debug('Key removed: $key');
    } catch (e) {
      AppLogger.error('Error removing key: $key', error: e);
    }
  }

  bool containsKey(String key) {
    try {
      return _prefs.containsKey(key);
    } catch (e) {
      AppLogger.error('Error checking key existence: $key', error: e);
      return false;
    }
  }

  Future<void> clear() async {
    try {
      await _prefs.clear();
      AppLogger.info('All preferences cleared');
    } catch (e) {
      AppLogger.error('Error clearing preferences', error: e);
    }
  }

  Set<String> getKeys() {
    try {
      return _prefs.getKeys();
    } catch (e) {
      AppLogger.error('Error retrieving keys', error: e);
      return {};
    }
  }
}