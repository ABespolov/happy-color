import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:happy_color/features/coloring/presentation/widgets/preview_worker.dart';

void main() {
  test(
    'paints colored regions from the artwork and leaves the rest white',
    () async {
      // A 2x2 region map: regions 0, 1, 2, 3 (stored as index + 1).
      final regions = Uint8List(2 * 2 * 4);
      for (var i = 0; i < 4; i++) {
        regions[i * 4] = i + 1;
        regions[i * 4 + 3] = 255;
      }
      final artwork = Uint8List.fromList([
        for (var i = 0; i < 4; i++) ...[10, 20, 30, 255],
      ]);
      const assetDir = 'assets/pictures/test';
      final request = PaintRequest(
        assetDir: assetDir,
        regions: regions,
        regionsWidth: 2,
        regionsHeight: 2,
        artwork: artwork,
        filled: {0, 3},
        size: 2,
      );

      final direct = paintPixels(request, regions);
      expect(direct.sublist(0, 4), [10, 20, 30, 255]);
      expect(direct.sublist(4, 8), [255, 255, 255, 255]);
      expect(direct.sublist(12, 16), [10, 20, 30, 255]);

      final worker = PreviewWorker();
      addTearDown(worker.dispose);
      final painted = await worker.paint(
        assetDir: assetDir,
        regions: regions,
        regionsWidth: 2,
        regionsHeight: 2,
        artwork: artwork,
        filled: {0, 3},
        size: 2,
      );
      expect(painted, direct);

      // The second request for the same picture leaves the region map out, and
      // the isolate uses the one it kept.
      final again = await worker.paint(
        assetDir: assetDir,
        regions: Uint8List(0),
        regionsWidth: 2,
        regionsHeight: 2,
        artwork: artwork,
        filled: {0, 3},
        size: 2,
      );
      expect(again, direct);
    },
  );
}
