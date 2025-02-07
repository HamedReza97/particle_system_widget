import 'dart:math';
import 'package:flutter/material.dart';
import 'particle.dart';

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double connectionDistance; // Maximum distance within which particles connect

  ParticlePainter(this.particles, {this.connectionDistance = 200.0});

  @override
  void paint(Canvas canvas, Size size) {
    // Clear the canvas with a black background.
    canvas.drawColor(Colors.black, BlendMode.srcOver);

    // Reuse a single Paint for drawing particles.
    final particlePaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    // Draw each particle as a circle.
    for (final particle in particles) {
      canvas.drawCircle(particle.position, particle.size, particlePaint);
    }

    // Cache the squared connection distance for efficiency.
    final double connectionDistanceSq = connectionDistance * connectionDistance;
    final int count = particles.length;

    // Create a base Paint for drawing lines.
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.2;

    // For every unique pair of particles, draw a connecting line if they're close enough.
    for (int i = 0; i < count; i++) {
      final p1 = particles[i].position;
      for (int j = i + 1; j < count; j++) {
        final p2 = particles[j].position;
        final double dx = p1.dx - p2.dx;
        final double dy = p1.dy - p2.dy;
        final double distanceSq = dx * dx + dy * dy;

        if (distanceSq < connectionDistanceSq) {
          // Compute the actual distance (this is the only sqrt call needed).
          final double distance = sqrt(distanceSq);

          // Compute a factor (1.0 when particles are on top of each other, and 0 when at the max distance).
          final double factor = 1.0 - (distance / connectionDistance);

          // Map this factor to an opacity value (0 to 255).
          final int alpha = (factor * 200).toInt();

          // Set the line color with the computed opacity.
          linePaint.color = Colors.white.withAlpha(alpha);

          // Draw the connecting line.
          canvas.drawLine(p1, p2, linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return true; // Always repaint for animation
  }
}
