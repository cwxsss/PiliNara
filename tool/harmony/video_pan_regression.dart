import '../../lib/plugin/pl_player/models/video_pan_axis.dart';

void check(double dx, double dy, VideoPanAxis? expected) {
  final actual = classifyVideoPan(dx, dy);
  if (actual != expected) throw StateError('($dx, $dy): $actual != $expected');
}

void main() {
  check(1, 4, null);
  check(4, 1, null);
  check(12, 12, null);
  check(24, 10, VideoPanAxis.horizontal);
  check(-24, -10, VideoPanAxis.horizontal);
  check(9, 24, VideoPanAxis.vertical);
  check(-9, -24, VideoPanAxis.vertical);
  check(20, 20, null);
  check(0, 18, VideoPanAxis.vertical);
  check(18, 0, VideoPanAxis.horizontal);
  print('PASS: jitter, horizontal drift, vertical motion, both directions, diagonal');
}
