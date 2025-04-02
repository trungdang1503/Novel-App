import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../ui/screens.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.orange,
      secondary: Colors.deepOrange,
      surface: Colors.black,
      surfaceTint: Colors.grey[200],
    );

    final themeData = ThemeData(
      fontFamily: 'Lato',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(
          fontFamily: 'Lato',
          color: Colors.white,
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedLabelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white,
        selectedIconTheme: IconThemeData(size: 32),
        unselectedIconTheme: IconThemeData(size: 32),
      ),

      splashFactory: InkRipple.splashFactory, // Giữ hiệu ứng nhấn nhẹ
      splashColor: Colors.transparent, // Xóa hiệu ứng lan rộng
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
      ),

      // Add a dialog theme definition to ThemeData
      dialogTheme: DialogTheme(
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
        ),
      ),
    );

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => AuthManager(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => NovelManager(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => ChapterManager(),
          )
        ],
        child: Consumer<AuthManager>(builder: (ctx, authManager, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Novel App',
            theme: themeData,
            home: authManager.isAuth
                ? SafeArea(child: Home())
                : FutureBuilder(
                    future: authManager.tryAutoLogin(),
                    builder: (ctx, snapshot) {
                      return snapshot.connectionState == ConnectionState.waiting
                          ? const SafeArea(child: SplashScreen())
                          : const SafeArea(child: AuthScreen());
                    },
                  ),
            routes: {
              Search.routeName: (ctx) => SafeArea(
                    child: Search(),
                  ),
              Write.routeName: (ctx) => SafeArea(
                    child: Write(),
                  ),
              Library.routeName: (ctx) => SafeArea(
                    child: Library(),
                  ),
              Profile.routeName: (ctx) => SafeArea(
                    child: Profile(),
                  ),
            },
            onGenerateRoute: (settings) {
              if (settings.name == NovelDetail.routeName) {
                final novelId = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (ctx) {
                    return SafeArea(
                      child: NovelDetail(
                        ctx.read<NovelManager>().findById(novelId)!,
                      ),
                    );
                  },
                );
              }

              if (settings.name == EditNovelScreen.routeName) {
                final novelId = settings.arguments as String?;
                return MaterialPageRoute(builder: (ctx) {
                  return SafeArea(
                    child: EditNovelScreen(
                      novelId != null
                          ? ctx.read<NovelManager>().findById(novelId)
                          : null,
                    ),
                  );
                });
              }

              return null;
            },
          );
        }));
  }
}
