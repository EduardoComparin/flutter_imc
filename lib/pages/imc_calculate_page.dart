import 'package:flutter/material.dart';
import 'package:flutter_imc/model/imc_model.dart';
import 'package:flutter_imc/repositories/imc_repository.dart';
import 'package:flutter_imc/service/storage_service.dart';
import 'package:flutter_imc/shared/widgets/fild_heigth.dart';
import 'package:flutter_imc/shared/widgets/fild_number.dart';
import 'package:flutter_imc/shared/widgets/fild_text.dart';
import 'package:flutter_imc/util/imc_util.dart';

class ImcPage extends StatefulWidget {
  const ImcPage({Key? key}) : super(key: key);

  @override
  State<ImcPage> createState() => _ImcPageState();
}

class _ImcPageState extends State<ImcPage> {
  StorageService storage = StorageService();
  ImcRepository imcRepository = ImcRepository();

  @override
  void initState() {
    super.initState();
    carregarDadosCalculadora();
  }

  carregarDadosCalculadora() async {
    double altura = await (storage.getConfiguracaoAltura());
    String nome = await storage.getConfiguracaoNome();

    if (altura > 0) {
      alturaController.text = altura.toString().replaceAll(".", ",");
    }

    if (nome != "") {
      nomeController.text = nome;
    }

    setState(() {});
  }

  Color corIcone = Colors.black;
  Color corBorder = Colors.black;
  Color? backgroundColor = Colors.white;
  Color textColor = Colors.black;

  var pesoController = TextEditingController();
  var alturaController = TextEditingController();
  var nomeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: const Text(
              "Calculadora IMC",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            )),
        backgroundColor: backgroundColor,
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 40,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(right: 30, left: 30),
                      height: 30,
                      alignment: Alignment.center,
                      child: FildText(
                          icon: Icons.person_3_rounded,
                          nomeController: nomeController,
                          textColor: textColor,
                          corBorder: corBorder,
                          corIcone: corIcone,
                          hint: "Nome"),
                    ))
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(left: 30),
                        height: 30,
                        alignment: Alignment.center,
                        child: FildNumber(
                            icon: Icons.balance_rounded,
                            controller: pesoController,
                            textColor: textColor,
                            corBorder: corBorder,
                            corIcone: corIcone,
                            hint: "Peso",
                            textSufix: "Kg"),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Expanded(
                        flex: 5,
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(right: 30),
                          height: 30,
                          alignment: Alignment.center,
                          child: FildHeigth(
                              icon: Icons.swap_vert,
                              controller: alturaController,
                              textColor: textColor,
                              corBorder: corBorder,
                              corIcone: corIcone,
                              hint: "Altura",
                              textSufix: "M"),
                        )),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 100),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () async {
                        FocusManager.instance.primaryFocus?.unfocus();

                        String nome = nomeController.text.trim();
                        double peso = validaPeso();
                        double altura = validaAltura();

                        if (peso > 0 && altura > 0 && nome != '') {
                          double valorImc = ImcUtil.calcularIMC(peso, altura);
                          String resultadoImc = ImcUtil.tipoImc(valorImc);

                          pesoController.text = "";
                          alturaController.text = "";
                          nomeController.text = "";

                          showMsg(
                              context,
                              "Seu indice é de ${valorImc.toStringAsFixed(2)}",
                              resultadoImc);

                          await imcRepository.save(ImcModel(
                              0, peso, altura, nome, valorImc, resultadoImc));

                          carregarDadosCalculadora();
                        } else {
                          showMsg(context, "ATENÇÃO",
                              "INFORME OS DADOS CORRETAMENTE");
                        }
                      },
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.teal)),
                      child: Text(
                        "Calcular",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double validaAltura() {
    String alturaText =
        alturaController.text == '' ? '0,00' : alturaController.text;

    double altura =
        double.parse(alturaText.replaceAll('.', '').replaceAll(',', '.'));
    return altura;
  }

  double validaPeso() {
    String pesoText = pesoController.text == '' ? '0,00' : pesoController.text;

    double peso =
        double.parse(pesoText.replaceAll('.', '').replaceAll(',', '.'));
    return peso;
  }

  void showMsg(BuildContext context, String title, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            content: Text(
              msg,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ));
      },
    );
  }
}
