import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';

/// Page de statistiques (PLACEHOLDER - ÉTAPE 4)
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistiques'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Graphiques'),
            Tab(text: 'Rapports'),
            Tab(text: 'Analyse'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGraphicsTab(),
          _buildReportsTab(),
          _buildAnalysisTab(),
        ],
      ),
    );
  }

  Widget _buildGraphicsTab() {
    return _buildPlaceholder(
      icon: '📊',
      title: 'Graphiques',
      description:
          'Visualisez vos dépenses et revenus\nsous forme de graphiques',
    );
  }

  Widget _buildReportsTab() {
    return _buildPlaceholder(
      icon: '📄',
      title: 'Rapports',
      description: 'Générez des rapports mensuels\net annuels détaillés',
    );
  }

  Widget _buildAnalysisTab() {
    return _buildPlaceholder(
      icon: '🔍',
      title: 'Analyse',
      description:
          'Analysez vos habitudes de dépenses\net obtenez des recommandations',
    );
  }

  Widget _buildPlaceholder({
    required String icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: AppDimensions.paddingPage,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 60)),
              ),
            ),
            AppDimensions.verticalSpace(AppDimensions.space24),
            Text(
              title,
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            AppDimensions.verticalSpace(AppDimensions.space16),
            Text(
              description,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            AppDimensions.verticalSpace(AppDimensions.space16),
            Container(
              padding: AppDimensions.paddingMD,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: AppDimensions.borderRadiusMD,
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.construction,
                    color: AppColors.warning,
                    size: AppDimensions.iconSM,
                  ),
                  AppDimensions.horizontalSpace(AppDimensions.space8),
                  Text(
                    'Disponible à l\'ÉTAPE 4',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
