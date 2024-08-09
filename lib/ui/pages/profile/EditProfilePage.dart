import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wish_pe/helper/customRoute.dart';
import 'package:wish_pe/helper/imagePicker.dart';
import 'package:wish_pe/helper/utility.dart';
import 'package:wish_pe/ui/widgets/circular_image.dart';
import 'package:wish_pe/state/authState.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  static MaterialPageRoute<T> getRoute<T>() {
    return CustomRoute<T>(
        builder: (BuildContext context) => const EditProfilePage());
  }

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _image;
  late TextEditingController _name;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    _name = TextEditingController();
    AuthState state = Provider.of<AuthState>(context, listen: false);
    _name.text = state.userModel?.displayName ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Widget _body() {
    var authState = Provider.of<AuthState>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 20),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * .6,
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: _userImage(authState),
                ),
              ],
            ),
          ),
        ),
        _entry('Your Name', controller: _name),
      ],
    );
  }

  Widget _userImage(AuthState authState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      height: 150,
      width: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 5),
        shape: BoxShape.circle,
        image: DecorationImage(
            image: customAdvanceNetworkImage(authState.userModel!.profilePic),
            fit: BoxFit.cover),
      ),
      child: CircleAvatar(
        radius: 80,
        backgroundImage: (_image != null
                ? FileImage(_image!)
                : customAdvanceNetworkImage(authState.userModel!.profilePic))
            as ImageProvider,
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black38,
          ),
          child: Center(
            child: IconButton(
              onPressed: uploadImage,
              icon: const Icon(Icons.camera_alt, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _entry(String hintText,
      {required TextEditingController controller,
      int maxLine = 1,
      bool enabled = true}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            enabled: enabled,
            controller: controller,
            maxLines: maxLine,
            decoration: InputDecoration(
              hintText: hintText,
              alignLabelWithHint: true,
              hintStyle: const TextStyle(color: Colors.grey),
              focusColor: Colors.white,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ), //
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            ),
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 10),
          Text('   This could be your first name or nickname.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ))
        ],
      ),
    );
  }

  void _submitButton() {
    if (_name.text.length > 27) {
      Utility.customToast(context, 'Name length cannot exceed 27 character');
      return;
    }
    var state = Provider.of<AuthState>(context, listen: false);
    var model = state.userModel!.copyWith(
      key: state.userModel!.userId,
      displayName: state.userModel!.displayName,
      email: state.userModel!.email,
      profilePic: state.userModel!.profilePic,
      userId: state.userModel!.userId,
    );
    if (_name.text.isNotEmpty) {
      model.displayName = _name.text;
    }

    state.updateUserProfile(model, image: _image);
    Navigator.of(context).pop();
  }

  void uploadImage() {
    openImagePicker(context, (file) {
      setState(() {
        _image = file;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Edit profile',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
            )),
        actions: <Widget>[
          InkWell(
            onTap: _submitButton,
            child: const Center(
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: _body(),
      ),
    );
  }
}
