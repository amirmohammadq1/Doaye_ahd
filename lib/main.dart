import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dua_data.dart';
import 'native_actions.dart';

const Color kGold = Color(0xFFC9A24B);

/// رنگ با شفافیت دلخواه (۰ تا ۱)
Color _a(Color c, double opacity) => c.withAlpha((opacity * 255).round());

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const DoayeAhdApp());
}

/// -------------------- مداحان --------------------
class Reciter {
  final String id;
  final String name;
  final String file; // نام فایل mp3 داخل assets/audio
  const Reciter(this.id, this.name, this.file);
}

const List<Reciter> kReciters = [
  Reciter('farahmand', 'فرهمند', 'farahmand.mp3'),
  Reciter('mirdamad', 'میرداماد', 'mirdamad.mp3'),
  Reciter('meysam_kazem', 'میثم کاظم', 'meysam_kazem.mp3'),
  Reciter('asadi', 'اسدی', 'asadi.mp3'),
];

/// -------------------- اپ --------------------
class DoayeAhdApp extends StatelessWidget {
  const DoayeAhdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دعای عهد',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const _SplashGate(),
    );
  }
}

/// -------------------- اسپلش تمام‌صفحه --------------------
class _SplashGate extends StatefulWidget {
  const _SplashGate();
  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      body: SizedBox.expand(
        child: Image.asset(
          'assets/splash.webp',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFF0B0B0B)),
        ),
      ),
    );
  }
}

/// -------------------- صفحه اصلی --------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription<dynamic>> _subs = [];

  // موقعیت و مدت صوت جدا از setState نگه داشته می‌شوند تا فقط نوار پخش دوباره ساخته شود
  final ValueNotifier<Duration> _position = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> _duration = ValueNotifier(Duration.zero);
  final ValueNotifier<double?> _dragValue = ValueNotifier(null);

  bool _isPlaying = false;
  bool _barVisible = false;
  int _reciterIndex = 0;
  double _fontScale = 1.0;
  bool _nightMode = false;
  bool _vibration = true;
  SharedPreferences? _prefs;

  Reciter get _reciter => kReciters[_reciterIndex];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _subs.add(_player.onPositionChanged.listen((p) => _position.value = p));
    _subs.add(_player.onDurationChanged.listen((d) => _duration.value = d));
    _subs.add(_player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _isPlaying = s == PlayerState.playing);
    }));
    _subs.add(_player.onPlayerComplete.listen((_) {
      _position.value = Duration.zero;
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _barVisible = false;
        });
      }
    }));
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefs = prefs;
      _reciterIndex = prefs.getInt('reciter') ?? 0;
      _fontScale = prefs.getDouble('fontScale') ?? 1.0;
      _nightMode = prefs.getBool('nightMode') ?? false;
      _vibration = prefs.getBool('vibration') ?? true;
    });
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _player.dispose();
    _position.dispose();
    _duration.dispose();
    _dragValue.dispose();
    super.dispose();
  }

  void _lightVibrate() {
    if (_vibration) HapticFeedback.selectionClick();
  }

  // ---------------- پخش ----------------
  Future<void> _togglePlay() async {
    _lightVibrate();
    try {
      if (_isPlaying) {
        await _player.pause();
        setState(() => _isPlaying = false);
      } else {
        if (_player.state == PlayerState.paused) {
          await _player.resume(); // ادامه از همان‌جا که مکث شده
        } else {
          await _player.play(AssetSource('audio/${_reciter.file}'));
        }
        setState(() {
          _isPlaying = true;
          _barVisible = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _barVisible = false;
        });
      }
    }
  }

  Future<void> _closePlayer() async {
    _lightVibrate();
    await _player.stop();
    _position.value = Duration.zero;
    if (mounted) {
      setState(() {
        _isPlaying = false;
        _barVisible = false;
      });
    }
  }

  Future<void> _seekTo(int ms) async {
    final max = _duration.value.inMilliseconds;
    if (max <= 0) return;
    final target = ms.clamp(0, max).toInt();
    _position.value = Duration(milliseconds: target);
    await _player.seek(Duration(milliseconds: target));
  }

  Future<void> _seekBy(int seconds) async {
    _lightVibrate();
    await _seekTo(_position.value.inMilliseconds + seconds * 1000);
  }

  Future<void> _selectReciter(int index) async {
    _lightVibrate();
    final wasPlaying = _isPlaying;
    await _player.stop();
    _position.value = Duration.zero;
    _duration.value = Duration.zero;
    setState(() {
      _reciterIndex = index;
      _isPlaying = false;
      _barVisible = wasPlaying;
    });
    _prefs?.setInt('reciter', index);
    if (wasPlaying) {
      await _player.play(AssetSource('audio/${_reciter.file}'));
      if (mounted) setState(() => _isPlaying = true);
    }
  }

  void _zoom(double delta) {
    _lightVibrate();
    setState(() {
      _fontScale = (_fontScale + delta).clamp(0.8, 1.6);
    });
    _prefs?.setDouble('fontScale', _fontScale);
  }

  void _toggleNight() {
    setState(() => _nightMode = !_nightMode);
    _prefs?.setBool('nightMode', _nightMode);
  }

  void _toggleVibration() {
    setState(() => _vibration = !_vibration);
    _prefs?.setBool('vibration', _vibration);
  }

  // ---------------- ساخت صفحه ----------------
  @override
  Widget build(BuildContext context) {
    final bg = _nightMode ? const Color(0xFF121212) : const Color(0xFFF6EFDF);
    final cardColor = _nightMode ? const Color(0xFF1E1E1E) : Colors.white;
    final arabicColor = _nightMode ? const Color(0xFFF3E9D2) : const Color(0xFF2A2110);
    final farsiColor = _nightMode ? Colors.white70 : const Color(0xFF6B5A2E);
    // کادر ترجمه: کم‌رنگ و هماهنگ با کارت، نه زرد پررنگ
    final translationBg = _nightMode ? const Color(0xFF211E16) : const Color(0xFFFBF8F0);
    final translationBorder = _a(kGold, _nightMode ? 0.20 : 0.28);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(kGold),
            _buildPlayerBar(kGold, cardColor),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                itemCount: kDuaSections.length + 1, // +۱ برای کادر پایانی
                itemBuilder: (context, index) {
                  if (index == kDuaSections.length) {
                    return _buildClosingCard(cardColor, arabicColor, farsiColor);
                  }
                  final section = kDuaSections[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (section.note != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            section.note!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _a(farsiColor, 0.55),
                              fontSize: 11.5 * _fontScale,
                            ),
                          ),
                        ),
                      _buildSectionCard(section, cardColor, arabicColor, farsiColor, translationBg, translationBorder),
                    ],
                  );
                },
              ),
            ),
            _buildBottomBar(kGold, cardColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(DuaSection section, Color cardColor, Color arabicColor, Color farsiColor,
      Color translationBg, Color translationBorder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _a(Colors.black, 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            section.arabic,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'QuranFont',
              color: arabicColor,
              fontSize: 21 * _fontScale,
              height: 2.0,
            ),
          ),
          _buildOrnamentDivider(kGold),
          // ترجمه: زمینه‌ی بسیار ملایم + حاشیه‌ی نازک + یک نوار طلایی باریک در کنار
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: translationBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: translationBorder),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 3.5, color: _a(kGold, 0.65)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Text(
                        section.farsi,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: farsiColor,
                          fontSize: 13.5 * _fontScale,
                          height: 1.9,
                        ),
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

  /// کادر جداگانه‌ی پایان دعا: دست زدن بر ران و گفتن «العجل»
  Widget _buildClosingCard(Color cardColor, Color arabicColor, Color farsiColor) {
    const marker = '«سه بار»';
    final i = kClosingInstruction.indexOf(marker);
    final spans = i < 0
        ? <InlineSpan>[TextSpan(text: kClosingInstruction)]
        : <InlineSpan>[
            TextSpan(text: kClosingInstruction.substring(0, i)),
            const TextSpan(text: marker, style: TextStyle(color: kGold, fontWeight: FontWeight.bold)),
            TextSpan(text: kClosingInstruction.substring(i + marker.length)),
          ];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _a(kGold, 0.55), width: 1.2),
        boxShadow: [
          BoxShadow(color: _a(Colors.black, 0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              style: TextStyle(color: farsiColor, fontSize: 14 * _fontScale, height: 1.9),
              children: spans,
            ),
            textAlign: TextAlign.center,
          ),
          _buildOrnamentDivider(kGold),
          Text(
            kClosingArabic,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'QuranFont',
              color: arabicColor,
              fontSize: 22 * _fontScale,
              height: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrnamentDivider(Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(height: 1, color: _a(accent, 0.5)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '\u262B',
              style: TextStyle(fontSize: 20, color: accent),
            ),
          ),
          Expanded(
            child: Container(height: 1, color: _a(accent, 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _a(accent, 0.35))),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_rounded, color: accent, size: 22),
              const SizedBox(width: 8),
              Text(
                'دعای عهد',
                style: TextStyle(
                  color: accent,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            child: Tooltip(
              message: 'درباره‌ی دعای عهد',
              child: GestureDetector(
                onTap: _showAboutSheet,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _a(accent, 0.6), width: 1.3),
                  ),
                  child: Center(
                    child: Text(
                      '؟',
                      style: TextStyle(
                        color: accent,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- نوار پخش (بالای صفحه، با انیمیشن) ----------------
  Widget _buildPlayerBar(Color accent, Color cardColor) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: _barVisible ? 1 : 0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: t,
          child: Opacity(opacity: t.clamp(0.0, 1.0).toDouble(), child: child),
        ),
      ),
      child: Container(
        height: 46,
        margin: const EdgeInsets.fromLTRB(14, 8, 14, 4),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: _a(accent, 0.35)),
          boxShadow: [BoxShadow(color: _a(Colors.black, 0.10), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            _barIcon(Icons.close_rounded, accent, _closePlayer, 'بستن'),
            _barIcon(Icons.replay_10_rounded, accent, () => _seekBy(-10), '۱۰ ثانیه عقب'),
            Expanded(
              child: AnimatedBuilder(
                animation: Listenable.merge([_position, _duration, _dragValue]),
                builder: (context, _) {
                  final total = _duration.value.inMilliseconds;
                  final max = total > 0 ? total.toDouble() : 1.0;
                  final value = (_dragValue.value ?? _position.value.inMilliseconds.toDouble()).clamp(0.0, max).toDouble();
                  return SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      activeTrackColor: accent,
                      inactiveTrackColor: _a(accent, 0.25),
                      thumbColor: accent,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      overlayColor: _a(accent, 0.18),
                    ),
                    child: Slider(
                      min: 0,
                      max: max,
                      value: value,
                      onChanged: total > 0 ? (v) => _dragValue.value = v : null,
                      onChangeEnd: (v) async {
                        await _seekTo(v.round());
                        _dragValue.value = null;
                      },
                    ),
                  );
                },
              ),
            ),
            _barIcon(Icons.forward_10_rounded, accent, () => _seekBy(10), '۱۰ ثانیه جلو'),
          ],
        ),
      ),
    );
  }

  Widget _barIcon(IconData icon, Color accent, VoidCallback onTap, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: accent, size: 22),
        ),
      ),
    );
  }

  // ---------------- درباره ----------------
  void _showAboutSheet() {
    _lightVibrate();
    final isNight = _nightMode;
    final bg = isNight ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isNight ? Colors.white : const Color(0xFF2A2110);
    final subColor = isNight ? Colors.white70 : const Color(0xFF6B5A2E);
    const gold = kGold;

    Widget sectionTitle(String t) => Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.brightness_1, size: 6, color: gold),
              const SizedBox(width: 6),
              Text(
                t,
                style: const TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 14.5),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.brightness_1, size: 6, color: gold),
            ],
          ),
        );

    Widget paragraph(String t, {bool italic = false}) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            t,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 13.5,
              height: 1.9,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              top: false,
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: _a(gold, 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_rounded, color: gold, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'درباره‌ی دعای عهد',
                        style: TextStyle(color: gold, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  sectionTitle('معرفی دعای عهد'),
                  paragraph(
                    'دعای عهد یکی از دعاهای مشهور شیعه است که در آن از خداوند درخواست می‌شود انسان را از یاران و یاوران حضرت ولی‌عصر (عج) قرار دهد و بر عهد و پیمان با امام زمان (عج) استوار بماند.',
                  ),
                  sectionTitle('فضیلت دعای عهد'),
                  paragraph(
                    'دعای عهد از دعاهایی است که خواندن آن در منابع روایی شیعه مورد توجه قرار گرفته است. از امام صادق (ع) درباره‌ی خواندن این دعا در صبحگاه روایت شده، و در آن بر پیوند و وفاداری مؤمن نسبت به حضرت صاحب‌الزمان (عج) تأکید شده است.',
                  ),
                  sectionTitle('مفهوم کلی دعا'),
                  paragraph(
                    'مضمون دعای عهد شامل سلام و درود بر پیامبر اکرم (ص) و اهل‌بیت (ع)، اظهار وفاداری و عهد با امام زمان (عج)، درخواست یاری و قرار گرفتن در شمار یاران ایشان، و درخواست تعجیل در فرج است.',
                  ),
                  sectionTitle('یک حدیث کوتاه'),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _a(gold, 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _a(gold, 0.3)),
                    ),
                    child: paragraph(
                      'امام صادق (ع): هر کس چهل صبح این دعا را بخواند، از یاوران قائم (عج) خواهد بود؛ و اگر پیش از ظهور آن حضرت بمیرد، خداوند او را از قبر بیرون می‌آورد تا در خدمت ایشان باشد.',
                      italic: true,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildOrnamentDivider(gold),
                  const SizedBox(height: 6),
                  Text(
                    'اَللّهُمَّ اجْعَلْنی مِنْ اَنْصارِهِ وَاَعْوانِهِ وَالذّابّینَ عَنْهُ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'QuranFont',
                      color: textColor,
                      fontSize: 17,
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'التماس دعا 🙏',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subColor, fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 18),
                  // خط جداکننده + امتیاز دادن + ارتباط با ما
                  Divider(color: _a(gold, 0.55), thickness: 1, height: 1),
                  const SizedBox(height: 14),
                  _AboutActions(night: isNight, onTap: _lightVibrate),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomBar(Color accent, Color cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: _a(Colors.black, 0.12), blurRadius: 14)],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _iconButton(Icons.person, accent, _showReciterSheet, tooltip: 'انتخاب مداح'),
            _iconButton(Icons.remove, accent, () => _zoom(-0.1), tooltip: 'کوچک‌نمایی'),
            GestureDetector(
              onTap: _togglePlay,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            _iconButton(Icons.add, accent, () => _zoom(0.1), tooltip: 'بزرگ‌نمایی'),
            _iconButton(Icons.settings, accent, _showSettingsSheet, tooltip: 'تنظیمات'),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, Color accent, VoidCallback onTap, {required String tooltip}) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _a(accent, 0.5)),
          ),
          child: Icon(icon, color: accent, size: 20),
        ),
      ),
    );
  }

  void _showReciterSheet() {
    _lightVibrate();
    showModalBottomSheet(
      context: context,
      backgroundColor: _nightMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        final textColor = _nightMode ? Colors.white : Colors.black87;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'انتخاب مداح',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                ),
                const SizedBox(height: 8),
                ...List.generate(kReciters.length, (i) {
                  final selected = i == _reciterIndex;
                  return ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _selectReciter(i);
                    },
                    title: Text(
                      kReciters[i].name,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: selected ? kGold : textColor,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(Icons.check_circle, color: kGold)
                        : const Icon(Icons.radio_button_off, color: Colors.grey),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettingsSheet() {
    _lightVibrate();
    showModalBottomSheet(
      context: context,
      backgroundColor: _nightMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final textColor = _nightMode ? Colors.white : Colors.black87;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('تنظیمات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: Text('حالت شب', style: TextStyle(color: textColor)),
                      value: _nightMode,
                      activeColor: kGold,
                      onChanged: (v) {
                        _toggleNight();
                        setSheetState(() {});
                      },
                    ),
                    SwitchListTile(
                      title: Text('لرزش', style: TextStyle(color: textColor)),
                      value: _vibration,
                      activeColor: kGold,
                      onChanged: (v) {
                        _toggleVibration();
                        setSheetState(() {});
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// -------------------- امتیاز دادن و ارتباط با ما (پایین بخش «درباره») --------------------
class _AboutActions extends StatefulWidget {
  final bool night;
  final VoidCallback onTap;
  const _AboutActions({required this.night, required this.onTap});

  @override
  State<_AboutActions> createState() => _AboutActionsState();
}

class _AboutActionsState extends State<_AboutActions> {
  String? _message;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _show(String msg) {
    setState(() => _message = msg);
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _message = null);
    });
  }

  Future<void> _rate() async {
    widget.onTap();
    if (!await NativeActions.openMyket()) _show('باز کردن مایکت ممکن نشد.');
  }

  Future<void> _contact() async {
    widget.onTap();
    if (!await NativeActions.openMail()) _show('برنامه‌ی ایمیل پیدا نشد.');
  }

  Widget _tile(IconData icon, String label, VoidCallback onTap) {
    final text = widget.night ? Colors.white : const Color(0xFF2A2110);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: _a(kGold, widget.night ? 0.08 : 0.07),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _a(kGold, 0.35)),
            ),
            child: Row(
              children: [
                Icon(icon, color: kGold, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(color: text, fontSize: 14.5, fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(Icons.chevron_left_rounded, color: _a(kGold, 0.8)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _tile(Icons.star_rounded, 'امتیاز دادن به برنامه', _rate),
        _tile(Icons.mail_outline_rounded, 'ارتباط با ما', _contact),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              _message!,
              textAlign: TextAlign.center,
              style: TextStyle(color: _a(kGold, 0.95), fontSize: 12.5),
            ),
          ),
      ],
    );
  }
}
