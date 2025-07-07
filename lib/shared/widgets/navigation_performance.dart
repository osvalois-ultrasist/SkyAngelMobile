import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import '../design_system/design_tokens.dart';

/// Sistema de optimización de performance para navegación
/// Implementa lazy loading, caching y optimizaciones de rendering
class NavigationPerformance {
  static const int maxCachedItems = 50;
  static const Duration debounceDelay = Duration(milliseconds: 100);
  static const int frameThreshold = 16; // 60 FPS
  
  static final Map<String, Widget> _cachedWidgets = {};
  static final Map<String, DateTime> _lastAccess = {};
  
  /// Cache inteligente de widgets de navegación
  static Widget getCachedWidget(String key, Widget Function() builder) {
    _lastAccess[key] = DateTime.now();
    
    if (_cachedWidgets.containsKey(key)) {
      return _cachedWidgets[key]!;
    }
    
    final widget = builder();
    _cacheWidget(key, widget);
    return widget;
  }
  
  static void _cacheWidget(String key, Widget widget) {
    // Limpiar cache si excede el límite
    if (_cachedWidgets.length >= maxCachedItems) {
      _cleanupCache();
    }
    
    _cachedWidgets[key] = widget;
  }
  
  static void _cleanupCache() {
    final sortedEntries = _lastAccess.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    // Remover los 10 elementos menos usados
    for (int i = 0; i < 10 && i < sortedEntries.length; i++) {
      final key = sortedEntries[i].key;
      _cachedWidgets.remove(key);
      _lastAccess.remove(key);
    }
  }
  
  static void clearCache() {
    _cachedWidgets.clear();
    _lastAccess.clear();
  }
}

/// Builder optimizado para listas de navegación con lazy loading
class OptimizedNavigationBuilder extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;

  const OptimizedNavigationBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
  });

  @override
  State<OptimizedNavigationBuilder> createState() => _OptimizedNavigationBuilderState();
}

class _OptimizedNavigationBuilderState extends State<OptimizedNavigationBuilder> {
  late ScrollController _scrollController;
  final Set<int> _builtItems = {};
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      itemCount: widget.itemCount,
      cacheExtent: 200, // Optimización para viewport caching
      itemBuilder: (context, index) {
        final cacheKey = 'navigation_item_$index';
        
        return NavigationPerformance.getCachedWidget(
          cacheKey,
          () {
            _builtItems.add(index);
            return RepaintBoundary(
              child: widget.itemBuilder(context, index),
            );
          },
        );
      },
    );
  }
}

/// Widget de navegación con optimizaciones de rendering
class PerformantNavigationItem extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isSelected;
  final String? semanticLabel;

  const PerformantNavigationItem({
    super.key,
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.semanticLabel,
  });

  @override
  State<PerformantNavigationItem> createState() => _PerformantNavigationItemState();
}

class _PerformantNavigationItemState extends State<PerformantNavigationItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isHovered = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.animationDurationQuick,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _animationController.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _animationController.reverse();
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_animationController.value * 0.02),
              child: Container(
                decoration: BoxDecoration(
                  color: _isHovered 
                      ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5)
                      : Colors.transparent,
                  borderRadius: DesignTokens.radiusS,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: DesignTokens.radiusS,
                    child: Semantics(
                      label: widget.semanticLabel,
                      button: true,
                      selected: widget.isSelected,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Sistema de debouncing para interacciones de navegación
class DebouncedNavigationInteraction extends StatefulWidget {
  final Widget child;
  final VoidCallback onInteraction;
  final Duration delay;

  const DebouncedNavigationInteraction({
    super.key,
    required this.child,
    required this.onInteraction,
    this.delay = NavigationPerformance.debounceDelay,
  });

  @override
  State<DebouncedNavigationInteraction> createState() => _DebouncedNavigationInteractionState();
}

class _DebouncedNavigationInteractionState extends State<DebouncedNavigationInteraction> {
  Timer? _debounceTimer;

  void _handleInteraction() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.delay, () {
      widget.onInteraction();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleInteraction,
      child: widget.child,
    );
  }
}

/// Monitor de performance para navegación
class NavigationPerformanceMonitor extends StatefulWidget {
  final Widget child;
  final String navigationName;
  final bool enableLogging;

  const NavigationPerformanceMonitor({
    super.key,
    required this.child,
    required this.navigationName,
    this.enableLogging = false,
  });

  @override
  State<NavigationPerformanceMonitor> createState() => _NavigationPerformanceMonitorState();
}

class _NavigationPerformanceMonitorState extends State<NavigationPerformanceMonitor> {
  late FrameTimeRecorder _frameTimeRecorder;
  int _frameCount = 0;
  double _averageFrameTime = 0;

  @override
  void initState() {
    super.initState();
    _frameTimeRecorder = FrameTimeRecorder();
    
    if (widget.enableLogging) {
      SchedulerBinding.instance.addPostFrameCallback(_trackFrame);
    }
  }

  void _trackFrame(Duration timestamp) {
    _frameCount++;
    final frameTime = _frameTimeRecorder.recordFrame();
    
    if (frameTime != null) {
      _averageFrameTime = (_averageFrameTime * (_frameCount - 1) + frameTime) / _frameCount;
      
      if (frameTime > NavigationPerformance.frameThreshold) {
        _logPerformanceIssue(frameTime);
      }
    }
    
    if (mounted) {
      SchedulerBinding.instance.addPostFrameCallback(_trackFrame);
    }
  }

  void _logPerformanceIssue(double frameTime) {
    debugPrint(
      'Performance warning in ${widget.navigationName}: '
      'Frame time: ${frameTime.toStringAsFixed(2)}ms '
      '(Avg: ${_averageFrameTime.toStringAsFixed(2)}ms)'
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Recorder de tiempo de frame optimizado
class FrameTimeRecorder {
  DateTime? _lastFrameTime;
  final List<double> _frameTimes = [];
  static const int maxSamples = 100;

  double? recordFrame() {
    final now = DateTime.now();
    
    if (_lastFrameTime != null) {
      final frameTime = now.difference(_lastFrameTime!).inMicroseconds / 1000.0;
      
      _frameTimes.add(frameTime);
      if (_frameTimes.length > maxSamples) {
        _frameTimes.removeAt(0);
      }
      
      _lastFrameTime = now;
      return frameTime;
    }
    
    _lastFrameTime = now;
    return null;
  }

  double get averageFrameTime {
    if (_frameTimes.isEmpty) return 0;
    return _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
  }

  double get maxFrameTime => _frameTimes.isEmpty ? 0 : _frameTimes.reduce((a, b) => a > b ? a : b);
  double get minFrameTime => _frameTimes.isEmpty ? 0 : _frameTimes.reduce((a, b) => a < b ? a : b);
}

/// Widget que optimiza el rebuild de componentes de navegación
class OptimizedNavigationComponent extends StatefulWidget {
  final Widget Function(BuildContext) builder;
  final List<Object> dependencies;
  final String? debugLabel;

  const OptimizedNavigationComponent({
    super.key,
    required this.builder,
    this.dependencies = const [],
    this.debugLabel,
  });

  @override
  State<OptimizedNavigationComponent> createState() => _OptimizedNavigationComponentState();
}

class _OptimizedNavigationComponentState extends State<OptimizedNavigationComponent> {
  Widget? _cachedWidget;
  List<Object>? _lastDependencies;

  @override
  Widget build(BuildContext context) {
    // Solo rebuild si las dependencias cambian
    if (_cachedWidget == null || !_dependenciesEqual()) {
      _cachedWidget = widget.builder(context);
      _lastDependencies = List.from(widget.dependencies);
    }
    
    return _cachedWidget!;
  }

  bool _dependenciesEqual() {
    if (_lastDependencies == null) return false;
    if (_lastDependencies!.length != widget.dependencies.length) return false;
    
    for (int i = 0; i < widget.dependencies.length; i++) {
      if (_lastDependencies![i] != widget.dependencies[i]) return false;
    }
    
    return true;
  }
}

/// Preloader para navegación compleja
class NavigationPreloader extends StatefulWidget {
  final List<Future<Widget>> navigationItems;
  final Widget Function(BuildContext, List<Widget>) builder;
  final Widget? loadingWidget;

  const NavigationPreloader({
    super.key,
    required this.navigationItems,
    required this.builder,
    this.loadingWidget,
  });

  @override
  State<NavigationPreloader> createState() => _NavigationPreloaderState();
}

class _NavigationPreloaderState extends State<NavigationPreloader> {
  List<Widget>? _loadedItems;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _preloadNavigationItems();
  }

  Future<void> _preloadNavigationItems() async {
    try {
      final items = await Future.wait(widget.navigationItems);
      if (mounted) {
        setState(() {
          _loadedItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error preloading navigation items: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ?? const CircularProgressIndicator();
    }
    
    return widget.builder(context, _loadedItems ?? []);
  }
}

/// Extensions para optimizaciones adicionales
extension NavigationOptimizations on Widget {
  Widget withRepaintBoundary() => RepaintBoundary(child: this);
  
  Widget withPerformanceMonitoring(String name, {bool enableLogging = false}) =>
      NavigationPerformanceMonitor(
        navigationName: name,
        enableLogging: enableLogging,
        child: this,
      );
      
  Widget withOptimizedRendering() => OptimizedNavigationComponent(
        builder: (context) => this,
      );
}