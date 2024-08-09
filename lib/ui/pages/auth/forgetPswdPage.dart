import 'package:flutter/material.dart';
import 'package:wish_pe/helper/utility.dart';
import 'package:wish_pe/state/authState.dart';
import 'package:wish_pe/ui/pages/auth/widget/input.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

class ForgetPswdPage extends StatefulWidget {
  const ForgetPswdPage({Key? key}) : super(key: key);
  @override
  State<ForgetPswdPage> createState() => _ForgetPswdPageState();
}

class _ForgetPswdPageState extends State<ForgetPswdPage> {
  late TextEditingController _emailController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _emailController.text = '';
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
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
              SingleChildScrollView(
                child: SizedBox(
                  height: height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 20),
                        height: height / 1.7,
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _label(),
                            const SizedBox(
                              height: 50,
                            ),
                            SizedBox(
                              height: 40,
                              child: Input(
                                  hint: 'Enter Email',
                                  controller: _emailController,
                                  icon: Icons.email_outlined),
                            ),
                            const SizedBox(height: 16),
                            MaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(31)),
                              height: 40,
                              color: ColorConstants.primaryColor,
                              onPressed: _submit,
                              child: const Text(
                                'Submit',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
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

  void _submit() {
    if (_emailController.text.isEmpty) {
      Utility.customToast(context, 'Email field cannot be empty');
      return;
    }
    var isValidEmail = Utility.validateEmail(
      _emailController.text,
    );
    if (!isValidEmail) {
      Utility.customToast(context, 'Please enter valid email address');
      return;
    }

    var state = Provider.of<AuthState>(context, listen: false);
    state.forgetPassword(_emailController.text, context: context);
  }

  Widget _label() {
    return Container(
        child: Column(
      children: <Widget>[
        customText('Forget Password',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: customText(
              'Enter your email address below to receive password reset instruction',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54),
              textAlign: TextAlign.center),
        )
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _body(context));
  }
}
