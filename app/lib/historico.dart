import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'database_helper.dart'; // Certifique-se de que o caminho esteja correto
//import 'db_helper.dart'; // Importe o arquivo onde configurou o SQLite

class TelaHistorico extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HistoricPage();
  }
}

class HistoricPage extends StatefulWidget {
  HistoricPage({Key? key}) : super(key: key);

  @override
  HistoricPageState createState() => HistoricPageState();
}

class HistoricPageState extends State<HistoricPage> {
  String DropDownTime = 'Últimas 24h';
  String DropDownType = 'Corrente';

  List<_SalesData> data = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<Map<String, dynamic>> rawData =
        await DatabaseHelper().getLast24HoursData();
    print(rawData); // Depuração para verificar os dados recebidos.

    setState(() {
      data = rawData.map((entry) {
        return _SalesData(
          entry['lst_hour_datetime'].toString() ??
              'N/A', // Verifique se está retornando um valor válido.
          entry['lst_hour_value_kw'] ?? 0.0, // Substitua valores nulos por 0.0.
        );
      }).toList();
      print(
          "Dados carregados: ${data.length}"); // Verifique quantos pontos estão sendo carregados.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Histórico de consumo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 30, 82, 144)
            : const Color.fromARGB(255, 10, 21, 50),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DropdownMenu2(
                    onChanged: (value) {
                      setState(() {
                        DropDownTime = value;
                        // Atualize os dados conforme o intervalo de tempo selecionado
                        _loadData(); // Chame a função para carregar os dados atualizados
                      });
                    },
                  ),
                  SizedBox(width: 10),
                  DropdownMenuType(
                    onChanged: (value) {
                      setState(() {
                        DropDownType = value;
                        // Aqui você pode adicionar lógica com base no valor selecionado
                      });
                    },
                  ),
                ],
              ),
            ),
            SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[500]
                        : Colors.grey[700],
                    fontWeight: FontWeight.bold),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[500]
                        : Colors.grey[700],
                    fontWeight: FontWeight.bold),
              ),
              title: ChartTitle(
                text: 'Histórico de Consumo',
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              legend: Legend(
                isVisible: true,
                textStyle: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries<_SalesData, String>>[
                LineSeries<_SalesData, String>(
                  dataSource: data,
                  xValueMapper: (_SalesData sales, _) => sales.year,
                  yValueMapper: (_SalesData sales, _) => sales.sales,
                  name: 'Consumo',
                  color: Color.fromARGB(255, 116, 50, 157),
                  dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      textStyle:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    color: Color.fromARGB(255, 116, 50, 157),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* class HistoricPageState extends State<HistoricPage> {
  String DropDownTime = 'Últimas 24h';
  String DropDownType = 'Corrente';
  List<_SalesData> data = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Função para carregar os dados do banco de dados
  Future<void> _loadData() async {
    final dbHelper = DBHelper();
    List<Map<String, dynamic>> results =
        await dbHelper.getSecondsData(DropDownTime);

    // Transformar os dados do banco em _SalesData
    List<_SalesData> salesData = results.map((record) {
      // Ajuste o mapeamento dependendo da tabela
      String time;
      double value;

      if (DropDownTime == 'Últimas 24h') {
        time = record['lst_hour_datetime']
            .toString(); // Formate conforme necessário
        value = record['lst_hour_miliampers'] ??
            0.0; // Mude para o valor que deseja plotar
      } else if (DropDownTime == 'Últimos 30 dias') {
        time = record['lst_day_date'].toString(); // Formate conforme necessário
        value = record['lst_day_ampers'] ??
            0.0; // Mude para o valor que deseja plotar
      } else if (DropDownTime == 'Últimos 12 meses') {
        time = record['lst_mnt_date'].toString(); // Formate conforme necessário
        value = record['lst_mnt_ampers'] ??
            0.0; // Mude para o valor que deseja plotar
      } else {
        time = ''; // Para outros casos, se necessário
        value = 0.0; // Valor padrão
      }

      return _SalesData(time, value);
    }).toList();

    setState(() {
      data = salesData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Histórico de consumo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 30, 82, 144)
            : const Color.fromARGB(255, 10, 21, 50),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DropdownMenu2(
                    onChanged: (value) {
                      setState(() {
                        DropDownTime = value;
                        _loadData(); // Recarrega os dados com base na seleção de tempo
                      });
                    },
                  ),

                  SizedBox(
                      width: 10), // Espaçamento entre os dois DropdownButtons
                  DropdownMenuType(
                    onChanged: (value) {
                      setState(() {
                        DropDownType = value;
                        // Aqui você pode adicionar lógica com base no valor selecionado
                      });
                    },
                  ),
                ],
              ),
            ),
            SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[500]
                        : Colors.grey[700],
                    fontWeight: FontWeight.bold),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[500]
                        : Colors.grey[700],
                    fontWeight: FontWeight.bold),
              ),
              title: ChartTitle(
                text: 'Histórico de Consumo',
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              legend: Legend(
                isVisible: true,
                textStyle: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries<_SalesData, String>>[
                LineSeries<_SalesData, String>(
                  dataSource: data,
                  xValueMapper: (_SalesData sales, _) => sales.year,
                  yValueMapper: (_SalesData sales, _) => sales.sales,
                  name: 'Consumo',
                  color: Color.fromARGB(255, 116, 50, 157),
                  dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      textStyle:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    color: Color.fromARGB(255, 116, 50, 157),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SfSparkLineChart.custom(
                trackball: SparkChartTrackball(
                    activationMode: SparkChartActivationMode.tap),
                marker: SparkChartMarker(
                    displayMode: SparkChartMarkerDisplayMode.all),
              ),
            ),
          ],
        ),
      ),
    );
  }
} */

class DropdownMenu2 extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const DropdownMenu2({super.key, required this.onChanged});

  @override
  State<DropdownMenu2> createState() => _DropdownMenuState();
}

const List<String> list = <String>[
  'Últimas 24h',
  'Últimos 7 dias',
  'Últimos 15 dias',
  'Últimos 30 dias',
  'Últimos 6 meses',
  'Últimos 12 meses'
];

class _DropdownMenuState extends State<DropdownMenu2> {
  String DropDownTime = list.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: DropDownTime,
      onChanged: (String? newValue) {
        setState(() {
          DropDownTime = newValue!;
        });
        widget.onChanged(DropDownTime);
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontSize: 20,
              )),
        );
      }).toList(),
      icon: Icon(
        Icons.arrow_downward,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      iconSize: 24,
    );
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}

// Novo Dropdown para selecionar "Corrente" ou "Valor"
class DropdownMenuType extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const DropdownMenuType({super.key, required this.onChanged});

  @override
  State<DropdownMenuType> createState() => _DropdownMenuTypeState();
}

const List<String> types = <String>['Corrente', 'Valor'];

class _DropdownMenuTypeState extends State<DropdownMenuType> {
  String DropDownType = types.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: DropDownType,
      onChanged: (String? newValue) {
        setState(() {
          DropDownType = newValue!;
        });
        widget.onChanged(DropDownType);
      },
      items: types.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontSize: 20,
              )),
        );
      }).toList(),
      icon: Icon(
        Icons.arrow_downward,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      iconSize: 24,
    );
  }
}
