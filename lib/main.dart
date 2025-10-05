import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const request =
    "https://api.currencyapi.com/v3/latest?apikey=cur_live_AMuQrdnrwclTSMKriepHhzu42XJXtecFoWH8lyvv";

void main() async {
  runApp(
    MaterialApp(
      home: Home(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          hintStyle: TextStyle(color: Colors.amber),
        ),
      ),
    ),
  );
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double? brl;
  double? eur;

  void realChanged(String text) {
    double real = double.parse(text);
    dolarController.text = (real / brl!).toStringAsFixed(2);
    euroController.text = (real / brl! * eur!).toStringAsFixed(2);
  }

  void dolarChanged(String text) {
    double dolar = double.parse(text);

    realController.text = (dolar * brl!).toStringAsFixed(2);
    euroController.text = (dolar * eur!).toStringAsFixed(2);
  }

  void euroChanged(String text) {
    double euro = double.parse(text);

    realController.text = (euro / eur! * brl!).toStringAsFixed(2);
    dolarController.text = (euro / eur!).toStringAsFixed(2);
  }

  void clearFields() {
    realController.clear();
    dolarController.clear();
    euroController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Currency converter \$"),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(onPressed: clearFields, icon: Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Loading data...",
                  style: TextStyle(color: Colors.amber, fontSize: 25),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error loading data :(",
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                brl = snapshot.data!["data"]["BRL"]["value"];
                eur = snapshot.data!["data"]["EUR"]["value"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      buildTextField(
                        "Reais",
                        "R\$",
                        realController,
                        realChanged,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: buildTextField(
                          "Dolar",
                          "US\$",
                          dolarController,
                          dolarChanged,
                        ),
                      ),

                      buildTextField("Euro", "€", euroController, euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

Widget buildTextField(
  String label,
  String prefix,
  TextEditingController controller,
  Function(String) function,
) {
  return TextField(
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    keyboardType: TextInputType.number,
    style: TextStyle(color: Colors.amber, fontSize: 25),
    controller: controller,
    onChanged: function,
  );
}
