import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/overview');
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Beautiful animated gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          if (w > 400)
            // Glass overlay for extra depth on big screens
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 13, sigmaY: 13),
                child: Container(color: Colors.transparent),
              ),
            ),
          Center(
            child: FadeIn(
              duration: Duration(milliseconds: 900),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo in a soft glowing glass blob
                  Hero(
                    tag: 'register-avatar',
                    child: Container(
                      padding: EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.27),
                        borderRadius: BorderRadius.circular(120),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.23),
                            blurRadius: 40,
                            spreadRadius: 5,
                          )
                        ],
                        border: Border.all(
                          color: Colors.deepPurpleAccent.withOpacity(0.17),
                          width: 3,
                        ),
                      ),
                      child: Image.asset(
                        'web/logo1.png',
                        width: 180,
                        height: 180,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                  SizedBox(height: 35),
                  // App/Brand tagline
                  Text(
                    "Smart Status Hub",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        fontSize: 32,
                        color: Colors.deepPurple.shade700,
                        letterSpacing: 1.5),
                  ),
                  SizedBox(height: 17),
                  Text(
                    "Know. Plan. Shop Smart.",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w400,
                      fontSize: 17,
                      color: Colors.deepPurple.shade300,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(height: 28),
                  // Optional: Progress spinner (theme color)
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                    strokeWidth: 3.2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
