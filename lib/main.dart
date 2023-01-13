import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<PokemonResponse> futurePokemon;

  @override
  void initState() {
    super.initState();
    futurePokemon = fetchResults();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokemon App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pokemon App'),
        ),
        body: Center(
          child: FutureBuilder<PokemonResponse>(
            future: futurePokemon,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                //return Text(snapshot.data!.name!);
                //print(snapshot.data!.next);
                return ListView.builder(
                  itemCount: snapshot.data!.results!.length,
                  prototypeItem: ListTile(
                    title: Text(snapshot.data!.results!.first.name!),
                  ),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data!.results![index].name!),
                      leading: Image.network(
                          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${index + 1}.png'),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              } else {
                return const CircularProgressIndicator();
              }
            },
          )
        ),
      ),
    );
  }
}

class DetallePokemon extends StatelessWidget{
  const DetallePokemon({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Data'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go Back'),
        )
      ),
    );
  }
}

Future<PokemonResponse> fetchResults() async {
  final response =
      await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=10'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return PokemonResponse.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class PokemonResponse {
  int? count;
  String? next;
  String? previous;
  List<Results>? results;

  PokemonResponse(
      {this.count, this.next, this.previous, required this.results});

  PokemonResponse.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results!.add(Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['count'] = this.count;
    data['next'] = this.next;
    data['previous'] = this.previous;
    if (this.results != null) {
      data['results'] = this.results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String? name;
  String? url;

  Results({this.name, this.url});

  Results.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = this.name;
    data['url'] = this.url;
    return data;
  }
}
