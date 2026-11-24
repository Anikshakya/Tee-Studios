import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tshirt_controller.dart';

class ViewportTopBar extends StatelessWidget {
  const ViewportTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TshirtController.to;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;

        return Row(
          children: [
            Obx(() {
              final is2D = controller.is2DView.value;
              return Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFF14171F).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 16, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeButton(
                      isActive: is2D,
                      icon: Icons.grid_on,
                      label: '2D',
                      onTap: () => controller.setViewerMode(true),
                    ),
                    const SizedBox(width: 3),
                    _buildModeButton(
                      isActive: !is2D,
                      icon: Icons.view_in_ar,
                      label: '3D',
                      onTap: () => controller.setViewerMode(false),
                    ),
                  ],
                ),
              );
            }),

            const Spacer(),

            // 360 Rotate vs Drag Mode Switcher
            Obx(() {
              final isDrag = controller.interactionMode.value == 'drag';
              final is2D = controller.is2DView.value;
              return Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFF14171F).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 16, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeButton(
                      isActive: !isDrag,
                      icon: is2D ? Icons.touch_app : Icons.threed_rotation,
                      label: isCompact ? (is2D ? 'Select' : '360°') : (is2D ? 'Select Layer' : '360° Rotate'),
                      onTap: () => controller.setInteractionMode('orbit'),
                    ),
                    const SizedBox(width: 3),
                    _buildModeButton(
                      isActive: isDrag,
                      icon: Icons.open_with,
                      label: isCompact ? 'Drag' : (is2D ? 'Drag Artwork' : 'Drag on Shirt'),
                      onTap: () => controller.setInteractionMode('drag'),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildModeButton({
    required bool isActive,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                    blurRadius: 8,
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isActive ? Colors.white : Colors.white60),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.white60,
              ),
            ),
          ],
        ),
      )
    );
  }
}
