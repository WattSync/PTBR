import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wattsync/configdispositivo.dart';
import 'package:wattsync/navigationbar.dart';

class ConfigPage extends StatelessWidget {
  ConfigPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Configurações",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 30, 82, 144)
            : const Color.fromARGB(255, 10, 21, 50),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //ALTERAR TEMA CLARO OU ESCURO

              Padding(
                padding: const EdgeInsets.only(left: 50.0, bottom: 8.0),
                child: Text(
                  "Tema",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ),

              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  height: 250,
                  width: 400,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[850]
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[300]
                                    : Colors.grey[600],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0)),
                              ),
                            ),
                            Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[300]
                                    : Colors.grey[600],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0)),
                              ),
                            )
                          ],
                        ),
                        Container(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              "Claro",
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Escuro",
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Radio<bool>(
                                value: false,
                                groupValue: Provider.of<AppController>(context)
                                    .isDartTheme,
                                onChanged: (bool? value) {
                                  Provider.of<AppController>(context,
                                          listen: false)
                                      .changeTheme(false);
                                },
                              ),
                              Radio<bool>(
                                value: true,
                                groupValue: Provider.of<AppController>(context)
                                    .isDartTheme,
                                onChanged: (bool? value) {
                                  Provider.of<AppController>(context,
                                          listen: false)
                                      .changeTheme(true);
                                },
                              ),
                            ]),
                      ]),
                ),
              ),

              //ESPAÇAMENTO
              Container(
                height: 50,
              ),

              //CUSTO DO KILOWATT/H
              Padding(
                padding: const EdgeInsets.only(left: 50.0, bottom: 8.0),
                child: Text(
                  "Custo do Kilowatt (Kw/h)",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    width: 400,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[850]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white // Cor do texto para tema escuro
                            : Colors.black, // Cor do texto
                        fontSize: 18, // Tamanho da fonte
                        fontWeight: FontWeight.bold, // Peso da fonte
                      ),
                      decoration: InputDecoration(
                        hintText: 'Digite o valor',
                        // Retira a barrinha roxa (outline) no foco
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none, // Remove a borda roxa
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide
                              .none, // Remove a borda quando o campo não está em foco
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              //ESPAÇAMENTO
              SizedBox(
                height: 10,
              ),

              //BOTÃO SALVAR AS ALTERAÇÕES DO KILOWATT/H
              Align(
                child: SizedBox(
                  height: 50.0,
                  width: 200.0,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Salvar as configurações
                    },
                    child: Text('Salvar', style: TextStyle(fontSize: 20.0)),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[850] ??
                                Colors
                                    .grey // Adicionando ?? Colors.grey para garantir que não seja nulo
                            : Colors.grey[350] ??
                                Colors
                                    .grey, // Adicionando ?? Colors.grey para garantir que não seja nulo
                      ),
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white // Cor do texto para tema escuro
                            : Colors.black, // Cor do texto para tema claro
                      ),
                    ),
                  ),
                ),
              ),

              //ESPAÇAMENTO
              Container(
                height: 50,
              ),

              //BOTÃO DEFINIR LIMITE DE CONSUMO
              Align(
                child: SizedBox(
                  height: 50.0,
                  width: 300.0,
                  child: ElevatedButton(
                    onPressed: () {
                      _showConfirmationDialog(context);
                      // TODO: Abrir a tela de limite de consumo
                    },
                    child: Text(
                      "Definir limite de consumo",
                      style: TextStyle(fontSize: 20.0),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).brightness == Brightness.dark
                            ? Color.fromARGB(255, 66, 14, 84)
                            : Color.fromARGB(255, 116, 50, 157),
                      ),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                  ),
                ),
              ),

              //ESPAÇAMENTO
              SizedBox(height: 16),

              //BOTÃO CONFIGURAÇÕES DO DISPOSITIVO
              Align(
                child: SizedBox(
                  height: 50.0,
                  width: 350.0,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => configDispositivo()),
                      );
                    },
                    child: Text(
                      "Configurações do Dispositivo",
                      style: TextStyle(fontSize: 20.0),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).brightness == Brightness.dark
                            ? Color.fromARGB(255, 66, 14, 84)
                            : Color.fromARGB(255, 116, 50, 157),
                      ),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Limite de Consumo'),
        content: Text('Deseja definir o limite de consumo?'),
        actions: <Widget>[
          TextButton(
            child: Text('Não'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Sim'),
            onPressed: () {
              // TODO: Adicionar lógica para desconectar o dispositivo
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
