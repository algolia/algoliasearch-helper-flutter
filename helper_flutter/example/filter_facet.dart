import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        home: Provider<SearchController>(
          create: (_) => SearchController(),
          dispose: (_, value) => value.dispose(),
          child: const MyHomePage(),
        ),
      );
}

class SearchController {
  // 1. Create the component to handle the filtering logic: FilterState.
  final filterState = FilterState();

  // 2.1 Create a hits searcher to performs search requests and get results
  late final searcher = HitsSearcher(
    applicationID: 'MY_APPLICATION_ID',
    apiKey: 'MY_API_KEY',
    indexName: 'MY_INDEX_NAME',
  )
    // 2.2. Create a connection between the searcher and the filter state
    ..connectFilterState(filterState);

  // 3. Create facet list (refinement list) component.
  late final FacetList facetList = FacetList(
    searcher: searcher,
    filterState: filterState,
    attribute: 'genre',
    persistent: true,
  );

  // 4.1 Components (disposables) composite
  late final _components = CompositeDisposable()
    ..add(searcher)
    ..add(filterState)
    ..add(facetList);

  // 4.2 Dispose of all underlying resources when done
  void dispose() => _components.dispose();
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final searcher = context.read<SearchController>().searcher;
    return Scaffold(
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
      endDrawer: const Drawer(
        child: FiltersPage(),
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
                        style: Theme.of(context).textTheme.subtitle2,
                        children:
                            hit.getHighlightedString('title').toInlineSpans(),
                      ),
                    ),
                    subtitle: Text((hit['genre'] as List).join(', ')),
                  );
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key});

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  @override
  Widget build(BuildContext context) {
    final facetList = context.read<SearchController>().facetList;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Genre'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<List<SelectableFacet>>(
        stream: facetList.facets,
        builder: (context, AsyncSnapshot<List<SelectableFacet>> snapshot) {
          if (snapshot.hasData) {
            final facets = snapshot.data ?? [];
            return ListView.builder(
              itemCount: facets.length,
              itemBuilder: (BuildContext context, int index) {
                final model = facets[index];
                final facet = model.item;
                return ListTile(
                  title: Text(
                    '${facet.value} '
                    "${facet.count > 0 ? '(${facet.count})' : ''} ",
                  ),
                  trailing: model.isSelected ? const Icon(Icons.check) : null,
                  onTap: () {
                    facetList.toggle(facet.value);
                  },
                );
              },
            );
          } else {
            return const LinearProgressIndicator();
          }
        },
      ),
    );
  }
}
