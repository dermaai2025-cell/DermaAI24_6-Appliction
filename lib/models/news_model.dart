class SkinNews {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String sourceName;

  SkinNews({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.sourceName,
  });

  // Factory to convert JSON to Dart Object
  factory SkinNews.fromJson(Map<String, dynamic> json) {
    return SkinNews(
      title: json['title'] ?? "Skin Care Update",
      description: json['description'] ?? "No description available.",
      url: json['url'] ?? "",
      urlToImage: json['urlToImage'] ?? "https://via.placeholder.com/400x200",
      sourceName: json['source']['name'] ?? "Health Source",
    );
  }
}


