import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dados do ESP32',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DataReceiver(),
    );
  }
}

class DataReceiver extends StatefulWidget {
  @override
  _DataReceiverState createState() => _DataReceiverState();
}

class _DataReceiverState extends State<DataReceiver> {
  String _data = 'Aguardando dados...';
  double voltage = 0.0;
  double current = 0.0;
  double frequency = 0.0;
  bool isOn = false;
  bool wire1 = false;
  bool wire2 = false;
  Timer? _timer; // Timer para o loop
  int _start = 10; // Contador

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      //     fetchData(); // Chama a função de buscar dados
    });
  }

  Future<void> fetchData() async {
    const url =
        'http://192.168.0.13/enviar-dados'; // Substitua pelo IP do ESP32

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        setState(() {
          voltage = (jsonResponse['tensao'] as num).toDouble();
          current = (jsonResponse['corrente'] as num).toDouble();
          frequency = (jsonResponse['frequencia'] as num).toDouble();
          isOn = jsonResponse['ligado'] == 1;
          wire1 = jsonResponse['Fio1'] == 1;
          wire2 = jsonResponse['Fio2'] == 1;
          _data = response.body;
        });
      } else {
        setState(() {
          _data = 'Erro ao receber dados: ${response.statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        _data = 'Erro: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receber Dados do ESP32'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Dados Recebidos:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Tensão: ${voltage.toStringAsFixed(1)} V',
                style: TextStyle(fontSize: 20)),
            Text('Corrente: ${current.toStringAsFixed(3)} mAh',
                style: TextStyle(fontSize: 20)),
            Text('Frequência: ${frequency.toStringAsFixed(2)} Hz',
                style: TextStyle(fontSize: 20)),
            Text('Está Ligado: ${isOn ? "Sim" : "Não"}',
                style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
