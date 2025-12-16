class SongModel {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String filePath;
  final Duration? duration;
  final String? albumArt;
  final int? fileSize;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    required this.filePath,
    this.duration,
    this.albumArt,
    this.fileSize,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String?,
      filePath: json['filePath'] as String,
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      albumArt: json['albumArt'] as String?,
      fileSize: json['fileSize'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'filePath': filePath,
      'duration': duration?.inMilliseconds,
      'albumArt': albumArt,
      'fileSize': fileSize,
    };
  }

  factory SongModel.fromAudioQuery(dynamic audioModel) {
    return SongModel(
      id: audioModel.id.toString(),
      title: audioModel.title as String,
      artist: audioModel.artist ?? 'Unknown Artist',
      album: audioModel.album as String?,
      filePath: audioModel.data as String,
      duration: Duration(milliseconds: audioModel.duration as int? ?? 0),
      albumArt: audioModel.artworkUri as String?,
      fileSize: audioModel.size as int?,
    );
  }
}
