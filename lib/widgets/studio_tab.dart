import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tshirt_controller.dart';

class StudioTab extends StatelessWidget {
  const StudioTab({super.key});

  static const List<Map<String, String>> lightingPresets = [
    {'key': 'studio', 'name': 'Soft Studio'},
    {'key': 'warm', 'name': 'Warm Sunlight'},
    {'key': 'cool', 'name': 'Cyber Neon'},
    {'key': 'dramatic', 'name': 'Dramatic Rim'},
  ];

  static const List<Map<String, String>> cameraPresets = [
    {'view': 'front', 'name': 'Front View'},
    {'view': 'back', 'name': 'Back View'},
    {'view': 'left-sleeve', 'name': 'Left Sleeve'},
    {'view': 'right-sleeve', 'name': 'Right Sleeve'},
    {'view': 'closeup', 'name': 'Chest Close-up'},
    {'view': 'reset', 'name': 'Full Overview'},
  ];

  @override
  Widget build(BuildContext context) {
    final controller = TshirtController.to;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Lighting Mood
          _buildSectionHeader('Studio Lighting Mood'),
          const SizedBox(height: 8),

          Obx(() {
            final currentLighting = controller.lightingPreset.value;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lightingPresets.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 3.2,
              ),
              itemBuilder: (context, index) {
                final item = lightingPresets[index];
                final isSelected = item['key'] == currentLighting;

                return InkWell(
                  onTap: () => controller.setLighting(item['key']!),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6366F1).withValues(alpha: 0.16)
                          : const Color(0xFF1C202A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : Colors.white12,
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
                            color: isSelected
                                ? const Color(0xFF6366F1)
                                : Colors.white24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item['name']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),

          const SizedBox(height: 20),

          // Section: 360 Auto Rotate
          Obx(
            () => _buildSectionHeader(
              controller.is2DView.value
                  ? 'Front / Back Auto Preview'
                  : '360° Interactive Turntable',
            ),
          ),
          const SizedBox(height: 8),

          Obx(() {
            final isRotating = controller.autoRotate.value;
            final is2D = controller.is2DView.value;
            return InkWell(
              onTap: () => controller.toggleAutoRotate(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isRotating
                      ? const Color(0xFF6366F1).withValues(alpha: 0.16)
                      : const Color(0xFF1C202A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isRotating
                        ? const Color(0xFF6366F1)
                        : Colors.white12,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.autorenew,
                      color: isRotating
                          ? const Color(0xFF6366F1)
                          : Colors.white60,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        is2D ? 'Cycle Front and Back' : 'Continuous 360° Rotation',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isRotating
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Switch(
                      value: isRotating,
                      activeThumbColor: const Color(0xFF6366F1),
                      onChanged: (v) => controller.toggleAutoRotate(),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Section: Camera Focus Presets
          _buildSectionHeader('Camera Focus Presets'),
          const SizedBox(height: 8),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cameraPresets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3.2,
            ),
            itemBuilder: (context, index) {
              final item = cameraPresets[index];
              return InkWell(
                onTap: () => controller.setCameraView(item['view']!),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C202A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 14,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item['name']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Section: 3D Model Selection (User extensibility for list of GLB)
          _buildSectionHeader(
            '3D Garment Model',
            badgeText: 'Customizable Models',
          ),
          const SizedBox(height: 8),

          Obx(() {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C202A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedModel.value,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1A1C23),
                  items: controller.availableModels.map((m) {
                    final label = m
                        .split('/')
                        .last
                        .replaceAll('.glb', '')
                        .replaceAll('-', ' ')
                        .toUpperCase();
                    return DropdownMenuItem<String>(
                      value: m,
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) controller.loadModel(val);
                  },
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Reset All Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => controller.resetAll(),
              icon: const Icon(
                Icons.restart_alt,
                size: 16,
                color: Color(0xFFF87171),
              ),
              label: const Text(
                'Reset All Customizations',
                style: TextStyle(color: Color(0xFFF87171), fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFF87171), width: 1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
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
            style: const TextStyle(fontSize: 10, color: Color(0xFF6366F1)),
          ),
      ],
    );
  }
}
