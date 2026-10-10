/// Locks a video gesture only after deliberate motion, allowing normal hand drift.
enum VideoPanAxis { horizontal, vertical }

VideoPanAxis? classifyVideoPan(double dx, double dy) {
  dx = dx.abs();
  dy = dy.abs();
  const touchSlop = 18.0;
  if (dx * dx + dy * dy < touchSlop * touchSlop) return null;
  if (dx >= dy * 1.2) return VideoPanAxis.horizontal;
  if (dy >= dx * 1.5) return VideoPanAxis.vertical;
  return null;
}
