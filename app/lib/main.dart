import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wattsync/navigationbar.dart';
import 'medidor.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

bool animation = true;
double currentValue = 0;
double voltageValue = 0;
double powerValue = 0;
double frequencyValue = 0;
bool isOn = false;
bool wire1 = false;
bool wire2 = false;
Timer? _timer;

Future<void> fetchData() async {
  const url =
      'http://WattSync.local/enviar-dados'; // Substitua pelo IP do ESP32. No caso do PC que não possui PORT, deixar "WattSync.local" no lugar do IP

  try {
    final response =
        await http.get(Uri.parse(url)).timeout(Duration(seconds: 5));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      voltageValue = (jsonResponse['tensao'] as num).toDouble();
      currentValue = (jsonResponse['corrente'] as num).toDouble();
      frequencyValue = (jsonResponse['frequencia'] as num).toDouble();
      isOn = jsonResponse['ligado'];
      wire1 = jsonResponse['Fio1'];
      wire2 = jsonResponse['Fio2'];
    } else {
      throw Exception('Erro ao receber dados: ${response.statusCode}');
    }
  } catch (error) {
    print('Erro: $error');
    // Trate o erro, talvez atualizando a interface do usuário
  }
}

void main() {
  runApp(
    TelaHome(),
  );
}

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String texto1 = "";
  String texto2 = "";
  bool determinante = false;
  TextStyle textStyle1 = const TextStyle(color: Colors.black, fontSize: 14);
  TextStyle textStyle2 = const TextStyle(color: Colors.black, fontSize: 14);

  void typeOfWire() {
    determinante = !wire1 && !wire2;
    if (determinante) {
      texto1 = 'Nenhuma rede identificada.';
      texto2 = '';
      textStyle1 = TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold);
      textStyle2 = TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold);
    } else {
      if (wire1) {
        texto1 = "Fase";
        textStyle1 = TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Color.fromARGB(255, 255, 137, 137)
                : Color.fromARGB(255, 129, 11, 11),
            fontSize: 16,
            fontWeight: FontWeight.bold);
      }
      if (!wire1) {
        texto1 = 'Neutro';
        textStyle1 = TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Color.fromARGB(255, 137, 191, 255)
                : Color.fromARGB(255, 30, 82, 144),
            fontSize: 16,
            fontWeight: FontWeight.bold);
      }
      if (wire2) {
        texto2 = ' Fase';
        textStyle2 = TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Color.fromARGB(255, 255, 137, 137)
                : Color.fromARGB(255, 129, 11, 11),
            fontSize: 16,
            fontWeight: FontWeight.bold);
      }
      if (!wire2) {
        texto2 = ' Neutro';
        textStyle2 = TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Color.fromARGB(255, 137, 191, 255)
                : Color.fromARGB(255, 30, 82, 144),
            fontSize: 16,
            fontWeight: FontWeight.bold);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      fetchData().then((_) {
        if (!mounted) return;
        setState(() {
          powerValue = (currentValue * voltageValue);
          typeOfWire();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calcula a largura do padding lateral
    final double screenWidth = MediaQuery.of(context).size.width;
    final double padding = screenWidth * 0.05;

    // Determina a cor baseada no tema
    final Color backgroundColor =
        Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 30, 82, 144)
            : const Color.fromARGB(255, 10, 21, 50);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "WattSync",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: backgroundColor,
              ),
              height: 150,
              child: Stack(
                children: [
                  Center(
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Color.fromARGB(255, 10, 21, 50)
                              : Color.fromARGB(255, 30, 82, 144),
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
                                fontSize: 16,
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromARGB(255, 30, 31, 28)
                    : const Color.fromARGB(255, 235, 235, 235),
              ),
              width: 360,
              height: 60,
              padding: EdgeInsets.only(left: 20.0, right: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Tipo de rede:',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8.0), // Espaçamento entre os textos
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          texto1,
                          style: textStyle1,
                        ),
                        if (texto1.isNotEmpty && texto2.isNotEmpty)
                          Text(
                            ' - ',
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        Text(
                          texto2,
                          style: textStyle2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 60,
            ),
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
                        alignment: Alignment.center,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromARGB(255, 30, 31, 28)
                            : const Color.fromARGB(255, 235, 235, 235),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ('Tensão'),
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              medidor(
                                  Colors.blue,
                                  Colors.purple,
                                  0,
                                  240,
                                  voltageValue, // Atualiza para usar a tensão recebida
                                  animation,
                                  "V"),
                            ]),
                      ),
                      Container(
                        alignment: Alignment.center,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromARGB(255, 30, 31, 28)
                            : const Color.fromARGB(255, 235, 235, 235),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ('Corrente'),
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              medidor(
                                  Colors.red,
                                  Colors.orange,
                                  0,
                                  16,
                                  currentValue, // Atualiza para usar a corrente recebida
                                  animation,
                                  "A"),
                            ]),
                      ),
                      Container(
                        alignment: Alignment.center,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromARGB(255, 30, 31, 28)
                            : const Color.fromARGB(255, 235, 235, 235),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ('Potência'),
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              medidor(Colors.green, Colors.yellow, 0, 4000,
                                  powerValue, animation, "W"),
                            ]),
                      ),
                      Container(
                        alignment: Alignment.center,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromARGB(255, 30, 31, 28)
                            : const Color.fromARGB(255, 235, 235, 235),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ('Frequência'),
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              medidor(Colors.purple, Colors.pink, 0, 80,
                                  frequencyValue, animation, "Hz"),
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
