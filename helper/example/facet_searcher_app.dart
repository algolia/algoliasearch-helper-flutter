import 'package:flutter/material.dart';
import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Algolia Helpers for Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Create a hits searcher.
  // The Searcher performs search requests and obtains search result
  final FacetSearcher facetSearcher = FacetSearcher(
    applicationID: 'latency',
    apiKey: '1f6fd3a6fb973cb08419fe7d288fa4db',
    indexName: 'instant_search',
    facet: 'brand',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: TextField(
              onChanged: facetSearcher.query, // 3. Run your search operations
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
        child: StreamBuilder<FacetSearchResponse>(
          stream: facetSearcher.responses,
          builder: (BuildContext context,
              AsyncSnapshot<FacetSearchResponse> snapshot) {
            if (snapshot.hasData) {
              final response = snapshot.data;
              final facets = response?.facetHits.toList() ?? [];
              return ListView.builder(
                itemCount: facets.length,
                itemBuilder: (BuildContext context, int index) {
                  final facet = facets[index];
                  return ListTile(
                    title: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleSmall,
                        children: facet.getHighlightedString().toInlineSpans()
                          ..add(TextSpan(text: '(${facet.count})')),
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
  }
}
