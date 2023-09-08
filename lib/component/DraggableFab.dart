import 'package:flutter/material.dart';

class DraggableFab extends StatefulWidget {
  DraggableFab(this.floatBtn, {super.key});

  Widget floatBtn;

  @override
  _DraggableFabState createState() => _DraggableFabState();
}

class _DraggableFabState extends State<DraggableFab> {
  Offset _offset = const Offset(0, 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      // 90是FloatingActionButton的大小
      int x = 60;
      int y = 60;
      setState(() {
        _offset = Offset(screenSize.width - x, screenSize.height - y);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: _offset.dx,
          top: _offset.dy,
          child: Draggable(
            feedback: widget.floatBtn,
            child: widget.floatBtn,
            childWhenDragging: Container(),
            // 隐藏原始组件
            onDraggableCanceled: (_, __) {},
            onDragEnd: (details) {
              setState(() {
                _offset = details.offset;
                print("[DraggableFab] ${_offset.dx} ${_offset.dy}");
              });
            },
          ),
        ),
      ],
    );
  }
}
