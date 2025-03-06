import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_data.dart';
import '../models/medical_history.dart';

class HealthService {
  final String baseUrl = 'http://10.0.2.2:5111';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<DailyData>> getDailyData() async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('\$baseUrl/api/data/daily'),
        headers: {
          'Authorization': 'Bearer \$token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => DailyData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load daily data');
      }
    } catch (e) {
      // Return mock data for testing
      return _getMockDailyData();
    }
  }

  Future<DailyData?> getDailyDataByDate(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('\$baseUrl/api/data/daily/\$dateStr'),
        headers: {
          'Authorization': 'Bearer \$token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return DailyData.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load daily data for date');
      }
    } catch (e) {
      // Return mock data for a specific date
      final mockData = _getMockDailyData();
      for (var data in mockData) {
        if (DateFormat('yyyy-MM-dd').format(data.date) == dateStr) {
          return data;
        }
      }
      return null;
    }
  }

  Future<bool> addDailyData(DailyData dailyData) async {
    try {
      final token = await _getToken();

      final response = await http.post(
        Uri.parse('\$baseUrl/api/data/daily'),
        headers: {
          'Authorization': 'Bearer \$token',
          'Content-Type': 'application/json'
        },
        body: json.encode(dailyData.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      // Simulate successful response for testing
      return true;
    }
  }

  Future<List<MedicalHistory>> getMedicalHistory() async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('\$baseUrl/api/medical/history'),
        headers: {
          'Authorization': 'Bearer \$token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => MedicalHistory.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load medical history');
      }
    } catch (e) {
      // Return mock data for testing
      return _getMockMedicalHistory();
    }
  }

  Future<bool> addMedicalHistory(MedicalHistory medicalHistory) async {
    try {
      final token = await _getToken();

      final response = await http.post(
        Uri.parse('\$baseUrl/api/medical/history'),
        headers: {
          'Authorization': 'Bearer \$token',
          'Content-Type': 'application/json'
        },
        body: json.encode(medicalHistory.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      // Simulate successful response for testing
      return true;
    }
  }

  // Mock data for offline testing
  List<DailyData> _getMockDailyData() {
    final now = DateTime.now();
    return [
      DailyData(
        id: 1,
        date: now.subtract(Duration(days: 6)),
        steps: 8432,
        distance: 5.8,
        caloriesBurned: 320,
        heartRate: 68,
        bloodPressureSystolic: 119,
        bloodPressureDiastolic: 79,
      ),
      DailyData(
        id: 2,
        date: now.subtract(Duration(days: 5)),
        steps: 10234,
        distance: 7.1,
        caloriesBurned: 405,
        heartRate: 72,
        bloodPressureSystolic: 122,
        bloodPressureDiastolic: 80,
      ),
      DailyData(
        id: 3,
        date: now.subtract(Duration(days: 4)),
        steps: 7865,
        distance: 5.2,
        caloriesBurned: 295,
        heartRate: 70,
        bloodPressureSystolic: 120,
        bloodPressureDiastolic: 78,
      ),
      DailyData(
        id: 4,
        date: now.subtract(Duration(days: 3)),
        steps: 9543,
        distance: 6.7,
        caloriesBurned: 378,
        heartRate: 71,
        bloodPressureSystolic: 118,
        bloodPressureDiastolic: 77,
      ),
      DailyData(
        id: 5,
        date: now.subtract(Duration(days: 2)),
        steps: 11023,
        distance: 7.8,
        caloriesBurned: 430,
        heartRate: 74,
        bloodPressureSystolic: 121,
        bloodPressureDiastolic: 79,
      ),
      DailyData(
        id: 6,
        date: now.subtract(Duration(days: 1)),
        steps: 9876,
        distance: 6.9,
        caloriesBurned: 385,
        heartRate: 69,
        bloodPressureSystolic: 117,
        bloodPressureDiastolic: 76,
      ),
      DailyData(
        id: 7,
        date: now,
        steps: 8765,
        distance: 6.1,
        caloriesBurned: 340,
        heartRate: 71,
        bloodPressureSystolic: 120,
        bloodPressureDiastolic: 78,
      ),
    ];
  }

  List<MedicalHistory> _getMockMedicalHistory() {
    return [
      MedicalHistory(
        id: 1,
        condition: 'Hypertension',
        diagnosis: 'Stage 1 Hypertension',
        diagnosisDate: DateTime(2022, 8, 15),
        treatment: 'Lifestyle changes and medication',
        medications: 'Lisinopril 10mg daily',
      ),
      MedicalHistory(
        id: 2,
        condition: 'Allergic Rhinitis',
        diagnosis: 'Seasonal allergies',
        diagnosisDate: DateTime(2021, 5, 10),
        treatment: 'Avoid allergens, take antihistamines',
        medications: 'Cetirizine 10mg as needed',
      ),
      MedicalHistory(
        id: 3,
        condition: 'Migraine',
        diagnosis: 'Chronic migraine without aura',
        diagnosisDate: DateTime(2019, 11, 22),
        treatment: 'Identify triggers, medication for acute attacks',
        medications: 'Sumatriptan 50mg for acute migraine',
      ),
    ];
  }
}
