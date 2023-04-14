import 'package:flutter/material.dart';

errorAlert(BuildContext context, String message, {String caption = "HATA"}) {
  showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text(caption, style: const TextStyle(color: Colors.red)),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text('Tamam'),
                onPressed: () {
                  if (context.mounted) Navigator.of(context).pop();
                },
              )
            ],
          ));
}

infoAlert(BuildContext context, {String caption = "BİLGİ", required Widget child}) {
  showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            scrollable: true,
            title: Text(caption, style: const TextStyle(color: Colors.blue)),
            content: child,
            actions: [
              TextButton(
                child: const Text('Tamam'),
                onPressed: () {
                  if (context.mounted) Navigator.of(context).pop();
                },
              )
            ],
          ));
}

successAlert(BuildContext context, String message, {String caption = "BAŞARILI", void Function()? ok}) {
  void Function()? okbtn = ok ??
      () {
        Navigator.of(context).pop();
      };
  showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            scrollable: true,
            title: Text(caption, style: const TextStyle(color: Colors.green)),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: okbtn,
                child: const Text('Tamam'),
              )
            ],
          ));
}
