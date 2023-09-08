import 'package:flutter/material.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/tool/lib.dart';

typedef callBack<T> = void Function(T value);

class DropInput<T> extends StatefulWidget {
  const DropInput(
      {super.key, this.name, required this.items, required this.callback});

  final String? name;
  final List<Object> items;
  final callBack<String> callback;

  @override
  State<DropInput> createState() => _DropInputState();
}

class _DropInputState extends State<DropInput> {
  Object? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          right: 10.0,
          top: 10.0,
          bottom: 10.0,
          child: Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
          ),
        ),
        Container(
          width: pageWidth(context),
          decoration: BoxDecoration(
            border: Border.all(width: 2.0, color: GameColor.border),
            borderRadius: BorderRadius.circular(3),
          ),
          child: DropdownButton(
            icon: const Icon(
              Icons.arrow_drop_down, //将下三角图标替换为一个空白的 Icon
              color: Colors.transparent,
            ),
            elevation: 0,
            underline: Container(color: Colors.white),
            hint: Container(
                padding: const EdgeInsets.only(left: 10),
                child: Text(widget.name!)),
            value: _selectedItem,
            items: widget.items.map((Object value) {
              return DropdownMenuItem(
                value: value,
                child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(value.toString())),
              );
            }).toList(),
            onChanged: (Object? selectedItem) {
              setState(() {
                _selectedItem = selectedItem;
                widget.callback(selectedItem.toString());
              });
            },
          ),
        )
      ],
    );
  }
}
