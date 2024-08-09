import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/resource/gemini_client.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/state/suggestionProviderState.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/ui/unused/locator.dart';

import 'helper/routes.dart';
import 'state/appState.dart';
import 'state/authState.dart';
import 'state/itemState.dart';
import 'state/notificationState.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GeminiClient().initialize();
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
        ChangeNotifierProvider<AuthState>(create: (_) => AuthState()),
        ChangeNotifierProvider<ListState>(create: (_) => ListState()),
        ChangeNotifierProvider<ItemState>(create: (_) => ItemState()),
        ChangeNotifierProvider<SearchState>(create: (_) => SearchState()),
        ChangeNotifierProvider<NotificationState>(
            create: (_) => NotificationState()),
        ChangeNotifierProvider<SuggestionsState>(
            create: (_) => SuggestionsState()),
      ],
      child: MaterialApp(
        title: 'WishPe',
        theme: AppTheme.appTheme.copyWith(
          textTheme: GoogleFonts.mulishTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        debugShowCheckedModeBanner: false,
        routes: Routes.route(),
        onGenerateRoute: (settings) => Routes.onGenerateRoute(settings),
        onUnknownRoute: (settings) => Routes.onUnknownRoute(settings),
        initialRoute: "SplashPage",
      ),
    );
  }
}
