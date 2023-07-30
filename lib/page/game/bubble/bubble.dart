// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:snatch_card/page/game/bubble/background.dart';
// import 'package:simple_animations/simple_animations.dart';
// import 'package:supercharged/supercharged.dart';
// import 'package:supercharged_dart/supercharged_dart.dart';
//
// class Bubble extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => BubbleState();
// }
//
// class BubbleState extends State<Bubble> {
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.black87,
//       child: Stack(children: <Widget>[
//         // 冒泡动效
//         Positioned.fill(child: ParticlesWidget(50)),
//       ]),
//     );
//   }
// }
//
// /// ///////////////////////////////////////////////////////////////////////////
// ///
// /// 冒泡动效Widget
// ///
// /// ///////////////////////////////////////////////////////////////////////////
// class ParticlesWidget extends StatefulWidget {
//   /// 粒子数量
//   final int numberOfParticles;
//
//   ParticlesWidget(this.numberOfParticles);
//
//   @override
//   _ParticlesWidgetState createState() => _ParticlesWidgetState();
// }
//
// class _ParticlesWidgetState extends State<ParticlesWidget>
//     with WidgetsBindingObserver {
//   final List<ParticleModel> particles = [];
//
//   @override
//   void initState() {
//     widget.numberOfParticles.times(() => particles.add(ParticleModel()));
//     WidgetsBinding.instance!.addObserver(this);
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance!.removeObserver(this);
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     print("-didChangeAppLifecycleState-" + state.toString());
//     if (state == AppLifecycleState.resumed) {
//       particles.forEach((particle) {
//         particle.restart();
//         particle.shuffle();
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return LoopAnimation(
//       tween: ConstantTween(1),
//       builder: (context, child, dynamic _) {
//         // 如果粒子动画完成，则重来
//         _simulateParticles();
//         return CustomPaint(
//           painter: ParticlePainter(particles),
//         );
//       },
//     );
//   }
//
//   /// 如果粒子动画结束，则调用 [ParticleModel.restart]
//   _simulateParticles() {
//     particles
//         .forEach((particle) => particle.checkIfParticleNeedsToBeRestarted());
//   }
// }
//
// /// ///////////////////////////////////////////////////////////////////////////
// ///
// /// 绘画逻辑
// /// 不懂的参考：<https://book.flutterchina.club/chapter10/custom_paint.html#custompainter>
// ///
// /// ///////////////////////////////////////////////////////////////////////////
// class ParticlePainter extends CustomPainter {
//   List<ParticleModel> particles;
//
//   ParticlePainter(this.particles);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = Colors.white.withAlpha(50);
//
//     particles.forEach((particle) {
//       final progress = particle.progress();
//       final MultiTweenValues<ParticleOffsetProps> animation =
//           particle.tween.transform(progress);
//       final position = Offset(
//         animation.get<double>(ParticleOffsetProps.x) * size.width,
//         animation.get<double>(ParticleOffsetProps.y) * size.height,
//       );
//       canvas.drawCircle(position, size.width * 0.2 * particle.size, paint);
//     });
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }
//
// /// ///////////////////////////////////////////////////////////////////////////
// ///
// /// 粒子对象，包含各种属性
// ///
// /// ///////////////////////////////////////////////////////////////////////////
// enum ParticleOffsetProps { x, y }
//
// class ParticleModel {
//   /// 粒子坐标补间
//   late MultiTween<ParticleOffsetProps> tween;
//
//   /// 粒子大小
//   late double size;
//
//   /// 动画过渡时间
//   late Duration duration;
//
//   /// 动画开始时间
//   late Duration startTime;
//
//   ParticleModel() {
//     restart();
//     shuffle();
//   }
//
//   /// 重置粒子属性
//   restart() {
//     // 对于Y轴：0为屏幕顶部，1位屏幕底部，-0.2为顶部外20%区域，1.2为底部20%
//     // 起始坐标（x，y）
//     final startPosition = Offset(-0.2 + 1.4 * Random().nextDouble(), 1.2);
//     // 结束坐标（X，y）
//     final endPosition = Offset(-0.2 + 1.4 * Random().nextDouble(), -0.2);
//
//     tween = MultiTween<ParticleOffsetProps>()
//       ..add(ParticleOffsetProps.x, startPosition.dx.tweenTo(endPosition.dx))
//       ..add(ParticleOffsetProps.y, startPosition.dy.tweenTo(endPosition.dy));
//
//     // 动画过渡时间
//     duration = 3.seconds + Random().nextInt(30000).milliseconds;
//     // 开始时间
//     startTime = DateTime.now().duration();
//     // 粒子大小
//     size = 0.2 + Random().nextDouble() * 0.4;
//   }
//
//   void shuffle() {
//     startTime -=
//         (Random().nextDouble() * duration.inMilliseconds).round().milliseconds;
//   }
//
//   checkIfParticleNeedsToBeRestarted() {
//     if (progress() == 1.0) {
//       restart();
//     }
//   }
//
//   /// 获取动画进度
//   /// 0 表示开始， 1 表示结束，相当于动画进度的百分比
//   double progress() {
//     return ((DateTime.now().duration() - startTime) / duration)
//         .clamp(0.0, 1.0)
//         .toDouble();
//   }
// }
