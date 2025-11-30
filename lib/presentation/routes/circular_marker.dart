import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> createCircularMarker({
  required Color backgroundColor,
  required IconData icon,
  required Color iconColor,
  double size = 100,
}) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  final Paint paint = Paint()..color = backgroundColor;
  final double radius = size / 2;

  // Dibuja el círculo
  canvas.drawCircle(Offset(radius, radius), radius, paint);

  // Dibuja el icono
  TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);

  textPainter.text = TextSpan(
    text: String.fromCharCode(icon.codePoint),
    style: TextStyle(
      fontSize: radius * 1.1,
      fontFamily: icon.fontFamily,
      color: iconColor,
    ),
  );

  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
  );

  final ui.Image img = await recorder.endRecording().toImage(
    size.toInt(),
    size.toInt(),
  );
  final ByteData? data = await img.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
}
