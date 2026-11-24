import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'controllers/tshirt_controller.dart';
import 'tshirt_viewer.dart';
import 'widgets/bottom_nav_tab_bar.dart';
import 'widgets/hud_content_panel.dart';
import 'widgets/viewport_camera_bar.dart';
import 'widgets/viewport_top_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(TshirtController());
  runApp(const MockupStudioApp());
}

class MockupStudioApp extends StatelessWidget {
  const MockupStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '3D T-Shirt Mockup Studio',
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        if (!Get.isRegistered<TshirtController>()) {
          Get.put(TshirtController());
        }
      }),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E1015),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          surface: Color(0xFF14171F),
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const MockupStudioHomePage(),
    );
  }
}


class MockupStudioHomePage extends StatelessWidget {
  const MockupStudioHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<TshirtController>()
        ? TshirtController.to
        : Get.put(TshirtController());

    return Scaffold(
      backgroundColor: const Color(0xFF0E1015),
      body: SafeArea(
        child: Obx(() {
          final isHudVisible = controller.isHudVisible.value;

          return LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;

              final isMobile = screenWidth < 800;
              final isTablet = screenWidth >= 800 &&
                  screenWidth < 1200;

              final hudWidth = isTablet ? 340.0 : 380.0;

              return Column(
                children: [
                  // MAIN WORKSPACE
                  Expanded(
                    child: isMobile
                        ? _buildMobileLayout(
                            isHudVisible: isHudVisible,
                            controller: controller,
                          )
                        : _buildWideLayout(
                            isHudVisible: isHudVisible,
                            hudWidth: hudWidth,
                            controller: controller,
                          ),
                  ),

                  // BOTTOM NAVIGATION
                  const BottomNavTabBar(),
                ],
              );
            },
          );
        }),
      ),
    );
  }

  // ============================================================
  // MOBILE LAYOUT
  // ============================================================

  Widget _buildMobileLayout({
    required bool isHudVisible,
    required TshirtController controller,
  }) {
    return Column(
      children: [
        // 3D VIEWPORT
        Expanded(
          flex: isHudVisible ? 6 : 1,
          child: _buildViewport(controller),
        ),

        // BOTTOM HUD
        if (isHudVisible)
          const Expanded(
            flex: 4,
            child: HudContentPanel(),
          ),
      ],
    );
  }

  // ============================================================
  // TABLET / WEB LAYOUT
  // ============================================================

  Widget _buildWideLayout({
    required bool isHudVisible,
    required double hudWidth,
    required TshirtController controller,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // FLEXIBLE 3D VIEWPORT
        Expanded(
          child: _buildViewport(controller),
        ),

        // RIGHT-SIDE CUSTOMIZATION HUD
        if (isHudVisible)
          Container(
            width: hudWidth,
            decoration: const BoxDecoration(
              color: Color(0xFF15171E),
              border: Border(
                left: BorderSide(
                  color: Color(0xFF292C36),
                  width: 1,
                ),
              ),
            ),
            child: const HudContentPanel(),
          ),
      ],
    );
  }

  // ============================================================
  // 3D VIEWPORT
  // ============================================================

  Widget _buildViewport(TshirtController controller) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // THREE.JS / WEBVIEW VIEWER
          const TshirtViewer(
            key: ValueKey('tshirt_viewer_canvas'),
          ),

          // TOP BAR
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: PointerInterceptor(
              child: ViewportTopBar(),
            ),
          ),

          // CAMERA CONTROLS
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: PointerInterceptor(
              child: ViewportCameraBar(),
            ),
          ),

          // DRAG MODE HINT
          Obx(() {
            if (controller.interactionMode.value != 'drag') {
              return const SizedBox.shrink();
            }

            return Positioned(
              top: 56,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1)
                      .withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1)
                          .withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('👆 ', style: TextStyle(fontSize: 12)),
                    Text(
                      'Drag active layer across shirt or sleeves',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
