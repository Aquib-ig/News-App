class Article {
  final String title;
  final String? description;
  final String? urlToImage;
  final String url;
  final String publishedAt;
  final String sourceName;
  final String? author;
  final String? content;

  Article({
    required this.title,
    this.description,
    this.urlToImage,
    required this.url,
    required this.publishedAt,
    required this.sourceName,
    this.author,
    this.content,
  });

  /// Handles both API and local storage JSON
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No Title',
      description: json['description'],
      urlToImage: json['urlToImage'],
      url: json['url'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      sourceName: json['source'] != null
          ? (json['source']['name'] ?? 'Unknown')
          : (json['sourceName'] ?? 'Unknown'),
      author: json['author'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'urlToImage': urlToImage,
      'url': url,
      'publishedAt': publishedAt,
      'sourceName': sourceName,
      'author': author,
      'content': content,
    };
  }
}
