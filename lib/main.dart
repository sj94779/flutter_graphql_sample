import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter(); // for cache
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GraphQL Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'GraphQL'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> characters = [];
  bool _loading = false;
  bool btnOneClick = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Center(
            child: Row(
              children: [
                ElevatedButton(
                  child: const Text("Fetch Characters"),
                  onPressed: () {
                    fetchData();
                  },
                ),
                ElevatedButton(
                  child: const Text("Fetch Films"),
                  onPressed: () {
                    fetchData2();
                  },
                ),
              ],
            ),
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : characters.isEmpty
              ? const Center(child: Text('No data'))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: btnOneClick
                      ? ListView.builder(
                          itemCount: characters.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                leading: Image(
                                  image: NetworkImage(
                                    characters[index]['image'],
                                  ),
                                ),
                                title: Text(
                                  characters[index]['name'],
                                ),
                              ),
                            );
                          })
                      :

                      // for fetchdata2 query
                      ListView.builder(
                          itemCount: characters.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                // leading: Image(
                                //   image: NetworkImage(
                                //     characters[index]['image'],
                                //   ),
                                // ),
                                title: Text(
                                  characters[index]['title'],
                                ),
                              ),
                            );
                          }),
                ),
    );
  }

  void fetchData() async {
    setState(() {
      _loading = true;
      btnOneClick = true;
    });
    HttpLink link = HttpLink("https://rickandmortyapi.com/graphql");
    GraphQLClient qlClient = GraphQLClient(
      link: link,
      cache: GraphQLCache(
        store: HiveStore(),
      ),
    );
    QueryResult queryResult = await qlClient.query(
      QueryOptions(
        document: gql(
          """query {
  characters() {
    results {
      name
      image 
    }
  }
  
}""",
        ),
      ),
    );

    setState(() {
      characters = queryResult.data!['characters']['results'];
      _loading = false;
    });
  }

  void fetchData2() async {
    setState(() {
      _loading = true;

      btnOneClick = false;
    });
    HttpLink link =
        HttpLink("https://swapi-graphql.netlify.app/.netlify/functions/index");
    GraphQLClient qlClient = GraphQLClient(
      link: link,
      cache: GraphQLCache(
        store: HiveStore(),
      ),
    );
    QueryResult queryResult = await qlClient.query(
      QueryOptions(
        document: gql(
          r"""
                    query GetContinent(){
                      allFilms {
    films {
      title
    }
  }
                    }
                  """,
        ),
      ),
    );

    setState(() {
      characters = queryResult.data!['allFilms']['films'];
      _loading = false;
    });
  }
}
