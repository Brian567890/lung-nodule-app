import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/medical_theme.dart';
import 'screens/home_screen.dart';
import 'screens/patient_list_screen.dart';
import 'screens/patient_detail_screen.dart';
import 'screens/add_patient_screen.dart';
import 'screens/add_nodule_screen.dart';
import 'screens/add_follow_up_screen.dart';
import 'screens/follow_up_calendar_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/statistics_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const LungNoduleApp());
}

class LungNoduleApp extends StatelessWidget {
  const LungNoduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, child) {
          return MaterialApp(
            title: '肺结节随访管理',
            debugShowCheckedModeBanner: false,
            
            // 医疗专业主题
            theme: MedicalTheme.lightTheme,
            darkTheme: MedicalTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            
            // 国际化配置
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('zh', 'CN'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            
            // 路由配置
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              '/patients': (context) => const PatientListScreen(),
              '/patient_detail': (context) => const PatientDetailScreen(),
              '/add_patient': (context) => const AddPatientScreen(),
              '/add_nodule': (context) => const AddNoduleScreen(),
              '/calendar': (context) => const FollowUpCalendarScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/statistics': (context) => const StatisticsScreen(),
            },
          );
        },
      ),
    );
  }
}