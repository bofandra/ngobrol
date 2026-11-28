import 'package:flutter/material.dart';

const night = Color(0xff081626);
const panel = Color(0xff10273d);
const stroke = Color(0xff28485f);
const textMuted = Color(0xffafc7d6);
const teal = Color(0xff5bf0d2);
const gold = Color(0xffffcb64);
const sky = Color(0xff8cccff);
const lilac = Color(0xffcab5ff);
const coral = Color(0xffff9696);
const playtestFont = 'Nunito';
const playtestFontFallbacks = ['CausalSymbols'];
const darkInk = Color(0xff09242c);

ThemeData playtestTheme() => ThemeData(
  brightness: Brightness.dark,
  fontFamily: playtestFont,
  fontFamilyFallback: playtestFontFallbacks,
  scaffoldBackgroundColor: night,
  colorScheme: const ColorScheme.dark(
    primary: teal,
    onPrimary: darkInk,
    secondary: gold,
    surface: panel,
    onSurface: Color(0xffedf7ff),
    onSurfaceVariant: textMuted,
    outline: stroke,
    error: coral,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: night,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontFamily: playtestFont,
      fontSize: 20,
      fontWeight: FontWeight.w800,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: panel,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(17)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: const BorderSide(color: stroke),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(56, 48),
      textStyle: const TextStyle(
        fontFamily: playtestFont,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
    ),
  ),
  segmentedButtonTheme: SegmentedButtonThemeData(
    style: ButtonStyle(
      side: const WidgetStatePropertyAll(BorderSide(color: stroke)),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? teal : panel,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? darkInk : textMuted,
      ),
    ),
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: night,
    indicatorColor: Color(0xff164b4e),
    height: 64,
  ),
);

class PlaytestFrame extends StatelessWidget {
  const PlaytestFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 740),
      child: child,
    ),
  );
}

class GamePanel extends StatelessWidget {
  const GamePanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = panel,
    this.border = stroke,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color border;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: border),
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );
}

class TopicArt extends StatelessWidget {
  const TopicArt(this.name, {super.key});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final asset = name;
    if (asset != null) {
      return Image.asset(
        'assets/topics/$asset.webp',
        fit: BoxFit.cover,
        excludeFromSemantics: true,
      );
    }
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff153658), Color(0xff225b5e)],
        ),
      ),
      child: Center(child: Icon(Icons.forum_outlined, size: 34, color: teal)),
    );
  }
}
