import 'package:flutter/material.dart';
import 'medidor.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

bool animation = true;
double currentValue = 0;
double voltageValue = 0;
double powerValue = 0;

Future<Map<String, double>> dataReceiver() async {
  var url = 'http://localhost';
  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    var json = jsonDecode(response.body);

    voltageValue = double.parse(json['voltageValueJSON'].toString());
    currentValue = double.parse(json['currentValueJSON'].toString());

    return {
      'currentValueJSON': currentValue,
      'voltageValueJSON': voltageValue,
    };
  } else {
    throw Exception('Falha ao carregar dados');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color.fromARGB(255, 243, 243, 243)),
      home: const MyHomePage(title: 'WattSync'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // Calcula a largura do padding lateral
    final double screenWidth = MediaQuery.of(context).size.width;
    final double padding = screenWidth * 0.05;

    powerValue = (currentValue * voltageValue);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 2, 91, 255),
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
              color: Color.fromARGB(255, 2, 91, 255),
            ),
            height: 150,
            child: Stack(
              children: [
                Center(
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                        color: const Color.fromARGB(255, 36, 112, 255),
                      ),
                      width: 360,
                      height: 120,
                      padding: const EdgeInsets.only(top: 12.0, left: 25.0),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ('Seu consumo nos últimos 30 dias foi:'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ('R\$ XX.XX'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              height: 3,
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.white,
              ),
              width: 360,
              height: 60,
              padding: const EdgeInsets.only(top: 12.0, left: 25.0),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ('Lorem ipsum dolor sit amet, consectetur adipiscing'),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )),
          Padding(
            padding: EdgeInsets.all(padding),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 2.0,
                  mainAxisSpacing: 2.0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1,
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      color: Colors.white,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              ('Tensão'),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            medidor(
                                //isso aqui é uma função feita lá no arquivo  "medidor.dart", sendo tudo isso aí de variável,
                                Colors.blue, //cor de inicio(tipo Color)
                                Colors.purple, //cor do final(tipo Color)
                                0, //valor minimo(tipo double)
                                240, // valor maximo(tipo double)
                                powerValue, //valor atual(tipo double)
                                animation, // animação(tipo bool)
                                "V"), //letra (tipo str)
                          ]),
                    ),
                    Container(
                      alignment: Alignment.topCenter,
                      color: Colors.white,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              ('Corrente'),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            medidor(
                                //isso aqui é uma função feita lá no arquivo  "medidor.dart", sendo tudo isso aí de variável,
                                Colors.red, //cor de inicio(tipo Color)
                                Colors.orange, //cor do final(tipo Color)
                                0, //valor minimo(tipo double)
                                16, // valor maximo(tipo double)
                                currentValue, //valor atual(tipo double)
                                animation, // animação(tipo bool)
                                "A"), //letra (tipo str)
                          ]),
                    ),
                    Container(
                      alignment: Alignment.topCenter,
                      color: Colors.white,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              ('Potência'),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            medidor(
                                //isso aqui é uma função feita lá no arquivo  "medidor.dart", sendo tudo isso aí de variável,
                                Colors.green, //cor de inicio(tipo Color)
                                Colors.yellow, //cor do final(tipo Color)
                                0, //valor minimo(tipo double)
                                4000, // valor maximo(tipo double)
                                powerValue, //valor atual(tipo double)
                                animation, // animação(tipo bool)
                                "W"), //letra (tipo str)
                          ]),
                    ),
                    Container(
                      alignment: Alignment.topCenter,
                      color: Colors.white,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              ('Lorem Ipsum'),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            medidor(
                                //isso aqui é uma função feita lá no arquivo  "medidor.dart", sendo tudo isso aí de variável,
                                Colors.blue, //cor de inicio(tipo Color)
                                Colors.purple, //cor do final(tipo Color)
                                0, //valor minimo(tipo double)
                                16, // valor maximo(tipo double)
                                1, //valor atual(tipo double)
                                true, // animação(tipo bool)
                                "L"), //letra (tipo str)
                          ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
