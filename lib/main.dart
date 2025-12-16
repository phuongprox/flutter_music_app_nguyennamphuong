import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'providers/audio_provider.dart';
import 'services/audio_player_service.dart';
import 'services/storage_service.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(const MusicPlayerApp());
}

class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AudioPlayerService>(
          create: (_) => AudioPlayerService(),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<StorageService>(
          create: (_) => StorageService(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<AudioProvider>(
          create: (context) => AudioProvider(
            context.read<AudioPlayerService>(),
            context.read<StorageService>(),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Music App',
            themeMode: themeProvider.themeMode,
            theme: ThemeData.light(useMaterial3: true).copyWith(
              colorScheme: ColorScheme.light(
                primary: const Color(0xFF1DB954),
                secondary: Colors.blueGrey,
              ),
            ),
            darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
              colorScheme: ColorScheme.dark(
                primary: const Color(0xFF1DB954),
                secondary: Colors.lightGreenAccent,
              ),
            ),
            home: HomeScreen(),
          );
        },
      ),
    );
  }
}
