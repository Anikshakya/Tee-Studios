import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tshirt_controller.dart';

class BottomNavTabBar extends StatelessWidget {
  const BottomNavTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TshirtController.to;

    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: const Color(0xFF14171F),
        border: const Border(
          top: BorderSide(color: Colors.white12, width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final isHudVisible = controller.isHudVisible.value;
          final activeTab = controller.activeTab.value;
          final layerCount = controller.layers.length;
          final hasActiveLayer = controller.activeLayer != null;

          return Row(
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.checkroom,
                label: 'Apparel',
                isSelected: isHudVisible && activeTab == 0,
                onTap: () => controller.onBottomNavTapped(0),
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.layers,
                label: 'Layers',
                badge: layerCount > 0 ? '$layerCount' : null,
                isSelected: isHudVisible && activeTab == 1,
                onTap: () => controller.onBottomNavTapped(1),
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.tune,
                label: 'Edit',
                showDot: hasActiveLayer,
                isSelected: isHudVisible && activeTab == 2,
                onTap: () => controller.onBottomNavTapped(2),
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.wb_sunny_outlined,
                label: 'Studio',
                isSelected: isHudVisible && activeTab == 3,
                onTap: () => controller.onBottomNavTapped(3),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    String? badge,
    bool showDot = false,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
          highlightColor: const Color(0xFF6366F1).withValues(alpha: 0.08),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                  width: 2.5,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      size: 22,
                      color: isSelected ? const Color(0xFF818CF8) : Colors.white60,
                    ),
                    if (badge != null)
                      Positioned(
                        top: -3,
                        right: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else if (showDot)
                      Positioned(
                        top: -1,
                        right: -3,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? const Color(0xFF818CF8) : Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
