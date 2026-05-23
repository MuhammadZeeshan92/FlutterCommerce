import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'core/services/api_service.dart';

void main() {
  ApiService.setupInterceptor();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const LoginScreen(),

        // ── Global Theme ──
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0A0A0F),
          primaryColor: const Color(0xFFD4AF37),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD4AF37),
            secondary: Color(0xFFB8860B),
            surface: Color(0xFF13131F),
            error: Colors.redAccent,
          ),

          // Ripple / splash color
          splashColor: const Color(0xFFD4AF37).withOpacity(0.08),
          highlightColor: const Color(0xFFD4AF37).withOpacity(0.05),

          // AppBar (fallback, all screens use custom bars)
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0D0D18),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            iconTheme: IconThemeData(color: Color(0xFFD4AF37)),
          ),

          // Cards
          cardColor: const Color(0xFF13131F),

          // Dividers
          dividerColor: const Color(0xFF2A2A3E),
          dividerTheme: const DividerThemeData(
            color: Color(0xFF2A2A3E),
            thickness: 1,
            space: 1,
          ),

          // Text fields (fallback)
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF13131F),
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF2A2A3E)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF2A2A3E)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                  color: Color(0xFFD4AF37), width: 1.5),
            ),
          ),

          // Elevated buttons (fallback)
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF0A0A0F),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),

          // Text buttons
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFD4AF37),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Bottom nav (fallback)
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF0D0D18),
            selectedItemColor: Color(0xFFD4AF37),
            unselectedItemColor: Colors.white38,
            elevation: 0,
          ),

          // Snackbar
          snackBarTheme: SnackBarThemeData(
            backgroundColor: const Color(0xFF1A1A2E),
            contentTextStyle: const TextStyle(color: Colors.white),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Progress indicator
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Color(0xFFD4AF37),
          ),

          // Icon theme
          iconTheme: const IconThemeData(
            color: Color(0xFFD4AF37),
          ),

          // Font
          fontFamily: 'SF Pro Display', // falls back to system sans-serif
        ),
      ),
    );
  }
}