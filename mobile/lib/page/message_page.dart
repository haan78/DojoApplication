import 'package:dojo_mobile/page/appwindow.dart';
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
      ts = const TextStyle(color: colorBad, backgroundColor: Colors.white);
    } else if (type == MessageType.info) {
      ts = const TextStyle(color: colorWarn, backgroundColor: Colors.white);
    } else {
      ts = const TextStyle(color: colorGood, backgroundColor: Colors.white);
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
