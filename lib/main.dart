import 'package:flutter/material.dart';
import 'package:seprec/page_menu.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';

// Nueva paleta
class AppColors {
  static const background = Color.fromARGB(255, 45, 49, 31);
  static const panel = Color(0xFF080D1C);
  static const card = Color(0xFF45F59D);
  static const cardBorder = Color(0xFF4A7A66);
  static const textPrimary = Color(0xFF1F2B31);
  static const textSecondary = Color(0xFFD0E3DA);
  static const icon = Color(0xFF13D8D8);
  static const header = Color(0xFFD0E3DA);
  static const appBarBackground = Color(0xFF061523);
  static const appBarForeground = Colors.white;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF061A2B),
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF1F2B31),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SEPREC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Solo cambio de colores
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.panel,
          brightness: Brightness.dark,
          primary: AppColors.panel,
          secondary: AppColors.card,
          surface: AppColors.panel,
          background: AppColors.background,
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: AppColors.textPrimary,
          onSurface: Colors.white,
          onBackground: Colors.white,
          onError: Colors.white,
        ),

        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF50E4D6),
          selectionColor: Color(0x6650E4D6),
          selectionHandleColor: Color(0xFF50E4D6),
        ),

        // Tipografía
        textTheme: TextTheme(
          displayLarge: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
          bodyLarge: TextStyle(fontSize: 16.0, color: AppColors.textSecondary),
          labelLarge: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            backgroundColor: AppColors.header,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.appBarBackground,
          foregroundColor: AppColors.appBarForeground,
          centerTitle: true,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.appBarForeground),
        ),
        useMaterial3: true,
      ),
      home: PageMenu(),
    );
  }
}
