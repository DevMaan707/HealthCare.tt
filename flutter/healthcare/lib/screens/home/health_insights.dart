import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/health_data_provider.dart';

class HealthInsightsScreen extends StatefulWidget {
  const HealthInsightsScreen({Key? key}) : super(key: key);

  @override
  State<HealthInsightsScreen> createState() => _HealthInsightsScreenState();
}

class _HealthInsightsScreenState extends State<HealthInsightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HealthProvider>(context, listen: false).fetchDailyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthProvider>(context);
    final summary = healthProvider.getWeeklyActivitySummary();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Insights'),
      ),
      body: healthProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weekly Activity Summary
                  _buildSectionHeader(context, 'Weekly Activity Summary'),
                  const SizedBox(height: 12),
                  _buildActivitySummaryCards(context, summary),
                  const SizedBox(height: 24),

                  // Heart Rate Trend
                  _buildSectionHeader(context, 'Heart Rate Trend'),
                  const SizedBox(height: 12),
                  _buildHeartRateChart(context, healthProvider),
                  const SizedBox(height: 24),

                  // Blood Pressure Trend
                  _buildSectionHeader(context, 'Blood Pressure Trend'),
                  const SizedBox(height: 12),
                  _buildBloodPressureChart(context, healthProvider),
                  const SizedBox(height: 24),

                  // Health Status
                  _buildSectionHeader(context, 'Health Status'),
                  const SizedBox(height: 12),
                  _buildHealthStatusCards(context, healthProvider),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildActivitySummaryCards(
      BuildContext context, Map<String, dynamic> summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Total Steps',
                summary['totalSteps'].toString(),
                'steps',
                Icons.directions_walk,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Avg Steps',
                summary['averageSteps'].toString(),
                'per day',
                Icons.show_chart,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Total Distance',
                summary['totalDistance'].toString(),
                'km',
                Icons.straighten,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Total Calories',
                summary['totalCalories'].toString(),
                'kcal',
                Icons.local_fire_department,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              unit,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartRateChart(
      BuildContext context, HealthProvider healthProvider) {
    final dailyData = healthProvider.dailyData;
    final last7Days = dailyData.take(7).toList();

    if (last7Days.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No heart rate data available'),
        ),
      );
    }

    last7Days.sort((a, b) => a.date.compareTo(b.date));

    final spots = last7Days.where((data) => data.heartRate != null).map((data) {
      final index = last7Days.indexOf(data);
      return FlSpot(index.toDouble(), data.heartRate!.toDouble());
    }).toList();

    if (spots.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No heart rate data available'),
        ),
      );
    }

    final dates =
        last7Days.map((data) => DateFormat('MMM d').format(data.date)).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final intValue = value.toInt();
                          if (intValue < 0 || intValue >= dates.length) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              dates[intValue],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: dates.length.toDouble() - 1,
                  minY: 40, // Minimum heart rate
                  maxY: 120, // Maximum heart rate
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.red.withOpacity(0.15),
                      ),
                    ),
                    // Normal range reference line (60-100 BPM)
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 60),
                        FlSpot(dates.length.toDouble() - 1, 60),
                      ],
                      isCurved: false,
                      color: Colors.green.withOpacity(0.5),
                      barWidth: 1,
                      dotData: FlDotData(show: false),
                      dashArray: [5, 5],
                    ),
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 100),
                        FlSpot(dates.length.toDouble() - 1, 100),
                      ],
                      isCurved: false,
                      color: Colors.green.withOpacity(0.5),
                      barWidth: 1,
                      dotData: FlDotData(show: false),
                      dashArray: [5, 5],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Normal range (60-100 BPM)'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'A normal resting heart rate for adults ranges from 60 to 100 beats per minute. Lower is generally better, indicating efficient heart function and higher cardiovascular fitness.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodPressureChart(
      BuildContext context, HealthProvider healthProvider) {
    final dailyData = healthProvider.dailyData;
    final last7Days = dailyData.take(7).toList();

    if (last7Days.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No blood pressure data available'),
        ),
      );
    }

    last7Days.sort((a, b) => a.date.compareTo(b.date));

    final systolicSpots = last7Days
        .where((data) => data.bloodPressureSystolic != null)
        .map((data) {
      final index = last7Days.indexOf(data);
      return FlSpot(index.toDouble(), data.bloodPressureSystolic!.toDouble());
    }).toList();

    final diastolicSpots = last7Days
        .where((data) => data.bloodPressureDiastolic != null)
        .map((data) {
      final index = last7Days.indexOf(data);
      return FlSpot(index.toDouble(), data.bloodPressureDiastolic!.toDouble());
    }).toList();

    if (systolicSpots.isEmpty && diastolicSpots.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No blood pressure data available'),
        ),
      );
    }

    final dates =
        last7Days.map((data) => DateFormat('MMM d').format(data.date)).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final intValue = value.toInt();
                          if (intValue < 0 || intValue >= dates.length) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              dates[intValue],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: dates.length.toDouble() - 1,
                  minY: 40,
                  maxY: 160,
                  lineBarsData: [
                    // Systolic
                    if (systolicSpots.isNotEmpty)
                      LineChartBarData(
                        spots: systolicSpots,
                        isCurved: true,
                        color: Colors.purple,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.purple.withOpacity(0.1),
                        ),
                      ),

                    // Diastolic
                    if (diastolicSpots.isNotEmpty)
                      LineChartBarData(
                        spots: diastolicSpots,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.1),
                        ),
                      ),

                    // Normal range reference lines
                    // Systolic normal (< 120)
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 120),
                        FlSpot(dates.length.toDouble() - 1, 120),
                      ],
                      isCurved: false,
                      color: Colors.green.withOpacity(0.5),
                      barWidth: 1,
                      dotData: FlDotData(show: false),
                      dashArray: [5, 5],
                    ),
                    // Diastolic normal (< 80)
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 80),
                        FlSpot(dates.length.toDouble() - 1, 80),
                      ],
                      isCurved: false,
                      color: Colors.green.withOpacity(0.5),
                      barWidth: 1,
                      dotData: FlDotData(show: false),
                      dashArray: [5, 5],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Systolic'),
                const SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Diastolic'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Normal blood pressure is less than 120/80 mm Hg. The green lines indicate the upper limit of normal blood pressure values.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStatusCards(
      BuildContext context, HealthProvider healthProvider) {
    final dailyData = healthProvider.dailyData;
    if (dailyData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No health data available'),
        ),
      );
    }

    final latestData = dailyData.first;

    final bloodPressureStatus = healthProvider.getBloodPressureStatus(
      latestData.bloodPressureSystolic,
      latestData.bloodPressureDiastolic,
    );

    final heartRateStatus =
        healthProvider.getHeartRateStatus(latestData.heartRate);

    final weeklyStepTotal =
        healthProvider.getWeeklyActivitySummary()['totalSteps'] as int;
    final stepGoal = 70000; // 10k steps per day for a week
    final stepProgress = weeklyStepTotal / stepGoal;

    return Column(
      children: [
        // Blood Pressure Status
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Blood Pressure Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color:
                            _getBloodPressureStatusColor(bloodPressureStatus),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      bloodPressureStatus,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getBloodPressureAdvice(bloodPressureStatus),
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Heart Rate Status
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Heart Rate Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getHeartRateStatusColor(heartRateStatus),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      heartRateStatus,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getHeartRateAdvice(heartRateStatus),
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Step Goal Progress
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Step Goal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      weeklyStepTotal.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      ' / 70,000 steps',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: stepProgress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  color: _getStepGoalColor(stepProgress),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 8),
                Text(
                  _getStepGoalAdvice(stepProgress),
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getBloodPressureStatusColor(String status) {
    switch (status) {
      case 'Normal':
        return Colors.green;
      case 'Elevated':
        return Colors.yellow[700]!;
      case 'Stage 1 Hypertension':
        return Colors.orange;
      case 'Stage 2 Hypertension':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getBloodPressureAdvice(String status) {
    switch (status) {
      case 'Normal':
        return 'Your blood pressure is within a healthy range. Maintain your healthy lifestyle!';
      case 'Elevated':
        return 'Your blood pressure is slightly elevated. Consider lifestyle changes like reducing sodium intake.';
      case 'Stage 1 Hypertension':
        return 'Your blood pressure is high. Consult with your healthcare provider about lifestyle changes and possible medication.';
      case 'Stage 2 Hypertension':
        return 'Your blood pressure is very high. Please consult with your healthcare provider as soon as possible.';
      default:
        return 'No blood pressure data available. Regular monitoring is recommended.';
    }
  }

  Color _getHeartRateStatusColor(String status) {
    switch (status) {
      case 'Normal':
        return Colors.green;
      case 'Low':
        return Colors.blue;
      case 'Elevated':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getHeartRateAdvice(String status) {
    switch (status) {
      case 'Normal':
        return 'Your heart rate is within a healthy range. Keep up the good work!';
      case 'Low':
        return 'Your heart rate is below normal. This might be due to good physical fitness, but consult your doctor if you feel symptoms.';
      case 'Elevated':
        return 'Your heart rate is higher than normal. This might be due to stress, caffeine, or medication. Monitor and consult your doctor if it persists.';
      default:
        return 'No heart rate data available. Regular monitoring is recommended.';
    }
  }

  Color _getStepGoalColor(double progress) {
    if (progress >= 0.9) {
      return Colors.green;
    } else if (progress >= 0.6) {
      return Colors.yellow[700]!;
    } else {
      return Colors.red;
    }
  }

  String _getStepGoalAdvice(double progress) {
    if (progress >= 0.9) {
      return 'Great job! You\'ve almost reached your weekly step goal.';
    } else if (progress >= 0.6) {
      return 'You\'re making good progress toward your weekly step goal. Keep it up!';
    } else if (progress >= 0.3) {
      return 'You\'re on your way to reaching your step goal. Try to increase your daily steps.';
    } else {
      return 'You\'re just getting started. Aim to increase your daily steps to reach your weekly goal.';
    }
  }
}
