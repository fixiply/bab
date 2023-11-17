import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;

// Internal package
import 'package:bab/controller/forms/form_recipe_page.dart';
import 'package:bab/controller/login_page.dart';
import 'package:bab/helpers/date_helper.dart';
import 'package:bab/models/message_model.dart';
import 'package:bab/models/recipe_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/widgets/containers/abstract_container.dart';
import 'package:bab/widgets/dialogs/confirm_dialog.dart';
import 'package:bab/widgets/dialogs/delete_dialog.dart';
import 'package:bab/widgets/form_decoration.dart';

// External package
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';


class ChatGPTContainer extends AbstractContainer {
  ChatGPTContainer({String? company, String? receipt, int? product}) : super(
    company: company,
    receipt: receipt,
    product: product
  );

  @override
  _ChatGPTContainerState createState() => _ChatGPTContainerState();
}


class _ChatGPTContainerState extends AbstractContainerState {
  OpenAI? _openAI;
  String? _openAI_api_key;
  Future<List<MessageModel>>? _messages;
  double _volume = 23;
  String topic = 'chatgpt';
  String openAI_url = 'https://platform.openai.com/account/api-keys';

  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      showSearchBar();
    });
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 60),
      child: FutureBuilder<List<MessageModel>>(
        future: _messages,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (currentUser == null) Align(
                  child: Text(AppLocalizations.of(context)!.text('log_in_feature'))
                ),
                if (currentUser == null)  const SizedBox(height: 4),
                if (currentUser == null)  Align(
                  child: TextButton(
                    child: Text(AppLocalizations.of(context)!.text('login'), style: TextStyle(color: Theme.of(context).primaryColor)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const LoginPage();
                      }));
                    },
                    style: TextButton.styleFrom(shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    )),
                  )
                ),
                if (currentUser == null) const SizedBox(height: 8),
                ExpansionTile(
                  initiallyExpanded: snapshot.data!.isEmpty,
                  childrenPadding: EdgeInsets.all(8.0),
                  title: Text(AppLocalizations.of(context)!.text('chatgpt_howto'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (currentUser != null && !currentUser!.isAdmin()) TextButton(
                          child: Text(AppLocalizations.of(context)!.text(currentUser!.openAI_api_key != null ? 'change_openai_key' : 'generate_openai_key' ), style: TextStyle(color: Theme.of(context).primaryColor)),
                          onPressed: () async {
                            bool confirm = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ConfirmDialog(
                                  title: AppLocalizations.of(context)!.text('generate_openai_key'),
                                  content: SizedBox(
                                    width: 420,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(AppLocalizations.of(context)!.text('open_openAI_api_key')),
                                        RichText(
                                          textAlign: TextAlign.left,
                                          text: TextSpan(
                                            text: 'URL - ',
                                            style: DefaultTextStyle.of(context).style,
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: openAI_url,
                                                // style: DefaultTextStyle.of(context).style.copyWith(color: Theme.of(context).primaryColor),
                                                style: TextStyle(color: Theme.of(context).primaryColor),
                                                recognizer: TapGestureRecognizer()..onTap = () async {
                                                  final Uri url = Uri.parse(openAI_url);
                                                  if (!await launchUrl(url)) {
                                                    throw Exception('Could not launch $openAI_url');
                                                  }
                                                }
                                              ),
                                            ]
                                          )
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          initialValue: _openAI_api_key,
                                          autofocus: true,
                                          decoration: FormDecoration(
                                            icon: const Icon(Icons.security),
                                            labelText: AppLocalizations.of(context)!.text('secret_key'),
                                            border: InputBorder.none,
                                            fillColor: FillColor, filled: true
                                          ),
                                          onChanged: (String? value) {
                                            setState(() {
                                              _openAI_api_key = value;
                                            });
                                          },
                                        ),
                                        const Divider(height: 32),
                                        Image.asset('assets/images/openAI_api_key.png')
                                      ],
                                    ),
                                  ),
                                );
                              }
                            );
                            if (confirm) {
                              currentUser!.openAI_api_key = _openAI_api_key;
                              Database().update(currentUser);
                              _initOpenAI();
                            }
                          },
                          style: TextButton.styleFrom(shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            side: BorderSide(color: Theme.of(context).primaryColor),
                          )),
                        ),
                        if (currentUser != null && !currentUser!.isAdmin()) const SizedBox(height: 8),
                        Text(AppLocalizations.of(context)!.text('chatgpt_description')),
                      ],
                    )
                  ],
                ),
                if (snapshot.data!.isNotEmpty) ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                  separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _bubble(snapshot.data![index]);
                  },
                )
              ]
            );
          }
          return const Center(child: CircularProgressIndicator(strokeWidth: 2.0, valueColor:AlwaysStoppedAnimation<Color>(Colors.black38)));
        }
      )
    );
  }

  _initialize() async {
    if (currentUser != null) {
      _openAI_api_key = currentUser!.openAI_api_key;
      if (_openAI_api_key == null && currentUser!.isAdmin()) {
        _openAI_api_key = dotenv.env["OPEN_AI_API_KEY"];
      }
    }
    _initOpenAI();
  }

  _initOpenAI() async {
    if (_openAI_api_key != null) {
      try {
        _openAI = OpenAI.instance.build(
            token: _openAI_api_key,
            baseOption: HttpSetup(
                receiveTimeout: const Duration(seconds: 20),
                connectTimeout: const Duration(seconds: 20)
            ),
            enableLog: foundation.kDebugMode
        );
      }
      catch(e) {
        _showSnackbar(e.toString());
      }
    }
  }

  showSearchBar() async {
    return showBottomSheet(
      context: context,
      shape: Border(
        top: BorderSide(width: 1.0, color: Colors.black38),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  icon: Icon(Icons.tune),
                  onPressed: () => _settings(),
                  color: Theme.of(context).primaryColor,
                  tooltip: AppLocalizations.of(context)!.text('settings'),
                ),
              ),
              Flexible(
                child: Container(
                  child: TextField(
                    onSubmitted: (value) {
                      _send(textEditingController.text);
                    },
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 15),
                    controller: textEditingController,
                    decoration: InputDecoration.collapsed(
                      hintText: '${AppLocalizations.of(context)!.text('chatgpt_search_hint')}...',
                      hintStyle: TextStyle(color: TextGrey),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _send(textEditingController.text),
                  color: Theme.of(context).primaryColor,
                  tooltip: AppLocalizations.of(context)!.text('send'),
                ),
              ),
            ],
          )
        );
      }
    );
  }

  _bubble(MessageModel model) {
    return SafeArea(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(width: 50),
              Text(DateHelper.formatDateTime(context, model.inserted_at)),
              const SizedBox(width: 12),
              Flexible(
                child:Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: SecondaryColorLight,
                  ),
                  child: Text(model.send ?? '?')
                ),
              ),
            ]
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(child: Text(AppLocalizations.of(context)!.text('ai')), radius: 16),
              const SizedBox(width: 12),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: BlendColor,
                  ),
                  child: Text(model.response ?? ''),
                )
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: AppLocalizations.of(context)!.text('new_recipe'),
                    onPressed: _new
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      _delete(model);
                    }
                  )
                ],
              ),
            ]
          ),
        ],
      )
    );
  }

  _fetch() async {
    setState(() {
      _messages = Database().getMessages(user: currentUser != null ? currentUser!.uuid : null, topic: topic);
    });
  }

  _send(String message) async {
    if (message.isNotEmpty) {
      if (currentUser == null) {
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return ConfirmDialog(
                content: Text(AppLocalizations.of(context)!.text('logged_in_feature')),
              );
            }
        );
        return;
      }
      if (_openAI == null) {
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return ConfirmDialog(
                content: Text(AppLocalizations.of(context)!.text('logged_in_feature')),
              );
            }
        );
        return;
      }
      try {
        String prompt = sprintf(
            AppLocalizations.of(context)!.text('chatgpt_model'),
            [
              message,
              _volume,
              AppLocalizations.of(context)!.liquid.toLowerCase()
            ]
        );
        final request = CompleteText(
            prompt: prompt,
            model: TextDavinci3Model(),
            maxTokens: 255
        );

        EasyLoading.show(status: AppLocalizations.of(context)!.text('in_progress'));
          _openAI!.onCompletion(request: request).then((value) {
          if (value != null) {
            Database().add(MessageModel(
                topic: topic,
                send: message,
                response: value.choices.last.text.trim()
            ));
            _fetch();
          }
          EasyLoading.dismiss();
        }).onError((e, s) {
          debugPrint(e.toString());
          _showSnackbar(e.toString());
          EasyLoading.dismiss();
        });
      } finally {
        // EasyLoading.dismiss();
      }
    }
  }

  _settings() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.text('settings')),
            content: Container(
              height: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${AppLocalizations.of(context)!.text('mash_volume')} :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade200,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      initialValue: AppLocalizations.of(context)!.volumeFormat(_volume, symbol: false) ?? '',
                      onChanged: (value) => setState(() {
                        _volume = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value))!;
                      }),
                      decoration: InputDecoration(
                        suffixText: AppLocalizations.of(context)!.liquid.toLowerCase(),
                        suffixIcon: Tooltip(
                          message: AppLocalizations.of(context)!.text('final_volume'),
                          child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                        ),
                        border: InputBorder.none
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!.text('validator_field_required');
                        }
                        return null;
                      }
                    ),
                  ),
                ],
              )
            ),
            actions: <Widget>[
              TextButton(
                child: Text(MaterialLocalizations.of(context).closeButtonLabel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }

  _new() async {
    RecipeModel newModel = RecipeModel();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormRecipePage(newModel);
    })).then((value) {
      _fetch();
    });
  }

  Future<bool> _delete(MessageModel model) async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog(
          title: AppLocalizations.of(context)!.text('delete_item_title'),
        );
      }
    );
    if (confirm) {
      try {
        await Database().delete(model, forced: true);
      } catch (e) {
        _showSnackbar(e.toString());
      }
      _fetch();
      return true;
    }
    return false;
  }

  _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 10)
        )
    );
  }
}