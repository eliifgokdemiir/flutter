import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:state_management/ui/view/dashboard.dart';
import 'package:state_management/ui/view/home.dart';
import 'package:state_management/ui/view/profile.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  String _selectedPeriod = 'Günlük';
  final List<String> _periods = ['Günlük', 'Haftalık', 'Aylık', 'Yıllık'];
  List<ReportData> _reportData = [];

  @override
  void initState() {
    super.initState();
    _reportData = _generateSampleData();
  }

  List<ReportData> _generateSampleData() {
    return [
      ReportData(DateTime(2024, 1, 1), 5400),
      ReportData(DateTime(2024, 1, 2), 8200),
      ReportData(DateTime(2024, 1, 3), 6200),
      ReportData(DateTime(2024, 1, 4), 7300),
      ReportData(DateTime(2024, 1, 5), 9100),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final total = _reportData.fold<double>(0, (sum, item) => sum + item.amount);
    final average = total / _reportData.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo/flexy-logo.png',
                width: 100,
                height: 50,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search,
                color: Color.fromARGB(255, 6, 83, 146)),
            onPressed: () {}, // Arama fonksiyonunu ekleyin
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Periyot Seçim Butonları
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _periods.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final period = _periods[index];
                    return _buildPeriodButton(period);
                  },
                ),
              ),
            ),
            _buildSummaryCards(total, average),
            const SizedBox(height: 20),
            Expanded(
              child: _buildChart(),
            ),
            const SizedBox(height: 20),
            _buildDataTable(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.blue[800], size: 28),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.analytics_outlined,
                  color: Colors.blue[800], size: 28),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Dashboard()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.blue[800], size: 28),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Profile()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    final isSelected = _selectedPeriod == period;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue[50] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey[300]!,
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      onPressed: () {
        setState(() {
          _selectedPeriod = period;
          _reportData = _generateSampleData();
        });
      },
      child: Text(
        period,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSummaryCards(double total, double average) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
              'Toplam', '₺${total.toStringAsFixed(2)}', Colors.blue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
              'Ortalama', '₺${average.toStringAsFixed(2)}', Colors.green),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: color.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceBetween,
            groupsSpace: 20,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _formatDate(_reportData[value.toInt()].date),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text(
                    '₺${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  reservedSize: 40,
                ),
              ),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: _reportData
                .asMap()
                .entries
                .map(
                  (entry) => BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.amount,
                        color: Colors.blue,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Tarih')),
        DataColumn(label: Text('Miktar (₺)'), numeric: true),
      ],
      rows: _reportData
          .map(
            (data) => DataRow(
              cells: [
                DataCell(Text(DateFormat('dd/MM/yyyy').format(data.date))),
                DataCell(Text(data.amount.toStringAsFixed(2))),
              ],
            ),
          )
          .toList(),
    );
  }

  String _formatDate(DateTime date) {
    switch (_selectedPeriod) {
      case 'Günlük':
        return DateFormat('dd/MM').format(date);
      case 'Haftalık':
        return 'Hafta ${DateFormat('w').format(date)}';
      case 'Aylık':
        return DateFormat('MMM').format(date);
      case 'Yıllık':
        return DateFormat('yyyy').format(date);
      default:
        return DateFormat('dd/MM').format(date);
    }
  }

  void _exportReport() {
    // PDF/excel export işlemleri
  }
}

class ReportData {
  final DateTime date;
  final double amount;

  ReportData(this.date, this.amount);
}
