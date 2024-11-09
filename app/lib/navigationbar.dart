import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wattsync/alarme.dart';
import 'package:wattsync/configapp.dart';
import 'package:wattsync/historico.dart';
import 'package:wattsync/main.dart';

//INICIAR O APP
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppController(),
      child: NavigationBar(),
    ),
  );
}

class NavigationBar extends StatelessWidget {
  const NavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, appController, child) {
        return MaterialApp(
          theme: ThemeData(
            brightness:
                appController.isDartTheme ? Brightness.dark : Brightness.light,
          ),
          home: HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int myIndex = 0;
  List<Widget> widgetList = [
    TelaHome(), //Text('Home', style: TextStyle(fontSize: 40)),
    TelaHistorico(), //Text('Music', style: TextStyle(fontSize: 40)),
    TelaAlarme(), //Text('News', style: TextStyle(fontSize: 40)),
    TelaConfig(), //Text('News', style: TextStyle(fontSize: 40)),
  ];
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: widgetList[myIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: false,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Color.fromARGB(255, 30, 82, 144)
            : Color.fromARGB(255, 10, 21, 50),
        selectedItemColor: Color.fromARGB(
            255, 137, 191, 255), // Define a cor do item selecionado
        unselectedItemColor:
            Colors.white, // Define a cor dos itens não selecionados
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        currentIndex: myIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_sharp),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_sharp),
            label: 'Ativação',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_sharp),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MyHomePage();
  }
}

class TelaHistorico extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HistoricPage();
  }
}

class TelaAlarme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ActivationManager();
  }
}

class TelaConfig extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConfigPage();
  }
}

class AppController extends ChangeNotifier {
  bool _isDartTheme = false;
  bool get isDartTheme => _isDartTheme;

  void changeTheme(bool isDart) {
    _isDartTheme = isDart;
    notifyListeners();
  }
}
