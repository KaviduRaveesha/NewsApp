// Import necessary packages and files
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ArticleDetailsScreen class
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

// TopStoriesScreen class
class TopStoriesScreen extends StatefulWidget {
  @override
  _TopStoriesScreenState createState() => _TopStoriesScreenState();
}

class _TopStoriesScreenState extends State<TopStoriesScreen> {
  List<Map<String, dynamic>> topStories = [];

  @override
  void initState() {
    super.initState();
    fetchTopStories();
  }

  Future<void> fetchTopStories() async {
    const apiKey = '76c0b06704c54ff2a709adaa8b986ffd'; // Replace with your actual API key
    final response = await http.get(
      Uri.parse('https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> articles = data['articles'];

      setState(() {
        topStories = articles
            .cast<Map<String, dynamic>>()
            .where((article) => !article.containsKey('removed') || !article['removed'])
            .toList();
        topStories = topStories.reversed.toList(); // Reverse the order of top stories
      });
    } else {
      print('Error - Status Code: ${response.statusCode}, Body: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load top stories. Please try again later.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Stories'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Top 5 Stories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: topStories.length > 5 ? 5 : topStories.length,
              itemBuilder: (context, index) {
                final article = topStories[index];
                return InkWell(
                  onTap: () {
                    _showArticleDetails(article);
                  },
                  child: Container(
                    width: 290,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (article['urlToImage'] != null)
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                article['urlToImage'],
                                width: double.infinity,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              article['title'] ?? 'No Title',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: topStories.length,
              itemBuilder: (context, index) {
                final article = topStories[index];
                return InkWell(
                  onTap: () {
                    _showArticleDetails(article);
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (article['urlToImage'] != null)
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                article['urlToImage'],
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              article['title'] ?? 'No Title',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showArticleDetails(Map<String, dynamic> article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailsScreen(article: article),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TopStoriesScreen(),
  ));
}
