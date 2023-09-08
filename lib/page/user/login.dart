import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:snatch_card/source/http.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:dio/dio.dart';
import 'package:snatch_card/page/user/signUp.dart';
import 'package:snatch_card/router/router.dart' as PageRouter;
import 'package:snatch_card/tool/lib.dart';
import 'dart:async';
import 'package:snatch_card/source/globalData.dart';
import 'package:snatch_card/component/CommonAppBar.dart';
import 'package:snatch_card/component/MyDialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (GlobalData().debug) {
      // if (PlatformUtils.isWeb) {
      //   login("4", "4", true); //自动登录
      //   return;
      // }
      // login("2", "2", true); //自动登录
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: GameColor.theme,
      appBar: CommonAppBar(title: "Login"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                  controller: _userNameController,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your account.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: '账号',
                  ),
                  onSaved: (value) {
                    _userNameController.text = value!;
                  }),
              const SizedBox(height: 16.0),
              TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: '密码',
                  ),
                  onSaved: (value) {
                    _passwordController.text = value!;
                  }),
              const SizedBox(height: 16.0),
              FloatingActionButton(
                onPressed: _isLoading ? null : _login,
                heroTag: "Login",
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('登录'),
              ),
              const SizedBox(height: 16.0),
              FloatingActionButton(
                onPressed: _isLoading ? null : _signUp,
                heroTag: "SignUp",
                child: const Text('注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    await login(_userNameController.text, _passwordController.text, false);
  }

  dynamic login(String username, String password, bool notCheck) async {
    if (notCheck || _formKey.currentState!.validate()) {
    try {
        Response res = await HttpRequest().POST(
            API.login,
            FormData.fromMap({
              "username": username,
              "password": password,
            }));

          if (mounted) {
            User user = GlobalData().user(context);
            user.update(
              id: res.data["data"]["id"],
              nickname: res.data["data"]["nickname"],
              username: res.data["data"]["username"],
              gender: res.data["data"]["gender"],
              delay: res.data["expired_at"],
              token: res.data["token"],
            );

            _isLoading = true;
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("token", res.data["token"]);

            // 获取头像
            String url = "${API.downloadImage}?id=${user.id}";
            HttpRequest().GETByToken(url, user.token!).then((value) {
              if (value.data["path"] != "/") {
                user.avatar = value.data["path"];
              }
            });

            Timer.periodic(const Duration(milliseconds: 500), (timer) {
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return const PageRouter.RouterPage(pageIndex: 2);
              }), (router) => false);
              timer.cancel();
            });
          }
      } catch (e) {
        print(e);
        var res = getErr(e);
        MyDialog().lightTip(context, "${res["err"]}");
      }
    }
  }

  void _signUp() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SignUpScreen(callback: login),
      ),
    );
  }
}
