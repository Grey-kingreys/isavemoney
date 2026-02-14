import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../app/routes.dart';
import '../../widgets/app_drawer.dart';
import '../../views/dashboard/dashboard_page.dart';
import '../../views/transactions/transaction_list.dart';
import '../../views/budgets/budget_list.dart';
import '../../views/statistics/statistics_page.dart';
import '../../views/settings/settings_page.dart';

/// Scaffold principal avec Bottom Navigation Bar
class MainScaffold extends StatefulWidget {
  final int initialIndex;

  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // Liste des pages (sans Scaffold)
  final List<Widget> _pages = [
    const DashboardPage(),
    const TransactionList(),
    const BudgetList(),
    const StatisticsPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      drawer: _shouldShowDrawer() ? const AppDrawer() : null,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    switch (_currentIndex) {
      case 0: // Dashboard
        return AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tableau de Bord',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Bonjour! 👋',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // TODO: Afficher les notifications
              },
            ),
          ],
        );

      case 1: // Transactions
        return AppBar(
          title: const Text('Transactions'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Recherche
              },
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // TODO: Filtres
              },
            ),
          ],
        );

      case 2: // Budgets
        return AppBar(
          title: const Text('Budgets'),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                // TODO: Info budgets
              },
            ),
          ],
        );

      case 3: // Statistiques
        return AppBar(title: const Text('Statistiques'));

      case 4: // Paramètres
        return AppBar(title: const Text('Paramètres'));

      default:
        return AppBar(title: const Text('BudgetBuddy'));
    }
  }

  bool _shouldShowDrawer() {
    // Afficher le drawer sur toutes les pages
    return true;
  }

  Widget? _buildFAB() {
    switch (_currentIndex) {
      case 0: // Dashboard
        return FloatingActionButton.extended(
          onPressed: () {
            AppRoutes.navigateTo(context, AppRoutes.transactionAdd);
          },
          icon: const Icon(Icons.add),
          label: const Text('Nouvelle transaction'),
          backgroundColor: AppColors.primary,
        );

      case 1: // Transactions
        return FloatingActionButton(
          onPressed: () {
            AppRoutes.navigateTo(context, AppRoutes.transactionAdd);
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add),
        );

      case 2: // Budgets
        return FloatingActionButton.extended(
          onPressed: () {
            AppRoutes.navigateTo(context, AppRoutes.budgetAdd);
          },
          backgroundColor: AppColors.budget,
          icon: const Icon(Icons.add),
          label: const Text('Créer un budget'),
        );

      default:
        return null;
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.labelSmall,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            activeIcon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Budgets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}
