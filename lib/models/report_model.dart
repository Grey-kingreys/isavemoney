import 'dart:convert';

/// Modèle de rapport
class ReportModel {
  final int? id;
  final String reportType; // 'monthly', 'yearly', 'custom'
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final Map<String, dynamic>? reportData;
  final DateTime generatedAt;
  final bool isFavorite;

  ReportModel({
    this.id,
    required this.reportType,
    required this.periodStart,
    required this.periodEnd,
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.netBalance = 0.0,
    this.reportData,
    DateTime? generatedAt,
    this.isFavorite = false,
  }) : generatedAt = generatedAt ?? DateTime.now();

  /// Crée un rapport depuis une Map
  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] as int?,
      reportType: map['report_type'] as String,
      periodStart: DateTime.parse(map['period_start'] as String),
      periodEnd: DateTime.parse(map['period_end'] as String),
      totalIncome: (map['total_income'] as num).toDouble(),
      totalExpense: (map['total_expense'] as num).toDouble(),
      netBalance: (map['net_balance'] as num).toDouble(),
      reportData: map['report_data'] != null
          ? jsonDecode(map['report_data'] as String)
          : null,
      generatedAt: DateTime.parse(map['generated_at'] as String),
      isFavorite: (map['is_favorite'] as int) == 1,
    );
  }

  /// Convertit le rapport en Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'report_type': reportType,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'net_balance': netBalance,
      'report_data': reportData != null ? jsonEncode(reportData) : null,
      'generated_at': generatedAt.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  /// Copie le rapport avec de nouvelles valeurs
  ReportModel copyWith({
    int? id,
    String? reportType,
    DateTime? periodStart,
    DateTime? periodEnd,
    double? totalIncome,
    double? totalExpense,
    double? netBalance,
    Map<String, dynamic>? reportData,
    DateTime? generatedAt,
    bool? isFavorite,
  }) {
    return ReportModel(
      id: id ?? this.id,
      reportType: reportType ?? this.reportType,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      netBalance: netBalance ?? this.netBalance,
      reportData: reportData ?? this.reportData,
      generatedAt: generatedAt ?? this.generatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Calcule le taux d'épargne
  double get savingsRate {
    if (totalIncome == 0) return 0;
    return (netBalance / totalIncome) * 100;
  }

  /// Vérifie si le solde est positif
  bool get isPositiveBalance => netBalance > 0;

  /// Obtient le nom du type de rapport
  String get reportTypeName {
    switch (reportType) {
      case 'monthly':
        return 'Rapport mensuel';
      case 'yearly':
        return 'Rapport annuel';
      case 'custom':
        return 'Rapport personnalisé';
      default:
        return reportType;
    }
  }

  @override
  String toString() {
    return 'ReportModel(id: $id, type: $reportType, balance: $netBalance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReportModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
