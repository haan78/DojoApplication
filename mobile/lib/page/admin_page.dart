import '../store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() {
    return _AdminPageState();
  }
}

class _AdminPageState extends State<AdminPage> {
  late Store store;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    store = Provider.of<Store>(context);
    return Scaffold(
      body: Center(child: Text("OK ${store.UserName} / ${store.UserStatus} ")),
    );
  }
}
