import 'package:flutter/material.dart';

enum ExpenseCategory { food, transport, rent, entertainment, other }

extension ExpenseCategoryExtension on ExpenseCategory {
  String get title {
    switch (this) {
      case ExpenseCategory.food:
        return 'Gıda';
      case ExpenseCategory.transport:
        return 'Ulaşım';
      case ExpenseCategory.rent:
        return 'Kira';
      case ExpenseCategory.entertainment:
        return 'Eğlence';
      case ExpenseCategory.other:
        return 'Diğer';
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return Colors.green;
      case ExpenseCategory.transport:
        return Colors.orange;
      case ExpenseCategory.rent:
        return Colors.red;
      case ExpenseCategory.entertainment:
        return Colors.blue;
      case ExpenseCategory.other:
        return Colors.purple;
    }
  }

  static ExpenseCategory fromTitle(String title) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.title == title,
      orElse: () => ExpenseCategory.other,
    );
  }
}
