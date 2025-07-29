import 'dart:io';
import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

class RecommendationHelper {
  late Interpreter _replacementInterpreter;
  late Interpreter _adviceInterpreter;
  late List<String> _exerciseLabels;
  late List<String> _muscleLabels;
  late List<String> _equipmentLabels;
  late List<String> _replacementLabels;
  late List<String> _adviceLabels;

  RecommendationHelper();

  Future<void> init() async {
    try {
      // Učitaj modele
      _replacementInterpreter = await Interpreter.fromAsset('replacement_model.tflite');
      _adviceInterpreter = await Interpreter.fromAsset('advice_model.tflite');

      // Učitaj labele
      _exerciseLabels = (await rootBundle.loadString('assets/labels/exercise_labels.txt')).split('\n');
      _muscleLabels = (await rootBundle.loadString('assets/labels/muscle_labels.txt')).split('\n');
      _equipmentLabels = (await rootBundle.loadString('assets/labels/equipment_labels.txt')).split('\n');
      _replacementLabels = (await rootBundle.loadString('assets/labels/replacement_labels.txt')).split('\n');
      _adviceLabels = (await rootBundle.loadString('assets/labels/advice_labels.txt')).split('\n');
    } catch (e) {
      print('Error loading models or labels: $e');
    }
  }

  Future<Map<String, String>> getRecommendation({
    required String exercise,
    required String muscleGroup,
    required String equipment,
  }) async {
    try {
      // Kodiraj ulaze
      final exerciseIdx = _exerciseLabels.indexOf(exercise);
      final muscleIdx = _muscleLabels.indexOf(muscleGroup);
      final equipmentIdx = _equipmentLabels.indexOf(equipment);

      if (exerciseIdx == -1 || muscleIdx == -1 || equipmentIdx == -1) {
        return {'error': 'Invalid input. Ensure exercise, muscle group, and equipment are valid.'};
      }

      // Pripremi ulaz za modele
      final input = Float32List.fromList([exerciseIdx.toDouble(), muscleIdx.toDouble(), equipmentIdx.toDouble()]);
      final replacementOutput = List.filled(1, List.filled(_replacementLabels.length, 0.0));
      final adviceOutput = List.filled(1, List.filled(_adviceLabels.length, 0.0));

      // Pokreni predikcije
      _replacementInterpreter.run(input, replacementOutput);
      _adviceInterpreter.run(input, adviceOutput);

      // Dekodiraj rezultate
      final replacementIdx = replacementOutput[0].indexOf(replacementOutput[0].reduce((a, b) => a > b ? a : b));
      final adviceIdx = adviceOutput[0].indexOf(adviceOutput[0].reduce((a, b) => a > b ? a : b));

      return {
        'replacement': _replacementLabels[replacementIdx],
        'advice': _adviceLabels[adviceIdx],
      };
    } catch (e) {
      print('Error getting recommendation: $e');
      return {'error': 'Failed to get recommendation: $e'};
    }
  }

  void close() {
    _replacementInterpreter.close();
    _adviceInterpreter.close();
  }
}