import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:spotter_app/bloc/post/post_bloc.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weekly Progress',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                return Center(
                  child: Text(
                    'No workouts in the last 7 days',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              }

              final muscleGroups = state.muscleSets.keys.toList();
              final values = state.muscleSets.values.toList();

              final totalSets = values.fold<int>(0, (a, b) => a + b);

              final today = DateTime.now();
              final weekStart = today.subtract(const Duration(days: 6));
              final formatter = DateFormat('dd.MM.');
              final dateRange = "${formatter.format(weekStart)} - ${formatter.format(today)}";

              return Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _summaryItem("Total", "$totalSets sets"),
                          _summaryItem("Period", dateRange),
                          //_summaryItem("🔥 Total", "$totalSets sets"),
                          //_summaryItem("📅 Period", dateRange),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            barGroups: muscleGroups.asMap().entries.map((entry) {
                              final index = entry.key;
                              final muscle = entry.value;
                              final sets = state.muscleSets[muscle]!.toDouble();
                              final status = state.muscleStatus[muscle]!;
                              final color = _statusColor(status);

                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: sets,
                                    color: color,
                                    width: muscleGroups.length > 5 ? 15 : 20,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ],
                              );
                            }).toList(),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < muscleGroups.length) {
                                      final name = muscleGroups[index];
                                      final shortName = name.length > 8 ? "${name.substring(0, 6)}…" : name;

                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        space: 6,
                                        child: Text(
                                          shortName,
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: Theme.of(context).colorScheme.surface,
                                tooltipPadding: const EdgeInsets.all(8),
                                tooltipMargin: 8,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final muscle = muscleGroups[group.x.toInt()];
                                  final sets = rod.toY.toInt();
                                  final status = state.muscleStatus[muscle]!;
                                  return BarTooltipItem(
                                    '$muscle\n$sets sets, $status',
                                    GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  );
                                },
                              ),
                            ),
                            maxY: values.reduce((a, b) => a > b ? a : b).toDouble() + 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView(
                      children: state.muscleStatus.entries.map((entry) {
                        final color = _statusColor(entry.value);
                        final icon = _statusIcon(entry.value);
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: Icon(icon, color: color, size: 28),
                            title: Text(
                              entry.key,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              "${state.muscleSets[entry.key]} sets — ${entry.value}",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: color,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            } else if (state is FailedWeeklyTotals) {
              return Center(
                child: Text(
                  'Error loading weekly totals: ${state.error}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              );
            }
            return Center(
              child: Text(
                'No data available',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
