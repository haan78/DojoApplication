import 'package:flutter/material.dart';

enum MessageType { error, info, success }

class MessagePage extends StatelessWidget {
  final String message;
  final MessageType type;

  const MessagePage(this.message, this.type, {super.key});

  @override
  Widget build(BuildContext context) {
    TextStyle ts;
    if (type == MessageType.error) {
      ts = const TextStyle(color: Colors.red, backgroundColor: Colors.black);
    } else if (type == MessageType.info) {
      ts = const TextStyle(color: Colors.yellow, backgroundColor: Colors.brown);
    } else {
      ts = const TextStyle(
          color: Color.fromARGB(255, 5, 54, 7),
          backgroundColor: Color.fromARGB(255, 171, 179, 177));
    }
    return MaterialApp(home: Builder(builder: (BuildContext context) {
      return Scaffold(
        body: Center(
          child: Text(
            message,
            style: ts,
          ),
        ),
      );
    }));
  }
}
