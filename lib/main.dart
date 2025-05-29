import 'package:finance/presentation/core/models/expense_model.dart';
import 'package:finance/presentation/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseAdapter());
  await Hive.openBox<Expense>('expenses');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance',
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      home: HomePage(),
    );
  }
}
