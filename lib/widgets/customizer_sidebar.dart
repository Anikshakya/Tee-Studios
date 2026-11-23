import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tshirt_controller.dart';
import 'apparel_tab.dart';
import 'layers_tab.dart';
import 'edit_layer_tab.dart';
import 'studio_tab.dart';

class CustomizerSidebar extends StatelessWidget {
  final double width;
  const CustomizerSidebar({super.key, this.width = 420});

  @override
  Widget build(BuildContext context) {
    final controller = TshirtController.to;

    return Container(
      width: width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF14171F).withValues(alpha: 0.96),
        border: const Border(left: BorderSide(color: Colors.white12, width: 1)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 30,
            offset: Offset(-8, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Sidebar Header: Hide Button + Title + Reset
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                // Prominent Hide / Collapse Button
                InkWell(
                  onTap: () => controller.hideHud(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chevron_right, color: Colors.white, size: 18),
                        SizedBox(width: 2),
                        Text(
                          'Hide',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                const Expanded(
                  child: Text(
                    '3D Studio',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Reset Button
                TextButton.icon(
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'Reset Customizer',
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
                  icon: const Icon(Icons.restart_alt, size: 13, color: Color(0xFFF87171)),
                  label: const Text('Reset', style: TextStyle(color: Color(0xFFF87171), fontSize: 11, fontWeight: FontWeight.bold)),
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

          const Divider(height: 1, color: Colors.white12),

          // 4-Tab Navigation Bar
          Obx(() {
            final activeTab = controller.activeTab.value;
            final layerCount = controller.layers.length;

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

          const Divider(height: 1, color: Colors.white12),

          // Tab Content
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

          const Divider(height: 1, color: Colors.white12),

          // Footer Action: Download Mockup PNG
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.onSend3DCommand?.call({'type': 'EXPORT_PNG'});
                },
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download Mockup PNG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 4,
                  shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.5),
                ),
              ),
            ),
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
            color: isSelected ? const Color(0xFF6366F1).withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.white60),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.white60,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
