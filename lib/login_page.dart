/// Flutter UI kütüphanesi
import 'package:flutter/material.dart';

/// Firebase Authentication paketi
import 'package:firebase_auth/firebase_auth.dart';

/// Giriş başarılı olunca açılacak sayfa
import 'main.dart';

/// Login ekranı Stateful çünkü form değişiyor
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  /// Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Kullanıcı adı controller
  final _usernameController = TextEditingController();

  /// Şifre controller
  final _passwordController = TextEditingController();

  /// Giriş sırasında loading göstermek için
  bool _loading = false;

  /// Giriş işlemi
  Future<void> _login() async {

    /// Kullanıcı adı alınır
    final username = _usernameController.text.trim();

    /// Şifre alınır
    final password = _passwordController.text.trim();

    /// Kullanıcı adı boş mu kontrol edilir
    if (username.isEmpty || password.isEmpty) {
      _mesaj("Kullanıcı adı ve şifre gerekli");
      return;
    }

    /// Kullanıcı adını e-posta formatına çeviriyoruz
    /// örnek:
    /// volkan.guder -> volkan.guder@nazrum.com
    final email = "$username@nazrum.com";

    try {

      setState(() {
        _loading = true;
      });

      /// Firebase login
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      /// Başarılı giriş sonrası ana sayfaya yönlendir
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const YeniUyeKayitSayfasi(),
        ),
      );

    } on FirebaseAuthException catch (e) {

      /// Firebase hata mesajı
      if (e.code == 'user-not-found') {
        _mesaj("Kullanıcı bulunamadı");
      } else if (e.code == 'wrong-password') {
        _mesaj("Şifre hatalı");
      } else {
        _mesaj("Giriş başarısız: ${e.message}");
      }

    } catch (e) {

      /// Genel hata
      _mesaj("Bir hata oluştu");

    } finally {

      setState(() {
        _loading = false;
      });

    }
  }

  /// Snackbar mesaj gösterme
  void _mesaj(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// Üst başlık
      appBar: AppBar(
        title: const Text("Giriş Yap"),
        centerTitle: true,
      ),

      body: Center(
        child: SizedBox(
          width: 400,

          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [

                /// Kullanıcı adı alanı
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Kullanıcı Adı",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                /// Şifre alanı
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Şifre",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                /// Giriş butonu
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,

                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text("Giriş Yap"),
                  ),
                ),

                const SizedBox(height: 16),

                /// Yönetici ile iletişim butonu
                TextButton(
                  onPressed: () {

                    /// İstersen buraya WhatsApp linki koyabiliriz
                    _mesaj("Yetki almak için yöneticiniz ile iletişime geçin.");

                  },
                  child: const Text("Yetki almak için yönetici ile iletişime geç"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}