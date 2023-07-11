import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/page/user/login.dart';
import 'package:snatch_card/tool/component.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/page/user/modify.dart';
import 'package:snatch_card/source/globalData.dart';


class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  void update(User user, User newUser) {
    setState(() {
      user = newUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    User user = GlobalData().user(context);
    return Container(
      color: GameColor.theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 50.0,
                    child: ClipOval(
                      child: Image.asset(user.avatar!,
                          width: 95, height: 95, fit: BoxFit.cover),
                    )),
                const SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.userName ?? "",
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      user.nickName ?? "",
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32.0),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return EditProfileDialog(
                    account: user.userName,
                    nickname: user.nickName,
                    avatarUrl: user.avatar,
                  );
                },
              ).then((value) => update(user, value));
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Log out'),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                  (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
