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
            // Logo Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14, vertical: 7),
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
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFEC4899)]),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: const Text('3D', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '3D Studio',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // 360 Rotate vs Drag Mode Switcher
            Obx(() {
              final isDrag = controller.interactionMode.value == 'drag';
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
                      icon: Icons.threed_rotation,
                      label: isCompact ? '360°' : '360° Rotate',
                      onTap: () => controller.setInteractionMode('orbit'),
                    ),
                    const SizedBox(width: 3),
                    _buildModeButton(
                      isActive: isDrag,
                      icon: Icons.open_with,
                      label: isCompact ? 'Drag' : 'Drag on Shirt',
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }
}
