import 'dart:convert';
import 'package:app_cotacao/widget_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Semanal extends StatefulWidget {
  @override
  _SemanalState createState() => _SemanalState();
}

class _SemanalState extends State<Semanal> {
  String search;
  double _variacao;
  double _abertura;
  double _fechamento;
  double _alta;
  double _baixa;
  DateTime _dateTime = new DateTime.now();

  Future<Map> _getStockPrice() async {
    http.Response response;
    if (search == null || search.isEmpty)
//Por padrão busca índice bovespa: ^BVSP
      response = await http.get(
          "https://www.alphavantage.co/query?function=TIME_SERIES_WEEKLY&symbol=^BVSP&apikey=DS2B6XU5GXEW1VEV");
    else
//Retorna o valor da ação a ser buscada, essa ação estará armazenada na variável search
      response = await http.get(
          "https://www.alphavantage.co/query?function=TIME_SERIES_WEEKLY&symbol=$search.SAO&apikey=DS2B6XU5GXEW1VEV");
//Retorna o json que foi obtido pela consulta a API
    return json.decode(response.body);
  }

//Método para mostrar retorno da API
  @override
  void initState() {
    super.initState();
    _getStockPrice().then((map) {
      print(map);
    });
  }

  double _getVariacao(double abertura, double fechamento) {
    return (fechamento / abertura - 1) * 100;
  }

  @override
  Widget build(BuildContext context) {
    String _dataFormatada = new DateFormat("yyyy-MM-dd").format(_dateTime);
    return new Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text("Cotação"),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.calendar_today,
              ),
              onPressed: () {
                showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    builder: (BuildContext context, Widget child) {
                      return Theme(
                        data: ThemeData.dark(),
                        child: child,
                      );
                    }).then((date) {
                  if (date != null) {
                    setState(() {
                      _dateTime = date;
                      print(_dateTime);
                      print(_dataFormatada);
                    });
                  }
                });
              },
            ),
          ],
        ),
        body: new Stack(children: <Widget>[
          Image.asset(
            "lib/images/market.jpg",
            fit: BoxFit.cover,
            height: 1000.0,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                      labelText: 'Pesquise Aqui!',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder()),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  onSubmitted: (text) {
                    setState(() {
                      search = text;
                    });
                  },
                ),
              ),
              Expanded(
                child: FutureBuilder(
                    future: _getStockPrice(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return Container(
                            width: 200.0,
                            height: 200.0,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 5.0,
                            ),
                          );
                        default:
                          if (snapshot.data["Weekly Time Series"]
                                  [_dataFormatada.toString()] ==
                              null)
                            return Padding(padding: EdgeInsets.all(40),
                            child:
                            Text("Não foi possível obter os dados, data inválida.",
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                    textAlign: TextAlign.center,));
                          _abertura = double.parse(
                              snapshot.data["Weekly Time Series"]
                                  [_dataFormatada.toString()]["1. open"]);
                          _alta = double.parse(
                              snapshot.data["Weekly Time Series"]
                                  [_dataFormatada.toString()]["2. high"]);
                          _baixa = double.parse(
                              snapshot.data["Weekly Time Series"]
                                  [_dataFormatada.toString()]["3. low"]);
                          _fechamento = double.parse(
                              snapshot.data["Weekly Time Series"]
                                  [_dataFormatada.toString()]["4. close"]);
                          _variacao = _getVariacao(_abertura, _fechamento);

                          return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Ativo: " + busca(search),
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                Text(_variacao.toStringAsPrecision(3) + "%",
                                    style: TextStyle(
                                        fontSize: 70,
                                        fontWeight: FontWeight.bold,
                                        color: _variacao > 0
                                            ? Colors.green
                                            : Colors.red)),
                                Text("Abertura: R\$" + _abertura.toString(),
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                Text("Alta: R\$" + _alta.toString(),
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                Text("Baixa: R\$" + _baixa.toString(),
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                Text("Fechamento: R\$" + _fechamento.toString(),
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white))
                              ]);
                      }
                    }),
              ),
            ],
          )
        ]));
  }
}
