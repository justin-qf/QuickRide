import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerUtils {
  static Future<BitmapDescriptor> getCustomMarker(
    IconData icon,
    Color bgColor,
    double size,
  ) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint paint = Paint()..color = bgColor;

    final double radius = size / 2;

    // Draw circle background
    canvas.drawCircle(Offset(radius, radius), radius, paint);

    // Draw icon
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size * 0.6,
        fontFamily: icon.fontFamily,
        color: Colors.white,
      ),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final ui.Image image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );

    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  static Future<BitmapDescriptor> getCustomMarkerFromIcon(
    IconData icon,
    Color color,
  ) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = color;

    // Draw Circle Background
    final double size = 120.0; // High resolution
    final double radius = size / 2;

    canvas.drawCircle(Offset(radius, radius), radius, paint);

    // Draw Icon
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size * 0.6,
        fontFamily: icon.fontFamily,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final ByteData? data = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  static Future<BitmapDescriptor> getBikeMarker({
    required Color color,
    double size = 120.0,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final double radius = size / 2;

    // Draw Shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8);
    canvas.drawCircle(Offset(radius, radius + 4), radius * 0.9, shadowPaint);

    // Draw Circle Background
    final Paint bgPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(radius, radius), radius * 0.85, bgPaint);

    // Draw Border
    final Paint borderPaint = Paint()
      ..color = color
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = size * 0.05;
    canvas.drawCircle(Offset(radius, radius), radius * 0.85, borderPaint);

    // Draw Icon (Bike)
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: String.fromCharCode(Icons.electric_bike_rounded.codePoint),
      style: TextStyle(
        fontSize: size * 0.5,
        fontFamily: Icons.electric_bike_rounded.fontFamily,
        package: Icons.electric_bike_rounded.fontPackage,
        color: color,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(
          size.toInt(),
          size.toInt(),
        );
    final ByteData? data = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  static Future<BitmapDescriptor> getMarkerFromAsset(
    String path, {
    int width = 100,
  }) async {
    return await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      path,
    );
  }
}
