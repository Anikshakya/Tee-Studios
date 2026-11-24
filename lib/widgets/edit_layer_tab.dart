import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tshirt_controller.dart';
import '../models/tshirt_layer.dart';

class EditLayerTab extends StatelessWidget {
  const EditLayerTab({super.key});

  static const List<Map<String, String>> fonts = [
    {'name': 'Bebas Neue (Athletic Bold)', 'value': "'Bebas Neue', sans-serif"},
    {'name': 'Montserrat (Modern Heavy)', 'value': "'Montserrat', sans-serif"},
    {'name': 'Oswald (Industrial Condensed)', 'value': "'Oswald', sans-serif"},
    {'name': 'Anton (Impact Statement)', 'value': "'Anton', sans-serif"},
    {'name': 'Permanent Marker (Graffiti)', 'value': "'Permanent Marker', cursive"},
    {'name': 'Pacifico (Retro Brush)', 'value': "'Pacifico', cursive"},
    {'name': 'Playfair Display (Luxury)', 'value': "'Playfair Display', serif"},
    {'name': 'Cinzel (Roman Architectural)', 'value': "'Cinzel', serif"},
    {'name': 'Space Mono (Tech / Code)', 'value': "'Space Mono', monospace"},
    {'name': 'Inter (Clean Neutral)', 'value': "'Inter', sans-serif"},
  ];

  static const List<Map<String, String>> textColors = [
    {'name': 'Black', 'hex': '#111111'},
    {'name': 'White', 'hex': '#FFFFFF'},
    {'name': 'Gold', 'hex': '#F59E0B'},
    {'name': 'Neon Pink', 'hex': '#EC4899'},
    {'name': 'Cyan', 'hex': '#06B6D4'},
    {'name': 'Red', 'hex': '#EF4444'},
  ];

  static const List<Map<String, String>> sampleGraphics = [
    {
      'name': 'Geometric Tiger',
      'svg': '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" fill="none" stroke="#E11D48" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polygon points="50,10 75,35 65,70 50,85 35,70 25,35"/><line x1="50" y1="10" x2="50" y2="85"/><line x1="25" y1="35" x2="75" y2="35"/><line x1="35" y1="70" x2="65" y2="70"/><circle cx="42" cy="45" r="4" fill="#E11D48"/><circle cx="58" cy="45" r="4" fill="#E11D48"/></svg>',
    },
    {
      'name': 'Retro Sunset',
      'svg': '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><linearGradient id="g1" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#F59E0B"/><stop offset="100%" stop-color="#DC2626"/></linearGradient></defs><circle cx="50" cy="50" r="40" fill="url(#g1)"/><rect x="10" y="52" width="80" height="3" fill="#1A1C23"/><rect x="10" y="60" width="80" height="4" fill="#1A1C23"/><rect x="10" y="70" width="80" height="6" fill="#1A1C23"/></svg>',
    },
    {
      'name': 'Cyber Skull',
      'svg': '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" fill="none" stroke="#06B6D4" stroke-width="3"><circle cx="50" cy="45" r="28"/><rect x="40" y="66" width="20" height="16" rx="3"/><circle cx="40" cy="46" r="6" fill="#06B6D4"/><circle cx="60" cy="46" r="6" fill="#06B6D4"/><line x1="46" y1="72" x2="46" y2="80"/><line x1="54" y1="72" x2="54" y2="80"/></svg>',
    },
    {
      'name': 'Mountain Peak',
      'svg': '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" fill="none" stroke="#10B981" stroke-width="3" stroke-linejoin="round"><polygon points="50,20 85,80 15,80"/><polygon points="50,20 62,45 50,40 38,45" fill="#10B981"/><circle cx="75" cy="30" r="7" stroke="#10B981"/></svg>',
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

    return Obx(() {
      final layer = controller.activeLayer;

      if (layer == null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.touch_app, size: 40, color: Colors.white30),
                const SizedBox(height: 12),
                const Text('No Layer Selected', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                const SizedBox(height: 4),
                const Text('Select a layer from the Layers tab or create a new graphic', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.white54)),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => controller.addTextLayer(),
                      icon: const Icon(Icons.title, size: 14),
                      label: const Text('+ Text', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => controller.pickImageForNewLayer(),
                      icon: const Icon(Icons.image, size: 14),
                      label: const Text('+ Image', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEC4899), foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }

      final isText = layer.type == LayerType.text;
      final landmarkName = TshirtController.landmarks[layer.positionKey]?.name ?? 'Custom Drag Placement';

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Layer Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C202A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: isText
                          ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)])
                          : const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFF43F5E)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: isText
                        ? const Text('T', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13))
                        : const Icon(Icons.image, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          layer.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${isText ? "TEXT" : "GRAPHIC"} • $landmarkName',
                          style: const TextStyle(fontSize: 10, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFF87171)),
                    onPressed: () => controller.deleteLayer(layer.id),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Text Specific Controls
            if (isText) ...[
              _buildSectionHeader('Text Content'),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: layer.text,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1C202A),
                  hintText: 'Enter text...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF6366F1))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (val) => controller.updateActiveText(val),
              ),

              const SizedBox(height: 14),
              _buildSectionHeader('Font Family'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C202A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: layer.fontFamily,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1A1C23),
                    items: fonts.map((f) {
                      return DropdownMenuItem<String>(
                        value: f['value'],
                        child: Text(f['name']!, style: const TextStyle(color: Colors.white, fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.updateActiveFont(val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 14),
              TextFormField(
                key: ValueKey('font_size_${layer.id}_${layer.fontSize.round()}'),
                initialValue: layer.fontSize.round().toString(),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1C202A),
                  labelText: 'Custom Font Size',
                  labelStyle: const TextStyle(color: Colors.white54),
                  suffixText: 'px',
                  suffixStyle: const TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF6366F1)),
                  ),
                  isDense: true,
                ),
                onChanged: (value) {
                  final parsed = double.tryParse(value.trim());
                  if (parsed != null && parsed > 0) {
                    controller.updateActiveFontSize(parsed);
                  }
                },
              ),

              const SizedBox(height: 10),
              _buildSliderRow(
                label: 'Curved / Arc Text',
                valText: '${layer.textArc.round()}%',
                value: layer.textArc,
                min: -100,
                max: 100,
                onChanged: (v) => controller.updateActiveTextArc(v),
              ),

              const SizedBox(height: 10),
              _buildSliderRow(
                label: 'Letter Spacing',
                valText: '${layer.textSpacing.round()}px',
                value: layer.textSpacing,
                min: -5,
                max: 35,
                onChanged: (v) => controller.updateActiveTextSpacing(v),
              ),

              const SizedBox(height: 14),
              _buildSectionHeader('Text Color'),
              const SizedBox(height: 6),
              Row(
                children: textColors.map((tc) {
                  final hex = tc['hex']!;
                  final color = _parseHex(hex);
                  final isSelected = layer.textColor.toUpperCase() == hex.toUpperCase();

                  return Expanded(
                    child: InkWell(
                      onTap: () => controller.updateActiveTextColor(hex),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isSelected ? Colors.white : Colors.white24, width: isSelected ? 2 : 1),
                        ),
                        child: isSelected
                            ? Icon(Icons.check, size: 14, color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ] else ...[
              // Image Specific Controls
              _buildSectionHeader('Upload / Replace Artwork'),
              const SizedBox(height: 6),
              InkWell(
                onTap: () => controller.replaceActiveLayerImage(),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 28, color: Color(0xFF6366F1)),
                        SizedBox(height: 6),
                        Text('Click to select image from gallery', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: 2),
                        Text('PNG, JPG, SVG or WebP', style: TextStyle(fontSize: 10, color: Colors.white38)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),
              _buildSliderRow(
                label: 'Graphic Scale / Size',
                valText: '${(layer.scale * 100).round()}%',
                value: layer.scale * 100,
                min: 20,
                max: 250,
                onChanged: (v) => controller.updateActiveImageScale(v / 100),
              ),
            ],

            // Shared Controls: Rotation, Opacity, Placement
            const SizedBox(height: 14),
            _buildSliderRow(
              label: 'Rotation Angle',
              valText: '${layer.rotation.round()}°',
              value: layer.rotation,
              min: -180,
              max: 180,
              onChanged: (v) => controller.updateActiveRotation(v),
            ),

            const SizedBox(height: 10),
            _buildSliderRow(
              label: 'Opacity',
              valText: '${(layer.opacity * 100).round()}%',
              value: layer.opacity * 100,
              min: 10,
              max: 100,
              onChanged: (v) => controller.updateActiveOpacity(v / 100),
            ),

            const SizedBox(height: 16),
            _buildSectionHeader('Placement Landmark', badgeText: 'Or drag directly on 3D shirt'),
            const SizedBox(height: 8),

            // Landmark Placement Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: TshirtController.landmarks.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 3.2,
              ),
              itemBuilder: (context, index) {
                final key = TshirtController.landmarks.keys.elementAt(index);
                final info = TshirtController.landmarks[key]!;
                final isSelected = layer.positionKey == key;

                return InkWell(
                  onTap: () => controller.setLayerPlacement(key),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF6366F1).withValues(alpha: 0.16) : const Color(0xFF1C202A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF6366F1) : Colors.white12,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? const Color(0xFF6366F1) : Colors.white24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            info.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title, {String? badgeText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.7, color: Colors.white60),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (badgeText != null)
          Text(badgeText, style: const TextStyle(fontSize: 10, color: Color(0xFF6366F1))),
      ],
    );
  }

  Widget _buildSliderRow({
    required String label,
    required String valText,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            Text(valText, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
          ],
        ),
        SliderTheme(
          data: const SliderThemeData(
            activeTrackColor: Color(0xFF6366F1),
            thumbColor: Color(0xFF6366F1),
            inactiveTrackColor: Colors.white12,
            trackHeight: 4,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
