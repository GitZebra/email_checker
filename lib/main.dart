import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<WebContent> fetchAlbum(email) async {
  final response = await http.get(
      Uri.parse('https://isitarealemail.com/api/email/validate?email=$email'));

  if (response.statusCode == 200) {
    return WebContent.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load');
  }
}

class WebContent {
  final String status;

  WebContent({
    required this.status,
  });

  factory WebContent.fromJson(Map<String, dynamic> json) {
    return WebContent(
      status: json['status'],
    );
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<WebContent> futureAlbum;

  final TextEditingController _emailController = TextEditingController();
  String email = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum(email);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Email Checker'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Email Checker',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              ),
              Column(
                children: [
                  TextField(
                    maxLength: 50,
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: true,
                    style: Theme.of(context).textTheme.headline4,
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 4.0,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 45.0,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_emailController.text.isNotEmpty) {
                            email = _emailController.text.trim();
                            futureAlbum = fetchAlbum(email);
                          }
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.save,
                            color: Theme.of(context).errorColor,
                          ),
                          const SizedBox(
                            width: 8.0,
                          ),
                          const Text(
                            "Check",
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Center(
                      child: FutureBuilder<WebContent>(
                        future: futureAlbum,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.status == 'valid') {
                              return Text(
                                snapshot.data!.status,
                                style: const TextStyle(
                                  fontSize: 25,
                                  color: Colors.green,
                                ),
                              );
                            } else {
                              return Text(
                                snapshot.data!.status,
                                style: const TextStyle(
                                  fontSize: 25,
                                  color: Colors.red,
                                ),
                              );
                            }
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}