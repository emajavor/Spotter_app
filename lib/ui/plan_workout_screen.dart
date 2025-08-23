import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:spotter_app/data/exercise_data.dart';
import 'package:spotter_app/models/post.dart';
import 'package:spotter_app/ml/workout_model.dart';

import '../bloc/planWorkout/plan_workout_bloc.dart';

class PlanWorkoutScreen extends StatefulWidget {
  const PlanWorkoutScreen({super.key});

  @override
  State<PlanWorkoutScreen> createState() => _PlanWorkoutScreenState();
}

class _PlanWorkoutScreenState extends State<PlanWorkoutScreen> {
  final _setsController = TextEditingController();
  Exercise? _selectedExercise;
  bool _mlReady = false;
  final _mlModel = WorkoutModel();

  Color _statusColor(String status) {
    if (status.contains('Balanced')) return Colors.green;
    if (status.contains('Overtrained')) return Colors.red;
    return Colors.orange;
  }

  IconData _statusIcon(String status) {
    if (status.contains('Balanced')) return Icons.check_circle_rounded;
    if (status.contains('Overtrained')) return Icons.warning_amber_rounded;
    return Icons.hourglass_bottom_rounded;
  }

  @override
  void initState() {
    super.initState();
    _mlModel.init().then((_) {
      setState(() {
        _mlReady = true;
      });
    });
  }

  @override
  void dispose() {
    _setsController.dispose();
    _mlModel.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Plan Your Week',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all_rounded),
            tooltip: "Clear all workouts",
            onPressed: () {
              context.read<PlanWorkoutBloc>().add(const ClearPlan());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Exercise',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownSearch<Exercise>(
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: 'Search for an exercise',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      items: allExercises,
                      itemAsString: (Exercise exercise) => exercise.name,
                      onChanged: (Exercise? exercise) {
                        setState(() {
                          _selectedExercise = exercise;
                        });
                      },
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: 'Select an exercise',
                          prefixIcon: Icon(Icons.fitness_center_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _setsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter number of sets',
                        prefixIcon: Icon(Icons.repeat_rounded),
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: Text('Add Exercise', style: GoogleFonts.poppins(fontSize: 14)),
                        onPressed: () async {
                          if (_selectedExercise == null || _setsController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select an exercise and enter sets')),
                            );
                            return;
                          }

                          if (!_mlReady) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Model loading, please wait…')),
                            );
                            return;
                          }

                          final setsToAdd = int.tryParse(_setsController.text.trim()) ?? 0;
                          final muscleGroups = _selectedExercise!.muscleGroups;
                          bool isOvertrained = false;

                          for (final muscleGroup in muscleGroups) {
                            final pred = _mlModel.predict(
                              muscle: muscleGroup,
                              soFar: context.read<PlanWorkoutBloc>().state.muscleSets[muscleGroup] ?? 0,
                              toAdd: setsToAdd,
                            );
                            if (pred == 2) isOvertrained = true;
                          }

                          if (isOvertrained) return;

                          FocusScope.of(context).unfocus();

                          context.read<PlanWorkoutBloc>().add(
                            AddPlannedExercise(
                              ExerciseEntry(
                                name: _selectedExercise!.name,
                                muscleGroups: _selectedExercise!.muscleGroups,
                                sets: setsToAdd,
                                isCompleted: false,
                              ),
                            ),
                          );

                          _setsController.clear();
                          setState(() {
                            _selectedExercise = null;
                          });
                        },
                      ),
                    ),

                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: SizedBox(
                width: 200,
                height: 40,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    context.read<PlanWorkoutBloc>().add(const AddNewWorkout());
                  },
                  label: Text('+ New Workout', style: GoogleFonts.poppins(fontSize: 14)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<PlanWorkoutBloc, PlanWorkoutState>(
                buildWhen: (previous, current) =>
                previous.workouts.length != current.workouts.length ||
                    previous.workouts.asMap().entries.any((entry) {
                      final index = entry.key;
                      final prevWorkout = entry.value;
                      final currWorkout = current.workouts[index];
                      return prevWorkout.exercises.length != currWorkout.exercises.length ||
                          prevWorkout.exercises.asMap().entries.any((e) =>
                          e.value.isCompleted != currWorkout.exercises[e.key].isCompleted);
                    }),
                builder: (context, state) {
                  if (state.workouts.isEmpty) {
                    return Center(
                      child: Text(
                        'Add exercises to plan your workouts',
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView(
                    children: [
                      ...state.workouts.asMap().entries.map((entry) {
                        final workoutIndex = entry.key;
                        final workout = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Text(
                                workout.workout_type,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            if (workout.exercises.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Text(
                                  'No exercises added yet',
                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                                ),
                              ),
                            ...workout.exercises.asMap().entries.map((exerciseEntry) {
                              final exerciseIndex = exerciseEntry.key;
                              final exercise = exerciseEntry.value;
                              return Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                elevation: 3,
                                child: ListTile(
                                  leading: Checkbox(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    value: exercise.isCompleted,
                                    onChanged: (value) {
                                      context.read<PlanWorkoutBloc>().add(
                                        ToggleExerciseCompleted(workoutIndex, exerciseIndex),
                                      );
                                    },
                                  ),
                                  title: Text(
                                    exercise.name,
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    '${exercise.sets} sets · ${exercise.muscleGroups.join(", ")}',
                                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      }),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                          childAspectRatio: 0.8,
                          children: state.muscleStatus.entries.map((entry) {
                            final muscle = entry.key;
                            final status = entry.value;
                            final recommendation = state.muscleRecommendations[muscle] ?? '';
                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(_statusIcon(status), color: _statusColor(status), size: 28),
                                    const SizedBox(height: 6),
                                    Text(
                                      muscle,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${state.muscleSets[muscle]} sets',
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[600],
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      status,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: _statusColor(status),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (recommendation.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        recommendation,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: Colors.grey[500],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}