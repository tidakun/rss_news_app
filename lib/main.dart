import 'package:flutter/material.dart';
import 'package:webfeed/domain/atom_feed.dart';
import 'package:webfeed/domain/atom_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;


void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Future Tech Blog Reader',
        theme: ThemeData(
          primaryColor: Colors.white,
        ),
        home: TechBlog());
  }
}

class TechBlog extends StatefulWidget {
  @override
  _TechBlogState createState() => _TechBlogState();
}

class _TechBlogState extends State<TechBlog> {
  final _articles = <AtomItem>[];

  @override
  void initState() {
    fetchFeed();
    setState(() {});
    super.initState();
  }

  void fetchFeed() async {
    final response = await http
        .get(Uri.parse('https://future-architect.github.io/atom.xml'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch atom.xml');
    }

    // debugPrint(utf8.decode(response.bodyBytes));
    final atomFeed = AtomFeed.parse(utf8.decode(response.bodyBytes));
    atomFeed.items.forEach((item) => {_articles.add(item)});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Future Tech Blog Reader'),
      ),
      body: ListView.builder(
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          final item = _articles[index];
          return Dismissible(
            key: Key(item.title.toString()),
            onDismissed: (direction) {
              setState(() {
                _articles.removeAt(index);
              });
            },
            background: Container(color: Colors.red),
            secondaryBackground: Container(color: Colors.blue),
            child: ListTile(
              leading: Text(item.published.toString()),
              title: Text(item.title.toString()),
              onTap: () => {_launchURL(item.id.toString())},
            ),
          );
        },
      ),
    );
  }

  void _launchURL(String _url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';
}