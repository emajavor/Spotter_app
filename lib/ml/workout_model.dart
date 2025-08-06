import 'dart:ffi';            // for Pointer
import 'dart:typed_data';     // for Float32List
import 'package:tflite_flutter/tflite_flutter.dart';

class WorkoutModel {
  late final Interpreter _interp;
  static const _modelPath = 'assets/models/workout_model.tflite';

  /// Call once at startup (e.g. in initState)
  Future<void> init() async {
    _interp = await Interpreter.fromAsset(
        _modelPath,
        options: InterpreterOptions()
          ..threads = 2
      // ..useNnApiForAndroid = true  // if you want NNAPI delegate
      // ..addDelegate(GpuDelegate()) // if you want GPU delegate
    );
  }

  /// Predict 0=undertrained,1=balanced,2=overtrained
  int predict({
    required String muscle,
    required int soFar,
    required int toAdd,
  }) {
    // 1) Map muscle → index (must match your Python sort order)
    const muscleGroups = [
      'Biceps','Back','Calves','Chest','Glutes',
      'Hamstrings','Quads','Shoulder','Triceps','Abs',
    ];
    final idx = muscleGroups.indexOf(muscle);
    if (idx < 0) throw Exception('Unknown muscle: $muscle');

    // 2) Build input tensor [1,3] float32
    final input = Float32List.fromList([
      idx.toDouble(),
      soFar.toDouble(),
      toAdd.toDouble(),
    ]).reshape([1, 3]);

    // 3) Prepare output buffer [1,3]
    final output = List.filled(3, 0.0).reshape([1, 3]);

    // 4) Run inference
    _interp.run(input, output);

    // 5) Argmax
    final scores = output[0];
    var best = 0;
    for (var i = 1; i < scores.length; i++) {
      if (scores[i] > scores[best]) best = i;
    }
    return best;
  }

  void close() => _interp.close();
}
