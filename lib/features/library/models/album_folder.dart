class AlbumFolder {
  final String title; // nazwa folderu (albumu)
  final String dirPath; // pełna ścieżka folderu
  final List<String> tracks; // pełne ścieżki plików audio
  final String? coverImagePath; // ścieżka do okładki (jpg/png) jeśli jest

  AlbumFolder({
    required this.title,
    required this.dirPath,
    required this.tracks,
    required this.coverImagePath,
  });

  int get trackCount => tracks.length;
}
