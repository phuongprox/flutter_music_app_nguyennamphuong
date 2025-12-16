import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/mini_player.dart';

class PlaylistScreen extends StatefulWidget {
  final String playlistName;
  final List<SongModel> songs;

  const PlaylistScreen({
    super.key,
    required this.playlistName,
    required this.songs,
  });

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  late List<SongModel> _playlistSongs;

  @override
  void initState() {
    super.initState();
    _playlistSongs = List.from(widget.songs);
  }

  void _removeSong(int index) {
    setState(() {
      _playlistSongs.removeAt(index);
    });
  }

  Future<void> _exportPdf() async {
    if (_playlistSongs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Playlist is empty!')),
      );
      return;
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                widget.playlistName,
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.ListView.builder(
                itemCount: _playlistSongs.length,
                itemBuilder: (context, index) {
                  final song = _playlistSongs[index];
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child:
                        pw.Text('${index + 1}. ${song.title} - ${song.artist}'),
                  );
                },
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

// UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.playlistName,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.black),
            tooltip: 'Export PDF',
            onPressed: _exportPdf,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildPlaylistContent(),
          ),
          Consumer<AudioProvider>(
            builder: (context, provider, child) {
              if (provider.currentSong == null) return const SizedBox.shrink();
              return const MiniPlayer();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistContent() {
    if (_playlistSongs.isEmpty) {
      return const Center(
        child: Text(
          'No songs in this playlist',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: _playlistSongs.length,
      itemBuilder: (context, index) {
        final song = _playlistSongs[index];
        return SongTile(
          song: song,
          onTap: () {
            context.read<AudioProvider>().setPlaylist(_playlistSongs, index);
          },
          onRemoveFromPlaylist: () => _removeSong(index),
          isInPlaylist: true,
        );
      },
    );
  }
}
