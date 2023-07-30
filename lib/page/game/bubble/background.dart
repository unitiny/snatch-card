// import 'package:flutter/material.dart';
// import 'package:simple_animations/simple_animations.dart';
// import 'package:supercharged/supercharged.dart';
//
// enum _ColorTween { color1, color2 }
//
// /// 渐变背景
// class AnimatedBackground extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final tween = MultiTween<_ColorTween>()
//       ..add(
//         _ColorTween.color1,
//         Color(0xffD38312).tweenTo(Color(0xFF01579B)),
//         3.seconds,
//       )
//       ..add(
//         _ColorTween.color2,
//         Color(0xFF2196F3).tweenTo(Color(0xffA83279)),
//         3.seconds,
//       );
//
//     return MirrorAnimation<MultiTweenValues<_ColorTween>>(
//       tween: tween,
//       duration: tween.duration,
//       builder: (context, child, value) {
//         return Container(
//           decoration: BoxDecoration(
//               gradient: LinearGradient(
//                   begin: Alignment.bottomLeft,
//                   end: Alignment.topRight,
//                   colors: [
//                     value.get<Color>(_ColorTween.color1),
//                     value.get<Color>(_ColorTween.color2)
//                   ]
//               )
//           ),
//         );
//       },
//     );
//   }
// }
