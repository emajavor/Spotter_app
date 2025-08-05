import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite/tflite.dart';
import 'dart:typed_data';

class RecommendationHelper {
  List<String> _exerciseLabels = [];
  List<String> _muscleLabels = [];
  List<String> _equipmentLabels = [];
  List<String> _replacementLabels = [];
  List<String> _adviceLabels = [];
  bool _isInitialized = false;

  RecommendationHelper();

  Future<void> init() async {
    try {
      // Učitaj modele
      await Tflite.loadModel(
        model: 'assets/replacement_model.tflite',
        labels: 'assets/labels/replacement_labels.txt',
        isAsset: true,
      ).then((_) {
        print('Replacement model loaded successfully');
      }).catchError((e) {
        print('Error loading replacement model: $e');
        throw Exception('Failed to load replacement model: $e');
      });

      await Tflite.loadModel(
        model: 'assets/advice_model.tflite',
        labels: 'assets/labels/advice_labels.txt',
        isAsset: true,
      ).then((_) {
        print('Advice model loaded successfully');
      }).catchError((e) {
        print('Error loading advice model: $e');
        throw Exception('Failed to load advice model: $e');
      });

      // Učitaj labele
      _exerciseLabels = (await rootBundle.loadString('assets/labels/exercise_labels.txt')).split('\n');
      _muscleLabels = (await rootBundle.loadString('assets/labels/muscle_labels.txt')).split('\n');
      _equipmentLabels = (await rootBundle.loadString('assets/labels/equipment_labels.txt')).split('\n');
      _replacementLabels = (await rootBundle.loadString('assets/labels/replacement_labels.txt')).split('\n');
      _adviceLabels = (await rootBundle.loadString('assets/labels/advice_labels.txt')).split('\n');

      print('Labels loaded: exercises=$_exerciseLabels, muscles=$_muscleLabels, equipment=$_equipmentLabels');
      _isInitialized = true;
    } catch (e) {
      print('Error initializing RecommendationHelper: $e');
      _isInitialized = false;
    }
  }

  Future<Map<String, String>> getRecommendation({
    required String exercise,
    required String muscleGroup,
    required String equipment,
  }) async {
    if (!_isInitialized) {
      return {'error': 'RecommendationHelper not initialized. Failed to load models or labels.'};
    }

    try {
      // Kodiraj ulaze
      final exerciseIdx = _exerciseLabels.indexOf(exercise);
      final muscleIdx = _muscleLabels.indexOf(muscleGroup);
      final equipmentIdx = _equipmentLabels.indexOf(equipment);

      if (exerciseIdx == -1 || muscleIdx == -1 || equipmentIdx == -1) {
        return {
          'error': 'Invalid input. Ensure exercise, muscle group, and equipment are valid. '
              'Received: exercise=$exercise, muscleGroup=$muscleGroup, equipment=$equipment'
        };
      }

      // Pripremi ulaz za modele
      final input = Float32List.fromList([exerciseIdx.toDouble(), muscleIdx.toDouble(), equipmentIdx.toDouble()]).buffer.asUint8List();

      // Pokreni predikcije za replacement model
      await Tflite.loadModel(
        model: 'assets/replacement_model.tflite',
        labels: 'assets/labels/replacement_labels.txt',
        isAsset: true,
      );
      final replacementOutput = await Tflite.runModelOnFrame(
        bytesList: [input],
      );

      // Pokreni predikcije za advice model
      await Tflite.loadModel(
        model: 'assets/advice_model.tflite',
        labels: 'assets/labels/advice_labels.txt',
        isAsset: true,
      );
      final adviceOutput = await Tflite.runModelOnFrame(
        bytesList: [input],
      );

      // Dekodiraj rezultate
      final replacementIdx = (replacementOutput![0] as List).indexOf((replacementOutput[0] as List).reduce((a, b) => a > b ? a : b));
      final adviceIdx = (adviceOutput![0] as List).indexOf((adviceOutput[0] as List).reduce((a, b) => a > b ? a : b));

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
    Tflite.close();
    _isInitialized = false;
  }
}