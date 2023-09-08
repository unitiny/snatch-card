import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  ChatBubble(
      {super.key,
      required this.message,
      required this.left,
      required this.top});

  final String message;
  final double left;
  final double top;
  final double size = 40;
  final double appBarHeight = AppBar().preferredSize.height;

  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: widget.left - widget.size,
        top: widget.top - widget.size - widget.appBarHeight,
        child: Row(
          children: [
            LeftEquilateralTriangle(
              size: widget.size,
              color: Colors.blue,
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Text(
                widget.message,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          ],
        ));
  }
}

class LeftEquilateralTriangle extends StatelessWidget {
  final double size;
  final Color color;

  LeftEquilateralTriangle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LeftEquilateralTrianglePainter(size: size, color: color),
      size: Size(size, size),
    );
  }
}

class _LeftEquilateralTrianglePainter extends CustomPainter {
  final double size;
  final Color color;

  _LeftEquilateralTrianglePainter({required this.size, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double height = size.height;
    final double width = size.width;

    final Path path = Path();
    path.moveTo(0, height); // 画笔移动到起点
    path.lineTo(width / 4, height / 2); // 画出起点到传入的x,y坐标点，形成直线
    path.lineTo(width, height / 2);
    path.close(); // 闭合路径
    canvas.translate(40, 12); // 移动x，y个单位

    // canvas.save(); // 保存当前的画布状态
    // canvas.translate(width / 3, height/2);
    // canvas.rotate(-math.pi/90); // 逆时针旋转90度
    // canvas.translate(-width / 3, -height/2);
    canvas.drawPath(path, paint);
    // canvas.restore(); // 恢复画布状态
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
