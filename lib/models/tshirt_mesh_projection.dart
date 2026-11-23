import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import 'tshirt_layer.dart';

class TshirtViewProjection {
  final Rect bounds;
  final ui.Vertices vertices;

  const TshirtViewProjection({required this.bounds, required this.vertices});
}

class TshirtMeshProjection {
  static const _identityMatrix = <double>[
    1,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    1,
  ];

  final Float32List _positions;
  final Float32List _normals;
  final Float32List _textureCoordinates;
  final Uint32List _indices;
  final ui.Image texture;
  final ui.ImageShader textureShader;
  final Map<String, TshirtViewProjection> _projections = {};

  TshirtMeshProjection._({
    required Float32List positions,
    required Float32List normals,
    required Float32List textureCoordinates,
    required Uint32List indices,
    required this.texture,
  }) : _positions = positions,
       _normals = normals,
       _textureCoordinates = textureCoordinates,
       _indices = indices,
       textureShader = ui.ImageShader(
         texture,
         ui.TileMode.clamp,
         ui.TileMode.clamp,
         Float64List.fromList(_identityMatrix),
         filterQuality: ui.FilterQuality.high,
       );

  static Future<TshirtMeshProjection> load({
    AssetBundle? assetBundle,
    String assetPath = 'assets/tshirt-mockup.glb',
  }) async {
    final assetData = await (assetBundle ?? rootBundle).load(assetPath);
    final bytes = assetData.buffer.asUint8List(
      assetData.offsetInBytes,
      assetData.lengthInBytes,
    );
    final data = ByteData.sublistView(bytes);
    if (data.lengthInBytes < 20 ||
        data.getUint32(0, Endian.little) != 0x46546C67) {
      throw const FormatException('The T-shirt asset is not a valid GLB file.');
    }

    final version = data.getUint32(4, Endian.little);
    if (version != 2) {
      throw FormatException('Unsupported GLB version: $version.');
    }

    Map<String, dynamic>? document;
    Uint8List? binary;
    var offset = 12;
    while (offset + 8 <= data.lengthInBytes) {
      final chunkLength = data.getUint32(offset, Endian.little);
      final chunkType = data.getUint32(offset + 4, Endian.little);
      offset += 8;
      if (chunkLength > data.lengthInBytes - offset) {
        throw const FormatException(
          'The T-shirt GLB contains a truncated chunk.',
        );
      }

      if (chunkType == 0x4E4F534A) {
        final jsonBytes = bytes.sublist(offset, offset + chunkLength);
        document =
            jsonDecode(utf8.decode(jsonBytes).trim()) as Map<String, dynamic>;
      } else if (chunkType == 0x004E4942) {
        binary = Uint8List.sublistView(bytes, offset, offset + chunkLength);
      }
      offset += chunkLength;
    }

    if (document == null || binary == null) {
      throw const FormatException('The T-shirt GLB is missing required data.');
    }

    final primitive =
        (document['meshes'] as List)
                .cast<Map<String, dynamic>>()
                .first['primitives']
            as List<dynamic>;
    final meshPrimitive = (primitive.first as Map).cast<String, dynamic>();
    final attributes = (meshPrimitive['attributes'] as Map)
        .cast<String, dynamic>();
    final positions = _readFloatAccessor(
      document,
      binary,
      attributes['POSITION'] as int,
      3,
    );
    final normals = _readFloatAccessor(
      document,
      binary,
      attributes['NORMAL'] as int,
      3,
    );
    final textureCoordinates = _readFloatAccessor(
      document,
      binary,
      attributes['TEXCOORD_0'] as int,
      2,
    );
    final indices = _readIndexAccessor(
      document,
      binary,
      meshPrimitive['indices'] as int,
    );
    final imageBytes = _readBaseColorImage(document, binary, meshPrimitive);
    final codec = await ui.instantiateImageCodec(
      imageBytes,
      targetWidth: 2048,
      targetHeight: 2048,
    );
    final texture = (await codec.getNextFrame()).image;
    codec.dispose();

    return TshirtMeshProjection._(
      positions: positions,
      normals: normals,
      textureCoordinates: textureCoordinates,
      indices: indices,
      texture: texture,
    );
  }

  static Float32List _readFloatAccessor(
    Map<String, dynamic> document,
    Uint8List binary,
    int accessorIndex,
    int componentCount,
  ) {
    final accessors = (document['accessors'] as List)
        .cast<Map<String, dynamic>>();
    final bufferViews = (document['bufferViews'] as List)
        .cast<Map<String, dynamic>>();
    final accessor = accessors[accessorIndex];
    if (accessor['componentType'] != 5126) {
      throw const FormatException(
        'The T-shirt mesh contains non-float attributes.',
      );
    }
    if (accessor['type'] != (componentCount == 3 ? 'VEC3' : 'VEC2')) {
      throw const FormatException(
        'The T-shirt mesh contains an unexpected attribute.',
      );
    }

    final view = bufferViews[accessor['bufferView'] as int];
    final count = accessor['count'] as int;
    final elementSize = componentCount * 4;
    final stride = view['byteStride'] as int? ?? elementSize;
    final start =
        (view['byteOffset'] as int? ?? 0) +
        (accessor['byteOffset'] as int? ?? 0);
    final source = ByteData.sublistView(binary);
    final values = Float32List(count * componentCount);
    for (var index = 0; index < count; index++) {
      final elementOffset = start + index * stride;
      for (var component = 0; component < componentCount; component++) {
        values[index * componentCount + component] = source.getFloat32(
          elementOffset + component * 4,
          Endian.little,
        );
      }
    }
    return values;
  }

  static Uint32List _readIndexAccessor(
    Map<String, dynamic> document,
    Uint8List binary,
    int accessorIndex,
  ) {
    final accessors = (document['accessors'] as List)
        .cast<Map<String, dynamic>>();
    final bufferViews = (document['bufferViews'] as List)
        .cast<Map<String, dynamic>>();
    final accessor = accessors[accessorIndex];
    if (accessor['type'] != 'SCALAR') {
      throw const FormatException('The T-shirt mesh indices are invalid.');
    }
    final view = bufferViews[accessor['bufferView'] as int];
    final count = accessor['count'] as int;
    final componentType = accessor['componentType'] as int;
    final componentSize = switch (componentType) {
      5121 => 1,
      5123 => 2,
      5125 => 4,
      _ => throw const FormatException(
        'The T-shirt mesh uses an unsupported index type.',
      ),
    };
    final stride = view['byteStride'] as int? ?? componentSize;
    final start =
        (view['byteOffset'] as int? ?? 0) +
        (accessor['byteOffset'] as int? ?? 0);
    final source = ByteData.sublistView(binary);
    final indices = Uint32List(count);
    for (var index = 0; index < count; index++) {
      final elementOffset = start + index * stride;
      indices[index] = switch (componentType) {
        5121 => source.getUint8(elementOffset),
        5123 => source.getUint16(elementOffset, Endian.little),
        5125 => source.getUint32(elementOffset, Endian.little),
        _ => throw const FormatException(
          'The T-shirt mesh uses an unsupported index type.',
        ),
      };
    }
    return indices;
  }

  static Uint8List _readBaseColorImage(
    Map<String, dynamic> document,
    Uint8List binary,
    Map<String, dynamic> primitive,
  ) {
    final materials = (document['materials'] as List)
        .cast<Map<String, dynamic>>();
    final textures = (document['textures'] as List)
        .cast<Map<String, dynamic>>();
    final images = (document['images'] as List).cast<Map<String, dynamic>>();
    final material = materials[primitive['material'] as int];
    final pbr = material['pbrMetallicRoughness'] as Map<String, dynamic>;
    final baseColorTexture = pbr['baseColorTexture'] as Map<String, dynamic>;
    final texture = textures[baseColorTexture['index'] as int];
    final image = images[texture['source'] as int];
    final bufferViews = (document['bufferViews'] as List)
        .cast<Map<String, dynamic>>();
    final view = bufferViews[image['bufferView'] as int];
    final start = view['byteOffset'] as int? ?? 0;
    final length = view['byteLength'] as int;
    return Uint8List.sublistView(binary, start, start + length);
  }

  TshirtViewProjection projectionFor(String view) {
    final normalizedView = _normalizedView(view);
    return _projections.putIfAbsent(
      normalizedView,
      () => _createProjection(normalizedView),
    );
  }

  static Offset projectPoint(Vector3D point, String view) {
    return switch (_normalizedView(view)) {
      'back' => Offset(-point.x, -point.y),
      'left-sleeve' => Offset(-point.z, -point.y),
      'right-sleeve' => Offset(point.z, -point.y),
      _ => Offset(point.x, -point.y),
    };
  }

  TshirtViewProjection _createProjection(String view) {
    final triangles = <_DepthSortedTriangle>[];
    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    var minY = double.infinity;
    var maxY = double.negativeInfinity;

    for (var vertex = 0; vertex < _positions.length ~/ 3; vertex++) {
      final projected = _projectVertex(vertex, view);
      minX = math.min(minX, projected.dx);
      maxX = math.max(maxX, projected.dx);
      minY = math.min(minY, projected.dy);
      maxY = math.max(maxY, projected.dy);
    }

    for (var indexOffset = 0; indexOffset < _indices.length; indexOffset += 3) {
      final a = _indices[indexOffset];
      final b = _indices[indexOffset + 1];
      final c = _indices[indexOffset + 2];
      final facing = _facingNormal(a, b, c, view);
      if (facing <= 0.02) continue;

      final depth =
          (_cameraDepth(a, view) +
              _cameraDepth(b, view) +
              _cameraDepth(c, view)) /
          3;
      triangles.add(_DepthSortedTriangle(a: a, b: b, c: c, depth: depth));
    }
    triangles.sort((a, b) => a.depth.compareTo(b.depth));

    final coordinateCount = triangles.length * 3 * 2;
    final screenPositions = Float32List(coordinateCount);
    final textureCoordinates = Float32List(coordinateCount);
    var coordinateIndex = 0;
    for (final triangle in triangles) {
      for (final vertex in [triangle.a, triangle.b, triangle.c]) {
        final projected = _projectVertex(vertex, view);
        screenPositions[coordinateIndex] = projected.dx;
        screenPositions[coordinateIndex + 1] = projected.dy;
        textureCoordinates[coordinateIndex] =
            _textureCoordinates[vertex * 2] * texture.width;
        textureCoordinates[coordinateIndex + 1] =
            _textureCoordinates[vertex * 2 + 1] * texture.height;
        coordinateIndex += 2;
      }
    }

    return TshirtViewProjection(
      bounds: Rect.fromLTRB(minX, minY, maxX, maxY),
      vertices: ui.Vertices.raw(
        ui.VertexMode.triangles,
        screenPositions,
        textureCoordinates: textureCoordinates,
      ),
    );
  }

  Offset _projectVertex(int vertex, String view) {
    final x = _positions[vertex * 3];
    final y = _positions[vertex * 3 + 1];
    final z = _positions[vertex * 3 + 2];
    return switch (view) {
      'back' => Offset(-x, -y),
      'left-sleeve' => Offset(-z, -y),
      'right-sleeve' => Offset(z, -y),
      _ => Offset(x, -y),
    };
  }

  double _cameraDepth(int vertex, String view) {
    final x = _positions[vertex * 3];
    final z = _positions[vertex * 3 + 2];
    return switch (view) {
      'back' => -z,
      'left-sleeve' => x,
      'right-sleeve' => -x,
      _ => z,
    };
  }

  double _facingNormal(int a, int b, int c, String view) {
    final normalX = (_normals[a * 3] + _normals[b * 3] + _normals[c * 3]) / 3;
    final normalZ =
        (_normals[a * 3 + 2] + _normals[b * 3 + 2] + _normals[c * 3 + 2]) / 3;
    return switch (view) {
      'back' => -normalZ,
      'left-sleeve' => normalX,
      'right-sleeve' => -normalX,
      _ => normalZ,
    };
  }

  static String _normalizedView(String view) {
    return switch (view) {
      'back' => 'back',
      'left-sleeve' => 'left-sleeve',
      'right-sleeve' => 'right-sleeve',
      _ => 'front',
    };
  }

  void dispose() {
    textureShader.dispose();
    texture.dispose();
    for (final projection in _projections.values) {
      projection.vertices.dispose();
    }
    _projections.clear();
  }
}

class _DepthSortedTriangle {
  final int a;
  final int b;
  final int c;
  final double depth;

  const _DepthSortedTriangle({
    required this.a,
    required this.b,
    required this.c,
    required this.depth,
  });
}
