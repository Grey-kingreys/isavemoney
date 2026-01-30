import 'package:flutter/material.dart';

/// Modèle de compte bancaire
class AccountModel {
  final int? id;
  final String name;
  final String
  accountType; // 'cash', 'bank', 'credit_card', 'savings', 'investment'
  final double initialBalance;
  final double currentBalance;
  final String currency;
  final bool isActive;
  final String? color;
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  AccountModel({
    this.id,
    required this.name,
    required this.accountType,
    this.initialBalance = 0.0,
    this.currentBalance = 0.0,
    this.currency = 'EUR',
    this.isActive = true,
    this.color,
    this.icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Crée un compte depuis une Map
  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      accountType: map['account_type'] as String,
      initialBalance: (map['initial_balance'] as num).toDouble(),
      currentBalance: (map['current_balance'] as num).toDouble(),
      currency: map['currency'] as String,
      isActive: (map['is_active'] as int) == 1,
      color: map['color'] as String?,
      icon: map['icon'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Convertit le compte en Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'account_type': accountType,
      'initial_balance': initialBalance,
      'current_balance': currentBalance,
      'currency': currency,
      'is_active': isActive ? 1 : 0,
      'color': color,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copie le compte avec de nouvelles valeurs
  AccountModel copyWith({
    int? id,
    String? name,
    String? accountType,
    double? initialBalance,
    double? currentBalance,
    String? currency,
    bool? isActive,
    String? color,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Obtient la couleur en tant que Color
  Color getColor() {
    if (color == null) return Colors.blue;
    try {
      final hex = color!.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  /// Calcule la variation par rapport au solde initial
  double get balanceChange {
    return currentBalance - initialBalance;
  }

  /// Obtient le pourcentage de variation
  double get balanceChangePercentage {
    if (initialBalance == 0) return 0;
    return (balanceChange / initialBalance) * 100;
  }

  /// Obtient le nom du type de compte
  String get accountTypeName {
    switch (accountType) {
      case 'cash':
        return 'Espèces';
      case 'bank':
        return 'Compte bancaire';
      case 'credit_card':
        return 'Carte de crédit';
      case 'savings':
        return 'Épargne';
      case 'investment':
        return 'Investissement';
      default:
        return accountType;
    }
  }

  /// Obtient l'icône par défaut selon le type
  IconData get defaultIcon {
    switch (accountType) {
      case 'cash':
        return Icons.account_balance_wallet;
      case 'bank':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      case 'savings':
        return Icons.savings;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.account_balance;
    }
  }

  @override
  String toString() {
    return 'AccountModel(id: $id, name: $name, balance: $currentBalance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AccountModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
