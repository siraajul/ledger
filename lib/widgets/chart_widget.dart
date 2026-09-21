import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class ChartWidget extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const ChartWidget({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BREAKDOWN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: Colors.grey[400],
                ),
              ),
              Text(
                NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(total),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: PieChart(
                    PieChartData(
                      sections: _buildSections(total),
                      centerSpaceRadius: 30,
                      sectionsSpace: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: sortedEntries.take(4).map((entry) {
                      final category = categories.firstWhere(
                        (c) => c.name == entry.key,
                        orElse: () => const ExpenseCategory(name: 'Other', icon: '📦', color: 0xFFA8D8EA),
                      );
                      final pct = (entry.value / total * 100).toStringAsFixed(0);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Color(category.color),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Text(
                              '$pct%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(double total) {
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.map((entry) {
      final category = categories.firstWhere(
        (c) => c.name == entry.key,
        orElse: () => const ExpenseCategory(name: 'Other', icon: '📦', color: 0xFFA8D8EA),
      );

      return PieChartSectionData(
        color: Color(category.color),
        value: entry.value,
        radius: 14,
        title: '',
      );
    }).toList();
  }
}
