import 'package:flutter/material.dart';

class OtherOperators extends StatefulWidget {
  const OtherOperators({super.key, required this.callback, this.icon});

  final void Function() callback;
  final IconData? icon;

  @override
  State<OtherOperators> createState() => _OtherOperatorsState();
}

class _OtherOperatorsState extends State<OtherOperators> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      focusColor: Colors.blue[50],
      onPressed: widget.callback,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
      ),
      child: Icon(widget.icon ?? Icons.add),
    );
  }
}
