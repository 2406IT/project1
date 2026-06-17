import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const TouchVisualizerApp());
}

class TouchVisualizerApp extends StatelessWidget {
  const TouchVisualizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Touch Visualizer',
      theme: ThemeData.dark(),
      home: const TouchVisualizerPage(),
    );
  }
}

class TouchVisualizerPage extends StatefulWidget {
  const TouchVisualizerPage({super.key});

  @override
  State<TouchVisualizerPage> createState() => _TouchVisualizerPageState();
}

class _TouchVisualizerPageState extends State<TouchVisualizerPage>
    with SingleTickerProviderStateMixin {
  final List<Particle> particles = [];
  final Random random = Random();
  late AnimationController controller;

  final List<Color> neonColors = [
    Colors.cyan,
    Colors.pinkAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.yellowAccent,
  ];

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(days: 1))
          ..addListener(() {
            if (mounted) {
              setState(() {
                for (final particle in particles) {
                  particle.update();
                }
                particles.removeWhere((particle) => particle.life <= 0);
                if (particles.length > 300) {
                  particles.removeRange(0, particles.length - 300);
                }
              });
            }
          })
          ..repeat();
  }

  void createExplosion(Offset position, {required bool isHolding}) {
    final color = neonColors[random.nextInt(neonColors.length)];
    int count = isHolding ? 2 : 25;

    for (int i = 0; i < count; i++) {
      particles.add(
        Particle(
          x: position.dx,
          y: position.dy,
          vx: (random.nextDouble() - 0.5) * 12,
          vy: (random.nextDouble() - 0.5) * 12,
          size: random.nextDouble() * 6 + 4,
          color: color,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Touch Visualizer',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: Colors.black.withOpacity(0.4),
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          createExplosion(details.localPosition, isHolding: false);
        },
        onPanUpdate: (details) {
          createExplosion(details.localPosition, isHolding: true);
        },
        child: CustomPaint(
          painter: ParticlePainter(particles),
          child: Container(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double life;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
  }) : life = 100;

  void update() {
    x += vx;
    y += vy;
    vx *= 0.96;
    vy *= 0.96;
    life -= 2.5;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);

    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(
          (particle.life / 100).clamp(0.0, 1.0),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
