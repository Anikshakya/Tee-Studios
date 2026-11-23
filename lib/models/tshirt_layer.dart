enum LayerType { text, image }

class Vector3D {
  final double x;
  final double y;
  final double z;

  const Vector3D({required this.x, required this.y, required this.z});

  factory Vector3D.fromJson(Map<String, dynamic> json) {
    return Vector3D(
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      z: (json['z'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'z': z};

  Vector3D copyWith({double? x, double? y, double? z}) {
    return Vector3D(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
    );
  }
}

class TshirtLayer {
  String id;
  LayerType type;
  String name;
  bool visible;
  String positionKey;
  Vector3D pos;
  Vector3D norm;
  double rotation;
  double opacity;

  // Text layer specific
  String text;
  String fontFamily;
  double fontSize;
  String textColor;
  double textArc;
  double textSpacing;

  // Image layer specific
  String imageSrc; // data URL or URL or asset path
  double scale;

  TshirtLayer({
    required this.id,
    required this.type,
    required this.name,
    this.visible = true,
    this.positionKey = 'front-chest',
    required this.pos,
    required this.norm,
    this.rotation = 0.0,
    this.opacity = 1.0,
    this.text = 'BROOKLYN',
    this.fontFamily = "'Bebas Neue', sans-serif",
    this.fontSize = 58.0,
    this.textColor = '#111111',
    this.textArc = 0.0,
    this.textSpacing = 2.0,
    this.imageSrc = '',
    this.scale = 1.0,
  });

  factory TshirtLayer.text({
    required String id,
    String initialText = 'BROOKLYN',
    String positionKey = 'front-chest',
    Vector3D? pos,
    Vector3D? norm,
    String fontFamily = "'Bebas Neue', sans-serif",
    double fontSize = 58.0,
    String textColor = '#111111',
    double textArc = 0.0,
    double textSpacing = 2.0,
    double rotation = 0.0,
    double opacity = 1.0,
  }) {
    return TshirtLayer(
      id: id,
      type: LayerType.text,
      name: 'Text: $initialText',
      positionKey: positionKey,
      pos: pos ?? const Vector3D(x: 0.0, y: 0.12, z: 0.1585),
      norm: norm ?? const Vector3D(x: 0.003, y: 0.148, z: 0.989),
      text: initialText,
      fontFamily: fontFamily,
      fontSize: fontSize,
      textColor: textColor,
      textArc: textArc,
      textSpacing: textSpacing,
      rotation: rotation,
      opacity: opacity,
    );
  }

  factory TshirtLayer.image({
    required String id,
    required String imageSrc,
    String name = 'Graphic Artwork',
    String positionKey = 'front-chest',
    Vector3D? pos,
    Vector3D? norm,
    double scale = 1.0,
    double rotation = 0.0,
    double opacity = 1.0,
  }) {
    return TshirtLayer(
      id: id,
      type: LayerType.image,
      name: name,
      positionKey: positionKey,
      pos: pos ?? const Vector3D(x: 0.0, y: 0.12, z: 0.1585),
      norm: norm ?? const Vector3D(x: 0.003, y: 0.148, z: 0.989),
      imageSrc: imageSrc,
      scale: scale,
      rotation: rotation,
      opacity: opacity,
    );
  }

  TshirtLayer cloneWith({
    String? id,
    String? name,
    Vector3D? pos,
    Vector3D? norm,
  }) {
    return TshirtLayer(
      id: id ?? '${this.id}_copy',
      type: type,
      name: name ?? '$this.name (Copy)',
      visible: visible,
      positionKey: positionKey,
      pos: pos ?? this.pos,
      norm: norm ?? this.norm,
      rotation: rotation,
      opacity: opacity,
      text: text,
      fontFamily: fontFamily,
      fontSize: fontSize,
      textColor: textColor,
      textArc: textArc,
      textSpacing: textSpacing,
      imageSrc: imageSrc,
      scale: scale,
    );
  }

  factory TshirtLayer.fromJson(Map<String, dynamic> json) {
    return TshirtLayer(
      id: json['id'] as String? ?? 'layer_${DateTime.now().millisecondsSinceEpoch}',
      type: (json['type'] == 'image') ? LayerType.image : LayerType.text,
      name: json['name'] as String? ?? 'Untitled',
      visible: json['visible'] as bool? ?? true,
      positionKey: json['positionKey'] as String? ?? 'front-chest',
      pos: json['pos'] != null ? Vector3D.fromJson(json['pos'] as Map<String, dynamic>) : const Vector3D(x: 0, y: 0.12, z: 0.1585),
      norm: json['norm'] != null ? Vector3D.fromJson(json['norm'] as Map<String, dynamic>) : const Vector3D(x: 0.003, y: 0.148, z: 0.989),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      text: json['text'] as String? ?? '',
      fontFamily: json['fontFamily'] as String? ?? "'Bebas Neue', sans-serif",
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 58.0,
      textColor: json['textColor'] as String? ?? '#111111',
      textArc: (json['textArc'] as num?)?.toDouble() ?? 0.0,
      textSpacing: (json['textSpacing'] as num?)?.toDouble() ?? 2.0,
      imageSrc: json['imageSrc'] as String? ?? '',
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type == LayerType.image ? 'image' : 'text',
      'name': name,
      'visible': visible,
      'positionKey': positionKey,
      'pos': pos.toJson(),
      'norm': norm.toJson(),
      'rotation': rotation,
      'opacity': opacity,
      'text': text,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'textColor': textColor,
      'textArc': textArc,
      'textSpacing': textSpacing,
      'imageSrc': imageSrc,
      'scale': scale,
    };
  }
}
