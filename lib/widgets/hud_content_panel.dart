import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tshirt_controller.dart';
import 'apparel_tab.dart';
import 'layers_tab.dart';
import 'edit_layer_tab.dart';
import 'studio_tab.dart';

class HudContentPanel extends StatelessWidget {
  const HudContentPanel({super.key});

  static const List<Map<String, dynamic>> tabTitles = [
    {'title': 'Apparel & Fabric', 'icon': Icons.checkroom},
    {'title': 'Layer Stack', 'icon': Icons.layers},
    {'title': 'Edit Layer', 'icon': Icons.tune},
    {'title': 'Studio Lighting', 'icon': Icons.wb_sunny_outlined},
  ];

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
            color: Colors.black45,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10, width: 1)),
            ),
            child: Row(
              children: [
                // Collapse / Unselect Arrow Button
                InkWell(
                  onTap: () => controller.hideHud(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 10),

                // Dynamic Tab Title
                Expanded(
                  child: Obx(() {
                    final tabIdx = controller.activeTab.value.clamp(0, tabTitles.length - 1);
                    final tabInfo = tabTitles[tabIdx];
                    return Row(
                      children: [
                        Icon(tabInfo['icon'] as IconData, size: 16, color: const Color(0xFF818CF8)),
                        const SizedBox(width: 6),
                        Text(
                          tabInfo['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );
                  }),
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
        ],
      ),
    );
  }
}
