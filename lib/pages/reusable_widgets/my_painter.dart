import 'package:flutter/material.dart';
import 'package:movie_list/data/constants.dart';

class MyPainter extends CustomPainter {
  final StarState status;

  MyPainter(this.status);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = status == StarState.full ? Colors.amber : lightGrey;

    final path = Path();
    path.moveTo(size.width / 2, 0.0);
    path.lineTo(size.width / 6, size.height);
    path.lineTo(size.width, size.height * 1 / 3);
    path.lineTo(0.0, size.height * 1 / 3);
    path.lineTo(size.width * 5 / 6, size.height);
    path.lineTo(size.width / 2, 0.0);

    canvas.drawPath(path, paint);


    if (status == StarState.half) {

      final paintHalf = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.amber;

      final pathHalf = Path();
      pathHalf.moveTo(size.width / 2, 0.0);
      pathHalf.lineTo(size.width / 6, size.height);
      pathHalf.lineTo(size.width / 2, size.height * 13 / 18);
      pathHalf.lineTo(size.width / 2, 0.0);
      pathHalf.moveTo(0.0, size.height * 1 / 3);
      pathHalf.lineTo(size.width / 2, size.height * 13 / 18);
      pathHalf.lineTo(size.width / 2, size.height * 1 / 3);
      pathHalf.lineTo(0.0, size.height * 1 / 3);

      canvas.drawPath(pathHalf, paintHalf);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
