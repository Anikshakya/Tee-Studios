import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tshirt_controller.dart';
import '../models/tshirt_layer.dart';

class LayersTab extends StatelessWidget {
  const LayersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TshirtController.to;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Buttons: Add Text & Add Image
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.addTextLayer(),
                  icon: const Icon(Icons.title, size: 16),
                  label: const Text('Add Text', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.18),
                    foregroundColor: const Color(0xFFA5B4FC),
                    side: const BorderSide(color: Color(0xFF6366F1), width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.pickImageForNewLayer(),
                  icon: const Icon(Icons.image, size: 16),
                  label: const Text('Add Image', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC4899).withValues(alpha: 0.18),
                    foregroundColor: const Color(0xFFF472B6),
                    side: const BorderSide(color: Color(0xFFEC4899), width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LAYER STACK (DRAG TO REORDER)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.7,
                  color: Colors.white60,
                ),
              ),
              Text(
                'Top renders above',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Reorderable Layers List
          Expanded(
            child: Obx(() {
              if (controller.layers.isEmpty) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.layers_clear, size: 36, color: Colors.white38),
                        SizedBox(height: 10),
                        Text(
                          'No Layers Added',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add text or image graphics to get started',
                          style: TextStyle(fontSize: 11, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemCount: controller.layers.length,
                  onReorder: (oldIndex, newIndex) => controller.reorderLayers(oldIndex, newIndex),
                  itemBuilder: (context, index) {
                    final layer = controller.layers[index];
                    final isSelected = layer.id == controller.selectedLayerId.value;
                    final landmarkName = TshirtController.landmarks[layer.positionKey]?.name ?? 'Custom';

                    return Container(
                      key: ValueKey(layer.id),
                      margin: const EdgeInsets.only(bottom: 8),
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
                                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                )
                              ]
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            controller.selectLayer(layer.id);
                            controller.setActiveTab(2); // Jump to Edit Layer
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            child: Row(
                              children: [
                                // Drag Handle
                                ReorderableDragStartListener(
                                  index: index,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                    child: const Icon(Icons.drag_indicator, size: 20, color: Colors.white38),
                                  ),
                                ),
                                const SizedBox(width: 6),

                                // Layer Type Badge
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: layer.type == LayerType.text
                                        ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)])
                                        : const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFF43F5E)]),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: layer.type == LayerType.text
                                      ? const Text('T', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13))
                                      : const Icon(Icons.image, size: 16, color: Colors.white),
                                ),
                                const SizedBox(width: 10),

                                // Info: Name + Landmark
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        layer.name,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$landmarkName • ${layer.visible ? "Visible" : "Hidden"}',
                                        style: const TextStyle(fontSize: 11, color: Colors.white54),
                                      ),
                                    ],
                                  ),
                                ),

                                // Actions: Visibility, Duplicate, Delete
                                IconButton(
                                  icon: Icon(
                                    layer.visible ? Icons.visibility : Icons.visibility_off,
                                    size: 18,
                                    color: layer.visible ? Colors.white70 : Colors.white30,
                                  ),
                                  onPressed: () => controller.toggleLayerVisibility(layer.id),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 16, color: Colors.white54),
                                  onPressed: () => controller.duplicateLayer(layer.id),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFF87171)),
                                  onPressed: () => controller.deleteLayer(layer.id),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
