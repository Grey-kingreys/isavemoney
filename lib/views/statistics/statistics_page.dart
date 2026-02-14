import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/empty_view.dart';

class StatisticsPage extends StatefulWidget {
  final bool showAppBar;

  const StatisticsPage({super.key, this.showAppBar = true});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String _selectedPeriod = 'month';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStatistics();
    });
  }

  Future<void> _loadStatistics() async {
    final provider = context.read<DashboardProvider>();
    await provider.loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.showAppBar ? _buildAppBar() : null,
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingView(
              message: 'Chargement des statistiques...',
              fullScreen: false,
            );
          }

          if (provider.error != null) {
            return ErrorView.loading(
              message: provider.error,
              onRetry: _loadStatistics,
              fullScreen: false,
            );
          }

          return _buildStatisticsContent(provider);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      title: const Text('Statistiques'),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.file_download),
          onPressed: _exportData,
          tooltip: 'Exporter en CSV',
        ),
      ],
    );
  }

  Widget _buildStatisticsContent(DashboardProvider provider) {
    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: SingleChildScrollView(
        padding: AppDimensions.paddingPage,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sélecteur de période
            _buildPeriodSelector(),

            AppDimensions.verticalSpace(AppDimensions.space24),

            // Résumé financier
            _buildFinancialSummary(provider),

            AppDimensions.verticalSpace(AppDimensions.space24),

            // Graphique circulaire (placeholder)
            _buildPieChartPlaceholder(),

            AppDimensions.verticalSpace(AppDimensions.space24),

            // Graphique linéaire (placeholder)
            _buildLineChartPlaceholder(),

            AppDimensions.verticalSpace(AppDimensions.space24),

            // Top catégories de dépenses
            _buildTopCategories(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMD),
      ),
      child: Row(
        children: [
          _buildPeriodButton('Semaine', 'week'),
          _buildPeriodButton('Mois', 'month'),
          _buildPeriodButton('Année', 'year'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = value;
          });
          _loadStatistics();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.space12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSM),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? AppColors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(DashboardProvider provider) {
    final summary = provider.summary;
    if (summary == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Revenus',
            summary.totalIncome,
            AppColors.success,
            Icons.arrow_upward,
          ),
        ),
        AppDimensions.horizontalSpace(AppDimensions.space12),
        Expanded(
          child: _buildSummaryCard(
            'Dépenses',
            summary.totalExpenses,
            AppColors.error,
            Icons.arrow_downward,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: Padding(
        padding: AppDimensions.paddingCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: AppDimensions.iconMD),
                AppDimensions.horizontalSpace(AppDimensions.space8),
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            AppDimensions.verticalSpace(AppDimensions.space8),
            Text(
              '${amount.toStringAsFixed(0)} FCFA',
              style: AppTextStyles.headlineSmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartPlaceholder() {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: Padding(
        padding: AppDimensions.paddingCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition des dépenses',
              style: AppTextStyles.headlineSmall,
            ),
            AppDimensions.verticalSpace(AppDimensions.space16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusMD,
                ),
              ),
              child: const Center(
                child: Text('Graphique circulaire (à implémenter)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChartPlaceholder() {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: Padding(
        padding: AppDimensions.paddingCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Évolution temporelle', style: AppTextStyles.headlineSmall),
            AppDimensions.verticalSpace(AppDimensions.space16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusMD,
                ),
              ),
              child: const Center(
                child: Text('Graphique linéaire (à implémenter)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCategories(DashboardProvider provider) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusCard,
      ),
      child: Padding(
        padding: AppDimensions.paddingCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top catégories', style: AppTextStyles.headlineSmall),
            AppDimensions.verticalSpace(AppDimensions.space16),
            const Text('Liste des catégories (à implémenter)'),
          ],
        ),
      ),
    );
  }

  void _exportData() {
    // TODO: Implémenter l'export CSV
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export CSV - Fonctionnalité à venir')),
    );
  }
}
