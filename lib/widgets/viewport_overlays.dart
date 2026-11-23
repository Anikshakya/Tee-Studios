import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tshirt_controller.dart';

class ViewportOverlays extends StatelessWidget {
  const ViewportOverlays({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TshirtController.to;

    return Stack(
      children: [
        // Top Responsive Control Bar
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: LayoutBuilder(
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
                        if (!isCompact) ...[
                          const SizedBox(width: 8),
                          const Text('T-Shirt Studio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Prominent Hide / Show Controls Button
                  Obx(() {
                    final isVisible = controller.isHudVisible.value;
                    return InkWell(
                      onTap: () => controller.toggleHud(),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isVisible ? Colors.white.withValues(alpha: 0.08) : const Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isVisible ? Colors.white12 : const Color(0xFF6366F1)),
                          boxShadow: isVisible
                              ? null
                              : [
                                  BoxShadow(
                                    color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isVisible ? Icons.visibility_off_outlined : Icons.tune,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isVisible ? (isCompact ? 'Hide' : 'Hide Controls') : (isCompact ? 'Show' : 'Show Controls'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

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
          ),
        ),

        // Drag Mode Hint Banner
        Obx(() {
          if (controller.interactionMode.value != 'drag') return const SizedBox.shrink();
          return Positioned(
            top: 58,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('👆 ', style: TextStyle(fontSize: 13)),
                  Text(
                    'Drag active layer across shirt or sleeves',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        }),

        // Bottom Camera Navigation Bar (horizontally scrollable on small screens)
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF14171F).withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCamButton('Front', () => controller.setCameraView('front')),
                    _buildCamButton('Back', () => controller.setCameraView('back')),
                    _buildCamButton('Left Sleeve', () => controller.setCameraView('left-sleeve')),
                    _buildCamButton('Right Sleeve', () => controller.setCameraView('right-sleeve')),
                    _buildCamButton('Reset', () => controller.setCameraView('reset')),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Floating Customize Button (appears when HUD is hidden so user can easily reopen)
        Obx(() {
          if (controller.isHudVisible.value) return const SizedBox.shrink();
          return Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () => controller.showHud(),
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.tune, size: 18),
              label: const Text('Customize', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          );
        }),
      ],
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

  Widget _buildCamButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70),
        ),
      ),
    );
  }
}
