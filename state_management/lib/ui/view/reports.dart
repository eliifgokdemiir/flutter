import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:state_management/ui/view/dashboard.dart';
import 'package:state_management/ui/view/home.dart';
import 'package:state_management/ui/view/navbar_menu.dart';
import 'package:state_management/ui/view/profile.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedPeriod = 'Günlük';
  final List<String> _periods = ['Günlük', 'Haftalık', 'Aylık', 'Yıllık'];
  List<ReportData> _reportData = [];

  @override
  void initState() {
    super.initState();
    _reportData = _generateSampleData();
  }

  List<ReportData> _generateSampleData() {
    switch (_selectedPeriod) {
      case 'Günlük':
        return [
          ReportData(DateTime(2024, 6, 1), 5400),
          ReportData(DateTime(2024, 6, 2), 8200),
          ReportData(DateTime(2024, 6, 3), 6200),
          ReportData(DateTime(2024, 6, 4), 7300),
          ReportData(DateTime(2024, 6, 5), 9100),
        ];
      case 'Haftalık':
        return [
          ReportData(DateTime(2024, 6, 7), 35000),
          ReportData(DateTime(2024, 6, 14), 42000),
          ReportData(DateTime(2024, 6, 21), 38500),
          ReportData(DateTime(2024, 6, 28), 41000),
        ];
      case 'Aylık':
        return [
          ReportData(DateTime(2024, 1, 1), 210000),
          ReportData(DateTime(2024, 2, 1), 234000),
          ReportData(DateTime(2024, 3, 1), 198000),
          ReportData(DateTime(2024, 4, 1), 245000),
        ];
      case 'Yıllık':
        return [
          ReportData(DateTime(2021, 1, 1), 1850000),
          ReportData(DateTime(2022, 1, 1), 2140000),
          ReportData(DateTime(2023, 1, 1), 1980000),
          ReportData(DateTime(2024, 1, 1), 2450000),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _reportData.fold<double>(0, (sum, item) => sum + item.amount);
    final average = total / _reportData.length;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const NavbarMenu(),
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
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceBetween,
            groupsSpace: _selectedPeriod == 'Günlük' ? 8 : 12,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                    BarTooltipItem(
                  '₺${rod.toY.toStringAsFixed(2)}',
                  const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => SizedBox(
                    width: 60,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _formatDate(_reportData[value.toInt()].date),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _selectedPeriod == 'Aylık' ? 10 : 11,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  reservedSize: 30,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text(
                    '₺${(value ~/ 1000)}K',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  reservedSize: 50,
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.blueGrey[100]!,
                strokeWidth: 1.5,
                dashArray: [4],
              ),
              horizontalInterval: _selectedPeriod == 'Yıllık'
                  ? 500000
                  : _selectedPeriod == 'Aylık'
                      ? 100000
                      : 10000,
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            barGroups: _reportData
                .asMap()
                .entries
                .map(
                  (entry) => BarChartGroupData(
                    x: entry.key,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.amount,
                        color: _getChartColor(entry.key),
                        width: _selectedPeriod == 'Günlük'
                            ? 18
                            : _selectedPeriod == 'Haftalık'
                                ? 22
                                : 24,
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

  Color _getChartColor(int index) {
    final colors = [
      Colors.blue[400]!,
      Colors.blue[300]!,
      Colors.blue[200]!,
    ];
    return colors[index % colors.length];
  }

  Widget _buildDataTable() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: DataTable(
          columnSpacing: 20,
          horizontalMargin: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          columns: [
            DataColumn(
              label: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'Tarih',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'Miktar (₺)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ),
              numeric: true,
            ),
          ],
          rows: _reportData
              .asMap()
              .entries
              .map(
                (entry) => DataRow(
                  color: MaterialStateProperty.resolveWith<Color>(
                    (states) => entry.key.isEven
                        ? Colors.blue.withOpacity(0.05)
                        : Colors.transparent,
                  ),
                  cells: [
                    DataCell(
                      Text(
                        DateFormat('dd/MM/yyyy').format(entry.value.date),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          NumberFormat.currency(
                            locale: 'tr_TR',
                            symbol: '',
                            decimalDigits: 2,
                          ).format(entry.value.amount),
                          style: const TextStyle(
                            fontSize: 13,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
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
