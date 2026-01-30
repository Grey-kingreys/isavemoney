import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';
import '../utils/date_utils.dart' as app_date_utils;

/// Controller pour la gestion des rapports
class ReportController {
  final ReportService _reportService = ReportService();

  // Données
  List<ReportModel> _reports = [];
  ReportModel? _currentReport;
  bool _isLoading = false;
  String? _error;

  // Période sélectionnée
  String _reportType = 'monthly';
  DateTime _selectedPeriod = DateTime.now();
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  /// Getters
  List<ReportModel> get reports => _reports;
  ReportModel? get currentReport => _currentReport;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get reportType => _reportType;
  DateTime get selectedPeriod => _selectedPeriod;

  /// Charge tous les rapports
  Future<void> loadReports() async {
    _setLoading(true);
    _error = null;

    try {
      _reports = await _reportService.getAllReports();
    } catch (e) {
      _error = 'Erreur lors du chargement des rapports: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Charge les rapports favoris
  Future<void> loadFavoriteReports() async {
    _setLoading(true);
    _error = null;

    try {
      _reports = await _reportService.getFavoriteReports();
    } catch (e) {
      _error = 'Erreur lors du chargement: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Génère un nouveau rapport
  Future<bool> generateReport() async {
    _setLoading(true);
    _error = null;

    try {
      ReportModel report;

      switch (_reportType) {
        case 'monthly':
          report = await _reportService.generateMonthlyReport(_selectedPeriod);
          break;
        case 'yearly':
          report = await _reportService.generateYearlyReport(_selectedPeriod);
          break;
        case 'custom':
          if (_customStartDate == null || _customEndDate == null) {
            _error = 'Veuillez définir les dates de début et de fin';
            return false;
          }
          report = await _reportService.generateCustomReport(
            _customStartDate!,
            _customEndDate!,
          );
          break;
        default:
          _error = 'Type de rapport non supporté';
          return false;
      }

      _currentReport = report;
      await loadReports();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la génération: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Charge un rapport spécifique
  Future<void> loadReport(int id) async {
    _setLoading(true);
    _error = null;

    try {
      _currentReport = await _reportService.getReportById(id);
    } catch (e) {
      _error = 'Erreur lors du chargement: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Supprime un rapport
  Future<bool> deleteReport(int id) async {
    try {
      await _reportService.deleteReport(id);
      await loadReports();
      if (_currentReport?.id == id) {
        _currentReport = null;
      }
      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      debugPrint(_error);
      return false;
    }
  }

  /// Bascule le statut favori
  Future<bool> toggleFavorite(int id, bool isFavorite) async {
    try {
      await _reportService.toggleFavorite(id, isFavorite);
      await loadReports();
      return true;
    } catch (e) {
      _error = 'Erreur: $e';
      debugPrint(_error);
      return false;
    }
  }

  /// Exporte un rapport en CSV
  Future<String?> exportReport(ReportModel report) async {
    try {
      return await _reportService.exportReportToCSV(report);
    } catch (e) {
      _error = 'Erreur lors de l\'export: $e';
      debugPrint(_error);
      return null;
    }
  }

  /// Génère un résumé rapide
  Future<Map<String, dynamic>?> generateQuickSummary() async {
    try {
      return await _reportService.generateQuickSummary();
    } catch (e) {
      _error = 'Erreur: $e';
      debugPrint(_error);
      return null;
    }
  }

  /// Change le type de rapport
  void setReportType(String type) {
    _reportType = type;
    if (type != 'custom') {
      _customStartDate = null;
      _customEndDate = null;
    }
  }

  /// Change la période sélectionnée
  void setPeriod(DateTime period) {
    _selectedPeriod = period;
  }

  /// Définit les dates personnalisées
  void setCustomDates(DateTime start, DateTime end) {
    _customStartDate = start;
    _customEndDate = end;
    _reportType = 'custom';
  }

  /// Passe au mois suivant
  void nextMonth() {
    _selectedPeriod = DateTime(_selectedPeriod.year, _selectedPeriod.month + 1);
  }

  /// Passe au mois précédent
  void previousMonth() {
    _selectedPeriod = DateTime(_selectedPeriod.year, _selectedPeriod.month - 1);
  }

  /// Passe à l'année suivante
  void nextYear() {
    _selectedPeriod = DateTime(_selectedPeriod.year + 1);
  }

  /// Passe à l'année précédente
  void previousYear() {
    _selectedPeriod = DateTime(_selectedPeriod.year - 1);
  }

  /// Obtient le titre de la période
  String getPeriodTitle() {
    switch (_reportType) {
      case 'monthly':
        return app_date_utils.DateUtils.formatMonthYear(_selectedPeriod);
      case 'yearly':
        return _selectedPeriod.year.toString();
      case 'custom':
        if (_customStartDate == null || _customEndDate == null) {
          return 'Période personnalisée';
        }
        return '${app_date_utils.DateUtils.formatShortDate(_customStartDate!)} - '
            '${app_date_utils.DateUtils.formatShortDate(_customEndDate!)}';
      default:
        return 'Rapport';
    }
  }

  /// Obtient les statistiques du rapport courant
  Map<String, dynamic>? getCurrentReportStats() {
    if (_currentReport == null) return null;

    return {
      'total_income': _currentReport!.totalIncome,
      'total_expense': _currentReport!.totalExpense,
      'net_balance': _currentReport!.netBalance,
      'savings_rate': _currentReport!.savingsRate,
      'is_positive': _currentReport!.isPositiveBalance,
    };
  }

  /// Obtient les données pour les graphiques
  List<Map<String, dynamic>>? getChartData() {
    if (_currentReport == null || _currentReport!.reportData == null) {
      return null;
    }

    final data = _currentReport!.reportData!;
    if (!data.containsKey('category_statistics')) return null;

    return List<Map<String, dynamic>>.from(data['category_statistics'] as List);
  }

  /// Obtient les dépenses principales
  List<Map<String, dynamic>>? getTopExpenses() {
    if (_currentReport == null || _currentReport!.reportData == null) {
      return null;
    }

    final data = _currentReport!.reportData!;
    if (!data.containsKey('top_expenses')) return null;

    return List<Map<String, dynamic>>.from(data['top_expenses'] as List);
  }

  /// Obtient les statistiques journalières
  List<Map<String, dynamic>>? getDailyStats() {
    if (_currentReport == null || _currentReport!.reportData == null) {
      return null;
    }

    final data = _currentReport!.reportData!;
    if (!data.containsKey('daily_statistics')) return null;

    return List<Map<String, dynamic>>.from(data['daily_statistics'] as List);
  }

  /// Vérifie si le rapport est vide
  bool isReportEmpty() {
    if (_currentReport == null) return true;
    return _currentReport!.totalIncome == 0 &&
        _currentReport!.totalExpense == 0;
  }

  /// Efface l'erreur
  void clearError() {
    _error = null;
  }

  /// Définit l'état de chargement
  void _setLoading(bool value) {
    _isLoading = value;
  }
}
