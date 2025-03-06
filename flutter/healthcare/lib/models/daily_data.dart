import 'package:intl/intl.dart';

class DailyData {
  final int? id;
  final DateTime date;
  final int? steps;
  final double? distance;
  final int? caloriesBurned;
  final int? heartRate;
  final double? bloodPressureSystolic;
  final double? bloodPressureDiastolic;

  DailyData({
    this.id,
    required this.date,
    this.steps,
    this.distance,
    this.caloriesBurned,
    this.heartRate,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
  });

  factory DailyData.fromJson(Map<String, dynamic> json) {
    return DailyData(
      id: json['id'],
      date: DateTime.parse(json['date']),
      steps: json['steps'],
      distance: json['distance']?.toDouble(),
      caloriesBurned: json['caloriesBurned'],
      heartRate: json['heartRate'],
      bloodPressureSystolic: json['bloodPressureSystolic']?.toDouble(),
      bloodPressureDiastolic: json['bloodPressureDiastolic']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': DateFormat('yyyy-MM-dd').format(date),
      'steps': steps,
      'distance': distance,
      'caloriesBurned': caloriesBurned,
      'heartRate': heartRate,
      'bloodPressureSystolic': bloodPressureSystolic,
      'bloodPressureDiastolic': bloodPressureDiastolic,
    };
  }
}
