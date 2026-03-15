import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Uygulamanın başlangıç noktası
void main() {
  runApp(const YeniUyeKayitApp());
}

/// Ana uygulama
class YeniUyeKayitApp extends StatelessWidget {
  const YeniUyeKayitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yeni Üye Kaydı',

      /// Uygulamanın Türkçe çalışmasını sağlar
      locale: const Locale('tr', 'TR'),

      /// Flutter'ın yerelleştirme desteği
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      /// Desteklenen diller
      supportedLocales: const [
        Locale('tr', 'TR'),
      ],

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const YeniUyeKayitSayfasi(),
    );
  }
}

/// StatefulWidget kullanıyoruz çünkü:
/// - form alanları değişiyor
/// - liste güncelleniyor
/// - kullanıcı seçim yaptıkça ekran yenileniyor
class YeniUyeKayitSayfasi extends StatefulWidget {
  const YeniUyeKayitSayfasi({super.key});

  @override
  State<YeniUyeKayitSayfasi> createState() => _YeniUyeKayitSayfasiState();
}

class _YeniUyeKayitSayfasiState extends State<YeniUyeKayitSayfasi> {
  /// Form doğrulama anahtarı
  final _formKey = GlobalKey<FormState>();

  /// Metin alanları için controller'lar
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonController = TextEditingController();

  /// Seçim alanları
  String? _cinsiyet;
  DateTime? _dogumTarihi;

  /// Eklenen üyeler burada tutulur
  final List<Uye> _uyeler = [];

  @override
  void dispose() {
    _adController.dispose();
    _soyadController.dispose();
    _emailController.dispose();
    _telefonController.dispose();
    super.dispose();
  }

  /// Doğum tarihi seçme
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
  void _kaydet() {
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

    final yeniUye = Uye(
      ad: _adController.text.trim(),
      soyad: _soyadController.text.trim(),
      email: _emailController.text.trim(),
      telefon: _telefonController.text.trim(),
      cinsiyet: _cinsiyet!,
      dogumTarihi: _dogumTarihi!,
    );

    setState(() {
      _uyeler.insert(0, yeniUye);
    });

    _formuTemizle();
    _mesajGoster('Yeni üye kaydı başarıyla eklendi.');
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
      appBar: AppBar(
        title: const Text('Yeni Üye Kaydı'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
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

                    _buildTextField(
                      controller: _adController,
                      label: 'Ad',
                      validator: _bosKontrol,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _soyadController,
                      label: 'Soyad',
                      validator: _bosKontrol,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _emailController,
                      label: 'E-posta',
                      keyboardType: TextInputType.emailAddress,
                      validator: _emailKontrol,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _telefonController,
                      label: 'Telefon',
                      keyboardType: TextInputType.phone,
                      validator: _telefonKontrol,
                    ),
                    const SizedBox(height: 16),

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
              const SizedBox(height: 8),
              Text('Toplam üye: ${_uyeler.length}'),
              const SizedBox(height: 16),
              Expanded(
                child: _uyeler.isEmpty
                    ? const Center(
                        child: Text('Henüz üye eklenmedi.'),
                      )
                    : ListView.separated(
                        itemCount: _uyeler.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final uye = _uyeler[index];

                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                uye.ad.isNotEmpty ? uye.ad[0].toUpperCase() : '?',
                              ),
                            ),
                            title: Text('${uye.ad} ${uye.soyad}'),
                            subtitle: Text(
                              '${uye.email}\n'
                              '${uye.telefon}\n'
                              '${uye.cinsiyet} - ${_tarihFormatla(uye.dogumTarihi)}',
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Sil',
                              onPressed: () {
                                setState(() {
                                  _uyeler.removeAt(index);
                                });
                                _mesajGoster('Üye kaydı silindi.');
                              },
                            ),
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

  /// Tekrarlayan text alanlarını kısaltmak için yardımcı widget
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

  /// Boş kontrolü
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