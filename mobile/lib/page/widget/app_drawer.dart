import 'package:dojo_mobile/page/kyu_page.dart';
import 'package:dojo_mobile/page/mac_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../store.dart';
import '../bilgi_page.dart';
import '../first_page.dart';
import '../grafikler_page.dart';
import '../raporlar_page.dart';
import '../web_login_page.dart';
import '../yoklama_page.dart';

appDrawer(BuildContext context) {
  final store = Provider.of<Store>(context);
  return Drawer(
      child: Column(
    children: [
      DrawerHeader(
          padding: const EdgeInsets.all(0),
          child: Container(
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/logo.png",
                  fit: BoxFit.contain,
                  height: 48,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(store.AppName, style: TextStyle(color: Colors.yellow.shade700, fontWeight: FontWeight.bold, fontSize: 30))
              ],
            ),
          )),
      TextButton(
          onPressed: () {
            //scaffoldKey.currentState?.openEndDrawer();
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => FirstPage(
                      store: store,
                    )));
            //Navigator.push(context, MaterialPageRoute(builder: (context) => const FirstPage()));
          },
          child: const ListTile(
              leading: Icon(
                Icons.supervisor_account,
                size: 32,
              ),
              title: Text("Üyeler"))),
      TextButton(
          onPressed: () {
            //scaffoldKey.currentState?.openEndDrawer();
            //Navigator.push(context, MaterialPageRoute(builder: (context) => const YoklamaPage()));
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => YoklamaPage(store: store)));
            //callback(AppWindow.yoklamalar);
          },
          child: const ListTile(
              leading: Icon(
                Icons.view_list,
                size: 32,
              ),
              title: Text("Yoklamalar"))),
      TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => KyuSinaviPage(store: store)));
          },
          child: const ListTile(
              leading: Icon(
                Icons.history_edu,
                size: 32,
              ),
              title: Text("Kyu Sınavı"))),
      TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MacCalismasi(store: store)));
          },
          child: const ListTile(
            leading: Icon(Icons.flag),
            title: Text("Maç Çalışması"),
          )),
      TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => GrafiklerPage(store: store)));
          },
          child: const ListTile(
              leading: Icon(
                Icons.bar_chart, //Icons.summarize,
                size: 32,
              ),
              title: Text("Grafikler"))),
      TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => RaporlarPage(store: store)));
          },
          child: const ListTile(
              leading: Icon(
                Icons.summarize,
                size: 32,
              ),
              title: Text("Raporlar"))),
      TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => BilgiPage(store: store)));
          },
          child: const ListTile(
              leading: Icon(
                Icons.help,
                size: 32,
              ),
              title: Text("Yardım"))),
      TextButton(
          onPressed: () {
            //scaffoldKey.currentState?.openEndDrawer();
            Navigator.push(context, MaterialPageRoute(builder: (context) => const WebLoginPage()));
          },
          child: const ListTile(
              leading: Icon(
                Icons.exit_to_app,
                size: 32,
              ),
              title: Text("Çıkış")))
              
    ],
  ));
}
