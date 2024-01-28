import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PopularScreen extends StatefulWidget {
  const PopularScreen({Key? key}) : super(key: key);

  @override
  _PopularScreenState createState() => _PopularScreenState();
}

class _PopularScreenState extends State<PopularScreen> {
  List<Map<String, dynamic>> popularNews = [];
  String selectedSortOption = 'publishedAt'; // Default sort option

  @override
  void initState() {
    super.initState();
    fetchPopularNews();
  }

  Future<void> fetchPopularNews() async {
    const apiKey = '76c0b06704c54ff2a709adaa8b986ffd'; // Replace with your actual API key

    final response = await http.get(
      Uri.parse('https://newsapi.org/v2/top-headlines?language=en&apiKey=$apiKey'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> articles = data['articles'];

      // Sort articles based on selectedSortOption
      articles.sort((a, b) {
        if (selectedSortOption == 'publishedAt') {
          final DateTime timeA = DateTime.parse(a['publishedAt']);
          final DateTime timeB = DateTime.parse(b['publishedAt']);
          return timeB.compareTo(timeA);
        } else if (selectedSortOption == 'title') {
          return a['title'].toString().compareTo(b['title'].toString());
        }
        // Add more sorting options as needed

        // Default: No sorting
        return 0;
      });

      setState(() {
        popularNews = articles
            .cast<Map<String, dynamic>>()
            .where((article) => !article.containsKey('removed') || !article['removed'])
            .toList();
      });
    } else {
      print('Error - Status Code: ${response.statusCode}, Body: ${response.body}');
      // Handle error, e.g., show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load popular news. Please try again later.'),
        ),
      );
    }
  }

  void _sortNews(String sortOption) {
    setState(() {
      selectedSortOption = sortOption;
    });
    fetchPopularNews();
  }

  void _showArticleDetails(Map<String, dynamic> article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailsScreen(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular News'),
        actions: [
          PopupMenuButton(
            onSelected: _sortNews,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'publishedAt',
                child: Text('Sort by Published At'),
              ),
              const PopupMenuItem<String>(
                value: 'title',
                child: Text('Sort by Title'),
              ),
              // Add more sorting options as needed
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: popularNews.length,
        itemBuilder: (context, index) {
          final article = popularNews[index];
          return InkWell(
            onTap: () {
              _showArticleDetails(article);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      article['urlToImage'] ?? '',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    article['title'] ?? 'No Title',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    article['description'] ?? 'No Description',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ArticleDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> article;

  const ArticleDetailsScreen({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article['urlToImage'] != null)
            Image.network(
              article['urlToImage'],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              article['title'] ?? 'No Title',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              article['description'] ?? 'No Description',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
