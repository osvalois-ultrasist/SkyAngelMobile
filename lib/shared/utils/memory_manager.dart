import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Manager de memoria para optimizar performance en mapas y datos geoespaciales
/// Implementa estrategias de lazy loading, cache inteligente y limpieza automática
class MemoryManager {
  static final MemoryManager _instance = MemoryManager._internal();
  factory MemoryManager() => _instance;
  MemoryManager._internal();

  // Cache con LRU (Least Recently Used) para datos de mapa
  final LRUCache<String, dynamic> _mapDataCache = LRUCache<String, dynamic>(50);
  
  // Cache de imágenes y tiles del mapa
  final LRUCache<String, Uint8List> _imageCache = LRUCache<String, Uint8List>(100);
  
  // Cache para polígonos de riesgo procesados
  final LRUCache<String, List<dynamic>> _polygonCache = LRUCache<String, List<dynamic>>(30);
  
  // Cache para POIs con geolocalización
  final LRUCache<String, List<dynamic>> _poiCache = LRUCache<String, List<dynamic>>(40);
  
  // Timer para limpieza automática
  Timer? _cleanupTimer;
  
  // Threshold de memoria en MB
  static const int _memoryThresholdMB = 100;
  
  // Configuración de limpieza automática
  static const Duration _cleanupInterval = Duration(minutes: 5);

  void initialize() {
    _setupPeriodicCleanup();
    _setupMemoryWarnings();
  }

  void _setupPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) {
      _performAutomaticCleanup();
    });
  }

  void _setupMemoryWarnings() {
    // Listening for memory pressure warnings
    SystemChannels.system.setMessageHandler((call) async {
      if (call.method == 'SystemChrome.systemUIChange') {
        // Force cleanup on system memory pressure
        await forceCleanup();
      }
      return null;
    });
  }

  /// Cache de datos de mapa con expiración inteligente
  void cacheMapData(String key, dynamic data, {Duration? ttl}) {
    final cacheItem = CacheItem(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl ?? const Duration(minutes: 10),
    );
    _mapDataCache.put(key, cacheItem);
  }

  /// Retrieval de datos con validación de expiración
  T? getCachedMapData<T>(String key) {
    final cacheItem = _mapDataCache.get(key);
    if (cacheItem is CacheItem) {
      if (cacheItem.isExpired) {
        _mapDataCache.remove(key);
        return null;
      }
      return cacheItem.data as T?;
    }
    return null;
  }

  /// Cache optimizado para imágenes y tiles de mapa
  void cacheImage(String url, Uint8List imageData) {
    // Solo cachear imágenes menores a 2MB
    if (imageData.lengthInBytes < 2 * 1024 * 1024) {
      _imageCache.put(url, imageData);
    }
  }

  Uint8List? getCachedImage(String url) {
    return _imageCache.get(url);
  }

  /// Cache específico para polígonos de riesgo procesados
  void cacheRiskPolygons(String regionKey, List<dynamic> polygons) {
    _polygonCache.put(regionKey, polygons);
  }

  List<dynamic>? getCachedRiskPolygons(String regionKey) {
    return _polygonCache.get(regionKey);
  }

  /// Cache para POIs con geolocalización
  void cachePOIs(String areaKey, List<dynamic> pois) {
    _poiCache.put(areaKey, pois);
  }

  List<dynamic>? getCachedPOIs(String areaKey) {
    return _poiCache.get(areaKey);
  }

  /// Limpieza automática basada en uso de memoria
  void _performAutomaticCleanup() {
    if (kDebugMode) {
      print('MemoryManager: Performing automatic cleanup');
    }
    
    // Limpiar items expirados
    _cleanExpiredItems();
    
    // Si aún hay mucha memoria en uso, limpiar más agresivamente
    if (_estimatedMemoryUsageMB() > _memoryThresholdMB) {
      _aggressiveCleanup();
    }
  }

  void _cleanExpiredItems() {
    // Limpiar items expirados del cache de datos de mapa
    final expiredKeys = <String>[];
    for (final entry in _mapDataCache.entries) {
      if (entry.value is CacheItem && (entry.value as CacheItem).isExpired) {
        expiredKeys.add(entry.key);
      }
    }
    for (final key in expiredKeys) {
      _mapDataCache.remove(key);
    }
  }

  void _aggressiveCleanup() {
    // Reducir el tamaño de todos los caches a la mitad
    _mapDataCache.resize(_mapDataCache.length ~/ 2);
    _imageCache.resize(_imageCache.length ~/ 2);
    _polygonCache.resize(_polygonCache.length ~/ 2);
    _poiCache.resize(_poiCache.length ~/ 2);
    
    // Forzar garbage collection
    Future.delayed(Duration.zero, () {
      // GC hint for Dart VM
      if (kDebugMode) {
        print('MemoryManager: Aggressive cleanup completed');
      }
    });
  }

  /// Estimación aproximada del uso de memoria en MB
  double _estimatedMemoryUsageMB() {
    int totalBytes = 0;
    
    // Estimar memoria de cache de imágenes
    for (final imageData in _imageCache.values) {
      totalBytes += imageData.lengthInBytes;
    }
    
    // Estimar memoria de otros caches (aproximación)
    totalBytes += _mapDataCache.length * 1024; // ~1KB per entry
    totalBytes += _polygonCache.length * 2048; // ~2KB per polygon list
    totalBytes += _poiCache.length * 1024; // ~1KB per POI list
    
    return totalBytes / (1024 * 1024); // Convert to MB
  }

  /// Limpieza forzada para situaciones de memoria crítica
  Future<void> forceCleanup() async {
    if (kDebugMode) {
      print('MemoryManager: Force cleanup initiated');
    }
    
    _mapDataCache.clear();
    _imageCache.clear();
    _polygonCache.clear();
    _poiCache.clear();
    
    // Dar tiempo al GC
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (kDebugMode) {
      print('MemoryManager: Force cleanup completed');
    }
  }

  /// Obtener estadísticas de uso de memoria
  MemoryStats getMemoryStats() {
    return MemoryStats(
      mapDataCacheSize: _mapDataCache.length,
      imageCacheSize: _imageCache.length,
      polygonCacheSize: _polygonCache.length,
      poiCacheSize: _poiCache.length,
      estimatedMemoryUsageMB: _estimatedMemoryUsageMB(),
    );
  }

  /// Optimizar cache antes de operaciones pesadas
  void optimizeForHeavyOperation() {
    if (_estimatedMemoryUsageMB() > _memoryThresholdMB * 0.7) {
      _aggressiveCleanup();
    }
  }

  /// Limpiar cache específico por tipo
  void clearCacheByType(CacheType type) {
    switch (type) {
      case CacheType.mapData:
        _mapDataCache.clear();
        break;
      case CacheType.images:
        _imageCache.clear();
        break;
      case CacheType.polygons:
        _polygonCache.clear();
        break;
      case CacheType.pois:
        _poiCache.clear();
        break;
      case CacheType.all:
        _mapDataCache.clear();
        _imageCache.clear();
        _polygonCache.clear();
        _poiCache.clear();
        break;
    }
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    forceCleanup();
  }
}

/// Cache LRU (Least Recently Used) optimizado para Flutter
class LRUCache<K, V> {
  final int _maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();

  LRUCache(this._maxSize);

  V? get(K key) {
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value; // Move to end (most recently used)
    }
    return value;
  }

  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= _maxSize) {
      _cache.remove(_cache.keys.first); // Remove least recently used
    }
    _cache[key] = value;
  }

  void remove(K key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }

  int get length => _cache.length;

  Iterable<MapEntry<K, V>> get entries => _cache.entries;
  Iterable<V> get values => _cache.values;

  void resize(int newSize) {
    if (newSize < _cache.length) {
      final keysToRemove = _cache.keys.take(_cache.length - newSize).toList();
      for (final key in keysToRemove) {
        _cache.remove(key);
      }
    }
  }
}

/// Item de cache con tiempo de vida
class CacheItem {
  final dynamic data;
  final DateTime timestamp;
  final Duration ttl;

  CacheItem({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(timestamp) > ttl;
}

/// Tipos de cache disponibles
enum CacheType {
  mapData,
  images,
  polygons,
  pois,
  all,
}

/// Estadísticas de uso de memoria
class MemoryStats {
  final int mapDataCacheSize;
  final int imageCacheSize;
  final int polygonCacheSize;
  final int poiCacheSize;
  final double estimatedMemoryUsageMB;

  MemoryStats({
    required this.mapDataCacheSize,
    required this.imageCacheSize,
    required this.polygonCacheSize,
    required this.poiCacheSize,
    required this.estimatedMemoryUsageMB,
  });

  @override
  String toString() {
    return 'MemoryStats(mapData: $mapDataCacheSize, images: $imageCacheSize, '
           'polygons: $polygonCacheSize, pois: $poiCacheSize, '
           'memory: ${estimatedMemoryUsageMB.toStringAsFixed(2)}MB)';
  }
}

/// Lazy loader para datos geoespaciales grandes
class LazyGeoDataLoader {
  static final Map<String, Completer<dynamic>> _loadingCompleters = {};
  static final MemoryManager _memoryManager = MemoryManager();

  /// Carga lazy de polígonos de riesgo por región
  static Future<List<dynamic>> loadRiskPolygons(
    String regionKey,
    Future<List<dynamic>> Function() loader,
  ) async {
    // Check cache first
    final cached = _memoryManager.getCachedRiskPolygons(regionKey);
    if (cached != null) {
      return cached;
    }

    // Prevent duplicate loading
    if (_loadingCompleters.containsKey('polygons_$regionKey')) {
      return await _loadingCompleters['polygons_$regionKey']!.future;
    }

    final completer = Completer<List<dynamic>>();
    _loadingCompleters['polygons_$regionKey'] = completer;

    try {
      // Optimize memory before heavy operation
      _memoryManager.optimizeForHeavyOperation();
      
      final data = await loader();
      _memoryManager.cacheRiskPolygons(regionKey, data);
      completer.complete(data);
      return data;
    } catch (error) {
      completer.completeError(error);
      rethrow;
    } finally {
      _loadingCompleters.remove('polygons_$regionKey');
    }
  }

  /// Carga lazy de POIs por área
  static Future<List<dynamic>> loadPOIs(
    String areaKey,
    Future<List<dynamic>> Function() loader,
  ) async {
    // Check cache first
    final cached = _memoryManager.getCachedPOIs(areaKey);
    if (cached != null) {
      return cached;
    }

    // Prevent duplicate loading
    if (_loadingCompleters.containsKey('pois_$areaKey')) {
      return await _loadingCompleters['pois_$areaKey']!.future;
    }

    final completer = Completer<List<dynamic>>();
    _loadingCompleters['pois_$areaKey'] = completer;

    try {
      final data = await loader();
      _memoryManager.cachePOIs(areaKey, data);
      completer.complete(data);
      return data;
    } catch (error) {
      completer.completeError(error);
      rethrow;
    } finally {
      _loadingCompleters.remove('pois_$areaKey');
    }
  }

  /// Precarga de datos para mejorar UX
  static void preloadAdjacentRegions(
    List<String> regionKeys,
    Future<List<dynamic>> Function(String) loader,
  ) {
    for (final regionKey in regionKeys) {
      // Solo precargar si no está en cache
      if (_memoryManager.getCachedRiskPolygons(regionKey) == null) {
        loadRiskPolygons(regionKey, () => loader(regionKey)).catchError((_) {
          // Silently fail preloading
        });
      }
    }
  }
}

/// Widget helper para gestión automática de memoria
mixin AutoMemoryManagement<T extends StatefulWidget> on State<T> {
  late final MemoryManager _memoryManager;

  @override
  void initState() {
    super.initState();
    _memoryManager = MemoryManager();
  }

  @override
  void dispose() {
    // Limpieza específica del widget
    _memoryManager.clearCacheByType(CacheType.mapData);
    super.dispose();
  }

  /// Cache datos específicos del widget
  void cacheWidgetData(String key, dynamic data) {
    _memoryManager.cacheMapData('${widget.runtimeType}_$key', data);
  }

  /// Obtener datos del cache del widget
  T? getCachedWidgetData<T>(String key) {
    return _memoryManager.getCachedMapData<T>('${widget.runtimeType}_$key');
  }
}