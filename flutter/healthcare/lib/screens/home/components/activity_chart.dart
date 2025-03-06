import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ActivityChart extends StatefulWidget {
  final Map<String, List<dynamic>>
      chartData; // Changed type to be more explicit

  const ActivityChart({Key? key, required this.chartData}) : super(key: key);

  @override
  State<ActivityChart> createState() => _ActivityChartState();
}

class _ActivityChartState extends State<ActivityChart> {
  int _selectedIndex = 0;
  final List<String> _chartTypes = ['Steps', 'Distance', 'Calories'];

  @override
  Widget build(BuildContext context) {
    // Cast the dynamic list to a list of strings
    List<String> dates = (widget.chartData['dates'] ?? List.filled(7, ''))
        .map((item) => item.toString())
        .toList();

    List<double> data;

    switch (_selectedIndex) {
      case 0:
        // Cast each value to double
        data = (widget.chartData['steps'] ?? List.filled(7, 0.0))
            .map((item) => item is num ? item.toDouble() : 0.0)
            .toList();
        break;
      case 1:
        data = (widget.chartData['distance'] ?? List.filled(7, 0.0))
            .map((item) => item is num ? item.toDouble() : 0.0)
            .toList();
        break;
      case 2:
        data = (widget.chartData['calories'] ?? List.filled(7, 0.0))
            .map((item) => item is num ? item.toDouble() : 0.0)
            .toList();
        break;
      default:
        data = (widget.chartData['steps'] ?? List.filled(7, 0.0))
            .map((item) => item is num ? item.toDouble() : 0.0)
            .toList();
    }

    double maxY = data.isNotEmpty
        ? data.reduce((curr, next) => curr > next ? curr : next)
        : 100;
    maxY = maxY * 1.2; // Add some padding to the max value

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
              children: _chartTypes.asMap().entries.map((entry) {
                final index = entry.key;
                final title = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(title),
                    selected: _selectedIndex == index,
                    onSelected: (_) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: false,
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
                          if (value.toInt() < 0 ||
                              value.toInt() >= dates.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              dates[value.toInt()],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
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
                          if (value == 0) return const SizedBox.shrink();

                          String text;
                          if (maxY > 10000) {
                            text =
                                '\${(value / 1000).toInt()}k'; // Fixed the string interpolation
                          } else {
                            text = value.toInt().toString();
                          }

                          return Text(
                            text,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: dates.length.toDouble() - 1,
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      color: _getColorForIndex(_selectedIndex),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color:
                            _getColorForIndex(_selectedIndex).withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getSummaryText(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    switch (index) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getSummaryText() {
    switch (_selectedIndex) {
      case 0:
        return 'Weekly step count shows your daily activity level. Aim for 10,000 steps per day.';
      case 1:
        return 'Distance walked or run each day. The average person walks about 5-7 kilometers daily.';
      case 2:
        return 'Calories burned through physical activity. More activity means more calories burned.';
      default:
        return '';
    }
  }
}
