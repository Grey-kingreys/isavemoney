import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/report_model.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart' as app_date_utils;
import 'database_service.dart';
import 'transaction_service.dart';

/// Service de génération et gestion des rapports
class ReportService {
  final DatabaseService _dbService = DatabaseService();
  final TransactionService _transactionService = TransactionService();

  /// Génère un rapport mensuel
  Future<ReportModel> generateMonthlyReport(DateTime month) async {
    final startDate = app_date_utils.DateUtils.getMonthStart(month);
    final endDate = app_date_utils.DateUtils.getMonthEnd(month);

    return await _generateReport('monthly', startDate, endDate);
  }

  /// Génère un rapport annuel
  Future<ReportModel> generateYearlyReport(DateTime year) async {
    final startDate = app_date_utils.DateUtils.getYearStart(year);
    final endDate = app_date_utils.DateUtils.getYearEnd(year);

    return await _generateReport('yearly', startDate, endDate);
  }

  /// Génère un rapport personnalisé
  Future<ReportModel> generateCustomReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _generateReport('custom', startDate, endDate);
  }

  /// Génère un rapport pour une période donnée
  Future<ReportModel> _generateReport(
    String reportType,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final totalIncome = await _transactionService.getIncomeByPeriod(
      startDate,
      endDate,
    );
    final totalExpense = await _transactionService.getExpenseByPeriod(
      startDate,
      endDate,
    );
    final netBalance = totalIncome - totalExpense;

    // Récupère les détails du rapport
    final reportData = await _generateReportData(startDate, endDate);

    final report = ReportModel(
      reportType: reportType,
      periodStart: startDate,
      periodEnd: endDate,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netBalance: netBalance,
      reportData: reportData,
    );

    // Sauvegarde le rapport
    final db = await _dbService.database;
    final id = await db.insert(AppConstants.tableReports, report.toMap());

    return report.copyWith(id: id);
  }

  /// Génère les données détaillées du rapport
  Future<Map<String, dynamic>> _generateReportData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbService.database;

    // Statistiques par catégorie
    final categoryStats = await db.rawQuery(
      '''
      SELECT 
        c.id,
        c.name,
        c.icon,
        c.color,
        c.category_type,
        COUNT(t.id) as transaction_count,
        SUM(t.amount) as total_amount,
        AVG(t.amount) as average_amount
      FROM ${AppConstants.tableCategories} c
      LEFT JOIN ${AppConstants.tableTransactions} t 
        ON c.id = t.category_id 
        AND t.date BETWEEN ? AND ?
      GROUP BY c.id
      HAVING total_amount > 0
      ORDER BY total_amount DESC
    ''',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    // Statistiques par jour
    final dailyStats = await db.rawQuery(
      '''
      SELECT 
        DATE(date) as day,
        SUM(CASE WHEN transaction_type = 'income' THEN amount ELSE 0 END) as income,
        SUM(CASE WHEN transaction_type = 'expense' THEN amount ELSE 0 END) as expense
      FROM ${AppConstants.tableTransactions}
      WHERE date BETWEEN ? AND ?
      GROUP BY DATE(date)
      ORDER BY day ASC
    ''',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    // Top 5 des dépenses
    final topExpenses = await db.rawQuery(
      '''
      SELECT *
      FROM ${AppConstants.tableTransactions}
      WHERE transaction_type = 'expense'
        AND date BETWEEN ? AND ?
      ORDER BY amount DESC
      LIMIT 5
    ''',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return {
      'category_statistics': categoryStats,
      'daily_statistics': dailyStats,
      'top_expenses': topExpenses,
      'period_days': app_date_utils.DateUtils.getDaysCount(startDate, endDate),
    };
  }

  /// Récupère tous les rapports
  Future<List<ReportModel>> getAllReports() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableReports,
      orderBy: 'generated_at DESC',
    );

    return maps.map((map) => ReportModel.fromMap(map)).toList();
  }

  /// Récupère un rapport par ID
  Future<ReportModel?> getReportById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableReports,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return ReportModel.fromMap(maps.first);
  }

  /// Récupère les rapports favoris
  Future<List<ReportModel>> getFavoriteReports() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableReports,
      where: 'is_favorite = 1',
      orderBy: 'generated_at DESC',
    );

    return maps.map((map) => ReportModel.fromMap(map)).toList();
  }

  /// Marque un rapport comme favori
  Future<int> toggleFavorite(int id, bool isFavorite) async {
    final db = await _dbService.database;
    return await db.update(
      AppConstants.tableReports,
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Supprime un rapport
  Future<int> deleteReport(int id) async {
    final db = await _dbService.database;
    return await db.delete(
      AppConstants.tableReports,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Exporte un rapport au format CSV
  Future<String> exportReportToCSV(ReportModel report) async {
    final buffer = StringBuffer();

    // En-tête
    buffer.writeln('Rapport ${report.reportTypeName}');
    buffer.writeln(
      'Période: ${app_date_utils.DateUtils.formatShortDate(report.periodStart)} - ${app_date_utils.DateUtils.formatShortDate(report.periodEnd)}',
    );
    buffer.writeln(
      'Généré le: ${app_date_utils.DateUtils.formatFullDate(report.generatedAt)}',
    );
    buffer.writeln();

    // Résumé
    buffer.writeln('Résumé');
    buffer.writeln('Revenus,Dépenses,Solde');
    buffer.writeln(
      '${report.totalIncome},${report.totalExpense},${report.netBalance}',
    );
    buffer.writeln();

    // Détails par catégorie
    if (report.reportData != null &&
        report.reportData!.containsKey('category_statistics')) {
      buffer.writeln('Détails par catégorie');
      buffer.writeln(
        'Catégorie,Type,Nombre de transactions,Montant total,Montant moyen',
      );

      final categoryStats = report.reportData!['category_statistics'] as List;
      for (final stat in categoryStats) {
        buffer.writeln(
          '${stat['name']},${stat['category_type']},${stat['transaction_count']},${stat['total_amount']},${stat['average_amount']}',
        );
      }
    }

    return buffer.toString();
  }

  /// Génère un résumé rapide
  Future<Map<String, dynamic>> generateQuickSummary() async {
    final now = DateTime.now();

    // Mois en cours
    final monthStart = app_date_utils.DateUtils.getMonthStart(now);
    final monthEnd = app_date_utils.DateUtils.getMonthEnd(now);
    final monthIncome = await _transactionService.getIncomeByPeriod(
      monthStart,
      monthEnd,
    );
    final monthExpense = await _transactionService.getExpenseByPeriod(
      monthStart,
      monthEnd,
    );

    // Année en cours
    final yearStart = app_date_utils.DateUtils.getYearStart(now);
    final yearEnd = app_date_utils.DateUtils.getYearEnd(now);
    final yearIncome = await _transactionService.getIncomeByPeriod(
      yearStart,
      yearEnd,
    );
    final yearExpense = await _transactionService.getExpenseByPeriod(
      yearStart,
      yearEnd,
    );

    return {
      'current_month': {
        'income': monthIncome,
        'expense': monthExpense,
        'balance': monthIncome - monthExpense,
      },
      'current_year': {
        'income': yearIncome,
        'expense': yearExpense,
        'balance': yearIncome - yearExpense,
      },
    };
  }
}
