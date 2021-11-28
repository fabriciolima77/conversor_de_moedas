import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json-cors&key=a7a20019";
//Requisição assincrona é uma requisição que você faz e não fica esperando
//receber a hora que você recebe você executa a ação
void main() async{

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
      ),

    ),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}
// stful => atalho widget stateful Scaffold permite colocar Appbar
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final btcController = TextEditingController();

  double dolar;
  double euro;
  double real;
  double btc;

  void _realChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
    btcController.text = (real/btc).toStringAsFixed(7);
  }
  void _dolarChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    btcController.text = (dolar * this.dolar / btc).toStringAsFixed(7);
  }
  void _euroChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    realController.text = (euro * this.euro / real).toStringAsFixed(2);
    btcController.text = (euro * this.euro / btc).toStringAsFixed(7);
  }
  void _btcChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double btc = double.parse(text);
    dolarController.text = (btc * this.btc / dolar).toStringAsFixed(2);
    euroController.text = (btc * this.btc / euro).toStringAsFixed(2);
    realController.text = (btc * this.btc).toStringAsFixed(2);
  }


  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
    btcController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(text: "Moedas",),
                Tab(text: "Criptomoedas",)
              ],
            ),
            title: Text("\$Conversor\$"),
            backgroundColor: Colors.amber,
            centerTitle: true,
          ),
          //FutureBuilder: Enquanto obtendo dados "Carregando dados"
          //Futuro = getData() futuro dos dados
          body: TabBarView(
            children: [
              FutureBuilder<Map>(
                  future: getData(),
                  builder: (context, snapshot){
                    switch(snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: Text("Carregando Dados...",
                            style: TextStyle(color: Colors.amber, fontSize: 25.0,),
                          ),
                        );
                      default:
                        if(snapshot.hasError){
                          return Center(
                            child: Text("Erro ao Carrear dados :(",
                              style: TextStyle(color: Colors.amber, fontSize: 25.0,),
                            ),
                          );
                        }else{
                          dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                          euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                          btc = snapshot.data["results"]["currencies"]["BTC"]["buy"];

                          return SingleChildScrollView(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Icon(Icons.monetization_on, size: 150.0,
                                    color: Colors.amber),
                                buildTextField("Reais", "R\$", realController, _realChanged),
                                Divider(),
                                buildTextField("Dolar", "\$", dolarController, _dolarChanged),
                                Divider(),
                                buildTextField("Euros", "€", euroController, _euroChanged),
                                Divider(),
                                buildTextField("Bitcoin", "₿", btcController, _btcChanged),

                              ],
                            ),
                          );
                        }
                    }
                  }),
              Column(),
            ],

          ),

          ),

        ),
      );

  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(
      color: Colors.amber, fontSize: 25.0,
    ),
    onChanged: f,
    keyboardType: TextInputType.number,
  );

}
