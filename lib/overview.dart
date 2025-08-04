import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';
import 'userview.dart';
import 'login_page.dart';
import 'register_screen.dart';

// Main entry point
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorSchemeSeed: Colors.deepPurple,
      brightness: Brightness.light,
      textTheme: GoogleFonts.montserratTextTheme(),
      useMaterial3: true,
    ),
    home: HomePage(),
    routes: {
      '/login': (context) => LoginPage(),
      '/register': (context) => RegisterScreen(),
    },
  );
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _otherKey = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  Widget _buildNavButton(String label, GlobalKey key) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _scrollToSection(key),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [Colors.deepPurpleAccent, Colors.blue.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.10),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mobile? Reduce padding/size for all cards
    final mobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFF6F9FF),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0x99a18cd1), Color(0x99fbc2eb)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16, offset: Offset(0, 8),
                  )
                ],
              ),
              child: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                title: Row(
                  children: [
                    // Logo with subtle glow/shadow
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.20),
                            blurRadius: 23, offset: Offset(0, 10),
                          )
                        ],
                      ),
                      child: Image.asset('web/logo1.png', height: 45, filterQuality: FilterQuality.high),
                    ),
                    const SizedBox(width: 30),
                    _buildNavButton("Home", _homeKey),
                    _buildNavButton("Our Services", _aboutKey),
                    _buildNavButton("About us", _otherKey),
                  ],
                ),
                // actions: [
                //   Padding(
                //     padding: const EdgeInsets.only(right: 30.0),
                //     child: GlassmorphicMenuButton(),
                //   ),
                // ],
              ),
            ), // BackdropFilter container\\
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated floating bubbles for decor (not functional, just pretty background)
          _BubblesBackground(),
          SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(top: 90),
            child: Column(
              children: [
                FadeInDown(child: HomeSection(homeKey: _homeKey)),
                FadeInUp(child: AboutSection(aboutKey: _aboutKey)),
                FadeInUp(delay: Duration(milliseconds: 200), child: OtherSection(otherKey: _otherKey)),
                SizedBox(height: 10),
                FadeIn(delay: Duration(milliseconds: 400), child: FooterSection(scrollCtrl: _scrollController)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// -------- CAPTIVATING BACKGROUND DECORATION BUBBLES ----------
class _BubblesBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 20, left: -60,
            child: _bubble(130, Colors.deepPurple.shade100.withOpacity(0.22)),
          ),
          Positioned(
            bottom: 240, right: -36,
            child: _bubble(70, Colors.blueAccent.shade100.withOpacity(0.19)),
          ),
          Positioned(
            bottom: 32, left: -32,
            child: _bubble(120, Colors.pinkAccent.shade100.withOpacity(0.14)),
          ),
          Positioned(
            top: w > 600 ? 210 : 120, right: -60,
            child: _bubble(90, Colors.blue.shade100.withOpacity(0.13)),
          ),
        ],
      ),
    );
  }

  Widget _bubble(double size, Color color) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color, blurRadius: 14)],
        ),
      );
}


// ======================= GLASSMORPHIC LOGIN/REGISTER MENU ===================
// class GlassmorphicMenuButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => Userview()),
//         );
//       },
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               color: Colors.purpleAccent.withOpacity(0.13),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.deepPurple.withOpacity(0.10),
//                   blurRadius: 8,
//                   offset: Offset(2, 5),
//                 )
//               ],
//             ),
//             padding: EdgeInsets.all(7),
//             child: Icon(Icons.person, color: Colors.deepPurple[800], size: 28),
//           ),
//         ),
//       ),
//     );
//   }
// }

// ======================= HERO SECTION ======================
class HomeSection extends StatelessWidget {
  final GlobalKey homeKey;
  const HomeSection({required this.homeKey});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      key: homeKey,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: w < 700 ? 32 : 60,
        horizontal: w < 800 ? 8 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SlideInDown(
            duration: Duration(milliseconds: 900),
            child: ImageSlider(),
          ),
          const SizedBox(height: 18),
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 850),
              child: GlassCard(
                child: Column(
                  children: [
                    FadeIn(
                      duration: Duration(milliseconds: 700),
                      child: Text(
                        "Welcome to Smart Status Hub!",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: w < 700 ? 25 : 37,
                          color: Colors.deepPurple.shade700,
                          letterSpacing: 0.75,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    FadeIn(
                      delay: Duration(milliseconds: 180),
                      child: Text(
                        "Make every outing count with instant, detailed shop status. No more guesswork—just tap, search, and go. "
                        "Real-time updates, powerful search—and complete planning power for your day!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: w < 700 ? 15 : 19,
                          color: Color(0xFF404040),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 18),
        ],
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 34, vertical: 32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.white.withOpacity(0.82),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.08),
                blurRadius: 24,
                offset: Offset(1, 10),
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}


// ======================= SERVICES / INFO SECTION ======================
class AboutSection extends StatelessWidget {
  final GlobalKey aboutKey;
  const AboutSection({required this.aboutKey});
  
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    const infoColor = Color(0xFFf6f2ff);
    return Container(
      key: aboutKey,
      padding: EdgeInsets.symmetric(
        vertical: w < 700 ? 24 : 46,
        horizontal: w < 700 ? 7 : 0,
      ),
      color: infoColor,
      width: double.infinity,
      child: Column(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 4, color: Colors.deepPurple.shade300, style: BorderStyle.solid)),
                ),
                child: Text(
                  "Our Services",
                  style: GoogleFonts.montserrat(
                    fontSize: w < 700 ? 22 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          Wrap(
            spacing: 30, runSpacing: 30, alignment: WrapAlignment.center,
            children: [
              ServiceTag(
                icon: Icons.access_time_rounded,
                title: "Real-time Status",
                desc: "Instantly see if shops are open, closed, or resuming—no more wasted trips!",
              ),
              ServiceTag(
                icon: Icons.place_rounded,
                title: "Discover & Plan",
                desc: "Smart search across local shops lets you plan the best shopping route.",
              ),
              ServiceTag(
                icon: Icons.people_rounded,
                title: "Connect Nearby",
                desc: "Support your local stores and stay instantly updated with changes nearby.",
              ),
            ],
          ),
          
          // New "Access Our Services" section
          SizedBox(height: 40),
          FadeInUp(
            delay: Duration(milliseconds: 300),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    "Access Our Services",
                    style: GoogleFonts.montserrat(
                      fontSize: w < 700 ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Userview()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: Colors.deepPurple.withOpacity(0.3),
                    ),
                    child: Text(
                      'Click Here',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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

class ServiceTag extends StatelessWidget {
  final IconData icon;
  final String title, desc;
  const ServiceTag({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return ZoomIn(
      duration: Duration(milliseconds: 700),
      child: GlassCard(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple[50],
                borderRadius: BorderRadius.circular(14),
              ),
              padding: EdgeInsets.all(17),
              child: Icon(icon, color: Colors.deepPurple, size: 36),
            ),
            SizedBox(width: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 7),
                SizedBox(
                  width: 230,
                  child: Text(
                    desc,
                    style: GoogleFonts.montserrat(fontSize: 14, color: Color(0xFF505050)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


// ======================= ABOUT US SECTION ======================
class OtherSection extends StatelessWidget {
  final GlobalKey otherKey;
  const OtherSection({required this.otherKey});
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      key: otherKey,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: w < 700 ? 22 : 42, horizontal: w < 800 ? 7 : 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFe0e7ff), Color(0xFFf7e9ff)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: GlassCard(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 4, color: Colors.deepPurpleAccent, style: BorderStyle.solid),
                    ),
                  ),
                  child: Text(
                    "About us",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                      fontSize: w < 700 ? 19 : 27,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
              Text(
                "Tired of wasted trips to closed stores? Get instant updates on local shop statuses—know if your favorite businesses are open, closed, or have just resumed operations.\n\n"
                "Easily browse and search for shops by category and plan your day more efficiently, knowing which shops in your area are currently available. "
                "Stay informed about reopenings and connect with businesses nearby, supporting local commerce with ease.",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: w < 700 ? 14 : 17,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ==================== IMAGE SLIDER with Caption/Gradient =====================
class ImageSlider extends StatefulWidget {
  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isForward = true;
  final List<_SliderItem> images = [
    _SliderItem(image: 'web/status.jpg', caption: 'Know Every Store Status - Instantly!'),
    _SliderItem(image: 'web/x.jpg', caption: 'Find Open Shops Around You, Anytime'),
    _SliderItem(image: 'web/y.jpg', caption: 'Save Time & Shop Smarter'),
    _SliderItem(image: 'web/z.jpg', caption: 'Support Your Local Businesses!'),
  ];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 4), (Timer timer) {
      if (_isForward) {
        if (_currentPage < images.length - 1) {
          _currentPage++;
        } else {
          _isForward = false;
          _currentPage--;
        }
      } else {
        if (_currentPage > 0) {
          _currentPage--;
        } else {
          _isForward = true;
          _currentPage++;
        }
      }

      if (mounted) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 900),
          curve: Curves.easeInOutExpo,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    const double sliderHeight = 320;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: sliderHeight,
              width: w > 1000 ? 1000 : w * 0.97,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (idx) => setState(() => _currentPage = idx),
                      itemBuilder: (context, index) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            // Main image with soft drop shadow
                            Container(
                              foregroundDecoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepPurpleAccent.withOpacity(0.10),
                                    Colors.blue.shade50.withOpacity(0.18),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Image.asset(
                                images[index].image,
                                fit: BoxFit.cover,
                                colorBlendMode: BlendMode.overlay,
                                color: Colors.black.withOpacity(0.05),
                              ),
                            ),
                            // Caption overlay
                            Positioned(
                              left: 0, right: 0, bottom: 32,
                              child: FadeInUp(
                                delay: Duration(milliseconds: 350),
                                duration: Duration(milliseconds: 700),
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: Colors.purple.withOpacity(0.65),
                                      boxShadow: [BoxShadow(
                                        color: Colors.deepPurple.withOpacity(0.13),
                                        blurRadius: 12
                                      )],
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 21, vertical: 9),
                                    child: Text(
                                      images[index].caption,
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: w < 700 ? 14 : 20,
                                        letterSpacing: 0.18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    // Indicators
                    Positioned(
                      left: 0, right: 0, bottom: 14,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (i) {
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            width: _currentPage == i ? 33 : 12,
                            height: 9,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: _currentPage == i
                                  ? Colors.deepPurpleAccent
                                  : Colors.deepPurple.withOpacity(0.14),
                              boxShadow: _currentPage == i
                                  ? [BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.22),
                                    blurRadius: 6, offset: Offset(1,2))]
                                  : [],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Left Arrow
            
            // Right Arrow
            Positioned(
              right: 8,
              child: IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: Colors.deepPurple, size: 32),
                onPressed: () {
                  if (_currentPage < images.length - 1) {
                    setState(() => _currentPage++);
                    _pageController.animateToPage(_currentPage, duration: Duration(milliseconds: 500), curve: Curves.easeOut);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SliderItem {
  final String image;
  final String caption;
  _SliderItem({required this.image, required this.caption});
}


// =============== FOOTER (with Wavy Top) ================
class FooterSection extends StatelessWidget {
  final ScrollController? scrollCtrl;
  FooterSection({this.scrollCtrl});

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  final List<_SocialItem> socials = const [
    _SocialItem(asset: 'web/facebook.png', url: 'https://www.facebook.com'),
    _SocialItem(asset: 'web/xlogo.png', url: 'https://www.twitter.com'),
    _SocialItem(asset: 'web/youtube.png', url: 'https://www.youtube.com'),
    _SocialItem(asset: 'web/github.png', url: 'https://www.github.com'),
    _SocialItem(asset: 'web/instagram.png', url: 'https://www.instagram.com'),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Wavy divider
        ClipPath(
          clipper: _WaveClipper(),
          child: Container(
            height: 40,
            color: Color(0xFF657CED),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF657CED), Color(0xFF7F53AC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 36),
          child: Column(
            children: [
              Wrap(
                spacing: 30,
                runSpacing: 15,
                alignment: WrapAlignment.center,
                children: socials.map((item) => _AnimatedSocialIcon(item: item, launch: _launchURL)).toList(),
              ),
              SizedBox(height: 26),
              GestureDetector(
                onTap: () {
                  scrollCtrl?.animateTo(
                    0,
                    duration: Duration(milliseconds: 600),
                    curve: Curves.easeInOutExpo,
                  );
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 170),
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 23),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Color(0xFFe8eafc)],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: Text(
                    "Back to Top ↑",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.deepPurpleAccent,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              Text(
                '© ${DateTime.now().year} YourShopStatus | Smart Store Discovery',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.88),
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Wavy footer divider
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 8);
    path.quadraticBezierTo(size.width * 0.20, 28, size.width * 0.5, 14);
    path.quadraticBezierTo(size.width * 0.8, 0, size.width, 28);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


class _SocialItem {
  final String asset;
  final String url;
  const _SocialItem({required this.asset, required this.url});
}

class _AnimatedSocialIcon extends StatefulWidget {
  final _SocialItem item;
  final void Function(String url) launch;
  const _AnimatedSocialIcon({required this.item, required this.launch});
  @override
  State<_AnimatedSocialIcon> createState() => _AnimatedSocialIconState();
}

class _AnimatedSocialIconState extends State<_AnimatedSocialIcon>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  void _onHover(bool isHover) => setState(() { _scale = isHover ? 1.21 : 1.0; });
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit:  (_) => _onHover(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.launch(widget.item.url),
        child: AnimatedScale(
          scale: _scale,
          duration: Duration(milliseconds: 205),
          curve: Curves.easeIn,
          child: Image.asset(
            widget.item.asset,
            width: 41,
            height: 41,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
