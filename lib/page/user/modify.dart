import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:snatch_card/source/http.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/source/globalData.dart';

class EditProfileDialog extends StatefulWidget {
  final String? account;
  final String? nickname;
  final String? avatarUrl;

  const EditProfileDialog(
      {super.key, this.account, this.nickname, this.avatarUrl});

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  File? _avatarImage;
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _accountController.text = widget.account!;
    _nickNameController.text = widget.nickname!;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('修改个人信息'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(
          color: Colors.blue,
          width: 2.0,
        ),
      ),
      backgroundColor: Colors.white,
      content: SizedBox(
        width: pageWidth(context) * 0.85,
        height: pageHeight(context) * 0.4,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  _pickAvatarImage();
                },
                child: CircleAvatar(
                  radius: 48.0,
                  backgroundImage: _avatarImage != null
                      ? FileImage(_avatarImage!)
                      : FileImage(File(Source.avatar1)),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: const InputDecoration(
                  labelText: '账号',
                  border: OutlineInputBorder(),
                ),
                controller: _accountController,
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: const InputDecoration(
                  labelText: '昵称',
                  border: OutlineInputBorder(),
                ),
                controller: _nickNameController,
              ),
              const SizedBox(height: 16.0),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '密码',
                  border: OutlineInputBorder(),
                ),
                controller: _passwordController,
              ),
            ],
          ),
        ),
      ),
      actions: [
        SizedBox(
          height: 45,
          width: 65,
          child: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            elevation: 3,
            child: const Text('取消'),
          ),
        ),
        const SizedBox(width: 5),
        SizedBox(
          height: 45,
          width: 65,
          child: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            onPressed: () async {
              Response res = await HttpRequest().PUTByToken(
                  API.modify,
                  token(context),
                  FormData.fromMap({
                    "nickname": _nickNameController.text,
                    "gender": false,
                    "username": _accountController.text,
                    "password": _passwordController.text,
                  }));
              if (res.statusCode == HTTPStatus.OK) {
                User user = GlobalData().user(context);
                user.update(
                    username: _accountController.text,
                    nickname: _nickNameController.text);
                Navigator.of(context).pop(user);
              }
            },
            elevation: 3,
            child: const Text('保存'),
          ),
        ),
      ],
    );
  }

  // TODO
  void _pickAvatarImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
    }
  }
}
