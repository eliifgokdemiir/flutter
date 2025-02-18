import 'package:flutter/material.dart';
import 'package:state_management/data/entity/branch.dart';

class Branches extends StatelessWidget {
  final Branch branch;

  const Branches({super.key, required this.branch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(branch.name),
        backgroundColor: Colors.white12,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
                'Günlük Ciro', '₺${(branch.turnover / 30).toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            _buildInfoCard('Saatlik Ortalama',
                '₺${(branch.turnover / 30 / 24).toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            _buildInfoCard('Haftalık Ciro',
                '₺${(branch.turnover / 4).toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            _buildInfoCard(
                'Aylık Ciro', '₺${branch.turnover.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
