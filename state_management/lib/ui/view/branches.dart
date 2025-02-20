import 'package:flutter/material.dart';
import 'package:state_management/data/entity/branch.dart';
import 'package:fl_chart/fl_chart.dart';

class Branches extends StatelessWidget {
  final Branch branch;

  const Branches({super.key, required this.branch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          branch.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 10, 97, 168),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[50]!,
              Colors.blue[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTurnoverChart(),
              const SizedBox(height: 25),
              _buildSectionTitle('Ciro Analizleri'),
              const SizedBox(height: 15),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildInfoCard(
                      Icons.today,
                      'Günlük Ciro',
                      '₺${(branch.turnover / 30).toStringAsFixed(2)}',
                      Colors.blueAccent,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      Icons.access_time,
                      'Saatlik Ortalama',
                      '₺${(branch.turnover / 30 / 24).toStringAsFixed(2)}',
                      Colors.lightBlue,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      Icons.date_range,
                      'Haftalık Ciro',
                      '₺${(branch.turnover / 4).toStringAsFixed(2)}',
                      Colors.indigo,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      Icons.calendar_month,
                      'Aylık Ciro',
                      '₺${branch.turnover.toStringAsFixed(2)}',
                      Colors.deepPurple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      IconData icon, String title, String value, Color color) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey[800],
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTurnoverChart() {
    final daily = branch.turnover / 30;
    final hourly = daily / 24;
    final weekly = branch.turnover / 4;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(enabled: false),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '₺${value.toInt()}K',
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(color: Colors.blue, fontSize: 12);
                  switch (value.toInt()) {
                    case 0:
                      return const Text('Saatlik', style: style);
                    case 1:
                      return const Text('Günlük', style: style);
                    case 2:
                      return const Text('Haftalık', style: style);
                    case 3:
                      return const Text('Aylık', style: style);
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: hourly,
                  width: 20,
                  gradient: LinearGradient(
                    colors: [Colors.blue[300]!, Colors.lightBlue[200]!],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(5),
                )
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: daily,
                  width: 20,
                  gradient: LinearGradient(
                    colors: [Colors.blue[500]!, Colors.lightBlue[300]!],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(5),
                )
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: weekly,
                  width: 20,
                  gradient: LinearGradient(
                    colors: [Colors.blue[700]!, Colors.lightBlue[500]!],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(5),
                )
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  toY: branch.turnover,
                  width: 20,
                  gradient: LinearGradient(
                    colors: [Colors.blue[900]!, Colors.lightBlue[700]!],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(5),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
