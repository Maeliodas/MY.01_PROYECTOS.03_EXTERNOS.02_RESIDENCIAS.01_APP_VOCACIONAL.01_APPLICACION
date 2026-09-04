import 'package:flutter/material.dart';

class ProgressMap extends StatelessWidget {
  final VoidCallback onStartTest;
  const ProgressMap({super.key, required this.onStartTest});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      child: SizedBox(
        height: 900,
        width: constraints.maxWidth,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _PathPainter())),
            const _Decor(left: 18, top: 55, icon: Icons.cloud_outlined),
            const _Decor(right: 24, top: 210, icon: Icons.park_outlined),
            _Node(top: 80, leftFactor: .50, label: 'Comienza', unlocked: true, onTap: onStartTest),
            const _Node(top: 255, leftFactor: .25, label: 'Explora', unlocked: false),
            const _Node(top: 435, leftFactor: .70, label: 'Descubre', unlocked: false),
            const _Node(top: 620, leftFactor: .38, label: 'Resultado', unlocked: false),
          ],
        ),
      ),
    ),
  );
}

class _Node extends StatelessWidget {
  final double top;
  final double leftFactor;
  final String label;
  final bool unlocked;
  final VoidCallback? onTap;
  const _Node({required this.top, required this.leftFactor, required this.label, required this.unlocked, this.onTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Positioned(
      top: top,
      left: width * leftFactor - 58,
      child: Column(children: [
        InkWell(
          onTap: unlocked ? onTap : null,
          borderRadius: BorderRadius.circular(58),
          child: Ink(
            width: 116,
            height: 116,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: unlocked ? const LinearGradient(colors: [Color(0xFF8B6CFF), Color(0xFF5D4BD8)]) : null,
              color: unlocked ? null : Colors.white,
              boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 14, offset: Offset(0, 8))],
              border: Border.all(color: Colors.white, width: 6),
            ),
            child: Icon(unlocked ? Icons.play_arrow_rounded : Icons.lock_outline_rounded, size: 48, color: unlocked ? Colors.white : Colors.black38),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _Decor extends StatelessWidget {
  final double? left, right;
  final double top;
  final IconData icon;
  const _Decor({this.left, this.right, required this.top, required this.icon});
  @override
  Widget build(BuildContext context) => Positioned(left: left, right: right, top: top, child: Icon(icon, size: 64, color: const Color(0x228B6CFF)));
}

class _PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDDD7FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * .50, 138)
      ..quadraticBezierTo(size.width * .68, 190, size.width * .25, 313)
      ..quadraticBezierTo(size.width * .05, 395, size.width * .70, 493)
      ..quadraticBezierTo(size.width * .88, 570, size.width * .38, 678);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
