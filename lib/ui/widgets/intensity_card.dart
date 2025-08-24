
import 'package:flutter/material.dart';

import '../../models/enums/intensity.dart';

class IntensityCard extends StatelessWidget {
  final Intensity? intensity;

  const IntensityCard({super.key, this.intensity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Intensity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (intensity != null)
            Row(
              children: _buildIntensityBars(intensity!),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildIntensityBars(Intensity intensity) {
    const Color active = Color(0xFF00FFBB);
    final Color inactive = Colors.grey[800]!;

    int level = 0;
    switch (intensity) {
      case Intensity.Easy:
        level = 1;
        break;
      case Intensity.Intermediate:
        level = 2;
        break;
      case Intensity.Hard:
        level = 3;
        break;
      default:
        level = 0;
    }

    return List.generate(3, (index) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 12,
          decoration: BoxDecoration(
            color: index < level ? active : inactive,
            borderRadius: BorderRadius.circular(6),
            boxShadow: index < level
                ? [
              BoxShadow(
                color: active.withOpacity(0.6),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ]
                : [],
          ),
        ),
      );
    });
  }
}