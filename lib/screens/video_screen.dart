import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageScreen extends StatefulWidget {
  const ImageScreen({Key? key}) : super(key: key);

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  List<Map<String, dynamic>> imageList = [];
  final String newsApiKey = '76c0b06704c54ff2a709adaa8b986ffd'; // Replace with your News API key

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    final response = await http.get(
      Uri.parse('https://newsapi.org/v2/top-headlines?q=image&language=en&apiKey=$newsApiKey'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> articles = data['articles'];

      setState(() {
        imageList = articles
            .cast<Map<String, dynamic>>()
            .where((article) =>
        article.containsKey('urlToImage') &&
            (!article.containsKey('removed') || !article['removed']))
            .toList();
      });
    } else {
      print('Error - Status Code: ${response.statusCode}, Body: ${response.body}');
      // Handle error, e.g., show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load images. Please try again later.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Images'),
      ),
      body: ListView.builder(
        itemCount: imageList.length,
        itemBuilder: (context, index) {
          final image = imageList[index];

          // Check if the article has an image URL
          if (image.containsKey('urlToImage')) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Column(
                  children: [
                    Image.network(
                      image['urlToImage'],
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      image['title'] ?? 'No Title',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      image['description'] ?? 'No Description',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink(); // Return an empty container for articles without an image
        },
      ),
    );
  }
}
