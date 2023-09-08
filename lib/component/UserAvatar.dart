import 'package:flutter/material.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/source/globalData.dart';
import 'package:snatch_card/source/platform.dart';
import 'package:snatch_card/compatible/ui/realUI.dart'
if (dart.library.io) 'package:snatch_card/compatible/ui/fakeUI.dart';


class UserAvatar extends StatefulWidget {
  const UserAvatar({super.key, this.size, this.user});

  final double? size;
  final User? user;

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  @override
  Widget build(BuildContext context) {
    User user = widget.user ?? GlobalData().user(context);
    if (user.isLocalAvatar()) {
      return Image.asset(user.avatar!,
          width: widget.size ?? 95,
          height: widget.size ?? 95,
          fit: BoxFit.cover);
    } else if (PlatformUtils.isWeb) {
      return WebImage(user.image(), widget.size ?? 95, widget.size ?? 95);
    } else {
      return Image.network(user.image(),
          width: widget.size ?? 95,
          height: widget.size ?? 95,
          fit: BoxFit.cover);
    }
  }
}
