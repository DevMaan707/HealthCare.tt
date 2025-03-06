import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/daily_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_data_provider.dart';
import '../chat/chat_screen.dart';
import 'add_daily_data.dart';
import 'add_medical_history.dart';
import 'components/health_card.dart';
import 'components/activity_chart.dart';
import 'health_insights.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat Assistant',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final healthProvider =
          Provider.of<HealthProvider>(context, listen: false);
      healthProvider.fetchDailyData();
      healthProvider.fetchMedicalHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final healthProvider = Provider.of<HealthProvider>(context);
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthAssist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () {
                        authProvider.logout();
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('LOGOUT'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await healthProvider.fetchDailyData();
          await healthProvider.fetchMedicalHistory();
        },
        child: healthProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
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
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.2),
                                  radius: 30,
                                  child: Icon(
                                    Icons.person,
                                    size: 36,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome back,',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      Text(
                                        authProvider.username ?? 'User',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy').format(today),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Today's Health Stats
                    _buildSectionHeader(
                        context, 'Today\'s Health Stats', Icons.favorite),
                    const SizedBox(height: 8),
                    _buildTodayHealthStats(context, healthProvider, today),
                    const SizedBox(height: 24),

                    // Activity Chart
                    _buildSectionHeader(
                        context, 'Weekly Activity', Icons.show_chart),
                    const SizedBox(height: 8),
                    ActivityChart(
                        chartData: healthProvider.getWeeklyChartData()),
                    const SizedBox(height: 24),

                    // Medical History
                    _buildSectionHeader(
                        context, 'Medical History', Icons.medical_information),
                    const SizedBox(height: 8),
                    _buildMedicalHistoryList(context, healthProvider),
                    const SizedBox(height: 16),

                    // Action Buttons
                    _buildActionButtons(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDataOptions(context),
        tooltip: 'Add Data',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildTodayHealthStats(
      BuildContext context, HealthProvider healthProvider, DateTime today) {
    final todayFormatted = DateFormat('yyyy-MM-dd').format(today);
    final dailyData = healthProvider.dailyData.firstWhere(
      (data) => DateFormat('yyyy-MM-dd').format(data.date) == todayFormatted,
      orElse: () => DailyData(date: today),
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: HealthCard(
                title: 'Steps',
                value: dailyData.steps?.toString() ?? 'No data',
                subtitle: 'steps today',
                icon: Icons.directions_walk,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: HealthCard(
                title: 'Distance',
                value: dailyData.distance?.toStringAsFixed(1) ?? 'No data',
                subtitle: 'km',
                icon: Icons.straighten,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: HealthCard(
                title: 'Heart Rate',
                value: dailyData.heartRate?.toString() ?? 'No data',
                subtitle: 'bpm',
                icon: Icons.favorite,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: HealthCard(
                title: 'Blood Pressure',
                value: dailyData.bloodPressureSystolic != null &&
                        dailyData.bloodPressureDiastolic != null
                    ? '\\${dailyData.bloodPressureSystolic!.toInt()}/${dailyData.bloodPressureDiastolic!.toInt()}'
                    : 'No data',
                subtitle: 'mmHg',
                icon: Icons.speed,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMedicalHistoryList(
      BuildContext context, HealthProvider healthProvider) {
    final medicalHistory = healthProvider.medicalHistory;

    if (medicalHistory.isEmpty) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.medical_information_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                'No medical history records',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add your medical conditions and medications',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: medicalHistory.take(2).map((history) {
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              history.condition,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(history.diagnosis),
                Text(
                  'Diagnosed: ${DateFormat('MMM d, yyyy').format(history.diagnosisDate)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(history.condition),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Diagnosis: ${history.diagnosis}'),
                      const SizedBox(height: 8),
                      Text(
                          'Date: ${DateFormat('MMM d, yyyy').format(history.diagnosisDate)}'),
                      const SizedBox(height: 8),
                      Text('Treatment: ${history.treatment}'),
                      const SizedBox(height: 8),
                      Text('Medications: ${history.medications}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CLOSE'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HealthInsightsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.insights),
            label: const Text('Health Insights'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatScreen(),
                ),
              );
            },
            icon: const Icon(Icons.chat),
            label: const Text('Chat Assistant'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddDataOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Health Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[50],
                child:
                    Icon(Icons.monitor_heart_outlined, color: Colors.blue[700]),
              ),
              title: const Text('Daily Health Data'),
              subtitle: const Text('Steps, heart rate, blood pressure, etc.'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DailyDataFormScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[50],
                child: Icon(Icons.medical_information_outlined,
                    color: Colors.green[700]),
              ),
              title: const Text('Medical History'),
              subtitle: const Text('Conditions, diagnoses, medications, etc.'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MedicalHistoryFormScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
