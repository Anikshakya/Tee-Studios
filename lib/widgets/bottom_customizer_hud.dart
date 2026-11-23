import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tshirt_controller.dart';
import 'apparel_tab.dart';
import 'layers_tab.dart';
import 'edit_layer_tab.dart';
import 'studio_tab.dart';

class BottomCustomizerHud extends StatelessWidget {
  const BottomCustomizerHud({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TshirtController.to;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF14171F).withValues(alpha: 0.98),
        border: const Border(
          top: BorderSide(color: Colors.white12, width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // HUD Top Header Bar: Hide Button + Title + Reset / Quick Export
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10, width: 1)),
            ),
            child: Row(
              children: [
                // Prominent Downward Hide Button
                InkWell(
                  onTap: () => controller.hideHud(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Hide HUD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Title
                const Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.tune, size: 16, color: Color(0xFF818CF8)),
                      SizedBox(width: 6),
                      Text(
                        '3D Studio Customizer',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Quick Export PNG Button
                IconButton(
                  onPressed: () {
                    controller.exportMockup();
                  },
                  tooltip: 'Download Mockup PNG',
                  icon: const Icon(Icons.download, size: 18, color: Color(0xFFA5B4FC)),
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.18),
                    padding: const EdgeInsets.all(6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 6),

                // Reset Button
                TextButton.icon(
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'Reset Customizer',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      middleText: 'Revert all colors, fabrics, and layers back to clean initial state?',
                      middleTextStyle: const TextStyle(color: Colors.white70, fontSize: 13),
                      backgroundColor: const Color(0xFF1C202A),
                      textConfirm: 'Reset',
                      confirmTextColor: Colors.white,
                      textCancel: 'Cancel',
                      cancelTextColor: Colors.white70,
                      buttonColor: const Color(0xFFEF4444),
                      onConfirm: () {
                        controller.resetAll();
                        Get.back();
                      },
                    );
                  },
                  icon: const Icon(Icons.restart_alt, size: 14, color: Color(0xFFF87171)),
                  label: const Text(
                    'Reset',
                    style: TextStyle(
                      color: Color(0xFFF87171),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),

          // 4-Tab Navigation Bar
          Obx(() {
            final activeTab = controller.activeTab.value;
            final layerCount = controller.layers.length;
            final hasActiveLayer = controller.activeLayer != null;

            return Container(
              color: Colors.black26,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  _buildTabButton(
                    index: 0,
                    activeTab: activeTab,
                    icon: Icons.checkroom,
                    label: 'Apparel',
                    onTap: () => controller.setActiveTab(0),
                  ),
                  _buildTabButton(
                    index: 1,
                    activeTab: activeTab,
                    icon: Icons.layers,
                    label: 'Layers',
                    badge: layerCount > 0 ? '$layerCount' : null,
                    onTap: () => controller.setActiveTab(1),
                  ),
                  _buildTabButton(
                    index: 2,
                    activeTab: activeTab,
                    icon: Icons.edit,
                    label: 'Edit',
                    showDot: hasActiveLayer,
                    onTap: () => controller.setActiveTab(2),
                  ),
                  _buildTabButton(
                    index: 3,
                    activeTab: activeTab,
                    icon: Icons.wb_sunny_outlined,
                    label: 'Studio',
                    onTap: () => controller.setActiveTab(3),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 1, color: Colors.white10),

          // Tab Content (Takes up the rest of the 40% HUD height)
          Expanded(
            child: Obx(() {
              switch (controller.activeTab.value) {
                case 0:
                  return const ApparelTab();
                case 1:
                  return const LayersTab();
                case 2:
                  return const EditLayerTab();
                case 3:
                  return const StudioTab();
                default:
                  return const ApparelTab();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required int activeTab,
    required IconData icon,
    required String label,
    String? badge,
    bool showDot = false,
    required VoidCallback onTap,
  }) {
    final isSelected = index == activeTab;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6366F1).withValues(alpha: 0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? const Color(0xFF818CF8) : Colors.white60,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.white60,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ] else if (showDot) ...[
                const SizedBox(width: 5),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
