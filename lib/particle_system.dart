import 'dart:math';
import 'package:flutter/material.dart';
import 'particle.dart';
import 'particle_painter.dart';

class ParticleSystemWidget extends StatefulWidget {
  const ParticleSystemWidget({super.key});

  @override
  ParticleSystemWidgetState createState() => ParticleSystemWidgetState();
}

class ParticleSystemWidgetState extends State<ParticleSystemWidget>
    with SingleTickerProviderStateMixin {
  late List<Particle> particles;
  late AnimationController _controller;

  final int particleCount = 70;
  Offset mousePosition = Offset.zero;
  final double interactionRadius = 200.0;
  final double moveSpeed = 5.0; // (currently not used in this update)

  // A single Random instance for reuse.
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 365),
    )..repeat();

    // Create particles once after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      generateParticles();
    });
  }

  void generateParticles() {
    final screenSize = MediaQuery.of(context).size;

    particles = List.generate(particleCount, (_) {
      return Particle(
        Offset(
          random.nextDouble() * screenSize.width,
          random.nextDouble() * screenSize.height,
        ),
        Offset(
          random.nextDouble() * 4 - 2,
          random.nextDouble() * 4 - 2,
        ),
        Colors.grey,
        random.nextDouble() * 4,
      );
    });
  }

 void updateParticles(Size screenSize) {
  // Pre-calculate squared interaction radius.
  final double sqInteractionRadius = interactionRadius * interactionRadius;

  for (var particle in particles) {
    // Update the particle's position based on its velocity.
    particle.position += particle.velocity;

    // Calculate delta from mouse to particle.
    final double dx = particle.position.dx - mousePosition.dx;
    final double dy = particle.position.dy - mousePosition.dy;
    final double sqDistanceToMouse = dx * dx + dy * dy;

    // Only process if the particle is within the interaction zone.
    if (sqDistanceToMouse < sqInteractionRadius && sqDistanceToMouse > 0) {
      // Compute the actual distance.
      final double distanceToMouse = sqrt(sqDistanceToMouse);
      // Get the current speed.
      final double speed = particle.velocity.distance;

      // Update velocity: Normalize the (dx, dy) vector and then multiply by speed.
      particle.velocity = Offset(
        dx / distanceToMouse * speed,
        dy / distanceToMouse * speed,
      );

      // Accelerate the particle slightly to help it exit the no-go area.
      particle.position += particle.velocity * 10;
    }

    // Keep particles within screen bounds.
    if (particle.position.dx < 0 ||
        particle.position.dx > screenSize.width ||
        particle.position.dy < 0 ||
        particle.position.dy > screenSize.height) {
      particle.position = Offset(
        random.nextDouble() * screenSize.width,
        random.nextDouble() * screenSize.height,
      );
    }
  }
}


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cache the screen size for the current frame.
    final screenSize = MediaQuery.of(context).size;

    return MouseRegion(
      onHover: (event) {
        // Update the mouse position when the pointer moves.
        mousePosition = event.localPosition;
      },
      // Using AnimatedBuilder so that only the CustomPaint is rebuilt on each animation tick.
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Update particle positions with the cached screen size.
          updateParticles(screenSize);
          return CustomPaint(
            size: Size.infinite,
            painter: ParticlePainter(particles, connectionDistance: 300.0),
          );
        },
      ),
    );
  }
}
