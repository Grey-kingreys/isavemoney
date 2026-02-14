import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/empty_view.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final provider = context.read<CategoryProvider>();
    await provider.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingView(
              message: 'Chargement des catégories...',
              fullScreen: false,
            );
          }

          if (provider.error != null) {
            return ErrorView.loading(
              message: provider.error,
              onRetry: _loadCategories,
              fullScreen: false,
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryList(provider, 'expense'),
              _buildCategoryList(provider, 'income'),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      title: const Text('Catégories'),
      elevation: 0,
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.white,
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.white.withOpacity(0.7),
        tabs: const [
          Tab(text: 'Dépenses'),
          Tab(text: 'Revenus'),
        ],
      ),
    );
  }

  Widget _buildCategoryList(CategoryProvider provider, String type) {
    final categories = provider.categories
        .where((cat) => cat.type == type)
        .toList();

    if (categories.isEmpty) {
      return EmptyView.noCategories(
        onAction: _showAddCategoryDialog,
        fullScreen: false,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: ListView.builder(
        padding: AppDimensions.paddingPage,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppDimensions.space12),
            elevation: AppDimensions.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.borderRadiusCard,
            ),
            child: ListTile(
              contentPadding: AppDimensions.paddingCard,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(category.color ?? AppColors.primary.value)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSM),
                ),
                child: Icon(
                  IconData(
                    category.icon ?? Icons.category.codePoint,
                    fontFamily: 'MaterialIcons',
                  ),
                  color: Color(category.color ?? AppColors.primary.value),
                ),
              ),
              title: Text(
                category.name,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.textSecondary),
                    onPressed: () => _showEditCategoryDialog(category.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => _showDeleteConfirmation(category.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une catégorie'),
        content: const Text('Fonctionnalité à venir'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la catégorie'),
        content: const Text('Fonctionnalité à venir'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous vraiment supprimer cette catégorie ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implémenter la suppression
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}