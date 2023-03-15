import 'package:flutter/material.dart';

import '../appwindow.dart';
import '../first_page.dart';
import '../web_login_page.dart';
import '../yoklama_page.dart';

app_drawer(BuildContext context) {
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
                Text(AppTitleText, style: TextStyle(color: Colors.yellow.shade700, fontWeight: FontWeight.bold, fontSize: 30))
              ],
            ),
          )),
      TextButton(
          onPressed: () {
            //scaffoldKey.currentState?.openEndDrawer();
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const FirstPage()));
            //Navigator.push(context, MaterialPageRoute(builder: (context) => const FirstPage()));
          },
          child: const ListTile(
              leading: Icon(
                Icons.supervisor_account,
                size: 32,
                color: Colors.black,
              ),
              title: Text("Üyeler"))),
      TextButton(
          onPressed: () {
            //scaffoldKey.currentState?.openEndDrawer();
            //Navigator.push(context, MaterialPageRoute(builder: (context) => const YoklamaPage()));
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const YoklamaPage()));
            //callback(AppWindow.yoklamalar);
          },
          child: const ListTile(
              leading: Icon(
                Icons.view_list,
                size: 32,
                color: Colors.black,
              ),
              title: Text("Yoklamalar"))),
      TextButton(
          onPressed: () {
            //scaffoldKey.currentState?.openEndDrawer();
            //callback(AppWindow.harcamalar);
          },
          child: const ListTile(
              leading: Icon(
                Icons.payments,
                size: 32,
                color: Colors.black,
              ),
              title: Text("Harcamalar"))),
      TextButton(
          onPressed: () {
            //scaffoldKey.currentState?.openEndDrawer();
            //callback(AppWindow.ayarlar);
          },
          child: const ListTile(
              leading: Icon(
                Icons.settings,
                size: 32,
                color: Colors.black,
              ),
              title: Text("Ayarlar"))),
      TextButton(
          onPressed: () {
            //scaffoldKey.currentState?.openEndDrawer();
            Navigator.push(context, MaterialPageRoute(builder: (context) => const WebLoginPage()));
          },
          child: const ListTile(
              leading: Icon(
                Icons.exit_to_app,
                size: 32,
                color: Colors.black,
              ),
              title: Text("Çıkış")))
    ],
  ));
}
