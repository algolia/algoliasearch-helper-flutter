import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Algolia Helpers for Flutter',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Create a hits searcher.
  // The Searcher performs search requests and obtains search result
  final searcher = HitsSearcher(
    applicationID: 'latency',
    apiKey: '1f6fd3a6fb973cb08419fe7d288fa4db',
    indexName: 'instant_search',
  );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: TextField(
                onChanged: searcher.query, // 3. Run your search operations
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
        body: Container(
          color: Colors.white,
          child: StreamBuilder<SearchResponse>(
            stream: searcher.responses, // 4. Listen and display search results!
            builder:
                (BuildContext context, AsyncSnapshot<SearchResponse> snapshot) {
              if (snapshot.hasData) {
                final response = snapshot.data;
                final hits = response?.hits.toList() ?? [];
                return ListView.builder(
                  itemCount: hits.length,
                  itemBuilder: (BuildContext context, int index) {
                    final hit = hits[index];
                    return ListTile(
                      title: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.titleSmall,
                          children:
                              hit.getHighlightedString('name').toInlineSpans(),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      );

  @override
  void dispose() {
    super.dispose();
    searcher.dispose();
  }
}
