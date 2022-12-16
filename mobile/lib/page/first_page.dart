import '../store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() {
    return _AdminPageState();
  }
}

class _AdminPageState extends State<FirstPage> {
  late Store store;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    store = Provider.of<Store>(context);
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          Image.asset(
            "assets/logo.png",
            fit: BoxFit.contain,
            height: 48,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(store.AppName)
        ],
      )),
      body: Center(child: Text("OK ${store.UserName} / ${store.UserStatus} ")),
    );
  }
}
