import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> _owners = [];
  Map<String, dynamic>? _selectedOwner;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredOwners = [];
  final String apiUrl = "http://localhost:5002";

  @override
  void initState() {
    super.initState();
    _fetchData();
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

  Future<void> _fetchData() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/get-owners"));
      if (response.statusCode == 200) {
        final ownersData = json.decode(response.body);
        setState(() {
          _owners = ownersData is List ? List<Map<String, dynamic>>.from(ownersData) : [];
          _filteredOwners = _owners;
        });
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  Future<void> _deleteOwner(String username) async {
    try {
      final response = await http.delete(Uri.parse("$apiUrl/delete-owner/$username"));
      if (response.statusCode == 200) {
        setState(() {
          _owners.removeWhere((owner) => owner['username'] == username);
          _filteredOwners.removeWhere((owner) => owner['username'] == username);
          _selectedOwner = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Owner deleted successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete owner')));
      }
    } catch (error) {
      print("Error deleting owner: $error");
    }
  }

  void _filterOwners(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOwners = _owners;
      } else {
        _filteredOwners = _owners
            .where((owner) =>
                owner['name'].toLowerCase().contains(query.toLowerCase()) ||
                owner['shopname'].toLowerCase().contains(query.toLowerCase()) ||
                owner['username'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _updateOwner() async {
    if (_selectedOwner == null) return;
    TextEditingController nameController = TextEditingController(text: _selectedOwner!['name']);
    TextEditingController shopController = TextEditingController(text: _selectedOwner!['shopname']);
    TextEditingController addressController = TextEditingController(text: _selectedOwner!['address']);
    TextEditingController phoneController = TextEditingController(text: _selectedOwner!['phone']);
    TextEditingController userController = TextEditingController(text: _selectedOwner!['username']);
    TextEditingController latitudeController = TextEditingController(text: _selectedOwner!['latitude']);
    TextEditingController longitudeController = TextEditingController(text: _selectedOwner!['longitude']);
    showDialog(
      context: context,
      builder: (context) {
        return FadeIn(
          duration: Duration(milliseconds: 400),
          child: AlertDialog(
            title: Text('Update Owner Details', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _roundedField('Name', nameController),
                  _roundedField('Shop Name', shopController),
                  _roundedField('Address', addressController),
                  _roundedField('Phone Number', phoneController, inputType: TextInputType.phone),
                  _roundedField('Username', userController),
                  _roundedField('Latitude', latitudeController, inputType: TextInputType.numberWithOptions(decimal: true)),
                  _roundedField('Longitude', longitudeController, inputType: TextInputType.numberWithOptions(decimal: true)),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () async {
                  final updatedData = {
                    "name": nameController.text,
                    "shopname": shopController.text,
                    "address": addressController.text,
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
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Owner updated successfully')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update owner')));
                    }
                  } catch (error) {
                    print("Error updating owner: $error");
                  }
                  Navigator.pop(context);
                },
                child: Text('Update', style: TextStyle(color: Colors.white)),
              ),
            ],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );
      },
    );
  }

  Widget _roundedField(String label, TextEditingController controller, {TextInputType? inputType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(11)),
          filled: true,
          fillColor: Color(0xFFF4F4FB),
        ),
      ),
    );
  }

  void _toggleOwnerDetails(Map<String, dynamic> owner) {
    setState(() {
      if (_selectedOwner == owner) {
        _selectedOwner = null;
      } else {
        _selectedOwner = owner;
        _showOwnerDetailsDialog();
      }
    });
  }

  Widget _buildOwnerList() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: EdgeInsets.symmetric(vertical: 10),
      color: Colors.white.withOpacity(0.89),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by name, shop or username',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                prefixIcon: Icon(Icons.search),
                fillColor: Colors.blue[50], filled: true,
              ),
              onChanged: _filterOwners,
            ),
            SizedBox(height: 18),
            Text("Registered Owners",
                style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5147c4))),
            Divider(),
            _filteredOwners.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(child: Text("No owners found", style: GoogleFonts.montserrat(color: Colors.grey))),
                  )
                : ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _filteredOwners.length,
                    separatorBuilder: (_, __) => SizedBox(height: 4),
                    itemBuilder: (context, idx) {
                      final owner = _filteredOwners[idx];
                      return ZoomIn(
                        duration: Duration(milliseconds: 320 + idx * 55),
                        child: Card(
                          color: Colors.deepPurple.withOpacity(0.06),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: Icon(Icons.store, color: Colors.deepPurple),
                            ),
                            title: Text("${owner['name']} - ${owner['shopname']}", style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
                            subtitle: Text("Username: ${owner['username']}"),
                            trailing: Icon(Icons.arrow_forward_ios, size: 17, color: Colors.grey.shade400),
                            onTap: () => _toggleOwnerDetails(owner),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void _showOwnerDetailsDialog() {
    if (_selectedOwner == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FadeIn(
          duration: Duration(milliseconds: 300),
          child: AlertDialog(
            title: Text("Owner Details", style: GoogleFonts.montserrat(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ownerDetailRow(Icons.person, "Name", _selectedOwner!['name']),
                  _ownerDetailRow(Icons.store, "Shop", _selectedOwner!['shopname']),
                  _ownerDetailRow(Icons.location_on, "Address", _selectedOwner!['address']),
                  _ownerDetailRow(Icons.phone, "Phone", _selectedOwner!['phone']),
                  _ownerDetailRow(Icons.account_circle, "Username", _selectedOwner!['username']),
                  _ownerDetailRow(Icons.lock, "Password", decryptPassword(_selectedOwner!['password'])),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.deepPurple, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                        ),
                        icon: Icon(Icons.edit, color: Colors.deepPurple),
                        label: Text("Edit", style: GoogleFonts.montserrat(color: Colors.deepPurple)),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _updateOwner();
                        },
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                        ),
                        icon: Icon(Icons.delete_outline, color: Colors.red),
                        label: Text("Delete", style: GoogleFonts.montserrat(color: Colors.red)),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _deleteOwner(_selectedOwner!['username']);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        );
      },
    );
  }

  Widget _ownerDetailRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              "$label: $value",
              style: GoogleFonts.montserrat(fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/adminLogin');
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showRoleMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.96),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 21),
        child: ListTile(
          leading: Icon(Icons.person_add, color: Colors.deepPurple),
          title: Text('Owner Register', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/ownerRegister');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.withOpacity(0.91),
        title: Text('Admin Dashboard',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _fetchData,
            icon: Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              _showLogoutDialog(context);
            },
            tooltip: 'Logout',
          ),
        ],
        elevation: 13,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
        ),
      ),
      backgroundColor: w > 750
          ? null
          : Color.fromARGB(255, 246, 246, 253),
      body: Container(
        decoration: w > 750
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7f53ac), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : null,
        child: Padding(
          padding: EdgeInsets.only(top: 38, left: w < 700 ? 3 : 16, right: w < 700 ? 3 : 16, bottom: 8),
          child: SingleChildScrollView(
            child: Column(
              children: [
                FadeIn(
                  duration: Duration(milliseconds: 520),
                  child: _buildOwnerList(),
                ),
                SizedBox(height: 25),
                // You can add more dashboard content here
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRoleMenu(context),
        icon: Icon(Icons.person_add),
        label: Text('Add Owner', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
