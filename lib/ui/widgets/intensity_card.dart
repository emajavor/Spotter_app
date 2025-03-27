
import 'package:flutter/material.dart';

import '../../models/enums/intensity.dart';

class IntensityCard extends StatelessWidget {
  final String text;
  final Intensity? intensity;

  const IntensityCard({super.key, this.text = '', this.intensity});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.93,
        height: MediaQuery.of(context).size.height * 0.15,
        child: Padding(
          padding: EdgeInsets.only(left: MediaQuery.sizeOf(context).width * 0.05) ,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: const TextStyle(fontSize: 18)),
              if (intensity != null) ...[
                Text('Intensity: ${intensity!.description}', style: const TextStyle(fontSize: 18)),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Row(
                  children: _buildIntensityBars(intensity!),

                ),
              ],
            ],
          ),
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
      margin: const EdgeInsets.symmetric(horizontal: 3.0),
      width: 30,
      height: 10,
      color: color,
    ))
        .toList();
  }
}