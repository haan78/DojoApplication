import 'package:flutter/material.dart';

class RadioGroup extends StatefulWidget {
  final List<Widget> children;
  final void Function(int)? onSelect;
  final int selectedIndex;
  const RadioGroup({super.key, required this.children, required this.onSelect, this.selectedIndex = -1});
  @override
  State<StatefulWidget> createState() {
    return _RadioGroup();
  }
}

class _RadioGroup extends State<RadioGroup> {
  late List<bool> selectList;

  @override
  void initState() {
    super.initState();
    selectList = List<bool>.filled(widget.children.length, false);
    if (widget.selectedIndex > -1 && widget.selectedIndex < selectList.length) {
      selectList[widget.selectedIndex] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: selectList,
      children: widget.children,
      onPressed: (int value) {
        int v = -1;
        for (int i = 0; i < selectList.length; i++) {
          if (i == value) {
            selectList[i] = !selectList[i];
            if (selectList[i]) {
              v = i;
            }
          } else {
            selectList[i] = false;
          }
        }
        setState(() {});
        if (widget.onSelect != null) {
          widget.onSelect!(v);
        }
      },
    );
  }
}
