import 'package:flutter/material.dart';
import 'package:state_management/ui/view/navbar_menu.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedInterval = 'Günlük';
  final List<String> _intervals = ['Günlük', 'Haftalık', 'Aylık', 'Yıllık'];
  late List<RevenueData> _revenueData;

  @override
  void initState() {
    super.initState();
    _revenueData = _generateSampleData();
  }

  List<RevenueData> _generateSampleData() {
    return [
      RevenueData(DateTime(2024, 1, 1), 5400, 4800),
      RevenueData(DateTime(2024, 1, 2), 8200, 7200),
      RevenueData(DateTime(2024, 1, 3), 6500, 5800),
      RevenueData(DateTime(2024, 1, 4), 12300, 11200),
      RevenueData(DateTime(2024, 1, 5), 9500, 8700),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          _buildIntervalDropdown(),
          const SizedBox(width: 12),
        ],
      ),
      drawer: const NavbarMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryCards(),
            const SizedBox(height: 20),
            Expanded(
              child: _buildRevenueTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DropdownButton<String>(
        value: _selectedInterval,
        icon: const Icon(Icons.arrow_drop_down),
        style: TextStyle(color: Theme.of(context).primaryColor),
        underline: Container(),
        items: _intervals.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedInterval = newValue!;
            _revenueData = _generateSampleData();
          });
        },
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalRevenue =
        _revenueData.fold<double>(0, (sum, item) => sum + item.grossRevenue);
    final averageRevenue = totalRevenue / _revenueData.length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _buildSummaryCard('Toplam Ciro', '₺${totalRevenue.toStringAsFixed(2)}',
            Icons.attach_money, Colors.blue),
        _buildSummaryCard(
            'Ortalama Ciro',
            '₺${averageRevenue.toStringAsFixed(2)}',
            Icons.trending_up,
            Colors.green),
        _buildSummaryCard(
            'Maksimum Ciro', '₺12300', Icons.bar_chart, Colors.orange),
        _buildSummaryCard(
            'Minimum Ciro', '₺5400', Icons.show_chart, Colors.red),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueTable() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Detaylı Ciro Raporu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: _revenueData.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final data = _revenueData[index];
                  return ListTile(
                    title: Text(
                        '${data.date.day}/${data.date.month}/${data.date.year}'),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Brüt: ₺${data.grossRevenue.toStringAsFixed(2)}'),
                        Text('Net: ₺${data.netRevenue.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.green)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RevenueData {
  final DateTime date;
  final double grossRevenue;
  final double netRevenue;

  RevenueData(this.date, this.grossRevenue, this.netRevenue);
}
