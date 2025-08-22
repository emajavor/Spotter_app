import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';

class WorkoutModel {
  late final Interpreter _interp;
  static const _modelPath = 'assets/models/workout_model.tflite';

  Future<void> init() async {
    _interp = await Interpreter.fromAsset(
        _modelPath,
        options: InterpreterOptions()
          ..threads = 2
    );
  }

  /// Predict 0=undertrained,1=balanced,2=overtrained
  int predict({
    required String muscle,
    required int soFar,
    required int toAdd,
  }) {
    // Map muscle -> index (must match my Python sort order)
    const muscleGroups = [
      'Biceps','Back','Calves','Chest','Glutes',
      'Hamstrings','Quads','Shoulders','Triceps','Abs','Obliques','Rear Delts',
      'Traps',
    ];
    final idx = muscleGroups.indexOf(muscle);
    if (idx < 0) throw Exception('Unknown muscle: $muscle');

    final input = Float32List.fromList([
      idx.toDouble(),
      soFar.toDouble(),
      toAdd.toDouble(),
    ]).reshape([1, 3]);

    final output = List.filled(3, 0.0).reshape([1, 3]);

    _interp.run(input, output);

    final scores = output[0];
    var best = 0;
    for (var i = 1; i < scores.length; i++) {
      if (scores[i] > scores[best]) best = i;
    }
    return best;
  }

  void close() => _interp.close();
}
