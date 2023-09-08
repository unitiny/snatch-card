import 'package:snatch_card/tool/lib.dart';
import 'package:flutter/material.dart';
import 'package:snatch_card/source/http.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:dio/dio.dart';
import 'package:snatch_card/component/CommonAppBar.dart';
import 'package:snatch_card/component/MyDialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.callback});

  final void Function(String a, String b, bool c)? callback;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    randNickName();
  }

  void randNickName() async {
    Response res = await HttpRequest().GET(API.getNickname);
    setState(() {
      _nameController.text = res.data["nickname"] ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColor.theme,
      appBar: CommonAppBar(title: "Sign up"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: pageWidth(context) * 0.7,
                    child: TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your name.';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
                        onSaved: (value) {
                          _nameController.text = value!;
                        }),
                  ),
                  Positioned(
                      right: 10,
                      top: 15,
                      child: Container(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                // 根据状态返回相应的背景颜色
                                if (states.contains(MaterialState.pressed)) {
                                  // 按下状态的背景颜色
                                  return GameColor.background2;
                                } else if (states
                                    .contains(MaterialState.disabled)) {
                                  // 禁用状态的背景颜色
                                  return Colors.grey;
                                }
                                // 默认状态的背景颜色
                                return GameColor.btn;
                              },
                            ),
                          ),
                          onPressed: randNickName,
                          child: Icon(Icons.ads_click),
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: pageWidth(context) * 0.7,
                child: TextFormField(
                    controller: _userNameController,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your accout.';
                      } else if (value.length > 5) {
                        return '账号长度要小于6';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: '账号',
                    ),
                    onSaved: (value) {
                      _userNameController.text = value!;
                    }),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password.';
                    } else if (value.length > 10) {
                      return '密码长度要小于10';
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
                onPressed: () {
                  _isLoading ? null : _signUp(context);
                },
                child: _isLoading
                    ? CircularProgressIndicator()
                    : const Text('注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signUp(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      HttpRequest()
          .POST(
              API.signUp,
              FormData.fromMap({
                "password": _passwordController.text,
                "nickname": _nameController.text,
                "gender": false,
                "username": _userNameController.text,
              }))
          .then((value) {
        MyDialog().lightTip(context, "注册成功");
        widget.callback!(
            _userNameController.text, _passwordController.text, true);
      }).catchError((e) {
        var res = getErr(e);
        MyDialog().lightTip(context, "${res["err"]}");
      });
    }
  }
}
