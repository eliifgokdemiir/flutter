import 'package:flutter/material.dart';
import 'package:state_management/ui/view/navbar_menu.dart';
import 'package:state_management/ui/view/home.dart';
import 'dart:math';

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSummaryCards(),
                    const SizedBox(height: 20),
                    _buildRevenueTable(),
                  ],
                ),
              ),
            ),
          );
        },
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.analytics_outlined,
                  color: Colors.blue[800], size: 28),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.blue[800], size: 28),
              onPressed: () {},
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
    final maxRevenue = _revenueData.map((e) => e.grossRevenue).reduce(max);
    final minRevenue = _revenueData.map((e) => e.grossRevenue).reduce(min);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isSmallScreen ? 1 : 2,
            childAspectRatio: isSmallScreen ? 2.0 : 1.4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return _buildSummaryCard(
                    'Toplam',
                    '₺${totalRevenue.toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.blue);
              case 1:
                return _buildSummaryCard(
                    'Ortalama',
                    '₺${averageRevenue.toStringAsFixed(2)}',
                    Icons.trending_up,
                    Colors.green);
              case 2:
                return _buildSummaryCard(
                    'Maksimum',
                    '₺${maxRevenue.toStringAsFixed(2)}',
                    Icons.bar_chart,
                    Colors.orange);
              case 3:
                return _buildSummaryCard(
                    'Minimum',
                    '₺${minRevenue.toStringAsFixed(2)}',
                    Icons.show_chart,
                    Colors.red);
              default:
                return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
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
            SizedBox(
              height: 200,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
