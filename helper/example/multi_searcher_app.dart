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
  // Create a multi searcher.
  // The Searcher performs search requests and obtains search result
  late MultiSearcher multiSearcher;
  late FacetSearcher facetSearcher;
  late HitsSearcher hitsSearcher;

  _MyHomePageState() {
    multiSearcher = MultiSearcher(
      applicationID: 'latency',
      apiKey: '1f6fd3a6fb973cb08419fe7d288fa4db',
    );
    hitsSearcher = multiSearcher.addHitsSearcher(
      initialState: const SearchState(
        indexName: 'instant_search',
      ),
    );
    facetSearcher = multiSearcher.addFacetSearcher(
        initialState: const FacetSearchState(
          facet: 'brand',
          searchState: SearchState(
            indexName: 'instant_search',
          ),
        ));
  }

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
              onChanged: (input) {
                facetSearcher.query(input);
                hitsSearcher.query(input);
              }, // 3. Run your search operations
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search...',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
      body: Column(children: [
        Expanded(
          child: StreamBuilder<FacetSearchResponse>(
            // Listen and display facet search results
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
        Expanded(
          child: StreamBuilder<SearchResponse>(
            // Listen and display hits search results
            stream: hitsSearcher.responses,
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
        )
      ]),
    );
  }
}