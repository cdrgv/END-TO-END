import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';
import 'register_screen.dart';
import 'overview.dart';

class Userview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop Directory',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: ShopListingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ShopListingPage extends StatefulWidget {
  @override
  _ShopListingPageState createState() => _ShopListingPageState();
}

class _ShopListingPageState extends State<ShopListingPage> {
  List<Shop> shops = [];
  List<Shop> filteredShops = [];
  List<String> categories = [];
  String searchQuery = '';
  String selectedCategory = '';
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

      final response = await http.get(Uri.parse('$apiUrl/get-owners'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        setState(() {
          shops = data.map((shop) => Shop(
            shop['shopname'] ?? 'No Name',
            shop['address'] ?? 'No Address',
            shop['name'] ?? 'No Owner',
            shop['phone'] ?? 'No Phone',
            shop['category']?.toLowerCase() ?? 'other',
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

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Login Required', style: GoogleFonts.montserrat()),
        content: Text('You need to login as an user to access these features.', 
                     style: GoogleFonts.montserrat()),
        actions: [
          TextButton(
            child: Text('Cancel', style: GoogleFonts.montserrat()),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text('Login', style: GoogleFonts.montserrat()),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
        ),
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
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onSelected: (value) {
              if (value == 'login') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              } else if (value == 'register') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'login',
                child: Text('Login'),
              ),
              PopupMenuItem<String>(
                value: 'register',
                child: Text('Register'),
              ),
            ],
          ),
        ],
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
                else
                  FadeInUp(
                    duration: Duration(milliseconds: 700),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: filteredShops.map((shop) => _buildShopCard(shop)).toList(),
                      ),
                    ),
                  ),
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
          onTap: () => _showLoginDialog(context),
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
  final String status;

  Shop(
    this.name,
    this.address,
    this.owner,
    this.phone,
    this.category,
    [this.status = 'open']
  );
}