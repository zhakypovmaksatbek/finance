import 'package:finance/presentation/core/constants/expense_category.dart';
import 'package:finance/presentation/core/constants/expense_filter.dart';
import 'package:finance/presentation/pages/category_chart_page.dart';
import 'package:finance/presentation/pages/home/add_expense_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../core/models/expense_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Box<Expense> expenseBox = Hive.box<Expense>("expenses");

  ExpenseFilter _selectedFilter = ExpenseFilter.thisMonth;
  DateTimeRange? _customRange;

  bool _isExpenseInSelectedRange(Expense expense) {
    final now = DateTime.now();

    switch (_selectedFilter) {
      case ExpenseFilter.today:
        return DateUtils.isSameDay(expense.date, now);
      case ExpenseFilter.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return expense.date.isAfter(
              startOfWeek.subtract(const Duration(days: 1)),
            ) &&
            expense.date.isBefore(endOfWeek.add(const Duration(days: 1)));
      case ExpenseFilter.thisMonth:
        return expense.date.year == now.year && expense.date.month == now.month;
      case ExpenseFilter.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1);
        return expense.date.year == lastMonth.year &&
            expense.date.month == lastMonth.month;
      case ExpenseFilter.thisYear:
        return expense.date.year == now.year;
      case ExpenseFilter.custom:
        if (_customRange == null) return false;
        return expense.date.isAfter(
              _customRange!.start.subtract(const Duration(days: 1)),
            ) &&
            expense.date.isBefore(
              _customRange!.end.add(const Duration(days: 1)),
            );
    }
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<ExpenseFilter>(
              value: _selectedFilter,
              onChanged: (filter) async {
                if (filter == ExpenseFilter.custom) {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _customRange = picked;
                      _selectedFilter = filter!;
                    });
                  }
                } else {
                  setState(() {
                    _selectedFilter = filter!;
                  });
                }
              },
              items: ExpenseFilter.values.map((filter) {
                return DropdownMenuItem(
                  value: filter,
                  child: Text(_getFilterLabel(filter)),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Filtrele',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel(ExpenseFilter filter) {
    switch (filter) {
      case ExpenseFilter.today:
        return 'Bugün';
      case ExpenseFilter.thisWeek:
        return 'Bu Hafta';
      case ExpenseFilter.thisMonth:
        return 'Bu Ay';
      case ExpenseFilter.lastMonth:
        return 'Geçen Ay';
      case ExpenseFilter.thisYear:
        return 'Bu Yıl';
      case ExpenseFilter.custom:
        return 'Tarih Aralığı';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CategoryChartPage()),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: expenseBox.listenable(),
        builder: (context, Box<Expense> box, _) {
          final expenses = box.values
              .where((e) => _isExpenseInSelectedRange(e))
              .toList()
              .cast<Expense>();

          final total = expenses.fold(0.0, (sum, e) => sum + e.amount);

          return Column(
            children: [
              _buildFilterDropdown(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.indigo.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 40,
                          color: Colors.indigo,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Toplam Harcama',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${total.toStringAsFixed(2)} KGS',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: expenses.isEmpty
                    ? const Center(
                        child: Text(
                          'Harcamalar bulunamadı...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: expenses.length,
                        separatorBuilder: (_, __) => const Divider(height: 8),
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: ExpenseCategory.values
                                  .firstWhere(
                                    (e) => e.title == expense.category,
                                  )
                                  .color,
                              child: const Icon(
                                Icons.category,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              '${expense.category} - ${expense.amount.toStringAsFixed(2)} KGS',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${expense.description} • ${DateFormat.yMMMd().format(expense.date)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text(
                                      'Silmek istediğinize emin misiniz?',
                                    ),
                                    content: const Text(
                                      'Bu işlem geri alınamaz.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context), // Vazgeç
                                        child: const Text('İptal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          expense.delete(); // Silme işlemi
                                          Navigator.pop(
                                            context,
                                          ); // Dialog'u kapat
                                        },
                                        child: const Text(
                                          'Sil',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddExpensePage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Ekle'),
      ),
    );
  }
}
