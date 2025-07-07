import 'package:flutter/material.dart';

/// Scaffold base de la aplicación que proporciona el layout correcto
class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final bool resizeToAvoidBottomInset;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.extendBody = true,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor,
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      body: _AppBody(
        child: body,
        hasBottomNav: bottomNavigationBar != null,
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

class _AppBody extends StatelessWidget {
  final Widget child;
  final bool hasBottomNav;

  const _AppBody({
    required this.child,
    required this.hasBottomNav,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: !hasBottomNav, // No aplicar SafeArea al bottom si hay bottom nav
      child: Padding(
        padding: EdgeInsets.only(
          bottom: hasBottomNav ? 104 : 0, // Espacio para el nav flotante ajustado
        ),
        child: child,
      ),
    );
  }
}

/// Extension para páginas que necesitan padding adicional
extension AppPageExtension on Widget {
  Widget withBottomPadding({bool hasBottomNav = true}) {
    return Builder(
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: hasBottomNav ? 104 : 0,
        ),
        child: this,
      ),
    );
  }
  
  Widget withSafeArea({
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: this,
    );
  }
}