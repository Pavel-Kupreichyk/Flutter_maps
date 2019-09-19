import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/src/blocs/multi_page_navigation_bar_bloc.dart';
import 'package:flutter_maps/src/screens/place_screen.dart';
import 'package:flutter_maps/src/services/geolocation_service.dart';
import 'package:flutter_maps/src/screens/main_screen.dart';
import 'package:flutter_maps/src/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_maps/src/blocs/main_bloc.dart';
import 'package:flutter_maps/src/blocs/place_screen_bloc.dart';
import 'package:flutter_maps/src/managers/alert_presenter.dart';
import 'package:flutter_maps/src/widgets/multi_page_navigation_bar.dart';
import 'package:flutter_maps/src/managers/route_manager.dart';
import 'package:flutter_maps/src/managers/upload_manager.dart';
import 'package:flutter_maps/src/other_classes/slide_right_route.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  final RouteManager _routeManager = RouteManager();
  final AlertPresenter _alertManager = AlertPresenter();
  final FirestoreService _firestoreService = FirestoreService();
  final GeolocationService _geolocationService = GeolocationService();
  final UploadManager _uploadManager = UploadManager();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildCloneableWidget>[
        Provider<GeolocationService>.value(value: _geolocationService),
        Provider<FirestoreService>.value(value: _firestoreService),
        Provider<AlertPresenter>.value(value: _alertManager),
        Provider<UploadManager>.value(value: _uploadManager),
        Provider<RouteManager>(
          builder: (_) => _routeManager,
          dispose: (_, manager) => manager.dispose(),
        ),
        Provider<MultiPageNavBarBloc>(
          builder: (_) => MultiPageNavBarBloc(_uploadManager),
          dispose: (_, bloc) => bloc.dispose(),
        )
      ],
      child: MaterialApp(
        navigatorObservers: [_routeManager],
        theme: ThemeData.dark(),
        builder: (_, child) => AppBarBuilder(child: child,),
        home: Provider<MainBloc>(
            builder: (_) => MainBloc(_firestoreService, _geolocationService),
            dispose: (_, bloc) => bloc.dispose(),
            child: Consumer<MainBloc>(
              builder: (_, bloc, __) => MainScreen(bloc),
            )),
        onGenerateRoute: (RouteSettings settings) {
          Widget newScreen;
          switch (settings.name) {
            case AddEditPlaceScreen.route:
              newScreen = Provider<AddEditPlaceBloc>(
                  builder: (_) => AddEditPlaceBloc(_firestoreService,
                      _geolocationService, _uploadManager, settings.arguments),
                  dispose: (_, bloc) => bloc.dispose(),
                  child: Consumer<AddEditPlaceBloc>(
                    builder: (_, bloc, __) =>
                        AddEditPlaceScreen(bloc, _alertManager),
                  ));
              break;
            default:
              throw Exception('Invalid route: ${settings.name}');
          }
          return SlideRightRoute(page: newScreen, settings: settings);
        },
      ),
    );
  }
}
