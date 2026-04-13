import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_colors.dart';

import 'screens/portfolio_home_page.dart';
import 'screens/project_details_page.dart';
import 'screens/admin_login_page.dart';
import 'screens/admin_dashboard_page.dart';
import 'screens/portfolio_technical_guide_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  } catch (e) {
    debugPrint("Environment initialization warning: $e");
  }
  
  runApp(const ArchitectPortfolioApp());
}

class ArchitectPortfolioApp extends StatelessWidget {
  const ArchitectPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Architect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.background,
          onSurface: AppColors.onSurface,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const PortfolioHomePage(),
        '/project': (context) => const ProjectDetailsPage(),
        '/login': (context) => const AdminLoginPage(),
        '/dashboard': (context) => const AdminDashboardPage(),
        '/prd': (context) => const PortfolioTechnicalGuidePage(),
      },
    );
  }
}
