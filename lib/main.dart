import 'package:flutter/material.dart';
import 'package:status_hub/overview.dart';
import 'adminregister.dart';
import 'superadminpage.dart';
import 'splash_screen.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'owner_register.dart';
import 'owner_dashboard.dart';
import 'admin_login_screen.dart';
import 'register_screen.dart';
import 'userview.dart';
import 'userdetails.dart';
void main() => runApp(StatusHubApp());
class StatusHubApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Status Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => SplashScreen());
          case '/overview':
            return MaterialPageRoute(builder: (context)=>HomePage());
          case '/login':
            return MaterialPageRoute(builder: (context) => LoginPage());
          case '/dashboard':
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => DashboardPage(
                  email: args['email'],
                ),
              );
            }
          case '/ownerRegister':
            return MaterialPageRoute(builder: (context) => OwnerRegisterScreen());
          case '/adminLogin':
            return MaterialPageRoute(builder: (context) => AdminLoginScreen());
          case '/userView':
            return MaterialPageRoute(builder: (context) => Userview());
          case '/userDetails':
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => UserDetailsPage(
                  userEmail:args['email']
                ),
              );
            }
          case '/register':
            return MaterialPageRoute(builder: (context) => RegisterScreen());
          case '/superadmin':
            return MaterialPageRoute(builder: (context) => SuperAdminPage());
          case '/adminRegister':
            return MaterialPageRoute(builder: (context) => AdminRegisterScreen());
          case '/ownerDashboard':
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => OwnerDashboard(
                  username: args['username'],
                  shopName: args['shopname'],
                ),
              );
            }
            return MaterialPageRoute(builder: (context) => ErrorScreen());
          default:
            return MaterialPageRoute(builder: (context) => ErrorScreen());
        }
      },
    );
  }
}
class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Error: Route Not Found')),
    );
  }
}
