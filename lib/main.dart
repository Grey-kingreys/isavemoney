import 'package:flutter/material.dart';
import 'package:isavemoney/app/app.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser la base de données
  final dbService = DatabaseService();
  await dbService.database;

  runApp(const BudgetBuddyApp());
}

