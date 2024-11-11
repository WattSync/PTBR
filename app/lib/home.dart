import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  List<Map<String, dynamic>> dataList = [];
  double totalConsumption = 0.0; // Para armazenar o consumo total

  @override
  void initState() {
    super.initState();
    fetchDataList(); // Buscar dados do banco assim que a tela for carregada
  }

  Future<Database> openDatabaseConnection() async {
    return openDatabase(
      join(await getDatabasesPath(), 'medidas.db'),
      version: 1,
    );
  }

  double totalGastoReais = 0.0;
  Future<void> fetchDataList() async {
    final Database db =
        await openDatabaseConnection(); // Abre a conexão com o banco

    // Nome da tabela e colunas a serem usadas para os últimos 30 dias
    String table = 'last_30_days';
    String typeColumn = 'lst_day_ampers'; // Corrente em amperes
    String voltColumn = 'lst_day_volts'; // Tensão em volts
    String valueColumn =
        'lst_day_value_kw'; // Se houver valor do kWh, pode ser usado aqui

    // Definir o valor do kWh em reais (exemplo: 0.60 reais por kWh)
    double precoKWh = 0.85;

    // Obter registros dos últimos 30 dias
    final List<Map<String, dynamic>> records = await db.query(
      table,
      orderBy: 'lst_day_date DESC',
      limit: 30, // Considera os últimos 30 registros
    );

    double totalGastoReais = 0.0;
    double sum = 0;
    int count = 0;

    // Agrupando e calculando o valor total em reais (similar ao agrupamento feito no histórico)
    for (int i = 0; i < records.length; i++) {
      final record = records[i];

      // Cálculo da potência (kWh) - considerando amperes e voltagem
      double amperes = record[typeColumn] ?? 0.0;
      double volts = record[voltColumn] ?? 0.0;
      double horas =
          1; // Ajuste o tempo conforme necessário (aqui foi assumido 1 hora)

      double consumoKWh = (amperes * volts * horas) / 1000; // Consumo em kWh

      // Se estiver calculando o valor, multiplica pelo preço do kWh
      double valorGasto = consumoKWh * precoKWh;

      sum += valorGasto;
      count++;

      // Se for necessário agrupar (como no histórico, por exemplo, a cada 5 registros)
      if (count == 5 || i == records.length - 1) {
        // Aqui você pode usar o sum e gerar uma média ou fazer outra lógica de agrupamento
        totalGastoReais += sum;
        sum = 0;
        count = 0;
      }
    }

    // Aqui, em vez de retornar diretamente o valor formatado, deixamos o cálculo pronto
    // A formatação será feita ao usá-lo.

    // Exemplo de uso direto da formatação
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WattSync - Home',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 91, 255),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 2, 91, 255),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Seu consumo nos últimos 30 dias foi:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'R\$ ${totalGastoReais.toStringAsFixed(2)}', // Consumindo valor calculado
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            height: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Abaixo, uma listagem dos dados recebidos do banco
          Expanded(
            child: ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('ID: ${dataList[index]['sec_id']}, '
                      'Tempo: ${dataList[index]['sec_time']}s, '
                      'Corrente: ${dataList[index]['sec_miliampers']} A, '
                      'Tensão: ${dataList[index]['sec_volts']} V, '
                      'Potência: ${dataList[index]['sec_value_kw']} kW'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
