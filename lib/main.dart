import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const MilkPleaseApp());
}

class MilkPleaseApp extends StatelessWidget {
  const MilkPleaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MilkPlease',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
