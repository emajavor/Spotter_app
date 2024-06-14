import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/enums/intensity.dart';

class IntensityCard extends StatelessWidget {
  final String text;
  final Intensity? intensity;

  const IntensityCard({this.text = '', this.intensity});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 120,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: TextStyle(fontSize: 18)),
            if (intensity != null) ...[
              Text('Intensity: ${intensity!.description}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              Row(
                children: _buildIntensityBars(intensity!),

              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildIntensityBars(Intensity intensity) {
    Color filledColor = Colors.teal;
    Color unfilledColor = Colors.grey[300]!;

    List<Color> colors;
    switch (intensity) {
      case Intensity.Easy:
        colors = [filledColor, unfilledColor, unfilledColor];
        break;
      case Intensity.Intermediate:
        colors = [filledColor, filledColor, unfilledColor];
        break;
      case Intensity.Hard:
        colors = [filledColor, filledColor, filledColor];
        break;
      default:
        colors = [unfilledColor, unfilledColor, unfilledColor];
    }

    return colors
        .map((color) => Container(
      margin: EdgeInsets.symmetric(horizontal: 3.0),
      width: 30,
      height: 10,
      color: color,
    ))
        .toList();
  }
}