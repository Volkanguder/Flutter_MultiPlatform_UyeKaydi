// Flutter'ın temel arayüz kütüphanesi
import 'package:flutter/material.dart';

// Uygulamanın Türkçe yerelleştirme desteği için gerekli paket
import 'package:flutter_localizations/flutter_localizations.dart';

// Firebase'i Flutter içinde başlatmak için gerekli paket
import 'package:firebase_core/firebase_core.dart';

// Firestore veritabanı işlemleri için gerekli paket
import 'package:cloud_firestore/cloud_firestore.dart';

// flutterfire configure komutu ile otomatik oluşan Firebase ayar dosyası
import 'firebase_options.dart';

// Login ekranını açmak için gerekli dosya
import 'login_page.dart';

/// Uygulamanın başlangıç noktası
void main() async {
  /// Firebase gibi async işlemlerden önce Flutter binding başlatılır
  WidgetsFlutterBinding.ensureInitialized();

  /// Firebase başlatılır
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

debugPrint('FIREBASE PROJECT ID: ${DefaultFirebaseOptions.currentPlatform.projectId}');
debugPrint('FIREBASE APP ID: ${DefaultFirebaseOptions.currentPlatform.appId}');

  /// Uygulama başlatılır
  runApp(const YeniUyeKayitApp());
}

/// Ana uygulama widget'ı
class YeniUyeKayitApp extends StatelessWidget {
  const YeniUyeKayitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /// Sağ üst debug yazısını kaldırır
      debugShowCheckedModeBanner: false,

      /// Uygulama başlığı
      title: 'Yeni Üye Kaydı',

      /// Türkçe locale
      locale: const Locale('tr', 'TR'),

      /// Türkçe yerelleştirme desteği
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      /// Desteklenen diller
      supportedLocales: const [
        Locale('tr', 'TR'),
      ],

      /// Tema ayarları
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),

      /// Şimdilik açılış ekranı login
      home: const LoginPage(),
    );
  }
}

/// Üye kayıt ekranı
class YeniUyeKayitSayfasi extends StatefulWidget {
  const YeniUyeKayitSayfasi({super.key});

  @override
  State<YeniUyeKayitSayfasi> createState() => _YeniUyeKayitSayfasiState();
}

class _YeniUyeKayitSayfasiState extends State<YeniUyeKayitSayfasi> {
  /// Form doğrulama anahtarı
  final _formKey = GlobalKey<FormState>();

  /// Text alanları için controller'lar
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonController = TextEditingController();

  /// Seçim alanları
  String? _cinsiyet;
  DateTime? _dogumTarihi;

  /// Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    /// Controller'ları kapatır
    _adController.dispose();
    _soyadController.dispose();
    _emailController.dispose();
    _telefonController.dispose();
    super.dispose();
  }

  /// Doğum tarihi seçme işlemi
  Future<void> _dogumTarihiSec() async {
    final now = DateTime.now();

    final secilenTarih = await showDatePicker(
      context: context,
      locale: const Locale('tr', 'TR'),
      initialDate: DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'Doğum Tarihi Seç',
      cancelText: 'İptal',
      confirmText: 'Tamam',
      fieldHintText: 'gg/aa/yyyy',
      fieldLabelText: 'Doğum tarihi',
    );

    if (secilenTarih != null) {
      setState(() {
        _dogumTarihi = secilenTarih;
      });
    }
  }

  /// Kaydetme işlemi
  /// Artık veriyi belleğe değil Firestore'a yazıyoruz
Future<void> _kaydet() async {
  debugPrint('KAYDET BUTONUNA BASILDI');

  final formGecerli = _formKey.currentState?.validate() ?? false;

  if (!formGecerli) return;

  if (_cinsiyet == null || _cinsiyet!.isEmpty) {
    _mesajGoster('Lütfen cinsiyet seçiniz.');
    return;
  }

  if (_dogumTarihi == null) {
    _mesajGoster('Lütfen doğum tarihi seçiniz.');
    return;
  }

  try {
    debugPrint('Firestore\'a veri yazılıyor...');

    await _firestore.collection('members').add({
      'ad': _adController.text.trim(),
      'soyad': _soyadController.text.trim(),
      'email': _emailController.text.trim(),
      'telefon': _telefonController.text.trim(),
      'cinsiyet': _cinsiyet,
      'dogumTarihi': Timestamp.fromDate(_dogumTarihi!),
      'createdAt': FieldValue.serverTimestamp(),
    });

    _formuTemizle();
    _mesajGoster('Yeni üye kaydı Firestore veritabanına eklendi.');
  } catch (e) {
    debugPrint('FIRESTORE KAYIT HATASI: $e');
    _mesajGoster('Kayıt hatası: $e');
  }
}

  /// Formu temizler
  void _formuTemizle() {
    _formKey.currentState?.reset();

    _adController.clear();
    _soyadController.clear();
    _emailController.clear();
    _telefonController.clear();

    setState(() {
      _cinsiyet = null;
      _dogumTarihi = null;
    });
  }

  /// Snackbar mesajı gösterir
  void _mesajGoster(String mesaj) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(mesaj)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Üst başlık
      appBar: AppBar(
        title: const Text('Yeni Üye Kaydı'),
        centerTitle: true,
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            /// Geniş ekranda yan yana
            final genisEkran = constraints.maxWidth >= 900;

            if (genisEkran) {
              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _formAlani(),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 2,
                    child: _uyeListesi(),
                  ),
                ],
              );
            }

            /// Dar ekranda alt alta
            return Column(
              children: [
                Expanded(
                  flex: 3,
                  child: _formAlani(),
                ),
                const Divider(height: 1),
                Expanded(
                  flex: 2,
                  child: _uyeListesi(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Form alanı
  Widget _formAlani() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yeni Üye Formu',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Mobil, web ve masaüstü uyumlu örnek kayıt uygulaması',
                    ),
                    const SizedBox(height: 24),

                    /// Ad alanı
                    _buildTextField(
                      controller: _adController,
                      label: 'Ad',
                      validator: _bosKontrol,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),

                    /// Soyad alanı
                    _buildTextField(
                      controller: _soyadController,
                      label: 'Soyad',
                      validator: _bosKontrol,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),

                    /// E-posta alanı
                    _buildTextField(
                      controller: _emailController,
                      label: 'E-posta',
                      keyboardType: TextInputType.emailAddress,
                      validator: _emailKontrol,
                    ),
                    const SizedBox(height: 16),

                    /// Telefon alanı
                    _buildTextField(
                      controller: _telefonController,
                      label: 'Telefon',
                      keyboardType: TextInputType.phone,
                      validator: _telefonKontrol,
                    ),
                    const SizedBox(height: 16),

                    /// Cinsiyet alanı
                    DropdownButtonFormField<String>(
                      value: _cinsiyet,
                      decoration: const InputDecoration(
                        labelText: 'Cinsiyet',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Kadın',
                          child: Text('Kadın'),
                        ),
                        DropdownMenuItem(
                          value: 'Erkek',
                          child: Text('Erkek'),
                        ),
                        DropdownMenuItem(
                          value: 'Belirtmek istemiyorum',
                          child: Text('Belirtmek istemiyorum'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _cinsiyet = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    /// Doğum tarihi seçim alanı
                    InkWell(
                      onTap: _dogumTarihiSec,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Doğum Tarihi',
                          suffixIcon: Icon(Icons.calendar_month),
                        ),
                        child: Text(
                          _dogumTarihi == null
                              ? 'Tarih seçiniz'
                              : _tarihFormatla(_dogumTarihi!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    /// Butonlar
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: _kaydet,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Kaydet'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _formuTemizle,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Temizle'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Üye listesi
  /// Artık Firestore stream ile canlı veri gösteriyoruz
  Widget _uyeListesi() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kayıtlı Üyeler',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              /// Firestore'dan gelen canlı veriyi dinler
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('members')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    /// Yüklenme durumu
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    /// Hata durumu
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Veriler yüklenirken hata oluştu.'),
                      );
                    }

                    /// Veri yoksa
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('Henüz üye eklenmedi.'),
                      );
                    }

                    /// Gelen belgeler
                    final docs = snapshot.data!.docs;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Toplam üye: ${docs.length}'),
                        const SizedBox(height: 16),

                        Expanded(
                          child: ListView.separated(
                            itemCount: docs.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final data =
                                  doc.data() as Map<String, dynamic>;

                              final ad = data['ad'] ?? '';
                              final soyad = data['soyad'] ?? '';
                              final email = data['email'] ?? '';
                              final telefon = data['telefon'] ?? '';
                              final cinsiyet = data['cinsiyet'] ?? '';
                              final dogumTarihiTimestamp =
                                  data['dogumTarihi'] as Timestamp?;

                              final dogumTarihi = dogumTarihiTimestamp != null
                                  ? dogumTarihiTimestamp.toDate()
                                  : null;

                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    ad.isNotEmpty
                                        ? ad[0].toUpperCase()
                                        : '?',
                                  ),
                                ),
                                title: Text('$ad $soyad'),
                                subtitle: Text(
                                  '$email\n'
                                  '$telefon\n'
                                  '$cinsiyet - ${dogumTarihi != null ? _tarihFormatla(dogumTarihi) : '-'}',
                                ),
                                isThreeLine: true,

                                /// Şimdilik silme açık
                                /// Sonraki aşamada rol sistemine göre kısıtlayacağız
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Sil',
                                  onPressed: () async {
                                    await _firestore
                                        .collection('members')
                                        .doc(doc.id)
                                        .delete();

                                    _mesajGoster('Üye kaydı silindi.');
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Yardımcı text field widget'ı
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
      ),
    );
  }

  /// Boş alan kontrolü
  String? _bosKontrol(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu alan zorunludur';
    }
    return null;
  }

  /// E-posta kontrolü
  String? _emailKontrol(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu alan zorunludur';
    }

    if (!value.contains('@') || !value.contains('.')) {
      return 'Geçerli bir e-posta giriniz';
    }

    return null;
  }

  /// Telefon kontrolü
  String? _telefonKontrol(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu alan zorunludur';
    }

    if (value.trim().length < 10) {
      return 'Telefon numarası en az 10 karakter olmalıdır';
    }

    return null;
  }

  /// Tarihi Gün/Ay/Yıl formatında gösterir
  String _tarihFormatla(DateTime tarih) {
    final gun = tarih.day.toString().padLeft(2, '0');
    final ay = tarih.month.toString().padLeft(2, '0');
    final yil = tarih.year.toString();

    return '$gun/$ay/$yil';
  }
}

/// Üye veri modeli
/// Şimdilik bu model ekranda doğrudan kullanılmıyor
/// Ama ileride repository / service yapısında faydalı olacak
class Uye {
  final String ad;
  final String soyad;
  final String email;
  final String telefon;
  final String cinsiyet;
  final DateTime dogumTarihi;

  Uye({
    required this.ad,
    required this.soyad,
    required this.email,
    required this.telefon,
    required this.cinsiyet,
    required this.dogumTarihi,
  });
}