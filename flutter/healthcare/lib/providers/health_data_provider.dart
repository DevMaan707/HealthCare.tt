import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/daily_data.dart';
import '../models/medical_history.dart';
import '../services/health_service.dart';

class HealthProvider extends ChangeNotifier {
  final HealthService _healthService = HealthService();

  List<DailyData> _dailyData = [];
  List<MedicalHistory> _medicalHistory = [];
  bool _isLoading = false;

  List<DailyData> get dailyData => _dailyData;
  List<MedicalHistory> get medicalHistory => _medicalHistory;
  bool get isLoading => _isLoading;

  // Daily health data
  Future<void> fetchDailyData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dailyData = await _healthService.getDailyData();
      _dailyData.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      print('Error fetching daily data: \$e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<DailyData?> fetchDailyDataByDate(DateTime date) async {
    try {
      return await _healthService.getDailyDataByDate(date);
    } catch (e) {
      print('Error fetching daily data for date: \$e');
      return null;
    }
  }

  Future<bool> addDailyData(DailyData data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _healthService.addDailyData(data);
      if (success) {
        await fetchDailyData();
      }
      return success;
    } catch (e) {
      print('Error adding daily data: \$e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Medical history
  Future<void> fetchMedicalHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _medicalHistory = await _healthService.getMedicalHistory();
      _medicalHistory
          .sort((a, b) => b.diagnosisDate.compareTo(a.diagnosisDate));
    } catch (e) {
      print('Error fetching medical history: \$e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addMedicalHistory(MedicalHistory history) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _healthService.addMedicalHistory(history);
      if (success) {
        await fetchMedicalHistory();
      }
      return success;
    } catch (e) {
      print('Error adding medical history: \$e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Health insights
  String getBloodPressureStatus(double? systolic, double? diastolic) {
    if (systolic == null || diastolic == null) return 'No data';

    if (systolic < 120 && diastolic < 80) {
      return 'Normal';
    } else if ((systolic >= 120 && systolic <= 129) && diastolic < 80) {
      return 'Elevated';
    } else if ((systolic >= 130 && systolic <= 139) ||
        (diastolic >= 80 && diastolic <= 89)) {
      return 'Stage 1 Hypertension';
    } else if (systolic >= 140 || diastolic >= 90) {
      return 'Stage 2 Hypertension';
    } else {
      return 'Unknown';
    }
  }

  String getHeartRateStatus(int? heartRate) {
    if (heartRate == null) return 'No data';

    if (heartRate < 60) {
      return 'Low';
    } else if (heartRate >= 60 && heartRate <= 100) {
      return 'Normal';
    } else {
      return 'Elevated';
    }
  }

  Map<String, dynamic> getWeeklyActivitySummary() {
    if (_dailyData.isEmpty) {
      return {
        'totalSteps': 0,
        'averageSteps': 0,
        'totalDistance': 0.0,
        'averageDistance': 0.0,
        'totalCalories': 0,
        'averageCalories': 0,
      };
    }

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: 6));

    final weeklyData = _dailyData
        .where((data) =>
            data.date.isAfter(weekStart.subtract(Duration(days: 1))) &&
            data.date.isBefore(now.add(Duration(days: 1))))
        .toList();

    if (weeklyData.isEmpty) {
      return {
        'totalSteps': 0,
        'averageSteps': 0,
        'totalDistance': 0.0,
        'averageDistance': 0.0,
        'totalCalories': 0,
        'averageCalories': 0,
      };
    }

    final totalSteps =
        weeklyData.fold<int>(0, (sum, data) => sum + (data.steps ?? 0));
    final totalDistance =
        weeklyData.fold<double>(0, (sum, data) => sum + (data.distance ?? 0));
    final totalCalories = weeklyData.fold<int>(
        0, (sum, data) => sum + (data.caloriesBurned ?? 0));

    return {
      'totalSteps': totalSteps,
      'averageSteps': (totalSteps / weeklyData.length).round(),
      'totalDistance': totalDistance.toStringAsFixed(1),
      'averageDistance': (totalDistance / weeklyData.length).toStringAsFixed(1),
      'totalCalories': totalCalories,
      'averageCalories': (totalCalories / weeklyData.length).round(),
    };
  }

  Map<String, List> getWeeklyChartData() {
    final List<double> steps = List.filled(7, 0);
    final List<double> distance = List.filled(7, 0);
    final List<double> calories = List.filled(7, 0);
    final List<String> dates = List.filled(7, '');

    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      dates[6 - i] = DateFormat('E').format(date); // Day of week abbreviation

      final dayData = _dailyData.firstWhere(
        (data) =>
            DateFormat('yyyy-MM-dd').format(data.date) ==
            DateFormat('yyyy-MM-dd').format(date),
        orElse: () =>
            DailyData(date: date, steps: 0, distance: 0, caloriesBurned: 0),
      );

      steps[6 - i] = (dayData.steps ?? 0).toDouble();
      distance[6 - i] = dayData.distance ?? 0;
      calories[6 - i] = (dayData.caloriesBurned ?? 0).toDouble();
    }

    return {
      'dates': dates,
      'steps': steps,
      'distance': distance,
      'calories': calories,
    };
  }
}
