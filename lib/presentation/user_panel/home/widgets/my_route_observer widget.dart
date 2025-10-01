import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/drawer/drawer_selection_controller.dart';

/// 🔹 Custom RouteObserver to keep Drawer selection in sync with navigation.
///
/// Whenever user navigates (push / pop a screen),
/// this observer will update the `DrawerSelectionController`
/// so that the correct menu item stays highlighted.
class MyRouteObserver extends GetObserver {
  // DrawerSelectionController instance (already registered with GetX)
  final DrawerSelectionController selectionController = Get.find();

  /// 🔹 Called when a new route (screen) is pushed
  @override
  void didPush(Route route, Route? previousRoute) {
    // Agar route ka name available hai to drawer selection update kar do
    if (route.settings.name != null) {
      selectionController.updateSelectionFromRoute(route.settings.name!);
    }
    super.didPush(route, previousRoute);
  }

  /// 🔹 Called when a route (screen) is popped (back navigation)
  @override
  void didPop(Route route, Route? previousRoute) {
    // Jab back hota hai to previous route ke name se selection update karna
    if (previousRoute?.settings.name != null) {
      selectionController.updateSelectionFromRoute(previousRoute!.settings.name!);
    }
    super.didPop(route, previousRoute);
  }
}
