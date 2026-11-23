import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tshirt_controller.dart';

class ApparelTab extends StatelessWidget {
  const ApparelTab({super.key});

  static const List<Map<String, String>> apparelColors = [
    {'name': 'Pure White', 'hex': '#FFFFFF'},
    {'name': 'Heather Gray', 'hex': '#D6D7DC'},
    {'name': 'Slate Gray', 'hex': '#686F7D'},
    {'name': 'Midnight Black', 'hex': '#1C1C1E'},
    {'name': 'Navy Blue', 'hex': '#1D2A44'},
    {'name': 'Deep Royal', 'hex': '#1E40AF'},
    {'name': 'Sky Cyan', 'hex': '#38BDF8'},
    {'name': 'Forest Green', 'hex': '#1E3A2F'},
    {'name': 'Olive Army', 'hex': '#4D533C'},
    {'name': 'Crimson Red', 'hex': '#991B1B'},
    {'name': 'Sunset Terracotta', 'hex': '#C25438'},
    {'name': 'Mustard Gold', 'hex': '#D97706'},
    {'name': 'Pastel Lilac', 'hex': '#C084FC'},
    {'name': 'Blush Pink', 'hex': '#F472B6'},
    {'name': 'Beige Oatmeal', 'hex': '#E7DFD5'},
    {'name': 'Sage Mint', 'hex': '#A3B899'},
    {'name': 'Dark Burgundy', 'hex': '#4A1224'},
    {'name': 'Chocolate Brown', 'hex': '#3E2723'},
  ];

  static const List<Map<String, dynamic>> fabrics = [
    {
      'key': 'cotton',
      'name': 'Ring-Spun Cotton',
      'badge': 'Matte Knit',
      'icon': '👕',
      'desc': 'Soft breathable combed cotton jersey knit',
      'roughness': 0.88,
    },
    {
      'key': 'dryfit',
      'name': 'Athletic Dry-Fit',
      'badge': 'Performance',
      'icon': '⚡',
      'desc': 'Breathable micro-mesh pores with athletic sheen',
      'roughness': 0.48,
    },
    {
      'key': 'fleece',
      'name': 'Heavy Fleece',
      'badge': 'Streetwear',
      'icon': '🧥',
      'desc': 'Dense French terry knit with deep woven texture',
      'roughness': 0.95,
    },
    {
      'key': 'silk',
      'name': 'Silk & Satin',
      'badge': 'Luxury Gloss',
      'icon': '✨',
      'desc': 'High-luster smooth textile with fluid drape sheen',
      'roughness': 0.20,
    },
    {
      'key': 'linen',
      'name': 'Organic Linen',
      'badge': 'Textured',
      'icon': '🌾',
      'desc': 'Uneven cross-slub natural yarn weave structure',
      'roughness': 0.92,
    },
    {
      'key': 'denim',
      'name': 'Vintage Denim',
      'badge': 'Heavy Twill',
      'icon': '👖',
      'desc': 'Diagonal 45° twill ridges with structured body',
      'roughness': 0.82,
    },
  ];

  Color _parseHex(String hex) {
    String clean = hex.replaceAll('#', '');
    if (clean.length == 6) clean = 'FF$clean';
    return Color(int.parse(clean, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final controller = TshirtController.to;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title: Color
          _buildSectionHeader('Base Shirt Color'),
          const SizedBox(height: 8),

          // Swatches Grid
          Obx(() {
            final activeHex = controller.shirtColor.value.toUpperCase();
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: apparelColors.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final item = apparelColors[index];
                final hex = item['hex']!.toUpperCase();
                final isSelected = activeHex.isNotEmpty && hex == activeHex;
                final color = _parseHex(hex);

                return InkWell(
                  onTap: () {
                    // Toggle off if tapping already selected color
                    if (isSelected) {
                      controller.setShirtColor('');
                    } else {
                      controller.setShirtColor(item['hex']!);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white12,
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 16,
                            color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                          )
                        : null,
                  ),
                );
              },
            );
          }),

          const SizedBox(height: 14),
          _buildSectionHeader('Custom Hex Color'),
          const SizedBox(height: 6),

          // Hex display row
          Obx(() {
            final currentHex = controller.shirtColor.value.toUpperCase();
            final hasColor = currentHex.isNotEmpty;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1C202A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: hasColor ? _parseHex(currentHex) : Colors.white12,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: !hasColor
                        ? const Icon(Icons.palette_outlined, size: 14, color: Colors.white54)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasColor ? currentHex : 'Default Model Texture (Tap a swatch to color)',
                      style: TextStyle(
                        fontFamily: hasColor ? 'monospace' : null,
                        fontWeight: hasColor ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                        color: hasColor ? Colors.white : Colors.white54,
                      ),
                    ),
                  ),
                  if (hasColor)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 16, color: Colors.white54),
                      tooltip: 'Revert to default color',
                      onPressed: () => controller.setShirtColor(''),
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),
          _buildSectionHeader('Fabric Selection (Meshy Style)', badgeText: 'Procedural Weave'),
          const SizedBox(height: 8),

          // Fabric Cards Grid
          Obx(() {
            final activeKey = controller.activeFabric.value;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fabrics.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.35,
              ),
              itemBuilder: (context, index) {
                final fab = fabrics[index];
                final isSelected = activeKey.isNotEmpty && fab['key'] == activeKey;

                return InkWell(
                  onTap: () => controller.setFabric(fab['key'] as String, (fab['roughness'] as num).toDouble()),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF6366F1).withValues(alpha: 0.16) : const Color(0xFF1C202A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF6366F1) : Colors.white10,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                                blurRadius: 10,
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(fab['icon'] as String, style: const TextStyle(fontSize: 18)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF6366F1) : Colors.white10,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                fab['badge'] as String,
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          fab['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          fab['desc'] as String,
                          style: const TextStyle(fontSize: 10, color: Colors.white54),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),

          const SizedBox(height: 16),

          // Surface Roughness Slider
          Obx(() {
            final roughness = controller.fabricRoughness.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Surface Roughness', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    Text(roughness.toStringAsFixed(2), style: const TextStyle(fontFamily: 'monospace', color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF6366F1),
                    thumbColor: const Color(0xFF6366F1),
                    inactiveTrackColor: Colors.white12,
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: roughness,
                    min: 0.1,
                    max: 1.0,
                    onChanged: (v) => controller.setFabricRoughness(v),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? badgeText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.7,
              color: Colors.white60,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (badgeText != null)
          Text(
            badgeText,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6366F1),
            ),
          ),
      ],
    );
  }
}
