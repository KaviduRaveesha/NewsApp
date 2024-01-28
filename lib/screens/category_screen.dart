import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Map<String, dynamic>> categoryNews = [];
  String selectedCategory = 'general'; // Default category

  @override
  void initState() {
    super.initState();
    fetchCategoryNews();
  }

  Future<void> fetchCategoryNews() async {
    const apiKey = '76c0b06704c54ff2a709adaa8b986ffd'; // Replace with your actual API key

    final response = await http.get(
      Uri.parse('https://newsapi.org/v2/top-headlines?category=$selectedCategory&language=en&apiKey=$apiKey'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> articles = data['articles'];

      setState(() {
        categoryNews = articles
            .cast<Map<String, dynamic>>()
            .where((article) => !article.containsKey('removed') || !article['removed'])
            .toList();
      });
    } else {
      print('Error - Status Code: ${response.statusCode}, Body: ${response.body}');
      // Handle error, e.g., show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load category news. Please try again later.'),
        ),
      );
    }
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
        title: const Text('Category News'),
        actions: [
          DropdownButton<String>(
            value: selectedCategory,
            items: <String>['general', 'business', 'technology', 'sports', 'science', 'health']
                .map<DropdownMenuItem<String>>(
                  (String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ),
            )
                .toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedCategory = newValue;
                });
                fetchCategoryNews();
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: categoryNews.length,
        itemBuilder: (context, index) {
          final article = categoryNews[index];
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
