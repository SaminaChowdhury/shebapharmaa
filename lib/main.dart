import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/auth_service.dart';
import 'core/cart_provider.dart';
import 'core/order_provider.dart';
import 'screens/auth/login.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'ShebaPharma',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF799EFF)),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: FutureBuilder<Map<String, dynamic>>(
          future: AuthService.checkAuthStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF799EFF)),
                  ),
                ),
              );
            }
            
            if (snapshot.hasData && snapshot.data!['isAuthenticated'] == true) {
              return const HomeScreen();
            }
            
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
