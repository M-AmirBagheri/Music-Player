import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../widgets/theme_provider.dart';  // اطمینان از وارد کردن فایل ThemeProvider
import 'pages/home/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(ThemeData.dark())..loadTheme(),  // بارگذاری تم ذخیره‌شده
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // اعمال تم در سطح اپلیکیشن
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'HICH Music',
          theme: themeProvider.themeData,  // استفاده از تم انتخابی
          home: const HomePage(),
        );
      },
    );
  }
}
