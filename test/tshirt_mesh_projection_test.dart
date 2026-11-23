import 'package:flutter_test/flutter_test.dart';
import 'package:printdesign/models/tshirt_mesh_projection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('projects the GLB model into front, back, and side views', () async {
    final model = await TshirtMeshProjection.load();
    addTearDown(model.dispose);

    final front = model.projectionFor('front').bounds;
    final back = model.projectionFor('back').bounds;
    final left = model.projectionFor('left-sleeve').bounds;
    final right = model.projectionFor('right-sleeve').bounds;

    expect(front.width, closeTo(back.width, 0.001));
    expect(front.height, closeTo(back.height, 0.001));
    expect(left.width, closeTo(right.width, 0.001));
    expect(left.height, closeTo(right.height, 0.001));
    expect(front.width, greaterThan(left.width));
    expect(front.height, closeTo(left.height, 0.001));
  });
}
