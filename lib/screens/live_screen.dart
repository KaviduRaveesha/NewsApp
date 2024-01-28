import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewsArticle {
  final String title;
  final String content;
  final String imageUrl;

  NewsArticle(this.title, this.content, this.imageUrl);
}

class NewsApp extends StatefulWidget {
  @override
  _NewsAppState createState() => _NewsAppState();
}

class _NewsAppState extends State<NewsApp> {
  final TextEditingController _searchController = TextEditingController();
  List<NewsArticle> articles = [];
  List<NewsArticle> searchResults = [];

  @override
  void initState() {
    super.initState();
    // Fetch initial news data
    fetchNews();
  }

  Future<void> fetchNews() async {
    final apiKey = '76c0b06704c54ff2a709adaa8b986ffd'; // Replace with your News API key
    final apiUrl = 'https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      final data = json.decode(response.body);

      if (data['status'] == 'ok') {
        setState(() {
          articles = (data['articles'] as List)
              .map((article) => NewsArticle(
            article['title'] ?? 'No Title',
            article['description'] ?? 'No Description',
            article['urlToImage'] ?? '',
          ))
              .toList();
          searchResults = articles; // Initial search results
        });
      }
    } catch (error) {
      print('Error fetching news: $error');
    }
  }

  void searchArticles(String query) {
    setState(() {
      searchResults = articles.where((article) =>
      article.title.toLowerCase().contains(query.toLowerCase()) ||
          article.content.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Search'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (query) => searchArticles(query),
                decoration: InputDecoration(
                  labelText: 'Search',
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final article = searchResults[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        article.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(article.title),
                    subtitle: Text(article.content),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(NewsApp());
}
