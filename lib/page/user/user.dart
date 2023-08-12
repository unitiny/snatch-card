import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/page/user/login.dart';
import 'package:snatch_card/tool/component.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/page/user/modify.dart';
import 'package:snatch_card/source/globalData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  void update(User? user, User? newUser) {
    if (user == null || newUser == null) {
      return;
    }
    setState(() {
      user = newUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    User user = GlobalData().user(context);
    user.state = UserState.inHome;
    return Column(children: [
      Expanded(
          flex: 90,
          child: Container(
            color: GameColor.theme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 50.0,
                          child: ClipOval(child: UserAvatar(size: 95))),
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
                  leading: const Icon(Icons.edit),
                  title: const Text('修改资料'),
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
                    ).then((value) {
                      update(user, value);
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('退出登录'),
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    if (prefs.getString("token") != null) {
                      prefs.remove('token');
                    }

                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false);
                    }
                  },
                ),
              ],
            ),
          )),
      const Expanded(flex: 0, child: StartGame())
    ]);
  }
}
