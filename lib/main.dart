import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const DoayeAhdApp());
}

/// -------------------- یک بخش از دعا (متن عربی + ترجمه فارسی) --------------------
class DuaSection {
  final String arabic;
  final String farsi;
  const DuaSection(this.arabic, this.farsi);
}

/// متن کامل دعای عهد، تقسیم‌شده به بخش‌های کوتاه همراه با ترجمه‌ی روان هرکدام
const List<DuaSection> kDuaSections = [
  DuaSection(
    'اَللّهُمَّ رَبَّ النُّورِ الْعَظیمِ، وَرَبَّ الْکُرْسِیِّ الرَّفیعِ، وَرَبَّ الْبَحْرِ الْمَسْجُورِ، وَمُنْزِلَ التَّوْراةِ وَالْاِنْجیلِ وَالزَّبُورِ، وَرَبَّ الظِّلِّ وَالْحَرُورِ، وَمُنَزِّلَ الْقُرْآنِ الْعَظیمِ، وَرَبَّ الْمَلائِکَةِ الْمُقَرَّبینَ، وَالْاَنْبِیاءِ وَالْمُرْسَلینَ.',
    'خدایا! ای پروردگار نور بزرگ، و پروردگار عرش بلند، و پروردگار دریای مواج، و فروفرستنده‌ی تورات و انجیل و زبور، و پروردگار سایه و گرما، و نازل‌کننده‌ی قرآن عظیم، و پروردگار فرشتگان مقرّب و پیامبران و فرستادگان.',
  ),
  DuaSection(
    'اَللّهُمَّ اِنّی اَسْأَلُکَ بِوَجْهِکَ الْکَریمِ، وَبِنُورِ وَجْهِکَ الْمُنیرِ، وَمُلْکِکَ الْقَدیمِ، یا حَیُّ یا قَیُّومُ، اَسْأَلُکَ بِاسْمِکَ الَّذی اَشْرَقَتْ بِهِ السَّماواتُ وَالْاَرَضُونَ، وَبِاسْمِکَ الَّذی یَصْلُحُ بِهِ الْاَوَّلُونَ وَالْآخِرُونَ.',
    'خدایا! از تو می‌خواهم به‌حقّ ذات گرامی‌ات، و نور روشن وجودت، و پادشاهی دیرینه‌ات؛ ای زنده‌ی پاینده! از تو می‌خواهم به نامی که آسمان‌ها و زمین‌ها بدان روشن گشت، و به نامی که کار پیشینیان و آیندگان بدان سامان می‌یابد.',
  ),
  DuaSection(
    'یا حَیّاً قَبْلَ کُلِّ حَیٍّ، وَیا حَیّاً بَعْدَ کُلِّ حَیٍّ، وَیا حَیّاً حینَ لا حَیَّ، یا مُحْیِیَ الْمَوْتی وَمُمیتَ الْاَحْیاءِ، یا حَیُّ لا اِلـهَ اِلاّ اَنْتَ.',
    'ای زنده‌ای پیش از هر زنده، و ای زنده‌ای پس از هر زنده، و ای زنده‌ای آنگاه که هیچ زنده‌ای نبود؛ ای زنده‌کننده‌ی مردگان و میراننده‌ی زندگان؛ ای زنده‌ای که جز تو خدایی نیست.',
  ),
  DuaSection(
    'اَللّهُمَّ بَلِّغْ مَوْلانَا الْاِمامَ الْهادِیَ الْمَهْدِیَّ الْقائِمَ بِاَمْرِکَ، صَلَواتُ اللهِ عَلَیْهِ وَعَلی آبائِهِ الطّاهِرینَ، عَنْ جَمیعِ الْمُؤْمِنینَ وَالْمُؤْمِناتِ، فی مَشارِقِ الْاَرْضِ وَمَغارِبِها، سَهْلِها وَجَبَلِها، وَبَرِّها وَبَحْرِها، وَعَنّی وَعَنْ والِدَیَّ، مِنَ الصَّلَواتِ زِنَةَ عَرْشِ اللهِ، وَمِدادَ کَلِماتِهِ، وَما اَحْصاهُ عِلْمُهُ، وَاَحاطَ بِهِ کِتابُهُ.',
    'خدایا! به مولای ما، امام هادی و مهدی، قیام‌کننده به فرمانت -که درود خدا بر او و بر پدران پاکش باد- از سوی همه‌ی مردان و زنان مؤمن، در شرق و غرب زمین، در دشت و کوهش، در خشکی و دریایش، و از سوی من و پدر و مادرم، درودهایی به وزن عرش خدا و به شمار مرکّب کلماتش و آنچه علمش برشمرده و کتابش در بر گرفته، برسان.',
  ),
  DuaSection(
    'اَللّهُمَّ اِنّی اُجَدِّدُ لَهُ فی صَبیحَةِ یَوْمی هذا وَما عِشْتُ مِنْ اَیّامی عَهْداً وَعَقْداً وَبَیْعَةً لَهُ فی عُنُقی، لا اَحُولُ عَنْها وَلا اَزُولُ اَبَداً.',
    'خدایا! من در صبحگاه امروز، و در تمام روزهایی که زنده‌ام، پیمان و عهد و بیعت او را بر گردن خود تازه می‌کنم؛ پیمانی که هرگز از آن رویگردان نمی‌شوم و هیچ‌گاه از آن دست برنمی‌دارم.',
  ),
  DuaSection(
    'اَللّهُمَّ اجْعَلْنی مِنْ اَنْصارِهِ وَاَعْوانِهِ، وَالذّابّینَ عَنْهُ، وَالْمُسارِعینَ اِلَیْهِ فی قَضاءِ حَوائِجِهِ، وَالْمُمْتَثِلینَ لِاَوامِرِهِ، وَالْمُحامینَ عَنْهُ، وَالسّابِقینَ اِلی اِرادَتِهِ، وَالْمُسْتَشْهَدینَ بَیْنَ یَدَیْهِ.',
    'خدایا! مرا از یاوران و کمک‌کاران او، و از مدافعانش، و از شتاب‌کنندگان به سوی او در برآوردن نیازهایش، و از فرمانبرداران دستورهایش، و از حمایت‌کنندگان از او، و از پیشی‌گیرندگان به خواست او، و از شهیدان در پیشگاه او قرار ده.',
  ),
  DuaSection(
    'اَللّهُمَّ اِنْ حالَ بَیْنی وَبَیْنَهُ الْمَوْتُ الَّذی جَعَلْتَهُ عَلی عِبادِکَ حَتْماً مَقْضِیّاً، فَاَخْرِجْنی مِنْ قَبْری مُؤْتَزِراً کَفَنی، شاهِراً سَیْفی، مُجَرِّداً قَناتی، مُلَبِّیاً دَعْوَةَ الدّاعی، فِی الْحاضِرِ وَالْبادی.',
    'خدایا! اگر مرگی که آن را برای بندگانت حتمی و گریزناپذیر مقرّر کرده‌ای، میان من و او فاصله انداخت، مرا از قبرم بیرون آور، در حالی که کفنم را به کمر بسته، شمشیرم را برکشیده، نیزه‌ام را از غلاف بیرون آورده، و اجابت‌کننده‌ی دعوتِ آن دعوت‌کننده باشم، چه در شهر و چه در بیابان.',
  ),
  DuaSection(
    'اَللّهُمَّ اَرِنِی الطَّلْعَةَ الرَّشیدَةَ، وَالْغُرَّةَ الْحَمیدَةَ، وَاکْحُلْ ناظِری بِنَظْرَةٍ مِنّی اِلَیْهِ، وَعَجِّلْ فَرَجَهُ، وَسَهِّلْ مَخْرَجَهُ، وَاَوْسِعْ مَنْهَجَهُ، وَاسْلُکْ بی مَحَجَّتَهُ، وَاَنْفِذْ اَمْرَهُ، وَاشْدُدْ اَزْرَهُ.',
    'خدایا! آن چهره‌ی خجسته و پیشانی ستوده را به من بنمایان، و دیده‌ام را با نگاهی از خودم به سوی او روشن و سرمه‌کش گردان، و در گشایش کارش شتاب کن، و راه بیرون‌آمدنش را آسان ساز، و روشش را گسترده گردان، و مرا در راه او قرار ده، و فرمانش را روان ساز، و پشتش را استوار گردان.',
  ),
  DuaSection(
    'وَاعْمُرِ اَللّهُمَّ بِهِ بِلادَکَ، وَاَحْیِ بِهِ عِبادَکَ، فَاِنَّکَ قُلْتَ وَقَوْلُکَ الْحَقُّ: «ظَهَرَ الْفَسادُ فِی الْبَرِّ وَالْبَحْرِ بِما کَسَبَتْ اَیْدِی النّاسِ»، فَاَظْهِرِ اَللّهُمَّ لَنا وَلِیَّکَ، وَابْنَ بِنْتِ نَبِیِّکَ، الْمُسَمّی بِاسْمِ رَسُولِکَ، حَتّی لا یَظْفَرَ بِشَیْءٍ مِنَ الْباطِلِ اِلاّ مَزَّقَهُ، وَیُحِقَّ الْحَقَّ وَیُحَقِّقَهُ.',
    'و خدایا! به‌وسیله‌ی او شهرهایت را آباد کن، و بندگانت را زنده گردان؛ زیرا تو خود فرمودی -و سخن تو حق است- که «فساد در خشکی و دریا به سبب آنچه دست‌های مردم فراهم آورده، آشکار شد». پس خدایا! ولیّ خود، و فرزند دختر پیامبرت، آن که به نام رسولت نامیده شده را برای ما آشکار کن، تا بر هیچ باطلی دست نیابد جز آنکه آن را از هم بدرد، و حق را برپا و ثابت گرداند.',
  ),
  DuaSection(
    'وَاجْعَلْهُ اَللّهُمَّ مَفْزَعاً لِمَظْلُومِ عِبادِکَ، وَناصِراً لِمَنْ لا یَجِدُ لَهُ ناصِراً غَیْرَکَ، وَمُجَدِّداً لِما عُطِّلَ مِنْ اَحْکامِ کِتابِکَ، وَمُشَیِّداً لِما وَرَدَ مِنْ اَعْلامِ دینِکَ وَسُنَّةِ نَبِیِّکَ صَلَّی اللهُ عَلَیْهِ وَآلِهِ.',
    'و خدایا! او را پناهگاه بندگان ستم‌دیده‌ات، و یاور کسی که جز تو یاوری ندارد قرار ده، و او را احیاگر احکام تعطیل‌شده‌ی کتابت، و برپادارنده‌ی نشانه‌های دینت و سنّت پیامبرت -که درود خدا بر او و خاندانش باد- گردان.',
  ),
  DuaSection(
    'وَاجْعَلْهُ اَللّهُمَّ مِمَّنْ حَصَّنْتَهُ مِنْ بَأْسِ الْمُعْتَدینَ، اَللّهُمَّ وَسُرَّ نَبِیَّکَ مُحَمَّداً صَلَّی اللهُ عَلَیْهِ وَآلِهِ بِرُؤْیَتِهِ، وَمَنْ تَبِعَهُ عَلی دَعْوَتِهِ، وَارْحَمِ اسْتِکانَتَنا بَعْدَهُ.',
    'و خدایا! او را از کسانی قرار ده که از آسیب تجاوزکاران در امانش داشته‌ای. خدایا! پیامبرت محمد -که درود خدا بر او و خاندانش باد- و هر کس را که از دعوتش پیروی کرده، با دیدار او شادمان گردان، و به فروتنی و بی‌پناهی ما پس از او رحم کن.',
  ),
  DuaSection(
    'اَللّهُمَّ اکْشِفْ هذِهِ الْغُمَّةَ عَنْ هذِهِ الْاُمَّةِ بِحُضُورِهِ، وَعَجِّلْ لَنا ظُهُورَهُ، اِنَّهُمْ یَرَوْنَهُ بَعیداً وَنَراهُ قَریباً، بِرَحْمَتِکَ یا اَرْحَمَ الرّاحِمینَ.',
    'خدایا! این اندوه را با حضور او از این امّت بردار، و ظهورش را برای ما شتاب بخش؛ که مردم آن را دور می‌بینند و ما آن را نزدیک می‌بینیم، به رحمت خودت، ای مهربان‌ترین مهربانان.',
  ),
  DuaSection(
    'اَللّهُمَّ اغْفِرْ لِلْمُؤْمِنینَ وَالْمُؤْمِناتِ، وَالْمُسْلِمینَ وَالْمُسْلِماتِ، الْاَحْیاءِ مِنْهُمْ وَالْاَمْواتِ، وَتابِعْ بَیْنَنا وَبَیْنَهُمْ بِالْخَیْراتِ، اِنَّکَ سَمیعُ الدُّعاءِ، اِنَّکَ عَلی کُلِّ شَیْءٍ قَدیرٌ.',
    'خدایا! مردان و زنان مؤمن، و مردان و زنان مسلمان را، چه زنده و چه مرده، بیامرز، و میان ما و آنان پیوسته خیر و نیکی برقرار ساز؛ که تو شنونده‌ی دعایی، و تو بر هر کاری توانایی.',
  ),
];

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
          'assets/splash.png',
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
  bool _isPlaying = false;
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
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
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
    _player.dispose();
    super.dispose();
  }

  void _lightVibrate() {
    if (_vibration) HapticFeedback.selectionClick();
  }

  Future<void> _togglePlay() async {
    _lightVibrate();
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      await _player.play(AssetSource('audio/${_reciter.file}'));
      setState(() => _isPlaying = true);
    }
  }

  Future<void> _selectReciter(int index) async {
    _lightVibrate();
    final wasPlaying = _isPlaying;
    await _player.stop();
    setState(() {
      _reciterIndex = index;
      _isPlaying = false;
    });
    _prefs?.setInt('reciter', index);
    if (wasPlaying) {
      await _player.play(AssetSource('audio/${_reciter.file}'));
      setState(() => _isPlaying = true);
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

  @override
  Widget build(BuildContext context) {
    final bg = _nightMode ? const Color(0xFF121212) : const Color(0xFFF6EFDF);
    final cardColor = _nightMode ? const Color(0xFF1E1E1E) : Colors.white;
    final goldAccent = const Color(0xFFC9A24B);
    final arabicColor = _nightMode ? const Color(0xFFF3E9D2) : const Color(0xFF2A2110);
    final farsiColor = _nightMode ? Colors.white70 : const Color(0xFF6B5A2E);
    final translationBg = _nightMode ? const Color(0xFF2A2416) : const Color(0xFFFCEFD8);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(goldAccent),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                itemCount: kDuaSections.length,
                itemBuilder: (context, index) {
                  final section = kDuaSections[index];
                  final isClosingSupplication = index == kDuaSections.length - 1;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isClosingSupplication)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'دعای خیر برای عموم مسلمانان و مؤمنان (جزو متن اصلی دعای عهد نیست)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: farsiColor.withOpacity(0.55),
                              fontSize: 11.5 * _fontScale,
                            ),
                          ),
                        ),
                      Container(
                    margin: const EdgeInsets.only(bottom: 22),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
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
                        _buildOrnamentDivider(goldAccent),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: translationBg,
                            borderRadius: BorderRadius.circular(14),
                          ),
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
                      ],
                    ),
                      ),
                    ],
                  );
                },
              ),
            ),
            _buildBottomBar(goldAccent, cardColor),
          ],
        ),
      ),
    );
  }

  Widget _buildOrnamentDivider(Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(height: 1, color: accent.withOpacity(0.5)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.star, size: 12, color: accent),
          ),
          Expanded(
            child: Container(height: 1, color: accent.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: accent.withOpacity(0.35))),
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
                    border: Border.all(color: accent.withOpacity(0.6), width: 1.3),
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

  void _showAboutSheet() {
    _lightVibrate();
    final isNight = _nightMode;
    final bg = isNight ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isNight ? Colors.white : const Color(0xFF2A2110);
    final subColor = isNight ? Colors.white70 : const Color(0xFF6B5A2E);
    const gold = Color(0xFFC9A24B);

    Widget sectionTitle(String t) => Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.brightness_1, size: 6, color: gold),
              const SizedBox(width: 6),
              Text(
                t,
                style: TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 14.5),
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
                        color: gold.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.menu_book_rounded, color: gold, size: 22),
                      const SizedBox(width: 8),
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
                      color: gold.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: gold.withOpacity(0.3)),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 14)],
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
            border: Border.all(color: accent.withOpacity(0.5)),
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
                        color: selected ? const Color(0xFFC9A24B) : textColor,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(Icons.check_circle, color: Color(0xFFC9A24B))
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
                      activeColor: const Color(0xFFC9A24B),
                      onChanged: (v) {
                        _toggleNight();
                        setSheetState(() {});
                      },
                    ),
                    SwitchListTile(
                      title: Text('لرزش', style: TextStyle(color: textColor)),
                      value: _vibration,
                      activeColor: const Color(0xFFC9A24B),
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
