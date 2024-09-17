import 'package:flutter/material.dart';
import 'package:flutter_application_1/managers/components/transparent-material-page/transparent_material_page.component.dart';
import 'package:flutter_application_1/router/constants.dart';
import 'package:flutter_application_1/screens/gf.screen.dart';
import 'package:flutter_application_1/screens/home.screen.dart';
import 'package:flutter_application_1/screens/popup.screen.dart';
import 'package:flutter_application_1/screens/saw.screen.dart';
import 'package:flutter_application_1/utils/crypto.utils.dart';

class CustomRoutePath {}

class CustomRouterDelegate extends RouterDelegate<CustomRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<CustomRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  late String popupUrl;
  late String sawUrl;
  late String gfUrl;

  CustomRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  List<Page> pages = initialPagesState;

  List<Page> pendingPopups = [];
  List<Page> pendingSaws = [];
  List<Page> pendingGfs = [];

  @override
  Future<void> setNewRoutePath(CustomRoutePath configuration) async {
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    pages[0] = MaterialPage(
      key: const ValueKey('HomePage'),
      child: Home(
        key: Key(cryptoUtils.generateRandomString(10)),
        openPopup: openPopup,
        openSaw: openSaw,
        resetNavigator: resetNavigator,
        openGf: openGf,
      ),
    );

    return Navigator(
      key: navigatorKey,
      pages: List.of(pages),
      onDidRemovePage: (Page<Object?> page) {
        pages.remove(page);
      },
    );
  }

  void resetNavigator() {
    pages = [];

    notifyListeners();

    pages.add(MaterialPage(
      key: const ValueKey('HomePage'),
      child: Home(
        key: Key(cryptoUtils.generateRandomString(10)),
        openPopup: openPopup,
        openSaw: openSaw,
        resetNavigator: resetNavigator,
        openGf: openGf,
      ),
    ));

    notifyListeners();
  }

  void openPopup(
    String popupUrl,
    dynamic eventPayload,
    void Function(String deepLinkJson) onDeepLinkHandle,
  ) {
    String uniqueKey = cryptoUtils.generateRandomString(10);

    TransparentMaterialPage popup = TransparentMaterialPage(
      child: Popup(
        closePopup: closePopup,
        url: popupUrl,
        eventPayload: eventPayload,
        onDeepLinkHandle: onDeepLinkHandle,
      ),
      name: Routes.popup.getRoute(),
      key: ValueKey(uniqueKey),
    );

    bool isMounted = checkIfRouteAlreadyMounted(Routes.popup.getRoute());

    if (isMounted) {
      pendingPopups.add(popup);

      return;
    }

    pages.add(popup);

    notifyListeners();
  }

  void closePopup() {
    for (int i = 0; i < pages.length; i++) {
      if (pages[i].name == Routes.popup.getRoute()) {
        pages.removeAt(i);
        break;
      }
    }

    notifyListeners();

    processQueue();
  }

  void openSaw(int templateId, int pendingMessageId, String url) {
    String uniqueKey = cryptoUtils.generateRandomString(10);

    TransparentMaterialPage saw = TransparentMaterialPage(
        child: Saw(
          closeSaw: closeSaw,
          templateId: templateId,
          pendingMessageId: pendingMessageId,
          url: url,
        ),
        name: Routes.saw.getRoute(),
        key: ValueKey(uniqueKey));

    bool isMounted = checkIfRouteAlreadyMounted(Routes.saw.getRoute());

    if (isMounted) {
      pendingPopups.add(saw);

      return;
    }

    for (int i = 0; i < pages.length; i++) {
      if (pages[i].name == Routes.popup.getRoute()) {
        pages.insert(
          i,
          saw,
        );

        notifyListeners();

        return;
      }
    }

    pages.add(saw);

    notifyListeners();
  }

  void closeSaw() {
    for (int i = 0; i < pages.length; i++) {
      if (pages[i].name == Routes.saw.getRoute()) {
        pages.removeAt(i);
        break;
      }
    }

    notifyListeners();

    processQueue();
  }

  void openGf(String url) {
    String uniqueKey = cryptoUtils.generateRandomString(10);

    pages.add(
      TransparentMaterialPage(
          child: Gf(
            url: url,
            closeGf: closeGf,
          ),
          name: Routes.gf.getRoute(),
          key: ValueKey(uniqueKey)),
    );

    notifyListeners();
  }

  void closeGf() {
    for (int i = 0; i < pages.length; i++) {
      if (pages[i].name == Routes.gf.getRoute()) {
        pages.removeAt(i);
        break;
      }
    }

    notifyListeners();

    processQueue();
  }

  bool checkIfRouteAlreadyMounted(String route) {
    for (int i = 0; i < pages.length; i++) {
      if (pages[i].name == route) {
        return true;
      }
    }

    return false;
  }

  void processQueue() {
    bool hasActivePopup =
        pages.any((page) => page.name == Routes.popup.getRoute());
    bool hasActiveSaw = pages.any((page) => page.name == Routes.saw.getRoute());

    if (pendingPopups.isNotEmpty) {
      pages.add(pendingPopups.removeAt(0));

      notifyListeners();
      return;
    }

    if (!hasActivePopup && !hasActiveSaw && pendingSaws.isNotEmpty) {
      pages.add(pendingSaws.removeAt(0));
      notifyListeners();
      return;
    }
  }
}
