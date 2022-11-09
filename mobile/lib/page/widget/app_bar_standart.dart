import 'package:dojo_mobile/store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

AppBar appBarStandart(BuildContext context, {List<Widget> actions = const []}) {
  List<Widget> acList = [];

  if (actions.isNotEmpty) {
    acList.addAll(actions);
  }
  acList.add(IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(Icons.arrow_back_ios)));

  String title = Provider.of<Store>(context).AppName;

  return AppBar(
    automaticallyImplyLeading: false,
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
        Text(title)
      ],
    ),
    actions: acList,
  );
}
