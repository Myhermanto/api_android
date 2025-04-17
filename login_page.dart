import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'admin_beranda.dart';
import 'users/user_beranda.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true; // Track password visibility

  // Data login statis untuk admin
  final String adminEmail = "admin@gmail.com";
  final String adminPassword = "123456";

  // Validasi email menggunakan regex
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  // Login sebagai admin
  void loginSebagaiAdmin(BuildContext context, String email, String password) {
    if (email == adminEmail && password == adminPassword) {
      _tampilkanDialog(
          context, 'Proses Masuk Berhasil!', 'Selamat Datang, Admin!',
          sukses: true, isAdmin: true);
    } else {
      _tampilkanDialog(
          context, 'Proses Masuk Gagal', 'Email atau kata sandi admin salah.');
    }
  }

  // Login sebagai pengguna biasa (dengan database)
  Future<void> loginSebagaiPengguna(
      BuildContext context, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/api_android/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] != null) {
          _tampilkanDialog(context, 'Proses Masuk Gagal', data['error']);
        } else {
          // Ambil nama, id, dan email pengguna dari respons
          final String namaPengguna = data['user']['name'];
          final String idPengguna = data['user']['id'];
          final String emailPengguna = data['user']['email'];

          _tampilkanDialog(context, 'Proses Masuk Berhasil', data['message'],
              sukses: true,
              isAdmin: false,
              namaPengguna: namaPengguna,
              idPengguna: idPengguna,
              emailPengguna: emailPengguna);
        }
      } else {
        _tampilkanDialog(context, 'Error',
            'Gagal terhubung ke server. Kode status: ${response.statusCode}');
      }
    } catch (e) {
      _tampilkanDialog(context, 'Error', 'Terjadi kesalahan: $e');
    }
  }

  // Fungsi untuk menampilkan dialog
  void _tampilkanDialog(BuildContext context, String judul, String pesan,
      {bool sukses = false,
      bool isAdmin = false,
      String namaPengguna = '',
      String idPengguna = '',
      String emailPengguna = ''}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(judul),
        content: Text(pesan),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
              if (sukses) {
                // Navigasi berdasarkan peran
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => isAdmin
                        ? const AdminHalaman()
                        : UserBerandaPage(
                            userName: namaPengguna,
                            userId: idPengguna,
                            userEmail: emailPengguna,
                          ), // Kirim data ke UserBerandaPage
                  ),
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Masuk"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Form Email
                _bangunTextField(
                  controller: emailController,
                  label: 'Email',
                  icon: Icons.mail,
                ),
                const SizedBox(height: 20),
                // Form Password
                _bangunTextField(
                  controller: passwordController,
                  label: 'Kata Sandi',
                  icon: Icons.lock,
                  obscureText: _obscureText,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText =
                            !_obscureText; // Toggle password visibility
                      });
                    },
                  ),
                ),
                const SizedBox(height: 40),
                // Tombol Login
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      String email = emailController.text;
                      String password = passwordController.text;

                      if (!isValidEmail(email)) {
                        _tampilkanDialog(context, 'Email Tidak Valid',
                            'Masukkan alamat email yang valid.');
                      } else if (email == adminEmail) {
                        loginSebagaiAdmin(context, email, password);
                      } else {
                        loginSebagaiPengguna(context, email, password);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD2B48C),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget untuk TextField
  Widget _bangunTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

