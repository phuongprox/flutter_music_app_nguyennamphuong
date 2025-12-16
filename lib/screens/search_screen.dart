import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../widgets/song_tile.dart';

class SearchScreen extends StatefulWidget {
  final List<SongModel> songs;

  const SearchScreen({super.key, required this.songs});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  List<SongModel> _results = [];

  void _search(String query) {
    setState(() {
      final queryLower = query.toLowerCase();
      _results = widget.songs
          .where((song) =>
              song.title.toLowerCase().contains(queryLower) ||
              song.artist.toLowerCase().contains(queryLower))
          .toList();
    });
  }

//UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildSearchBar(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: _controller,
        autofocus: true,
        style: const TextStyle(color: Colors.black87),
        decoration: const InputDecoration(
          hintText: 'Search songs...',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
        ),
        onChanged: _search,
      ),
    );
  }

  Widget _buildBody() {
    if (_results.isEmpty && _controller.text.isNotEmpty) {
      return const Center(
        child: Text(
          'No results',
          style: TextStyle(color: Colors.grey, fontSize: 18),
        ),
      );
    }

    if (_results.isEmpty && _controller.text.isEmpty) {
      // Có thể hiển thị gợi ý hoặc danh sách gần đây nếu có
      return const Center(
        child: Text(
          'Start typing to search your music',
          style: TextStyle(color: Colors.grey, fontSize: 18),
        ),
      );
    }

    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(
        color: Colors.grey,
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        final song = _results[index];
        return SongTile(
          song: song,
          onTap: () {
            context.read<AudioProvider>().setPlaylist(_results, index);
          },
        );
      },
    );
  }
}
