import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'owner_register.dart';
import 'adminregister.dart';
class SuperAdminPage extends StatefulWidget {
  @override
  _SuperAdminPageState createState() => _SuperAdminPageState();
}

class _SuperAdminPageState extends State<SuperAdminPage> {
  TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _selectedOwner;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _owners = [];
  List<Map<String, dynamic>> _admins = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  List<Map<String, dynamic>> _filteredOwners = [];
  List<Map<String, dynamic>> _filteredAdmins = [];
  String selectedRole = "users"; 
  final String apiUrl = "http://localhost:5002"; 
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_onSearchChanged); 
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      if (selectedRole == "users") {
        _filteredUsers = _searchController.text.isEmpty
            ? _users
            : _users
                .where((user) =>
                    user['email'].toLowerCase().contains(_searchController.text.toLowerCase()))
                .toList();
      } else if (selectedRole == "owners") {
        _filteredOwners = _searchController.text.isEmpty
            ? _owners
            : _owners
                .where((owner) =>
                    owner['shopname'].toLowerCase().contains(_searchController.text.toLowerCase()))
                .toList();
      } else if (selectedRole == "admins") {
        _filteredAdmins = _searchController.text.isEmpty
            ? _admins
            : _admins
                .where((admin) =>
                    admin['username'].toLowerCase().contains(_searchController.text.toLowerCase()))
                .toList();
      }
    });
  }

  String decryptPassword(String encryptedText) {
    try {
      final parts = encryptedText.split(":");
      if (parts.length != 2) return "Invalid format";
      final ivHex = parts[0]; 
      final encryptedHex = parts[1]; 
      final key = encrypt.Key.fromUtf8("sukeshpavanjayakrishnanarasaredd"); 
      final iv = encrypt.IV.fromBase16(ivHex); 
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final decrypted = encrypter.decrypt(encrypt.Encrypted.fromBase16(encryptedHex), iv: iv);
      return decrypted;
    } catch (e) {
      print("Decryption error: $e");
      return "Error decrypting";
    }
  }

  Future<void> _deleteOwner(String username) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Owner', style: GoogleFonts.montserrat()),
          content: Text('Are you sure you want to delete this owner?', style: GoogleFonts.montserrat()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: GoogleFonts.montserrat()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete', style: GoogleFonts.montserrat(color: Colors.red)),
            ),
          ],
        );
      },
    );
    if (!confirmDelete) return;
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleting owner...', style: GoogleFonts.montserrat())),
      );
      final response = await http.delete(Uri.parse("$apiUrl/delete-owner/$username"));
      if (response.statusCode == 200) {
        setState(() {
          _admins.removeWhere((owner) => owner['username'] == username);
          _filteredAdmins.removeWhere((owner) => owner['username'] == username);
          _selectedOwner = null; 
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Owner deleted successfully', style: GoogleFonts.montserrat())));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete owner', style: GoogleFonts.montserrat())));
      }
    } catch (error) {
      print("Error deleting owner: $error");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while deleting owner', style: GoogleFonts.montserrat())));
    }
  }

  Future<void> _deleteUser(String email) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete User', style: GoogleFonts.montserrat()),
          content: Text('Are you sure you want to delete this user?', style: GoogleFonts.montserrat()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: GoogleFonts.montserrat()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete', style: GoogleFonts.montserrat(color: Colors.red)),
            ),
          ],
        );
      },
    );
    if (!confirmDelete) return;
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleting user...', style: GoogleFonts.montserrat())),
      );
      final response = await http.delete(Uri.parse("$apiUrl/delete-user/$email"));
      if (response.statusCode == 200) {
        setState(() {
          _admins.removeWhere((user) => user['email'] == email);
          _filteredAdmins.removeWhere((user) => user['email'] == email);
          _selectedOwner = null; 
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User deleted successfully', style: GoogleFonts.montserrat())));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete user', style: GoogleFonts.montserrat())));
      }
    } catch (error) {
      print("Error deleting user: $error");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while deleting user', style: GoogleFonts.montserrat())));
    }
  }

  Future<void> _deleteAdmin(String username) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Admin', style: GoogleFonts.montserrat()),
          content: Text('Are you sure you want to delete this admin?', style: GoogleFonts.montserrat()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: GoogleFonts.montserrat()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete', style: GoogleFonts.montserrat(color: Colors.red)),
            ),
          ],
        );
      },
    );
    if (!confirmDelete) return;
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleting admin...', style: GoogleFonts.montserrat())),
      );
      final response = await http.delete(Uri.parse("$apiUrl/delete-admin/$username"));
      if (response.statusCode == 200) {
        setState(() {
          _admins.removeWhere((admin) => admin['username'] == username);
          _filteredAdmins.removeWhere((admin) => admin['username'] == username);
          _selectedOwner = null; 
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Admin deleted successfully', style: GoogleFonts.montserrat())));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete admin', style: GoogleFonts.montserrat())));
      }
    } catch (error) {
      print("Error deleting admin: $error");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while deleting admin', style: GoogleFonts.montserrat())));
    }
  }

  Future<void> _updateOwner() async {
    if (_selectedOwner == null) return;
    TextEditingController nameController = TextEditingController(text: _selectedOwner!['name']);
    TextEditingController shopController = TextEditingController(text: _selectedOwner!['shopname']);
    TextEditingController addressController = TextEditingController(text: _selectedOwner!['address']);
    TextEditingController categoryController = TextEditingController(text: _selectedOwner!['category']);
    TextEditingController phoneController = TextEditingController(text: _selectedOwner!['phone']);
    TextEditingController userController = TextEditingController(text: _selectedOwner!['username']);
    TextEditingController latitudeController = TextEditingController(text: _selectedOwner!['latitude']);
    TextEditingController longitudeController = TextEditingController(text: _selectedOwner!['longitude']);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Owner Details', style: GoogleFonts.montserrat()),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _roundedTextForm(
                    label: 'Name',
                    icon: Icons.person,
                    controller: nameController,
                  ),
                  SizedBox(height: 10),
                  _roundedTextForm(
                    label: 'Shop Name',
                    icon: Icons.store,
                    controller: shopController,
                  ),
                  SizedBox(height: 10),
                  _roundedTextForm(
                    label: 'Address',
                    icon: Icons.location_on,
                    controller: addressController,
                  ),
                  SizedBox(height: 10),
                  _roundedTextForm(
                    label: 'category',
                    icon: Icons.category,
                    controller: categoryController,
                  ),
                  SizedBox(height: 10),
                  _roundedTextForm(
                    label: 'Phone Number',
                    icon: Icons.phone,
                    controller: phoneController,
                  ),
                  SizedBox(height: 10),
                  _roundedTextForm(
                    label: 'Username',
                    icon: Icons.person_outline,
                    controller: userController,
                  ),
                  SizedBox(height: 10),
                  _roundedTextForm(
                    label: 'Latitude',
                    icon: Icons.map,
                    controller: latitudeController,
                  ),
                  SizedBox(height: 10),
                  _roundedTextForm(
                    label: 'Longitude',
                    icon: Icons.map,
                    controller: longitudeController,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.montserrat()),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedData = {
                  "name": nameController.text,
                  "shopname": shopController.text,
                  "address": addressController.text,
                  "category":categoryController.text,
                  "phone": phoneController.text,
                  "username": userController.text,
                  "latitude": latitudeController.text,
                  "longitude": longitudeController.text
                };
                try {
                  final response = await http.put(
                    Uri.parse("$apiUrl/update-owner/${_selectedOwner!['username']}"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode(updatedData),
                  );
                  if (response.statusCode == 200) {
                    setState(() {
                      _fetchData(); 
                      _selectedOwner = null; 
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Owner updated successfully', style: GoogleFonts.montserrat()))
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update owner', style: GoogleFonts.montserrat()))
                    );
                  }
                } catch (error) {
                  print("Error updating owner: $error");
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text('Update', style: GoogleFonts.montserrat(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAdmin() async {
    if (_selectedOwner == null) return;
    TextEditingController nameController = TextEditingController(text: _selectedOwner!['name']);
    TextEditingController addressController = TextEditingController(text: _selectedOwner!['address']);
    TextEditingController userController = TextEditingController(text: _selectedOwner!['username']);
    
    showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false; 
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Admin Details', style: GoogleFonts.montserrat()),
              content: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _roundedTextForm(
                        label: 'Name',
                        icon: Icons.person,
                        controller: nameController,
                      ),
                      SizedBox(height: 10),
                      _roundedTextForm(
                        label: 'Address',
                        icon: Icons.location_on,
                        controller: addressController,
                      ),
                      SizedBox(height: 10),
                      _roundedTextForm(
                        label: 'Username',
                        icon: Icons.person_outline,
                        controller: userController,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.montserrat()),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null 
                      : () async {
                          setState(() {
                            isLoading = true; 
                          });
                          final updatedData = {
                            "name": nameController.text,
                            "address": addressController.text,
                            "username": userController.text,
                          };
                          try {
                            final response = await http.put(
                              Uri.parse("$apiUrl/update-admin/${_selectedOwner!['username']}"),
                              headers: {"Content-Type": "application/json"},
                              body: jsonEncode(updatedData),
                            );
                            if (response.statusCode == 200) {
                              setState(() {
                                _fetchData(); 
                                _selectedOwner = null; 
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Admin updated successfully', style: GoogleFonts.montserrat())));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to update admin', style: GoogleFonts.montserrat())));
                            }
                          } catch (error) {
                            print("Error updating admin: $error");
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('An error occurred while updating admin', style: GoogleFonts.montserrat())));
                          } finally {
                            setState(() {
                              isLoading = false; 
                            });
                            Navigator.pop(context); 
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text('Update', style: GoogleFonts.montserrat(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateUser() async {
    if (_selectedOwner == null) return;
    TextEditingController emailController = TextEditingController(text: _selectedOwner!['email']);
    TextEditingController nameController = TextEditingController(text: _selectedOwner!['name']);
    TextEditingController genderController = TextEditingController(text: _selectedOwner!['gender']);
    TextEditingController addressController = TextEditingController(text: _selectedOwner!['address']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update User Details', style: GoogleFonts.montserrat()),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _roundedTextForm(
                    label: 'Email',
                    icon: Icons.email,
                    controller: emailController,
                  ),
                  _roundedTextForm(
                    label: 'Name',
                    icon: Icons.person,
                    controller: nameController,
                  ),
                  _roundedTextForm(
                    label: 'Gender',
                    icon: Icons.gesture_rounded,
                    controller: genderController,
                  ),
                  _roundedTextForm(
                    label: 'Address',
                    icon: Icons.add,
                    controller: addressController,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.montserrat()),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedData = {
                  "email": emailController.text,
                  "name":nameController.text,
                  "gender":genderController.text,
                  "address":addressController.text
                };
                try {
                  final response = await http.put(
                    Uri.parse("$apiUrl/update-user/${_selectedOwner!['email']}"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode(updatedData),
                  );
                  if (response.statusCode == 200) {
                    setState(() {
                      _fetchData(); 
                      _selectedOwner = null; 
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User updated successfully', style: GoogleFonts.montserrat()))
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update user', style: GoogleFonts.montserrat()))
                    );
                  }
                } catch (error) {
                  print("Error updating user: $error");
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text('Update', style: GoogleFonts.montserrat(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final usersResponse = await http.get(Uri.parse("$apiUrl/get-users"));
      final ownersResponse = await http.get(Uri.parse("$apiUrl/get-owners"));
      final adminsResponse = await http.get(Uri.parse("$apiUrl/get-admins"));
      if (usersResponse.statusCode == 200 &&
          ownersResponse.statusCode == 200 &&
          adminsResponse.statusCode == 200) {
        final usersData = json.decode(usersResponse.body);
        final ownersData = json.decode(ownersResponse.body);
        final adminsData = json.decode(adminsResponse.body);
        setState(() {
          _users = usersData is List ? List<Map<String, dynamic>>.from(usersData) : [];
          _owners = ownersData is List ? List<Map<String, dynamic>>.from(ownersData) : [];
          _admins = adminsData is List ? List<Map<String, dynamic>>.from(adminsData) : [];
          _filteredUsers = _users; 
          _filteredOwners = _owners;
          _filteredAdmins = _admins;
          _isLoading = false;
        });
      } else {
        print("Failed to fetch data. Status codes: Users(${usersResponse.statusCode}), Owners(${ownersResponse.statusCode}), Admins(${adminsResponse.statusCode})");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching data: $error");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _roundedTextForm({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.montserrat(),
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFF8F8FB),
        labelText: label,
        labelStyle: GoogleFonts.montserrat(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurple, width: 2.1),
          borderRadius: BorderRadius.circular(13),
        ),
        prefixIcon: Icon(icon, color: Colors.deepPurple),
      ),
      validator: validator,
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final String email = user['email']?.toString() ?? "Unknown";
    final String encryptedPassword = user['password']?.toString() ?? "Unknown";
    final String password = decryptPassword(encryptedPassword);
    
    return FadeInUp(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "User Details",
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF492fad),
                  ),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.person, color: Colors.deepPurple),
                  title: Text(email, style: GoogleFonts.montserrat()),
                  subtitle: Text("Password: $password", style: GoogleFonts.montserrat()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _selectedOwner = user; 
                        _updateUser(); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text("Update", style: GoogleFonts.montserrat(color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _selectedOwner = user; 
                        _deleteUser(user['email']); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text("Delete", style: GoogleFonts.montserrat(color: Colors.white)),
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

  Widget _buildOwnerCard(Map<String, dynamic> owner) {
    final String name = owner['name']?.toString() ?? "Unknown";
    final String shopName = owner['shopname']?.toString() ?? "Unknown";
    final String address = owner['address']?.toString() ?? "Unknown";
    final String category=owner['category']?.toString()?? "Unknown";
    final String phone = owner['phone']?.toString() ?? "Unknown";
    final String username = owner['username']?.toString() ?? "Unknown";
    final String encryptedPassword = owner['password']?.toString() ?? "Unknown";
    final String password = decryptPassword(encryptedPassword);
    final String latitude = owner['latitude']?.toString() ?? "Unknown";
    final String longitude = owner['longitude']?.toString() ?? "Unknown";
    
    return FadeInUp(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Owner Details",
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF492fad),
                  ),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.store, color: Colors.deepPurple),
                  title: Text("$name - $shopName", style: GoogleFonts.montserrat()),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Address: $address", style: GoogleFonts.montserrat()),
                      Text("Phone Number: $phone", style: GoogleFonts.montserrat()),
                      Text("Category: $category",style: GoogleFonts.montserrat()),
                      Text("Username: $username", style: GoogleFonts.montserrat()),
                      Text("Password: $password", style: GoogleFonts.montserrat()),
                      Text("Latitude: $latitude", style: GoogleFonts.montserrat()),
                      Text("Longitude: $longitude", style: GoogleFonts.montserrat()),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _selectedOwner = owner; 
                        _updateOwner(); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text("Update", style: GoogleFonts.montserrat(color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _selectedOwner = owner; 
                        _deleteOwner(owner['username']); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text("Delete", style: GoogleFonts.montserrat(color: Colors.white)),
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

  Widget _buildAdminCard(Map<String, dynamic> admin) {
    final String name = admin['name']?.toString() ?? "Unknown";
    final String address = admin['address']?.toString() ?? "Unknown";
    final String username = admin['username']?.toString() ?? "Unknown";
    final String encryptedPassword = admin['password']?.toString() ?? "Unknown";
    final String password = decryptPassword(encryptedPassword);
    
    return FadeInUp(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Admin Details",
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF492fad),
                  ),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.person, color: Colors.deepPurple),
                  title: Text(name, style: GoogleFonts.montserrat()),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Address: $address", style: GoogleFonts.montserrat()),
                      Text("Username: $username", style: GoogleFonts.montserrat()),
                      Text("Password: $password", style: GoogleFonts.montserrat()),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _selectedOwner = admin; 
                        _updateAdmin(); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text("Update", style: GoogleFonts.montserrat(color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _selectedOwner = admin; 
                        _deleteAdmin(admin['username']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text("Delete", style: GoogleFonts.montserrat(color: Colors.white)),
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

  Widget _buildRoleButton(String role) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedRole = role;
          _searchController.clear(); 
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedRole == role ? Colors.deepPurple : Colors.grey[300],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(
        role.toUpperCase(),
        style: GoogleFonts.montserrat(
          color: selectedRole == role ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _filteredUsers.isEmpty
            ? Center(child: Text("No matching users found", style: GoogleFonts.montserrat()))
            : ListView.builder(
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: 100 * index),
                    child: ListTile(
                      leading: Icon(Icons.person, color: Colors.deepPurple),
                      title: Text(user['email'], style: GoogleFonts.montserrat()),
                      subtitle: Text("Password: ${decryptPassword(user['password'])}", 
                          style: GoogleFonts.montserrat()),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("User Details", style: GoogleFonts.montserrat()),
                              content: _buildUserCard(user),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Close", style: GoogleFonts.montserrat()),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              );
  }

  Widget _buildOwnerList() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _filteredOwners.isEmpty
            ? Center(child: Text("No matching owners found", style: GoogleFonts.montserrat()))
            : ListView.builder(
                itemCount: _filteredOwners.length,
                itemBuilder: (context, index) {
                  final owner = _filteredOwners[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: 100 * index),
                    child: ListTile(
                      leading: Icon(Icons.store, color: Colors.deepPurple),
                      title: Text(owner['shopname'], style: GoogleFonts.montserrat()),
                      subtitle: Text("Address: ${owner['address']}", 
                          style: GoogleFonts.montserrat()),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Owner Details", style: GoogleFonts.montserrat()),
                              content: _buildOwnerCard(owner),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Close", style: GoogleFonts.montserrat()),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              );
  }

  Widget _buildAdminList() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _filteredAdmins.isEmpty
            ? Center(child: Text("No matching admins found", style: GoogleFonts.montserrat()))
            : ListView.builder(
                itemCount: _filteredAdmins.length,
                itemBuilder: (context, index) {
                  final admin = _filteredAdmins[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: 100 * index),
                    child: ListTile(
                      leading: Icon(Icons.admin_panel_settings, color: Colors.deepPurple),
                      title: Text(admin['username'], style: GoogleFonts.montserrat()),
                      subtitle: Text("Password: ${decryptPassword(admin['password'])}", 
                          style: GoogleFonts.montserrat()),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Admin Details", style: GoogleFonts.montserrat()),
                              content: _buildAdminCard(admin),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Close", style: GoogleFonts.montserrat()),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout', style: GoogleFonts.montserrat()),
          content: Text('Do you want to logout?', style: GoogleFonts.montserrat()),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: GoogleFonts.montserrat()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/adminLogin');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text('OK', style: GoogleFonts.montserrat()),
            ),
          ],
        );
      },
    );
  }

  void _showRoleMenu(BuildContext context) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        overlay.size.width - 150,
        overlay.size.height - 200,
        10,
        10,
      ),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.person_add, color: Colors.deepPurple),
            title: Text('Admin Register', style: GoogleFonts.montserrat()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => AdminRegisterScreen()));
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.person_add, color: Colors.deepPurple),
            title: Text('Owner Register', style: GoogleFonts.montserrat()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => OwnerRegisterScreen()));
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Super Admin Dashboard", style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple[900],
        )),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.deepPurple[800]),
            onPressed: _fetchData,
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.deepPurple[800]),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Pretty gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          if (w > 560)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(color: Colors.transparent),
              ),
            ),
          Center(
            child: SingleChildScrollView(
              child: FadeInDown(
                duration: Duration(milliseconds: 700),
                child: Container(
                  width: w < 420 ? w * 0.99 : w < 700 ? w * 0.85 : w * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.93),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.13),
                        blurRadius: 16,
                        offset: Offset(3, 14),
                      )
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 34, vertical: 34),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'admin-avatar',
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.deepPurple,
                          child: Icon(Icons.admin_panel_settings, size: 54, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text("Super Admin Panel", style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                        color: Color(0xFF492fad)
                      )),
                      SizedBox(height: 18),
                      _roundedTextForm(
                        label: 'Search',
                        icon: Icons.search,
                        controller: _searchController,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildRoleButton("users"),
                          _buildRoleButton("owners"),
                          _buildRoleButton("admins"),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: selectedRole == "users"
                            ? _buildUserList()
                            : selectedRole == "owners"
                                ? _buildOwnerList()
                                : _buildAdminList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.more_vert, color: Colors.white),
        onPressed: () {
          _showRoleMenu(context);
        },
      ),
    );
  }
}