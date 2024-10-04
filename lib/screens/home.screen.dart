import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/managers/components/form-field/custom_form_field.component.dart';
import 'package:flutter_application_1/managers/persistant-storage/constants.dart';
import 'package:flutter_application_1/utils/form_validators.utils.dart';

class Home extends StatefulWidget {
  final void Function(
    String popupUrl,
    dynamic eventPayload,
    void Function(String deepLinkJson) onDeepLinkHandle,
  ) openPopup;
  final void Function(int templateId, int pendingMessageId, String url) openSaw;
  final void Function(String url) openGf;
  final void Function() resetNavigator;

  const Home({
    super.key,
    required this.openPopup,
    required this.openSaw,
    required this.resetNavigator,
    required this.openGf,
  });

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  String? username;
  bool? isLoggedIn;

  @override
  void initState() {
    String? resUsername =
        persistantStorage.getString(PersistantStorageKeys.username.value);

    username = resUsername ?? 'testuser';

    bool? resIsLoggedIn =
        persistantStorage.getBool(PersistantStorageKeys.isLoggedIn.value);

    isLoggedIn = resIsLoggedIn ?? false;

    super.initState();
  }

  void openGamification() {
    widget.openGf(gfUrl!);
  }

  void openSaw() {
    widget.openGf("${gfUrl!}&dp=dp:gf_saw");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Smartico Demo'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Form(
                child: Builder(
                  builder: (formContext) {
                    FormState form = Form.of(formContext);

                    return Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: CustomFormField(
                              initialValue: username,
                              validator: formValdators.checkRequired,
                              enabled: !(isLoggedIn ?? false),
                              onSaved: (value) async {
                                if (value == null) {
                                  return;
                                }

                                await persistantStorage.setString(
                                    PersistantStorageKeys.username.value,
                                    value);

                                await initConnection();

                                setState(() {
                                  username = value;
                                  isLoggedIn = true;
                                });
                              },
                            )),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (isLoggedIn == false) {
                                if (form.validate() == false) {
                                  return;
                                }

                                form.save();
                              } else {
                                await webSocketManager.disconnect();

                                await persistantStorage.setBool(
                                    PersistantStorageKeys.isLoggedIn.value,
                                    false);

                                setState(() {
                                  isLoggedIn = false;
                                });
                              }
                            },
                            child: (isLoggedIn ?? false)
                                ? const Text('Logout')
                                : const Text('Set'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: !(isLoggedIn ?? false) ? null : openGamification,
                child: const Text('Open Gamification'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: !(isLoggedIn ?? false) ? null : openSaw,
                child: const Text('Open SAW'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
