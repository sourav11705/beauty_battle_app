import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GlitterBackground extends StatelessWidget {
  const GlitterBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Moving Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F0F0F),
                Color(0xFF1A0B2E), // Deep purple
                Color(0xFF0F0F0F),
                Color(0xFF2E1A0B), // Deep gold/brown
                Color(0xFF0F0F0F),
              ],
            ),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .shimmer(duration: 5.seconds, color: Colors.white10),

        // Random Glitter Stars
        ...List.generate(30, (index) => _RandomStar(index: index)),
      ],
    );
  }
}

class _RandomStar extends StatelessWidget {
  final int index;
  const _RandomStar({required this.index});

  @override
  Widget build(BuildContext context) {
    final random = Random(index); // Seeded random for consistent positions on rebuild if key stays
    // Actually we want random positions on every build? No, that would be chaotic.
    // We want static positions but random animations.
    
    // Using simple layout positioning
    final top = random.nextDouble() * MediaQuery.of(context).size.height;
    final left = random.nextDouble() * MediaQuery.of(context).size.width;
    final size = random.nextDouble() * 10 + 2; // size 2 to 12
    final delay = random.nextInt(2000);
    final duration = random.nextInt(2000) + 1000;

    return Positioned(
      top: top,
      left: left,
      child: Icon(
        Icons.star,
        color: Colors.white.withValues(alpha: 0.3),
        size: size,
      )
      .animate(onPlay: (c) => c.repeat(reverse: true), delay: Duration(milliseconds: delay))
      .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.5, 1.5), duration: Duration(milliseconds: duration))
      .fade(begin: 0.2, end: 0.8)
      .rotate(begin: 0, end: 0.5),
    );
  }
}
