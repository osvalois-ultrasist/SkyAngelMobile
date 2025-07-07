import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../shared/models/menu_item.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../alertas/presentation/pages/alerts_page.dart';
import '../../../maps/presentation/pages/maps_page.dart';
import '../../../rutas/presentation/pages/routes_page.dart';
import '../../../ai_assistant/presentation/pages/copilot_page.dart';
import '../pages/app_page.dart';

class NavigationState {
  final int currentIndex;
  final List<Widget> availablePages;
  final List<MenuItem> availableMenuItems;

  const NavigationState({
    required this.currentIndex,
    required this.availablePages,
    required this.availableMenuItems,
  });

  NavigationState copyWith({
    int? currentIndex,
    List<Widget>? availablePages,
    List<MenuItem>? availableMenuItems,
  }) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      availablePages: availablePages ?? this.availablePages,
      availableMenuItems: availableMenuItems ?? this.availableMenuItems,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  final Ref ref;
  
  static const List<Widget> _allPages = [
    MapsPage(),                  // 0 - Maps
    AlertsPage(),                // 1 - Alerts
    RoutesPage(),                // 2 - Routes
    CopilotPage(),               // 3 - Copilot
    ProfilePage(),               // 4 - Profile
  ];

  NavigationNotifier(this.ref) : super(const NavigationState(
    currentIndex: 0,
    availablePages: [],
    availableMenuItems: [],
  )) {
    _updateAvailablePages();
  }

  void _updateAvailablePages() {
    final authState = ref.read(authStateProvider);
    final user = authState.user;

    final availableItems = MenuConfig.bottomNavigationItems
        .where((item) => item.requiredPermission == null || 
                       PermissionService.hasPermission(user, item.requiredPermission!))
        .toList();

    final availablePages = availableItems
        .map((item) => _allPages[item.tabIndex!])
        .toList();

    state = state.copyWith(
      availablePages: availablePages,
      availableMenuItems: availableItems,
    );
  }

  void setCurrentIndex(int index) {
    final mappedIndex = _mapToAvailableIndex(index);
    state = state.copyWith(currentIndex: mappedIndex);
  }

  void navigateToTab(int originalTabIndex) {
    final mappedIndex = _mapToAvailableIndex(originalTabIndex);
    state = state.copyWith(currentIndex: mappedIndex);
  }

  int _mapToAvailableIndex(int originalIndex) {
    for (int i = 0; i < state.availableMenuItems.length; i++) {
      if (state.availableMenuItems[i].tabIndex == originalIndex) {
        return i;
      }
    }
    return 0;
  }

  void refreshNavigation() {
    _updateAvailablePages();
  }
}

final navigationProvider = StateNotifierProvider<NavigationNotifier, NavigationState>(
  (ref) => NavigationNotifier(ref),
);

final currentPageProvider = Provider<Widget>((ref) {
  final navigation = ref.watch(navigationProvider);
  
  if (navigation.availablePages.isEmpty) {
    return const Scaffold(
      body: Center(
        child: Text('No tienes permisos para acceder a esta aplicación'),
      ),
    );
  }
  
  final index = navigation.currentIndex.clamp(0, navigation.availablePages.length - 1);
  return navigation.availablePages[index];
});