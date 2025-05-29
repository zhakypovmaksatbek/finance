import 'package:finance/presentation/core/constants/expense_category.dart';
import 'package:finance/presentation/core/models/expense_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CategoryChartPage extends StatelessWidget {
  final Box<Expense> expenseBox = Hive.box<Expense>("expenses");

  CategoryChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = expenseBox.values.toList();
    final Map<String, double> categoryTotals = {};

    for (var e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }

    final total = categoryTotals.values.fold(0.0, (sum, val) => sum + val);

    final sections = categoryTotals.entries.map((entry) {
      final category = ExpenseCategory.values.firstWhere(
        (e) => e.title == entry.key,
        orElse: () => ExpenseCategory.other,
      );
      final percent = entry.value / total * 100;

      return PieChartSectionData(
        value: entry.value,
        title: '${percent.toStringAsFixed(1)}%',
        color: category.color,
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Harcama Dağılımı')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: total == 0
            ? const Center(
                child: Text(
                  'Grafiği görebilmek için harcama ekleyin.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Kategori Bazlı Harcama Dağılımı',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 4,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const Text(
                    'Detaylar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      itemCount: categoryTotals.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final entry = categoryTotals.entries.elementAt(index);
                        final category = ExpenseCategory.values.firstWhere(
                          (e) => e.title == entry.key,
                          orElse: () => ExpenseCategory.other,
                        );

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: category.color,
                            child: Icon(
                              Icons.label,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            category.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: Text(
                            '${entry.value.toStringAsFixed(2)} KGS',
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
