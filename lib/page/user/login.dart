import 'dart:io';
import 'dart:math';
import 'package:snatch_card/source/platform.dart';
import 'package:flutter/material.dart';
import 'package:snatch_card/source/http.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/tool/component.dart';
import 'package:dio/dio.dart';
import 'package:snatch_card/page/user/signUp.dart';
import 'package:snatch_card/router/router.dart' as PageRouter;
import 'dart:async';
import 'package:snatch_card/source/globalData.dart';

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
    if(PlatformUtils.isWeb) {
      login("2", "2", true); //自动登录
      return;
    }
    login("1", "1", true); //自动登录
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
                    labelText: 'Account',
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
                    labelText: 'Password',
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
                    : const Text('Login'),
              ),
              const SizedBox(height: 16.0),
              FloatingActionButton(
                onPressed: _isLoading ? null : _signUp,
                heroTag: "SignUp",
                child: const Text('Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    login(_userNameController.text, _passwordController.text, false);
  }

  void login(String username, String password, bool notCheck) async {
    if (notCheck || _formKey.currentState!.validate()) {
      Response res = await HttpRequest().POST(
          API.login,
          FormData.fromMap({
            "username": username,
            "password": password,
          }));
      if (res.statusCode == HTTPStatus.OK) {
        User user = GlobalData().user(context);
        user.update(
          id: res.data["data"]["id"],
          nickname: res.data["data"]["nickname"],
          username: res.data["data"]["username"],
          gender: res.data["data"]["gender"],
          delay: res.data["expired_at"],
          token: res.data["token"],
        );

        if (mounted) {
          Timer.periodic(Duration(seconds: 1), (timer) {
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return const PageRouter.Router(pageIndex: 2);
            }), (router) => false);
            timer.cancel();
          });
        }
      }
      setState(() {
        _isLoading = true;
      });
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
