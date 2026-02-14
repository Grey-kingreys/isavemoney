import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'utils/app_colors.dart';
import 'services/database_service.dart';


void main() async {
  // Initialisation de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de la base de données
  try {
    final dbService = DatabaseService();
    await dbService.database; // Force l'initialisation de la DB
    debugPrint('✅ Base de données initialisée avec succès');
  } catch (e) {
    debugPrint('❌ Erreur lors de l\'initialisation de la base de données: $e');
  }

  // Configuration de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Configuration de l'orientation (portrait uniquement)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Lancement de l'application avec les providers
  runApp(const BudgetBuddyApp());
}
