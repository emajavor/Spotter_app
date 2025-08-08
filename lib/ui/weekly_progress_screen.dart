import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotter_app/bloc/post/post_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyProgressScreen extends StatefulWidget {
  const WeeklyProgressScreen({super.key});

  @override
  State<WeeklyProgressScreen> createState() => _WeeklyProgressScreenState();
}

class _WeeklyProgressScreenState extends State<WeeklyProgressScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      context.read<PostBloc>().add(GetWeeklyTotals(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weekly Progress',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Muscle Group Status',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<PostBloc, PostState>(
                buildWhen: (prev, curr) =>
                curr is FetchingWeeklyTotals ||
                    curr is FetchedWeeklyTotals ||
                    curr is FailedWeeklyTotals,
                builder: (context, state) {
                  if (state is FetchingWeeklyTotals) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is FetchedWeeklyTotals) {
                    if (state.muscleSets.isEmpty) {
                      return Text(
                        'No workouts in the last 7 days',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      );
                    }

                    final muscleGroups = state.muscleSets.keys.toList();
                    final values = state.muscleSets.values.toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bar Chart
                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              barGroups: muscleGroups.asMap().entries.map((entry) {
                                final index = entry.key;
                                final muscle = entry.value;
                                final sets = state.muscleSets[muscle]!.toDouble();
                                final status = state.muscleStatus[muscle]!;
                                final color = status.contains('Balanced')
                                    ? Colors.green
                                    : status.contains('Overtrained')
                                    ? Colors.red
                                    : Colors.orange;

                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: sets,
                                      color: color,
                                      width: 20,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                );
                              }).toList(),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < muscleGroups.length) {
                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          child: Text(
                                            muscleGroups[index],
                                            style: GoogleFonts.poppins(fontSize: 12),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barTouchData: BarTouchData(enabled: true),
                              maxY: values.reduce((a, b) => a > b ? a : b).toDouble() + 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Status List
                        Expanded(
                          child: ListView(
                            children: state.muscleStatus.entries
                                .map(
                                  (entry) => Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  '${entry.key}: ${state.muscleSets[entry.key]} sets, ${entry.value}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: entry.value.contains('Balanced')
                                        ? Colors.green
                                        : entry.value.contains('Overtrained')
                                        ? Colors.red
                                        : Colors.orange,
                                  ),
                                ),
                              ),
                            )
                                .toList(),
                          ),
                        ),
                      ],
                    );
                  } else if (state is FailedWeeklyTotals) {
                    return Text(
                      'Error loading weekly totals: ${state.error}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                  return Text(
                    'No data available',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final userId = _auth.currentUser?.uid;
                  if (userId != null) {
                    context.read<PostBloc>().add(GetWeeklyTotals(userId));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Refresh',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
