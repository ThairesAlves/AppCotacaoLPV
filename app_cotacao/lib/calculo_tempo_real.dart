import 'dart:convert';
import 'package:app_cotacao/widget_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TempoReal extends StatefulWidget {
  @override
  _TempoRealState createState() => _TempoRealState();
}

class _TempoRealState extends State<TempoReal> {
  String search;
  double _variacao;
  double _abertura;
  double _fechamento;
  double _alta;
  double _baixa;
  DateTime _dateTime = new DateTime.now();
  TimeOfDay _horas = new TimeOfDay.now();
  String _joinDataHora;

  Future<Map> _getStockPrice() async {
    http.Response response;
    if (search == null || search.isEmpty)
//Por padrão busca índice bovespa: ^BVSP
      response = await http.get(
          "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=^BVSP&interval=5min&apikey=S4GKIM7HXPJLJE2N");
    else
//Retorna o valor da ação a ser buscada, essa ação estará armazenada na variável _search
      response = await http.get(
          "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=$search.SAO&interval=5min&apikey=S4GKIM7HXPJLJE2N");
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
    String _horaFormatada;
    String _horaFormatada2;
    String _horaFormatada3;
    var mediaQuery = MediaQuery.of(context);
    var size = mediaQuery.size;
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("COTAÇÃO EM TEMPO REAL"),
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
                    _dateTime = date;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.access_time,
            ),
            onPressed: () {
              showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (BuildContext context, Widget child) {
                    return Theme(
                      data: ThemeData.dark(),
                      child: child,
                    );
                  }).then((hour) {
                if (hour != null) {
                  setState(() {
                    _horas = hour;
                    _horaFormatada =
                        _horas.toString().replaceAll("TimeOfDay", "");
                    _horaFormatada2 =
                        _horaFormatada.toString().replaceAll("(", "");
                    _horaFormatada3 =
                        _horaFormatada2.toString().replaceAll(")", "");
                    _joinDataHora = _dataFormatada.toString() +
                        ' ' +
                        _horaFormatada3 +
                        ':00';
                    print(hour);
                    print(_joinDataHora);
                  });
                }
              });
            },
          ),
        ],
      ),
      body: new Stack(
        children: <Widget>[
          Image.asset(
            "lib/images/market.jpg",
            fit: BoxFit.cover,
            height: 1000.0,
          ),
          Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Consultas em tempo real estão disponíveis para todo dia útil a cada 5 minutos, considere que é necessário que o último número deve ser 0 ou 5",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              )),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding:
                    EdgeInsets.only(top: 80, left: 10, right: 10, bottom: 20),
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                      labelText: 'Pesquisar Ativo',
                      hintText: 'Ex.: Bidi4',
                      hintStyle: TextStyle(color: Colors.white),
                      labelStyle: TextStyle(color: Colors.white),
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.white))),
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
                            width: size.width / 2,
                            height: size.height / 2,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 5.0,
                            ),
                          );
                        default:
                          if (snapshot.data["Time Series (5min)"] == null)
                            return Padding(
                                padding: EdgeInsets.all(40),
                                child: Text(
                                  "Não foi possível obter os dados, ativo inválido.",
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ));
                          if (snapshot.data["Time Series (5min)"]
                                      [_joinDataHora.toString()] ==
                                  null ||
                              snapshot.hasError)
                            return Padding(
                                padding: EdgeInsets.all(40),
                                child: Text(
                                  "Não foi possível obter os dados, data inválida.",
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ));
                          _abertura = double.parse(
                              snapshot.data["Time Series (5min)"]
                                  [_joinDataHora.toString()]["1. open"]);
                          _alta = double.parse(
                              snapshot.data["Time Series (5min)"]
                                  [_joinDataHora.toString()]["2. high"]);
                          _baixa = double.parse(
                              snapshot.data["Time Series (5min)"]
                                  [_joinDataHora.toString()]["3. low"]);
                          _fechamento = double.parse(
                              snapshot.data["Time Series (5min)"]
                                  [_joinDataHora.toString()]["4. close"]);
                          _variacao = _getVariacao(_abertura, _fechamento);
                          return ListView(
                              padding: EdgeInsets.all(40),
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
        ],
      ),
    );
  }
}
