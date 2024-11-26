import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

void main() {
  runApp(const PainTrackerApp());
}

class PainTrackerApp extends StatelessWidget {
  const PainTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pain Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<PainRecord> painRecords = [];
  final List<MedicationRecord> medicationRecords = [];
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  // Add a variable to store current time for the clock
  String currentTime = '';
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Update time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    // First select date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (pickedDate != null) {
      // Then select time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedTime,
      );
      
      if (pickedTime != null) {
        setState(() {
          selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          selectedTime = pickedTime;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pain Management Tracker'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDateTime(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add digital clock at the top
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.access_time, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        currentTime,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSummaryCards(),
              const SizedBox(height: 20),
              _buildPainChart(),
              const SizedBox(height: 20),
              _buildRecentRecords(),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () => _showPainRecordDialog(),
            label: const Text('Record Pain'),
            icon: const Icon(Icons.add),
            backgroundColor: Colors.red[400],
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () => _showMedicationRecordDialog(),
            label: const Text('Log Medication'),
            icon: const Icon(Icons.medication),
            backgroundColor: Colors.green[400],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pain Episodes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${painRecords.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Medications Taken',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${medicationRecords.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPainChart() {
    // Calculate the time window based on selected date
    final endDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);
    final startDate = endDate.subtract(const Duration(days: 2)); // Show 3 days including selected date
    
    // Filter records for selected 3-day window
    final recentPainRecords = painRecords.where(
      (record) => record.dateTime.isAfter(startDate) && 
                  record.dateTime.isBefore(endDate.add(const Duration(seconds: 1)))
    ).toList();
    
    final recentMedicationRecords = medicationRecords.where(
      (record) => record.dateTime.isAfter(startDate) && 
                  record.dateTime.isBefore(endDate.add(const Duration(seconds: 1)))
    ).toList();

    // Calculate daily midnight timestamps for grid lines
    final gridLineDates = <DateTime>[];
    for (int i = 0; i <= 3; i++) {
      gridLineDates.add(
        DateTime(startDate.year, startDate.month, startDate.day).add(Duration(days: i))
      );
    }

    return SizedBox(
      height: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pain Intensity Over Time (3 Days)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('MM/dd/yyyy').format(selectedDate),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 1,
                      getDrawingVerticalLine: (value) {
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        final isMidnight = date.hour == 0 && date.minute == 0;
                        return FlLine(
                          color: isMidnight 
                            ? Colors.grey[300]! 
                            : Colors.transparent,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35,
                          interval: 3600000 * 6, // 6-hour interval
                          getTitlesWidget: (value, meta) {
                            final date = DateTime.fromMillisecondsSinceEpoch(
                                value.toInt());
                                
                            // Skip the first hour label if it's midnight
                            if (date.compareTo(startDate) == 0) {
                              return const Text('');
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                date.hour == 0 
                                  ? DateFormat('MM/dd').format(date)  // Only date at midnight
                                  : (date.difference(startDate).inHours >= 6  // Only show hours after first 6 hours
                                      ? DateFormat('HH:00').format(date) 
                                      : ''),
                                style: TextStyle(
                                  color: date.hour == 0 
                                    ? Colors.black 
                                    : Colors.grey[600],
                                  fontSize: date.hour == 0 ? 12 : 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    minX: startDate.millisecondsSinceEpoch.toDouble(),
                    maxX: endDate.millisecondsSinceEpoch.toDouble(),
                    minY: 0,
                    maxY: 10,
                    lineBarsData: [
                      LineChartBarData(
                        spots: recentPainRecords
                            .map((record) => FlSpot(
                                record.dateTime.millisecondsSinceEpoch.toDouble(),
                                record.intensity.toDouble()))
                            .toList(),
                        isCurved: true,
                        color: Colors.red,
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                    extraLinesData: ExtraLinesData(
                      horizontalLines: const [],
                      verticalLines: recentMedicationRecords
                          .map(
                            (record) => VerticalLine(
                              x: record.dateTime.millisecondsSinceEpoch.toDouble(),
                              color: Colors.green.withOpacity(0.5),
                              strokeWidth: 2,
                              label: VerticalLineLabel(
                                show: true,
                                alignment: Alignment.topRight,
                                style: const TextStyle(fontSize: 10),
                                labelResolver: (line) => '💊',
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentRecords() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Records',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medicationRecords.length,
              itemBuilder: (context, index) {
                final record = medicationRecords[index];
                return ListTile(
                  leading: const Icon(Icons.medication, color: Colors.green),
                  title: Text(record.medicationName),
                  subtitle: Text(
                      '${DateFormat('MM/dd/yyyy HH:mm').format(record.dateTime)} - ${record.dose}'),
                  trailing: Text(
                    DateFormat('HH:mm').format(record.dateTime),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPainRecordDialog() {
    int painLevel = 5;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Pain Level'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Date & Time: ${DateFormat('MM/dd/yyyy HH:mm').format(selectedDate)}'),
              const SizedBox(height: 16),
              const Text('Select pain intensity (0-10):'),
              Slider(
                value: painLevel.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                label: painLevel.toString(),
                onChanged: (value) {
                  setState(() {
                    painLevel = value.round();
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                painRecords.add(
                  PainRecord(
                    dateTime: selectedDate,
                    intensity: painLevel,
                  ),
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showMedicationRecordDialog() {
    final medicationController = TextEditingController();
    final doseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Medication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Date & Time: ${DateFormat('MM/dd/yyyy HH:mm').format(selectedDate)}'),
            const SizedBox(height: 16),
            TextField(
              controller: medicationController,
              decoration: const InputDecoration(
                labelText: 'Medication Name',
              ),
            ),
            TextField(
              controller: doseController,
              decoration: const InputDecoration(
                labelText: 'Dose',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                medicationRecords.add(
                  MedicationRecord(
                    dateTime: selectedDate,
                    medicationName: medicationController.text,
                    dose: doseController.text,
                  ),
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class PainRecord {
  final DateTime dateTime;
  final int intensity;

  PainRecord({
    required this.dateTime,
    required this.intensity,
  });
}

class MedicationRecord {
  final DateTime dateTime;
  final String medicationName;
  final String dose;

  MedicationRecord({
    required this.dateTime,
    required this.medicationName,
    required this.dose,
  });
}