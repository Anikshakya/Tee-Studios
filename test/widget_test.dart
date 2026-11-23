import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:printdesign/controllers/tshirt_controller.dart';
import 'package:printdesign/main.dart';
import 'package:printdesign/tshirt_viewer.dart';
import 'package:printdesign/widgets/bottom_nav_tab_bar.dart';
import 'package:printdesign/widgets/hud_content_panel.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  testWidgets('Bottom nav tab bar selects and unselects to expand/collapse HUD', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MockupStudioApp());
    await tester.pumpAndSettle();

    expect(find.byType(MockupStudioHomePage), findsOneWidget);
    expect(find.byType(BottomNavTabBar), findsOneWidget);

    final controller = TshirtController.to;
    // Initially HUD is closed (full screen 3D view with bottom nav)
    expect(controller.isHudVisible.value, isFalse);
    expect(find.byType(HudContentPanel), findsNothing);
    final fullViewportHeight = tester.getSize(find.byType(TshirtViewer)).height;
    expect(fullViewportHeight, greaterThan(0));

    // Tap "Apparel" in bottom nav to select it
    final apparelTab = find.text('Apparel');
    expect(apparelTab, findsOneWidget);
    await tester.tap(apparelTab);
    await tester.pumpAndSettle();

    // Now Apparel is selected and HUD content panel is open
    expect(controller.isHudVisible.value, isTrue);
    expect(controller.activeTab.value, 0);
    expect(find.byType(HudContentPanel), findsOneWidget);
    expect(
      tester.getSize(find.byType(TshirtViewer)).height,
      closeTo(fullViewportHeight * 0.6, 0.1),
    );
    expect(
      tester.getSize(find.byType(HudContentPanel)).height,
      closeTo(fullViewportHeight * 0.4, 0.1),
    );

    // Tap "Apparel" again to UNSELECT it
    await tester.tap(apparelTab);
    await tester.pumpAndSettle();

    // Now it unselects and collapses the HUD!
    expect(controller.isHudVisible.value, isFalse);
    expect(find.byType(HudContentPanel), findsNothing);
    expect(
      tester.getSize(find.byType(TshirtViewer)).height,
      closeTo(fullViewportHeight, 0.1),
    );

    // Tap "Layers" in bottom nav to select it
    final layersTab = find.text('Layers');
    expect(layersTab, findsOneWidget);
    await tester.tap(layersTab);
    await tester.pumpAndSettle();

    expect(controller.isHudVisible.value, isTrue);
    expect(controller.activeTab.value, 1);
    expect(find.byType(HudContentPanel), findsOneWidget);

    // Tap "Studio" to switch tab
    final studioTab = find.descendant(
      of: find.byType(BottomNavTabBar),
      matching: find.text('Studio'),
    );
    expect(studioTab, findsOneWidget);
    await tester.tap(studioTab);
    await tester.pumpAndSettle();

    expect(controller.isHudVisible.value, isTrue);
    expect(controller.activeTab.value, 3);
  });
}
