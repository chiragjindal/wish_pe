import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wish_pe/helper/constant.dart';
import 'package:wish_pe/helper/enum.dart';
import 'package:wish_pe/helper/utility.dart';
import 'package:wish_pe/model/user.dart';
import 'package:wish_pe/ui/pages/auth/widget/input.dart';
import 'package:wish_pe/state/authState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/newWidget/customLoader.dart';
import 'package:provider/provider.dart';

class LogupPage extends StatefulWidget {
  final VoidCallback? loginCallback;

  const LogupPage({Key? key, this.loginCallback}) : super(key: key);
  @override
  State<LogupPage> createState() => _LogupPageState();
}

class _LogupPageState extends State<LogupPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmController;
  late CustomLoader loader;

  @override
  void initState() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    loader = CustomLoader();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Widget _body(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SizedBox(
          height: height,
          child: Stack(
            children: [
              Container(
                height: height / 2,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: ColorConstants.primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(60),
                      bottomLeft: Radius.circular(60),
                    )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 70,
                        child: Image.asset('assets/images/logo.png')),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Millions of Lists, Infinite Dreams',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Roboto',
                          fontStyle: FontStyle.normal),
                    )
                  ],
                ),
              ),
              SingleChildScrollView(
                child: SizedBox(
                  height: height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 2),
                        height: height / 1.8,
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(
                              height: 22,
                            ),
                            SizedBox(
                              height: 40,
                              child: Input(
                                  hint: 'Name',
                                  controller: _nameController,
                                  icon: Icons.visibility_outlined),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 40,
                              child: Input(
                                  hint: 'Email',
                                  controller: _emailController,
                                  icon: Icons.email_outlined),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 40,
                              child: Input(
                                  hint: 'Password',
                                  controller: _passwordController,
                                  icon: Icons.visibility_outlined,
                                  isPassword: true),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 40,
                              child: Input(
                                  hint: 'Confirm Password',
                                  controller: _confirmController,
                                  icon: Icons.visibility_outlined,
                                  isPassword: true),
                            ),
                            const SizedBox(height: 16),
                            MaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(31)),
                              height: 40,
                              color: ColorConstants.primaryColor,
                              onPressed: () => _submitForm(context),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm(BuildContext context) {
    if (_nameController.text.isEmpty) {
      Utility.customToast(context, 'Please enter name');
      return;
    }
    if (_nameController.text.length > 27) {
      Utility.customToast(context, 'Name length cannot exceed 27 character');
      return;
    }
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Utility.customToast(context, 'Please fill form carefully');
      return;
    } else if (_passwordController.text != _confirmController.text) {
      Utility.customToast(
          context, 'Password and confirm password did not match');
      return;
    }

    loader.showLoader(context);
    var state = Provider.of<AuthState>(context, listen: false);
    var listState = Provider.of<ListState>(context, listen: false);
    Random random = Random();
    int randomNumber = random.nextInt(8);

    UserModel user = UserModel(
      email: _emailController.text.toLowerCase(),
      displayName: _nameController.text,
      profilePic: Constants.dummyProfilePicList[randomNumber],
      isVerified: false,
    );
    state
        .signUp(
      user,
      password: _passwordController.text,
      context: context,
    )
        .then((status) {
      listState.createDefaultList(user);
    }).whenComplete(
      () {
        loader.hideLoader();
        if (state.authStatus == AuthStatus.LOGGED_IN) {
          Navigator.pop(context);
          if (widget.loginCallback != null) widget.loginCallback!();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _body(context));
  }
}
