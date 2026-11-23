import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/tshirt_layer.dart';

class LandmarkInfo {
  final String key;
  final String name;
  final Vector3D pos;
  final Vector3D norm;
  final String camView;

  const LandmarkInfo({
    required this.key,
    required this.name,
    required this.pos,
    required this.norm,
    required this.camView,
  });
}

class TshirtController extends GetxController {
  static TshirtController get to => Get.find<TshirtController>();

  // 3D Landmarks
  static const Map<String, LandmarkInfo> landmarks = {
    'front-chest': LandmarkInfo(
      key: 'front-chest',
      name: 'Center Chest',
      pos: Vector3D(x: 0.0, y: 0.12, z: 0.1585),
      norm: Vector3D(x: 0.003, y: 0.148, z: 0.989),
      camView: 'front',
    ),
    'front-pocket': LandmarkInfo(
      key: 'front-pocket',
      name: 'Left Pocket',
      pos: Vector3D(x: 0.11, y: 0.14, z: 0.1633),
      norm: Vector3D(x: 0.116, y: 0.165, z: 0.979),
      camView: 'front',
    ),
    'front-right': LandmarkInfo(
      key: 'front-right',
      name: 'Right Chest',
      pos: Vector3D(x: -0.11, y: 0.14, z: 0.1636),
      norm: Vector3D(x: -0.032, y: 0.136, z: 0.990),
      camView: 'front',
    ),
    'left-sleeve': LandmarkInfo(
      key: 'left-sleeve',
      name: 'Left Sleeve',
      pos: Vector3D(x: 0.4281, y: 0.10, z: -0.01),
      norm: Vector3D(x: 0.911, y: 0.353, z: 0.214),
      camView: 'left-sleeve',
    ),
    'right-sleeve': LandmarkInfo(
      key: 'right-sleeve',
      name: 'Right Sleeve',
      pos: Vector3D(x: -0.4279, y: 0.10, z: -0.01),
      norm: Vector3D(x: -0.935, y: 0.351, z: -0.037),
      camView: 'right-sleeve',
    ),
    'back-upper': LandmarkInfo(
      key: 'back-upper',
      name: 'Upper Back',
      pos: Vector3D(x: 0.0, y: 0.16, z: -0.1787),
      norm: Vector3D(x: -0.014, y: 0.042, z: -0.999),
      camView: 'back',
    ),
    'back-center': LandmarkInfo(
      key: 'back-center',
      name: 'Center Back',
      pos: Vector3D(x: 0.0, y: 0.04, z: -0.181),
      norm: Vector3D(x: 0.052, y: -0.001, z: -0.999),
      camView: 'back',
    ),
    'back-neck': LandmarkInfo(
      key: 'back-neck',
      name: 'Back Collar',
      pos: Vector3D(x: 0.0, y: 0.28, z: -0.1712),
      norm: Vector3D(x: -0.064, y: 0.070, z: -0.995),
      camView: 'back',
    ),
  };

  // State Observables: Empty at first (user customizes from clean state)
  final shirtColor = ''.obs; // Empty string: original raw shirt color
  final activeFabric = ''.obs; // Empty string: no fabric selected at first
  final fabricRoughness = 0.88.obs;
  final interactionMode = 'orbit'.obs; // 'orbit' or 'drag'
  final isHudVisible = false.obs; // Starts collapsed, bottom nav unselected
  final activeTab = 0.obs; // 0: Apparel, 1: Layers, 2: Edit Layer, 3: Studio
  final lightingPreset = 'studio'.obs;
  final autoRotate = false.obs;

  // GLB Models List
  final availableModels = <String>['models/tshirt-mockup.glb'].obs;
  final selectedModel = 'models/tshirt-mockup.glb'.obs;

  // Layer Hierarchy: Empty at first (no default text or image)
  final layers = <TshirtLayer>[].obs;
  final selectedLayerId = ''.obs;

  // Communication callback with 3D Viewport
  void Function(Map<String, dynamic> command)? onSend3DCommand;

  TshirtLayer? get activeLayer {
    if (selectedLayerId.value.isEmpty) return null;
    return layers.firstWhereOrNull((l) => l.id == selectedLayerId.value);
  }

  int get activeLayerIndex {
    return layers.indexWhere((l) => l.id == selectedLayerId.value);
  }

  // --- ACTIONS ---

  void setShirtColor(String hex) {
    shirtColor.value = hex;
    syncStateTo3D();
  }

  void setFabric(String fabricKey, double defaultRoughness) {
    // If tapping already active fabric, toggle off
    if (activeFabric.value == fabricKey) {
      activeFabric.value = '';
    } else {
      activeFabric.value = fabricKey;
      fabricRoughness.value = defaultRoughness;
    }
    syncStateTo3D();
  }

  void setFabricRoughness(double roughness) {
    fabricRoughness.value = roughness;
    syncStateTo3D();
  }

  void setInteractionMode(String mode) {
    interactionMode.value = mode;
    onSend3DCommand?.call({
      'type': 'SET_INTERACTION_MODE',
      'mode': mode,
    });
  }

  void toggleHud() {
    isHudVisible.value = !isHudVisible.value;
    notify3DResize();
  }

  void hideHud() {
    isHudVisible.value = false;
    notify3DResize();
  }

  void showHud() {
    isHudVisible.value = true;
    notify3DResize();
  }

  void notify3DResize() {
    onSend3DCommand?.call({'type': 'RESIZE'});
    Future.delayed(const Duration(milliseconds: 80), () {
      onSend3DCommand?.call({'type': 'RESIZE'});
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      onSend3DCommand?.call({'type': 'RESIZE'});
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      onSend3DCommand?.call({'type': 'RESIZE'});
    });
  }

  void setActiveTab(int index) {
    activeTab.value = index;
  }

  void onBottomNavTapped(int index) {
    if (isHudVisible.value && activeTab.value == index) {
      // Already selected: unselect and collapse HUD!
      hideHud();
    } else {
      // Select this tab and open/show HUD!
      activeTab.value = index;
      showHud();
    }
  }

  // --- LAYER MANAGEMENT & REORDERING ---

  void addTextLayer([String initialText = 'NEW TEXT']) {
    final landmark = landmarks['front-chest']!;
    final layer = TshirtLayer.text(
      id: 'layer_${DateTime.now().millisecondsSinceEpoch}_${layers.length}',
      initialText: initialText,
      positionKey: 'front-chest',
      pos: landmark.pos,
      norm: landmark.norm,
      textColor: '#111111',
      fontSize: 58,
    );
    layers.add(layer);
    selectedLayerId.value = layer.id;
    activeTab.value = 2; // Jump to Edit Layer tab
    syncStateTo3D();
  }

  void addImageLayer(String dataUrl, String fileName) {
    final landmark = landmarks['front-chest']!;
    final layer = TshirtLayer.image(
      id: 'layer_${DateTime.now().millisecondsSinceEpoch}_${layers.length}',
      imageSrc: dataUrl,
      name: fileName,
      positionKey: 'front-chest',
      pos: landmark.pos,
      norm: landmark.norm,
      scale: 1.0,
    );
    layers.add(layer);
    selectedLayerId.value = layer.id;
    activeTab.value = 2; // Jump to Edit Layer tab
    syncStateTo3D();
  }

  Future<void> pickImageForNewLayer() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 95,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        final base64Data = base64Encode(bytes);
        final mime = file.mimeType ?? 'image/png';
        final dataUrl = 'data:$mime;base64,$base64Data';
        addImageLayer(dataUrl, file.name);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> replaceActiveLayerImage() async {
    final layer = activeLayer;
    if (layer == null || layer.type != LayerType.image) return;

    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 95,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        final base64Data = base64Encode(bytes);
        final mime = file.mimeType ?? 'image/png';
        layer.imageSrc = 'data:$mime;base64,$base64Data';
        layer.name = file.name;
        layers.refresh();
        syncStateTo3D();
      }
    } catch (e) {
      debugPrint('Error replacing image: $e');
    }
  }

  void selectLayer(String id) {
    selectedLayerId.value = id;
  }

  /// Drag-and-Drop Reordering using Flutter's ReorderableListView
  void reorderLayers(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = layers.removeAt(oldIndex);
    layers.insert(newIndex, item);
    layers.refresh();
    syncStateTo3D();
  }

  void toggleLayerVisibility(String id) {
    final layer = layers.firstWhereOrNull((l) => l.id == id);
    if (layer != null) {
      layer.visible = !layer.visible;
      layers.refresh();
      syncStateTo3D();
    }
  }

  void duplicateLayer(String id) {
    final idx = layers.indexWhere((l) => l.id == id);
    if (idx != -1) {
      final orig = layers[idx];
      final clone = orig.cloneWith(
        id: 'layer_${DateTime.now().millisecondsSinceEpoch}',
        pos: Vector3D(x: orig.pos.x + 0.02, y: orig.pos.y - 0.02, z: orig.pos.z),
      );
      layers.insert(idx + 1, clone);
      selectedLayerId.value = clone.id;
      layers.refresh();
      syncStateTo3D();
    }
  }

  void deleteLayer(String id) {
    final idx = layers.indexWhere((l) => l.id == id);
    if (idx != -1) {
      layers.removeAt(idx);
      if (selectedLayerId.value == id) {
        selectedLayerId.value = layers.isNotEmpty ? layers[layers.length - 1].id : '';
      }
      layers.refresh();
      syncStateTo3D();
    }
  }

  // --- ACTIVE LAYER FIELD MUTATIONS ---

  void updateActiveText(String text) {
    final layer = activeLayer;
    if (layer != null && layer.type == LayerType.text) {
      layer.text = text;
      layer.name = 'Text: ${text.isEmpty ? "Untitled" : text}';
      layers.refresh();
      syncStateTo3D();
    }
  }

  void updateActiveFont(String font) {
    final layer = activeLayer;
    if (layer != null && layer.type == LayerType.text) {
      layer.fontFamily = font;
      layers.refresh();
      syncStateTo3D();
    }
  }

  void updateActiveFontSize(double size) {
    final layer = activeLayer;
    if (layer != null && layer.type == LayerType.text) {
      layer.fontSize = size;
      layers.refresh();
      syncStateTo3D();
    }
  }

  void updateActiveTextArc(double arc) {
    final layer = activeLayer;
    if (layer != null && layer.type == LayerType.text) {
      layer.textArc = arc;
      layers.refresh();
      syncStateTo3D();
    }
  }

  void updateActiveTextSpacing(double spacing) {
    final layer = activeLayer;
    if (layer != null && layer.type == LayerType.text) {
      layer.textSpacing = spacing;
      layers.refresh();
      syncStateTo3D();
    }
  }

  void updateActiveTextColor(String hex) {
    final layer = activeLayer;
    if (layer != null && layer.type == LayerType.text) {
      layer.textColor = hex;
      layers.refresh();
      syncStateTo3D();
    }
  }

  void updateActiveImageScale(double scale) {
    final layer = activeLayer;
    if (layer != null && layer.type == LayerType.image) {
      layer.scale = scale;
      layers.refresh();
      syncStateTo3D();
    }
  }

  void updateActiveRotation(double deg) {
    final layer = activeLayer;
    if (layer != null) {
      layer.rotation = deg;
      layers.refresh();
      syncStateTo3D();
    }
  }

  void updateActiveOpacity(double opacity) {
    final layer = activeLayer;
    if (layer != null) {
      layer.opacity = opacity;
      layers.refresh();
      syncStateTo3D();
    }
  }

  void setLayerPlacement(String placementKey) {
    final layer = activeLayer;
    if (layer != null && landmarks.containsKey(placementKey)) {
      final landmark = landmarks[placementKey]!;
      layer.positionKey = placementKey;
      layer.pos = landmark.pos;
      layer.norm = landmark.norm;
      layers.refresh();
      setCameraView(landmark.camView);
      syncStateTo3D();
    }
  }

  // --- STUDIO & ENVIRONMENT ---

  void setCameraView(String view) {
    onSend3DCommand?.call({
      'type': 'SET_CAMERA',
      'view': view,
    });
  }

  void setLighting(String preset) {
    lightingPreset.value = preset;
    onSend3DCommand?.call({
      'type': 'SET_LIGHTING',
      'preset': preset,
    });
  }

  void toggleAutoRotate() {
    autoRotate.value = !autoRotate.value;
    onSend3DCommand?.call({
      'type': 'SET_AUTO_ROTATE',
      'enabled': autoRotate.value,
    });
  }

  void loadModel(String path) {
    selectedModel.value = path;
    onSend3DCommand?.call({
      'type': 'LOAD_MODEL',
      'modelPath': path,
    });
  }

  void resetAll() {
    layers.clear();
    selectedLayerId.value = '';
    shirtColor.value = '';
    activeFabric.value = '';
    fabricRoughness.value = 0.88;
    autoRotate.value = false;
    interactionMode.value = 'orbit';
    activeTab.value = 0;

    syncStateTo3D();
    setCameraView('front');
  }

  // --- BIDIRECTIONAL SYNC TO 3D ---

  void syncStateTo3D() {
    onSend3DCommand?.call({
      'type': 'SYNC_STATE',
      'shirtColor': shirtColor.value,
      'activeFabric': activeFabric.value,
      'fabricRoughness': fabricRoughness.value,
      'interactionMode': interactionMode.value,
      'autoRotate': autoRotate.value,
      'lighting': lightingPreset.value,
      'layers': layers.map((l) => l.toJson()).toList(),
    });
  }

  void handleMessageFrom3D(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    if (type == 'READY') {
      syncStateTo3D();
    } else if (type == 'LAYER_MOVED') {
      final layerId = data['layerId'] as String?;
      final pos = data['pos'] != null ? Vector3D.fromJson(data['pos'] as Map<String, dynamic>) : null;
      final norm = data['norm'] != null ? Vector3D.fromJson(data['norm'] as Map<String, dynamic>) : null;
      if (layerId != null && pos != null && norm != null) {
        final layer = layers.firstWhereOrNull((l) => l.id == layerId);
        if (layer != null) {
          layer.pos = pos;
          layer.norm = norm;
          layer.positionKey = 'custom';
          layers.refresh();
        }
      }
    } else if (type == 'LAYER_SELECTED') {
      final layerId = data['layerId'] as String?;
      if (layerId != null) {
        selectedLayerId.value = layerId;
        activeTab.value = 2; // Jump to Edit Layer
      }
    }
  }
}
