import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import 'controllers/tshirt_controller.dart';
import 'models/tshirt_layer.dart';
import 'models/tshirt_mesh_projection.dart';

class TshirtViewer2D extends StatefulWidget {
  const TshirtViewer2D({super.key});

  @override
  State<TshirtViewer2D> createState() => _TshirtViewer2DState();
}

class _TshirtViewer2DState extends State<TshirtViewer2D>
    with SingleTickerProviderStateMixin {
  static Future<TshirtMeshProjection>? _sharedMesh;

  final _boundaryKey = GlobalKey();
  final _zoomController = TransformationController();
  late final TshirtController _controller;
  late final AnimationController _rotationController;
  late final Worker _autoRotateWorker;
  late final Future<TshirtMeshProjection> _meshFuture;

  @override
  void initState() {
    super.initState();
    _controller = TshirtController.to;
    _meshFuture = _sharedMesh ??= TshirtMeshProjection.load();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    if (_controller.autoRotate.value) {
      _rotationController.repeat();
    }
    _autoRotateWorker = ever<bool>(_controller.autoRotate, (isRotating) {
      if (isRotating) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    });
    _controller.onExport2D = _exportPngPreview;
  }

  @override
  void dispose() {
    _autoRotateWorker.dispose();
    _rotationController.dispose();
    _zoomController.dispose();
    _controller.onExport2D = null;
    super.dispose();
  }

  Future<void> _exportPngPreview() async {
    await WidgetsBinding.instance.endOfFrame;
    final renderObject = _boundaryKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) return;

    final image = await renderObject.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (data == null || !mounted) return;

    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF14171F),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '2D Mockup PNG',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                  maxHeight: 600,
                ),
                child: Image.memory(bytes, fit: BoxFit.contain),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _moveLayerByDelta(
    TshirtLayer layer,
    Offset delta,
    Rect shirtRect,
    TshirtViewProjection projection,
    String view,
  ) {
    if (shirtRect.width <= 0 || shirtRect.height <= 0) return;

    final deltaX = delta.dx / shirtRect.width * projection.bounds.width;
    final deltaY = delta.dy / shirtRect.height * projection.bounds.height;
    final position = switch (view) {
      'back' => layer.pos.copyWith(
        x: (layer.pos.x - deltaX).clamp(-0.45, 0.45).toDouble(),
        y: (layer.pos.y - deltaY).clamp(-0.5, 0.5).toDouble(),
      ),
      'left-sleeve' => layer.pos.copyWith(
        y: (layer.pos.y - deltaY).clamp(-0.5, 0.5).toDouble(),
        z: (layer.pos.z - deltaX).clamp(-0.223, 0.223).toDouble(),
      ),
      'right-sleeve' => layer.pos.copyWith(
        y: (layer.pos.y - deltaY).clamp(-0.5, 0.5).toDouble(),
        z: (layer.pos.z + deltaX).clamp(-0.223, 0.223).toDouble(),
      ),
      _ => layer.pos.copyWith(
        x: (layer.pos.x + deltaX).clamp(-0.45, 0.45).toDouble(),
        y: (layer.pos.y - deltaY).clamp(-0.5, 0.5).toDouble(),
      ),
    };
    final normal = switch (view) {
      'back' => const Vector3D(x: 0, y: 0, z: -1),
      'left-sleeve' => const Vector3D(x: 1, y: 0, z: 0),
      'right-sleeve' => const Vector3D(x: -1, y: 0, z: 0),
      _ => const Vector3D(x: 0, y: 0, z: 1),
    };
    _controller.updateLayerPosition(layer.id, position, normal);
  }

  void _selectLayer(TshirtLayer layer) {
    _controller.selectLayer(layer.id);
    _controller.setInteractionMode('drag');
    _controller.setActiveTab(2);
  }

  void _clearLayerSelection() {
    _controller.clearLayerSelection();
  }

  bool _isLayerOnView(TshirtLayer layer, String view) {
    final isBack = layer.positionKey.startsWith('back-') || layer.pos.z < -0.05;
    switch (view) {
      case 'back':
        return isBack;
      case 'left-sleeve':
      case 'right-sleeve':
        return layer.positionKey == view ||
            (layer.positionKey == 'custom' &&
                (view == 'left-sleeve'
                    ? layer.pos.x > 0.25
                    : layer.pos.x < -0.25));
      default:
        return !isBack;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TshirtMeshProjection>(
      future: _meshFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to load the 2D shirt model: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.checkroom, color: Color(0xFF818CF8), size: 28),
                SizedBox(height: 8),
                Text(
                  'Loading shirt model…',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        }
        return _buildModelViewer(snapshot.requireData);
      },
    );
  }

  Widget _buildModelViewer(TshirtMeshProjection model) {
    return Obx(() {
      final shirtColor = _controller.shirtColor.value;
      final fabric = _controller.activeFabric.value;
      final roughness = _controller.fabricRoughness.value;
      final lighting = _controller.lightingPreset.value;
      final cameraView = _controller.cameraView.value;
      final autoRotate = _controller.autoRotate.value;
      final interactionMode = _controller.interactionMode.value;
      final selectedLayerId = _controller.selectedLayerId.value;
      final layers = _controller.layers.toList();

      return AnimatedBuilder(
        animation: _rotationController,
        builder: (context, _) {
          final view = autoRotate
              ? (_rotationController.value < 0.5 ? 'front' : 'back')
              : cameraView;
          final projection = model.projectionFor(view);
          final visibleLayers = layers
              .where((layer) => layer.visible && _isLayerOnView(layer, view))
              .toList();

          return RepaintBoundary(
            key: _boundaryKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                final shirtRect = Tshirt2DLayout.destinationRect(
                  size,
                  projection,
                  closeup: view == 'closeup',
                );
                final activeLayer = _controller.activeLayer;

                return InteractiveViewer(
                  transformationController: _zoomController,
                  boundaryMargin: const EdgeInsets.all(120),
                  minScale: 0.8,
                  maxScale: 5,
                  panEnabled: interactionMode != 'drag',
                  scaleEnabled: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _clearLayerSelection,
                    onPanUpdate: activeLayer != null
                        ? (details) => _moveLayerByDelta(
                            activeLayer,
                            details.delta,
                            shirtRect,
                            projection,
                            view,
                          )
                        : null,
                    child: Stack(
                      fit: StackFit.expand,
                      clipBehavior: Clip.hardEdge,
                      children: [
                        CustomPaint(
                          painter: Tshirt2DPainter(
                            model: model,
                            projection: projection,
                            shirtColor: shirtColor,
                            fabric: fabric,
                            roughness: roughness,
                            lighting: lighting,
                            closeup: view == 'closeup',
                          ),
                        ),
                        for (final layer in visibleLayers)
                          _buildLayer(
                            layer: layer,
                            shirtRect: shirtRect,
                            projection: projection,
                            selected: layer.id == selectedLayerId,
                            interactionMode: interactionMode,
                            view: view,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    });
  }

  Widget _buildLayer({
    required TshirtLayer layer,
    required Rect shirtRect,
    required TshirtViewProjection projection,
    required bool selected,
    required String interactionMode,
    required String view,
  }) {
    final center = Tshirt2DLayout.layerPosition(
      layer,
      view,
      projection,
      shirtRect,
    );
    final isText = layer.type == LayerType.text;
    final side = isText
        ? Tshirt2DLayout.textLayerWidth(
            layer,
            shirtRect.width,
            projection.bounds.width,
          )
        : ((0.24 * layer.scale / projection.bounds.width) * shirtRect.width)
              .clamp(36.0, shirtRect.width * 0.62)
              .toDouble();
    final layerSize = Size(side, isText ? side * 0.38 : side);

    Widget artwork = isText
        ? CustomPaint(
            size: layerSize,
            painter: _LayerTextPainter(layer: layer, size: layerSize),
          )
        : _LayerImage(layer: layer);
    artwork = Opacity(
      opacity: layer.opacity.clamp(0, 1).toDouble(),
      child: Transform.rotate(
        angle: layer.rotation * math.pi / 180,
        child: artwork,
      ),
    );

    return Positioned(
      left: center.dx - layerSize.width / 2,
      top: center.dy - layerSize.height / 2,
      width: layerSize.width,
      height: layerSize.height,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _selectLayer(layer),
        onPanStart: (_) => _selectLayer(layer),
        onPanUpdate: selected
            ? (details) => _moveLayerByDelta(
                layer,
                details.delta,
                shirtRect,
                projection,
                view,
              )
            : null,
        child: DecoratedBox(
          decoration: selected
              ? BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF818CF8),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                )
              : const BoxDecoration(),
          child: Padding(padding: const EdgeInsets.all(3), child: artwork),
        ),
      ),
    );
  }
}

class Tshirt2DLayout {
  static double textLayerWidth(
    TshirtLayer layer,
    double shirtWidth,
    double projectedMeshWidth,
  ) {
    final fontRatio = layer.fontSize / 100;
    final characterRatio = math
        .pow(math.max(1, layer.text.trim().length) / 8, 0.35)
        .toDouble();
    final normalizedWidth = 0.24 * fontRatio * characterRatio;
    return (projectedMeshWidth > 0
            ? (normalizedWidth / projectedMeshWidth) * shirtWidth
            : shirtWidth * normalizedWidth)
        .toDouble();
  }

  static Rect destinationRect(
    Size size,
    TshirtViewProjection projection, {
    bool closeup = false,
  }) {
    final bounds = projection.bounds;
    if (size.isEmpty || bounds.isEmpty) return Rect.zero;
    final fitScale = math.min(
      size.width * 0.86 / bounds.width,
      size.height * 0.82 / bounds.height,
    );
    final scale = fitScale * (closeup ? 1.45 : 1);
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: bounds.width * scale,
      height: bounds.height * scale,
    );
  }

  static Offset layerPosition(
    TshirtLayer layer,
    String view,
    TshirtViewProjection projection,
    Rect destination,
  ) {
    final point = TshirtMeshProjection.projectPoint(layer.pos, view);
    final bounds = projection.bounds;
    return Offset(
      destination.left +
          ((point.dx - bounds.left) / bounds.width) * destination.width,
      destination.top +
          ((point.dy - bounds.top) / bounds.height) * destination.height,
    );
  }
}

class Tshirt2DPainter extends CustomPainter {
  final TshirtMeshProjection model;
  final TshirtViewProjection projection;
  final String shirtColor;
  final String fabric;
  final double roughness;
  final String lighting;
  final bool closeup;

  Tshirt2DPainter({
    required this.model,
    required this.projection,
    required this.shirtColor,
    required this.fabric,
    required this.roughness,
    required this.lighting,
    required this.closeup,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final viewport = Offset.zero & size;
    final backgroundColors = switch (lighting) {
      'warm' => const [Color(0xFF2B211D), Color(0xFF171416), Color(0xFF090A0E)],
      'cool' => const [Color(0xFF192633), Color(0xFF12141C), Color(0xFF090A0E)],
      'dramatic' => const [
        Color(0xFF11141F),
        Color(0xFF0B0D12),
        Color(0xFF050609),
      ],
      _ => const [Color(0xFF202432), Color(0xFF12141C), Color(0xFF090A0E)],
    };
    canvas.drawRect(
      viewport,
      Paint()
        ..shader = RadialGradient(
          colors: backgroundColors,
          stops: const [0, 0.65, 1],
        ).createShader(viewport),
    );

    final destination = Tshirt2DLayout.destinationRect(
      size,
      projection,
      closeup: closeup,
    );
    if (destination.isEmpty) return;

    final scale = destination.width / projection.bounds.width;
    canvas.saveLayer(viewport, Paint());
    canvas.save();
    canvas.translate(destination.center.dx, destination.center.dy);
    canvas.scale(scale);
    canvas.translate(
      -projection.bounds.center.dx,
      -projection.bounds.center.dy,
    );
    canvas.drawVertices(
      projection.vertices,
      BlendMode.srcOver,
      Paint()
        ..shader = model.textureShader
        ..filterQuality = FilterQuality.high
        ..isAntiAlias = true,
    );
    if (shirtColor.isNotEmpty) {
      canvas.drawVertices(
        projection.vertices,
        BlendMode.srcOver,
        Paint()
          ..color = _parseColor(shirtColor).withValues(alpha: 0.72)
          ..blendMode = BlendMode.srcATop
          ..isAntiAlias = true,
      );
    }
    canvas.restore();

    _paintFabric(canvas, destination, shirtColor);
    _paintLighting(canvas, destination);
    canvas.restore();
  }

  void _paintFabric(Canvas canvas, Rect rect, String shirtColor) {
    if (fabric.isEmpty) return;
    final alpha = (0.025 + roughness * 0.055).clamp(0.02, 0.09);
    final shirt = shirtColor.isEmpty ? Colors.white : _parseColor(shirtColor);
    final color = _contrastColor(shirt).withValues(alpha: alpha);
    final paint = Paint()
      ..color = color
      ..blendMode = BlendMode.srcATop
      ..strokeWidth = math.max(0.45, rect.width * 0.0015);

    switch (fabric) {
      case 'dryfit':
        for (double y = rect.top; y < rect.bottom; y += 6) {
          for (double x = rect.left; x < rect.right; x += 6) {
            canvas.drawCircle(Offset(x, y), rect.width * 0.0025, paint);
          }
        }
        break;
      case 'fleece':
        _paintDiagonalWeave(canvas, rect, paint, spacing: 9, crosshatch: false);
        break;
      case 'linen':
        _paintDiagonalWeave(canvas, rect, paint, spacing: 7, crosshatch: true);
        break;
      case 'denim':
        _paintDiagonalWeave(canvas, rect, paint, spacing: 5, crosshatch: false);
        break;
      case 'silk':
        canvas.drawRect(
          rect,
          Paint()
            ..blendMode = BlendMode.srcATop
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.18),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.06),
              ],
              stops: const [0, 0.48, 1],
            ).createShader(rect),
        );
        break;
      default:
        for (double y = rect.top; y < rect.bottom; y += 4) {
          canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
        }
    }
  }

  void _paintLighting(Canvas canvas, Rect rect) {
    final highlight = switch (lighting) {
      'warm' => const Color(0xFFFFD8A8),
      'cool' => const Color(0xFF9BDFFF),
      'dramatic' => const Color(0xFFB9C6FF),
      _ => Colors.white,
    };
    final intensity = lighting == 'dramatic' ? 0.12 : 0.06;
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.srcATop
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            highlight.withValues(alpha: intensity),
            Colors.transparent,
            Colors.black.withValues(alpha: intensity * 0.65),
          ],
        ).createShader(rect),
    );
  }

  void _paintDiagonalWeave(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    required double spacing,
    required bool crosshatch,
  }) {
    for (double offset = -rect.height; offset < rect.width; offset += spacing) {
      canvas.drawLine(
        Offset(rect.left + offset, rect.top),
        Offset(rect.left + offset + rect.height, rect.bottom),
        paint,
      );
      if (crosshatch) {
        canvas.drawLine(
          Offset(rect.left + offset, rect.bottom),
          Offset(rect.left + offset + rect.height, rect.top),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant Tshirt2DPainter oldDelegate) => true;
}

class _LayerImage extends StatelessWidget {
  final TshirtLayer layer;

  const _LayerImage({required this.layer});

  @override
  Widget build(BuildContext context) {
    final source = layer.imageSrc;
    if (source.startsWith('data:')) {
      final separator = source.indexOf(',');
      if (separator < 0) return _imageError();

      try {
        final metadata = source.substring(0, separator);
        final payload = source.substring(separator + 1);
        final bytes = metadata.contains(';base64')
            ? base64Decode(payload)
            : Uint8List.fromList(utf8.encode(Uri.decodeComponent(payload)));
        return Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => _imageError(),
        );
      } on FormatException {
        return _imageError();
      }
    }

    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _imageError(),
      );
    }
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _imageError(),
      );
    }
    return _imageError();
  }

  Widget _imageError() {
    return const Center(
      child: Icon(Icons.broken_image_outlined, color: Colors.white54),
    );
  }
}

class _LayerTextPainter extends CustomPainter {
  final TshirtLayer layer;
  final Size size;

  _LayerTextPainter({required this.layer, required this.size});

  @override
  void paint(Canvas canvas, Size _) {
    if (layer.text.isEmpty) return;
    final fontSize = size.height * (layer.fontSize * 2.2 / 1024);
    final letterSpacing =
        layer.textSpacing * size.width / 2048;
    final firstFamily = layer.fontFamily
        .split(',')
        .first
        .replaceAll("'", '')
        .replaceAll('"', '')
        .trim();
    final style = TextStyle(
      color: _parseColor(layer.textColor),
      fontFamily: firstFamily.isEmpty ? null : firstFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      letterSpacing: letterSpacing,
    );

    if (layer.textArc == 0 || layer.text.contains('\n')) {
      final painter = TextPainter(
        text: TextSpan(text: layer.text, style: style),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 3,
      )..layout(maxWidth: size.width);
      painter.paint(
        canvas,
        Offset(
          (size.width - painter.width) / 2,
          (size.height - painter.height) / 2,
        ),
      );
      return;
    }

    final characters = layer.text.split('');
    final painters = characters
        .map(
          (character) => TextPainter(
            text: TextSpan(text: character, style: style),
            textDirection: TextDirection.ltr,
          )..layout(),
        )
        .toList();
    final rawWidth = painters.fold<double>(
      0,
      (total, painter) => total + painter.width,
    );
    final spacing = layer.textSpacing * size.width / 2048;
    final totalWidth = math.max(
      1.0,
      rawWidth + spacing * math.max(0, painters.length - 1),
    );
    final scale = math.min(1.0, size.width / totalWidth);
    final arc = (layer.textArc / 100) * 1.6;
    final radius = totalWidth / math.max(0.15, arc.abs());
    var cursor = -totalWidth / 2;

    for (var index = 0; index < painters.length; index++) {
      final painter = painters[index];
      final characterWidth = painter.width;
      final centerX = cursor + characterWidth / 2;
      final progress = (centerX / (totalWidth / 2)).clamp(-1.0, 1.0);
      final angle = progress * arc / 2;
      final offsetY = -arc.sign * radius * (1 - math.cos(angle));
      canvas.save();
      canvas.translate(
        size.width / 2 + centerX * scale,
        size.height / 2 + offsetY * scale,
      );
      canvas.rotate(angle);
      canvas.scale(scale);
      painter.paint(canvas, Offset(-characterWidth / 2, -painter.height / 2));
      canvas.restore();
      cursor += characterWidth + spacing;
    }
  }

  @override
  bool shouldRepaint(covariant _LayerTextPainter oldDelegate) => true;
}

Color _parseColor(String hex) {
  final clean = hex.replaceAll('#', '');
  if (clean.length == 6) {
    return Color(int.parse('FF$clean', radix: 16));
  }
  if (clean.length == 8) {
    return Color(int.parse(clean, radix: 16));
  }
  return const Color(0xFFFFFFFF);
}

Color _contrastColor(Color color) {
  return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}
