import 'package:dojo_mobile/service.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';

import '../api.dart';
import '../store.dart';
import 'appwindow.dart';

class Harcama extends StatefulWidget {
  final Store store;
  final String uyeAd;
  final int uyeId;
  final MuhasebeDiger muhasebe;

  const Harcama(BuildContext context, {super.key, required this.store, required this.uyeAd, required this.uyeId, required this.muhasebe});
  @override
  State<StatefulWidget> createState() {
    return _Harcama();
  }
}

class _Harcama extends State<Harcama> {
  final int yil = DateTime.now().year;
  final _formKey = GlobalKey<FormState>();
  final aciklamacon = TextEditingController();
  late Api api;
  late LoadingDialog loadingdlg;

  late MoneyMaskedTextController tutarcon;

  @override
  void initState() {
    api = Api(url: widget.store.ApiUrl, authorization: widget.store.ApiToken);
    widget.muhasebe.tarih = DateTime.now();
    aciklamacon.text = widget.muhasebe.aciklama;
    tutarcon = MoneyMaskedTextController(thousandSeparator: ".", decimalSeparator: "", rightSymbol: "TL", precision: 0, initialValue: widget.muhasebe.tutar);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    loadingdlg = LoadingDialog(context);
    return uyeScaffold(
        uyeAd: widget.uyeAd,
        body: Form(
            key: _formKey,
            child: Column(children: [
              ElevatedButton(
                  onPressed: () {
                    loadingdlg.toggle();
                    Future.delayed(
                      const Duration(seconds: 5),
                      () {
                        loadingdlg.toggle();
                      },
                    );
                  },
                  child: Text("load"))
            ])));
  }
}
