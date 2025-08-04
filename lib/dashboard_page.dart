import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'userview.dart';
import 'userdetails.dart';
class DashboardPage extends StatelessWidget {
  final String email; // Add email parameter

  const DashboardPage({Key? key, required this.email}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop Directory',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: ShopListingPage(userEmail: email),
      debugShowCheckedModeBanner: false,
    );
  }
}
class ShopListingPage extends StatefulWidget {
  final String userEmail; // Add userEmail parameter

  const ShopListingPage({Key? key, required this.userEmail}) : super(key: key);
  @override
  _ShopListingPageState createState() => _ShopListingPageState();
}
class _ShopListingPageState extends State<ShopListingPage> {
  List<Shop> shops = [];
  List<Shop> filteredShops = [];
  List<String> categories = [];
  String searchQuery = '';
  String selectedCategory = '';
  Shop? selectedShop;
  bool showIcons = false;
  bool isLoading = true;
  String errorMessage = '';

  final TextEditingController _searchController = TextEditingController();
  final String apiUrl = 'http://localhost:5002'; // Replace with your server URL

  @override
  void initState() {
    super.initState();
    _fetchShops();
  }

  Future<void> _fetchShops() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await http.get(Uri.parse('$apiUrl/get-owners')); // Changed from get-owner to get-owners
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        setState(() {
          shops = data.map((shop) => Shop(
            shop['shopname'] ?? 'No Name',
            shop['address'] ?? 'No Address',
            shop['name'] ?? 'No Owner',
            shop['phone'] ?? 'No Phone',
            shop['category']?.toLowerCase() ?? 'other',
            shop['latitude']?.toString(),
            shop['longitude']?.toString(),
            shop['status']?.toLowerCase() ?? 'open',
          )).toList();

          // Extract unique categories
          categories = shops.map((shop) => shop.category).toSet().toList();
          filteredShops = List.from(shops);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load shops');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data. Please try again later.';
        isLoading = false;
      });
      print("Error fetching shops: $e");
    }
  }

  void filterShops() {
    setState(() {
      filteredShops = shops.where((shop) {
        final matchesSearch = searchQuery.isEmpty ||
            shop.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            shop.address.toLowerCase().contains(searchQuery.toLowerCase()) ||
            shop.category.toLowerCase().contains(searchQuery.toLowerCase()) ||
            shop.owner.toLowerCase().contains(searchQuery.toLowerCase());
        
        final matchesCategory = selectedCategory.isEmpty || 
            shop.category.toLowerCase() == selectedCategory.toLowerCase();
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _showShopDetailsDialog(Shop shop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${shop.name} - Details', style: GoogleFonts.montserrat()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(Icons.location_on, shop.address),
            _infoRow(Icons.person, "Owner: ${shop.owner}"),
            _infoRow(Icons.phone, shop.phone),
            _infoRow(Icons.category, shop.category[0].toUpperCase() + shop.category.substring(1)),
            if (shop.latitude != null && shop.longitude != null)
              _infoRow(Icons.map, "Lat: ${shop.latitude}\nLng: ${shop.longitude}"),
            SizedBox(height: 10),
            _infoRow(Icons.info_outline, "Status: ${shop.status}"),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Close", style: GoogleFonts.montserrat()),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        SizedBox(width: 8),
        Expanded(child: Text(text, style: GoogleFonts.montserrat(fontSize: 14))),
      ],
    ),
  );

  void _callPhoneNumber(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch dialer", style: GoogleFonts.montserrat())),
      );
    }
  }

  void sendSms(String phoneNumber) async {
    final Uri smsUri = Uri.parse('sms:$phoneNumber');
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open SMS app", style: GoogleFonts.montserrat())),
      );
    }
  }

  void openGoogleMaps(String latitude, String longitude) async {
    final Uri googleMapsUri = Uri.parse('https://www.google.com/maps?q=$latitude,$longitude');
    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open Google Maps", style: GoogleFonts.montserrat())),
      );
    }
  }


  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          content: Text('Do you want to logout?', style: GoogleFonts.montserrat()),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.montserrat()),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  

 @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.person, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserDetailsPage(userEmail: widget.userEmail)),
           );
         },
       ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () { _showLogoutDialog(context); },
          ),
        ],
        backgroundColor: Colors.deepPurple.withOpacity(0.92),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'web/logo1.png',
              height: 40,
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFa18cd1), Color(0xFFfbc2eb), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          if (w > 500)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(-0.25, -0.3),
                      radius: 1.2,
                      colors: [
                        Colors.deepPurple.withOpacity(0.08),
                        Colors.white.withOpacity(0.84),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 100),
            child: Column(
              children: [
                FadeInDown(
                  duration: Duration(milliseconds: 500),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.montserrat(),
                        decoration: InputDecoration(
                          hintText: 'Search shops by name, address or category...',
                          prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.95),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                            filterShops();
                          });
                        },
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 20),
                
                if (isLoading)
                  CircularProgressIndicator()
                else if (errorMessage.isNotEmpty)
                  Text(errorMessage, style: GoogleFonts.montserrat(color: Colors.red))
                else
                  FadeInDown(
                    duration: Duration(milliseconds: 600),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _buildCategoryButton('All', ''),
                          SizedBox(width: 8),
                          ...categories.map((category) => 
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildCategoryButton(
                                category[0].toUpperCase() + category.substring(1),
                                category
                              ),
                            )
                          ).toList(),
                        ],
                      ),
                    ),
                  ),
                
                SizedBox(height: 20),
                
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else if (errorMessage.isNotEmpty)
                  Center(child: Text(errorMessage, style: GoogleFonts.montserrat(color: Colors.red)))
                else if (selectedShop == null)
                  FadeInUp(
                    duration: Duration(milliseconds: 700),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: filteredShops.map((shop) => _buildShopCard(shop)).toList(),
                      ),
                    ),
                  )
                else
                  _buildSelectedShopCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String label, String category) {
    final isSelected = selectedCategory == category;
    return BounceInDown(
      duration: Duration(milliseconds: 500 + (category.isEmpty ? 0 : category.codeUnitAt(0) * 10)),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.deepPurple,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isSelected ? 4 : 2,
          shadowColor: Colors.deepPurple.withOpacity(0.3),
        ),
        onPressed: () {
          setState(() {
            selectedCategory = isSelected ? '' : category;
            filterShops();
          });
        },
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildShopCard(Shop shop) {
    final statusColor = shop.status == 'open' ? Colors.green.shade600 : 
                       shop.status == 'closed' ? Colors.redAccent.shade700 : Colors.amber.shade700;
    final statusLabel = shop.status == 'open' ? 'Open' : 
                       shop.status == 'closed' ? 'Closed' : 'Resumed';

    return ZoomIn(
      duration: Duration(milliseconds: 300),
      child: Card(
        margin: EdgeInsets.only(bottom: 15),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            setState(() {
              selectedShop = shop;
              showIcons = false;
            });
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.deepPurple[50],
                      child: Icon(
                        _getCategoryIcon(shop.category),
                        size: 25,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop.name,
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            shop.address,
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.montserrat(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.person, size: 18, color: Colors.deepPurple),
                    SizedBox(width: 5),
                    Text(
                      shop.owner,
                      style: GoogleFonts.montserrat(fontSize: 14),
                    ),
                    Spacer(),
                    Icon(Icons.phone, size: 18, color: Colors.deepPurple),
                    SizedBox(width: 5),
                    Text(
                      shop.phone,
                      style: GoogleFonts.montserrat(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedShopCard() {
    if (selectedShop == null) return SizedBox.shrink();
    
    final shop = selectedShop!;
    final statusColor = shop.status == 'open' ? Colors.green.shade600 : 
                       shop.status == 'closed' ? Colors.redAccent.shade700 : Colors.amber.shade700;
    final statusLabel = shop.status == 'open' ? 'Open' : 
                       shop.status == 'closed' ? 'Closed' : 'Resumed';

    return FadeIn(
      duration: Duration(milliseconds: 500),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Card(
          elevation: 7,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.deepPurple[50],
                      child: Icon(
                        _getCategoryIcon(shop.category),
                        size: 27,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop.name,
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            shop.address,
                            style: GoogleFonts.montserrat(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.montserrat(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(height: 30),
                showIcons
                    ? _buildActionIcons(shop)
                    : Center(
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() => showIcons = true),
                          icon: Icon(Icons.expand_more, color: Colors.deepPurple),
                          label: Text("Actions", style: GoogleFonts.montserrat()),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                        ),
                      ),
                SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: Icon(Icons.arrow_back, color: Colors.deepPurple),
                    label: Text('Back', style: GoogleFonts.montserrat()),
                    onPressed: () => setState(() {
                      selectedShop = null;
                      showIcons = false;
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcons(Shop shop) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.deepPurple[50],
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.08),
                blurRadius: 11,
                offset: Offset(1, 5),
              )
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionIcon(Icons.message, 'Message', () => sendSms(shop.phone)),
              _actionIcon(Icons.location_on, 'Location', () {
                if (shop.latitude != null && shop.longitude != null) {
                  openGoogleMaps(shop.latitude!, shop.longitude!);
                }
              }),
              _actionIcon(Icons.phone, 'Call', () => _callPhoneNumber(shop.phone)),
              _actionIcon(Icons.info, 'About', () => _showShopDetailsDialog(shop)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionIcon(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      splashColor: Colors.deepPurple.withOpacity(0.14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: Colors.deepPurple[100],
            radius: 20,
            child: Icon(icon, color: Colors.deepPurple, size: 24),
          ),
          SizedBox(height: 4),
          Text(label, style: GoogleFonts.montserrat(fontSize: 13)),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'medical':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'sports':
        return Icons.sports_soccer;
      case 'kirana':
        return Icons.store;
      default:
        return Icons.store;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class Shop {
  final String name;
  final String address;
  final String owner;
  final String phone;
  final String category;
  final String? latitude;
  final String? longitude;
  final String status;

  Shop(
    this.name,
    this.address,
    this.owner,
    this.phone,
    this.category,
    [this.latitude,
    this.longitude,
    this.status = 'open']
  );
}