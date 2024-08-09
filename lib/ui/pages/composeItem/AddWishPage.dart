import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/helper/constant.dart';
import 'package:wish_pe/helper/fileHelper.dart';
import 'package:wish_pe/helper/imagePicker.dart';
import 'package:wish_pe/helper/llmResponseParser.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/resource/gemini_client.dart';
import 'package:wish_pe/resource/gemini_prompts.dart';
import 'package:wish_pe/state/authState.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/ui/pages/composeItem/ComposeItemPage.dart';
import 'package:wish_pe/ui/pages/feed/widgets/customTitle.dart';
import 'package:wish_pe/ui/pages/feed/widgets/welcomeTitle.dart';
import 'package:wish_pe/ui/pages/list/editListPage.dart';
import 'package:wish_pe/ui/pages/provider/providerPage.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/avatar_image.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class AddWishPage extends StatefulWidget {
  AddWishPage(
      {Key? key, required this.scaffoldKey, this.sharedFiles, this.sharedUrl})
      : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;
  final List<SharedMediaFile>? sharedFiles;
  final String? sharedUrl;
  @override
  _AddWishPageState createState() => _AddWishPageState();
}

class _AddWishPageState extends State<AddWishPage> {
  late TextEditingController _url;
  File? _banner;
  bool _isLoading = false;

  @override
  void initState() {
    _url = TextEditingController();
    super.initState();

    if (widget.sharedFiles != null && widget.sharedFiles!.isNotEmpty) {
      _banner = File(widget.sharedFiles!.first.path);
      fileToPart('image/jpeg', _banner!).then((image) {
        _processUsingGemini(context, imagePrompt,
            inputDataPart: image, inputFile: _banner);
      });
    }

    if (widget.sharedUrl != null &&
        widget.sharedUrl != 'null' &&
        widget.sharedUrl!.isNotEmpty) {
      _url.text = extractUrl(widget.sharedUrl!);
      _processUsingGemini(context, urlPrompt, url: _url.text);
    }
  }

  String extractUrl(String text) {
    final urlPattern = RegExp(
      r'http(s)?://([a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+',
      caseSensitive: false,
      multiLine: false,
    );

    final match = urlPattern.firstMatch(text);
    if (match != null) {
      return match.group(0) ?? '';
    }
    return '';
  }

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 0.0, vertical: 3.0),
                  sliver: SliverAppBar(
                    floating: true,
                    elevation: 0,
                    title: Row(
                      children: [
                        WelcomeTitle(
                          title: 'Add Wish',
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          icon: Image.asset(
                              'assets/images/Google-Gemini-AI-Icon.png'),
                          onPressed: () {},
                          iconSize: 6,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(0.0),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.black,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _entryBox('Paste provider\'s webpage URL',
                          controller: _url, context: context),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                uploadBanner(context);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.camera_alt, color: Colors.grey),
                                    SizedBox(width: 10),
                                    Text(
                                      'Snap Your Wish',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) =>
                                            ComposeItemPage()));
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.grey),
                                    SizedBox(width: 10),
                                    Text(
                                      'Type Your Wish',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_isLoading)
                        Center(
                            child: CircularProgressIndicator(
                                color: hexToColor('#1ED760'))),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    child: Divider(
                      color: Colors.grey,
                      thickness: 2,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    child: CustomTitle(
                      title: 'Universal Mall',
                    ),
                  ),
                ),
                Consumer<SearchState>(builder: (context, searchState, child) {
                  final providerList = searchState.providerList ?? [];
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: providerList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        itemBuilder: (context, int index) {
                          final provider = providerList[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  ProviderPage.getRoute(
                                      providerKey: provider.key!));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 150,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: ImageOrAvatar(
                                      imagePath: 'assets/images/' +
                                          provider.displayName!.toLowerCase() +
                                          '.png',
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.width,
                                      name: provider.displayName!),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
              ],
            )),
      ),
    );
  }

  Widget _entryBox(String hintText,
      {required TextEditingController controller,
      required BuildContext context,
      int maxLine = 1,
      bool enabled = true}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey),
        ),
        child: TextField(
          enabled: enabled,
          controller: controller,
          maxLines: maxLine,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            suffixIcon: IconButton(
              icon: Icon(Icons.arrow_forward, color: Colors.grey),
              onPressed: () {
                _processUsingGemini(
                  context,
                  urlPrompt,
                  url: _url.text,
                );
              },
            ),
          ),
          cursorColor: Colors.white,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void uploadBanner(BuildContext context) async {
    Completer<File?> completer = Completer();
    openImagePicker(context, (file) {
      completer.complete(file);
    });
    File? file = await completer.future;
    if (file != null) {
      setState(() {
        _banner = file;
        _isLoading = true;
      });

      try {
        final image = await fileToPart('image/jpeg', _banner!);
        _processUsingGemini(context, imagePrompt,
            inputDataPart: image, inputFile: _banner);
      } catch (e) {
        print('Error uploading file: $e');
      }
    }
  }

  Future<void> _processUsingGemini(BuildContext context, String prompt,
      {String? url, DataPart? inputDataPart, File? inputFile}) async {
    if (url == null && inputDataPart == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final gemini = GeminiClient();
      final geminiFuture = gemini.generateContent(
        prompt: prompt,
        input: url,
        data: inputDataPart,
      );
      final restApiFuture = _callRestApi(url);

      final results =
          await Future.wait([geminiFuture, restApiFuture], eagerError: false);

      // Handle responses
      final geminiResponse = results[0];
      final restApiResponse = results[1];
      final response =
          jsonDecode(geminiResponse.split('```json\n')[1].split('```')[0]);

      await _processResponse(context, response, inputFile, restApiResponse);
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _processResponse(BuildContext context, dynamic response,
      File? inputFile, dynamic imageUrls) async {
    final searchState = Provider.of<SearchState>(context, listen: false);
    final authState = Provider.of<AuthState>(context, listen: false);
    final itemState = Provider.of<ItemState>(context, listen: false);
    final listState = Provider.of<ListState>(context, listen: false);

    if (response.length == 1) {
      final result = await parseLLMResponse(
          response.first, searchState, authState, imageUrls);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ComposeItemPage(
            model: result.value1,
            itemDetailModel: result.value2,
            itemImageFile: inputFile,
            scaffoldKey: widget.scaffoldKey,
          ),
        ),
      );
    } else if (response.length > 1) {
      List<String> itemKeys = [];
      for (var item in response) {
        final result = await parseLLMResponse(item, searchState, authState, []);
        String? itemKey = await itemState.createItem(result.value1,
            itemDetailModel: result.value2);
        itemKeys.add(itemKey!);
        listState.addToList(listState.myDefaultList!, itemKey);
      }

      var myUser = authState.userModel!;
      var newList = ListModel(
        name: "My list #${myUser.listCounter! + 1}",
        userId: myUser.userId!,
        itemKeyList: itemKeys,
        privacyLevel: ListPrivacyLevel.Private,
        createdAt: DateTime.now().toString(),
      );

      myUser.listCounter = myUser.listCounter! + 1;
      await authState.updateUserProfile(myUser);

      final listKey = await listState.createList(newList);
      newList.key = listKey;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditListPage(
            listModel: newList,
          ),
        ),
      );
    }
  }

  Future<dynamic> _callRestApi(String? url) async {
    if (url == null || url.isEmpty) {
      return null;
    }

    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    final data = remoteConfig.getString('scraperMasterKey');
    final scraperMasterKey = jsonDecode(data)["key"];

    Uri uri = Uri.http(Constants.scraperBasePath, Constants.imageScrapeEndpoint,
        {'input_url': url, 'code': scraperMasterKey});
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }
}
