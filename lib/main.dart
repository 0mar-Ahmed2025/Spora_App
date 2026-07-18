import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spora_app/core/network/api_helper.dart';
import 'package:spora_app/core/routing/app_router.dart';
import 'package:spora_app/core/theme/app_theme.dart';
import 'package:spora_app/core/theme/theme_cubit.dart';
import 'package:spora_app/core/theme/theme_helper.dart';
import 'package:spora_app/generated/codegen_loader.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await APIHelper.init();
  final ThemeMode savedTheme = await ThemeCacheHelper().getCachedThemeMode();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      assetLoader: const CodegenLoader(),
      child: MyApp(initialTheme: savedTheme),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeMode initialTheme;

  const MyApp({super.key, required this.initialTheme});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(initialTheme),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, currentThemeMode) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) {
              return MaterialApp.router(
                title: 'Spora App',
                debugShowCheckedModeBanner: false,
                routerConfig: AppRouter.router,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: currentThemeMode,
              );
            },
          );
        },
      ),
    );
  }
}
