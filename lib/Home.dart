import 'package:flutter/material.dart';
import 'package:flutter_anota_bd/helper/anotacaoHelper.dart';
import 'package:flutter_anota_bd/model/Anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _titutoControler = TextEditingController();
  TextEditingController _descricaoControler = TextEditingController();

  var _db = AnotacaoHelper();

  List<Anotacao> _anotacoes = List<Anotacao>();

  _exibirTeleCadastro( { Anotacao anotacao }){

    String textoSalvarAtualizar = "";

    if(anotacao == null){// salvar
      _titutoControler.text = "";
      _descricaoControler.text = "";
      textoSalvarAtualizar = "Salvar";
    }else{
      _titutoControler.text = anotacao.titulo;
      _descricaoControler.text = anotacao.descricao;

      textoSalvarAtualizar = "Atualizar";

    }


    showDialog(
      context: context,
      builder: (context){

        return AlertDialog(
          title: Text(textoSalvarAtualizar + " Anotação"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                controller: _titutoControler,
                decoration: InputDecoration(
                  labelText: 'Título',
                  hintText: 'Digite o Títudo'
                ),
              ),
              TextField(
                controller: _descricaoControler,
                decoration: InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Digite a Descição'
                ),
              )
            ],
          ),
          actions: [
            FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar')
            ),
            FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  _salvarAtualizarAnotacao( anotacaoSelecionada: anotacao );
                },
                child: Text(textoSalvarAtualizar)
            )
          ],

        );
      }
    );
  }

  _recuperarAnotacoes() async {

    List anotacoesRecuperadas = await _db.recuperarAnotacoes();

    List<Anotacao> _listaTemporaria = List<Anotacao>();

    for (var item in anotacoesRecuperadas){
      Anotacao anotacao = Anotacao.fromMap(item);
      _listaTemporaria.add(anotacao);
    }

    setState(() {
      _anotacoes = _listaTemporaria;
    });
    _listaTemporaria = null;

  }

  _salvarAtualizarAnotacao( {Anotacao anotacaoSelecionada}) async{
    String titulo = _titutoControler.text;
    String descricao = _descricaoControler.text;

    if (anotacaoSelecionada == null){
      Anotacao anotacao = Anotacao(titulo, descricao, DateTime.now().toString());
      int resultado = await _db.salvarAnotacao(anotacao);
    }else {
      anotacaoSelecionada.titulo =  titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();
      int resultado = await _db.atualizarAnotacao(anotacaoSelecionada);
    }


    _titutoControler.clear();
    _descricaoControler.clear();

    _recuperarAnotacoes();
  }

  _formatarData(String data){
    initializeDateFormatting("pt_BR");
    
    var formatador = DateFormat.yMd("pt_BT");
    
    DateTime dataConcertida = DateTime.parse(data);
    String dataFormatada = formatador.format(dataConcertida);

    return dataFormatada;
  }

  _removerAnotacao(int id) async{
    await _db.removerAnotacao(id);
    _recuperarAnotacoes();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreenAccent,
        title: Text('Anotações'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _anotacoes.length,
              itemBuilder: (context, index){

                final anotacao = _anotacoes[index];

                return Card(
                  child: ListTile(
                    title: Text(anotacao.titulo),
                    subtitle: Text("${_formatarData(anotacao.data)} - ${anotacao.descricao}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: (){
                            _exibirTeleCadastro(anotacao: anotacao);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(
                              Icons.edit,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            _removerAnotacao( anotacao.id );
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightGreen,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: _exibirTeleCadastro,
      ),
    );
  }
}
