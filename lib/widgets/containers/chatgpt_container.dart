import 'package:bab/controller/forms/form_receipt_page.dart';
import 'package:bab/models/receipt_model.dart';
import 'package:bab/widgets/dialogs/delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;

// Internal package
import 'package:bab/models/message_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/widgets/containers/abstract_container.dart';
import 'package:bab/widgets/containers/error_container.dart';
import 'package:bab/widgets/dialogs/confirm_dialog.dart';

// External package
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sprintf/sprintf.dart';


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
  late OpenAI _openAI;
  final _formKey = GlobalKey<FormState>();
  Future<List<MessageModel>>? _messages;
  String? _text;
  double _volume = 23;
  String topic = 'chatgpt';

  @override
  void initState() {
    _openAI = OpenAI.instance.build(
        token: dotenv.env["OPEN_AI_API_KEY"],
        baseOption: HttpSetup(
            receiveTimeout: const Duration(seconds: 20),
            connectTimeout: const Duration(seconds: 20)
        ),
        enableLog: foundation.kDebugMode
    );
    super.initState();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
            const SizedBox(height: 20),
            Text("${AppLocalizations.of(context)!.text('description_beer')} :", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade200,
              ),
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                maxLines: 8, //or null
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.text('description_beer_hint'),
                  border: InputBorder.none,
                  // fillColor: FillColor, filled: true
                ),
                onEditingComplete: () async {
                  _send();
                },
                onChanged: (value) {
                  setState(() {
                    _text = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(18)),
                icon: const Icon(Icons.send, size: 18),
                label: Text(AppLocalizations.of(context)!.text('send')),
                onPressed: _text != null ? _send : null,
              ),
            ),
            FutureBuilder<List<MessageModel>>(
              future: _messages,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return Container();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.text('answers'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
                        const SizedBox(height: 8),
                        ListView.separated(
                          shrinkWrap: true,
                          itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 16),
                          itemBuilder: (context, index){
                            return Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: SecondaryColorLight,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: Text(snapshot.data![index].response ?? '')),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        tooltip: AppLocalizations.of(context)!.text('new_recipe'),
                                        onPressed: _new
                                      ),
                                      const SizedBox(height: 4),
                                      Tooltip(message: '${AppLocalizations.of(context)!.text('description')}: ${snapshot.data![index].send}', child: Icon(Icons.help_outline)),
                                      const SizedBox(height: 4),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () {
                                          _delete(snapshot.data![index]);
                                        }
                                      )
                                    ],
                                  ),
                                ]
                              )
                            );
                          },
                        )
                      ]
                    )
                  );
                }
                if (snapshot.hasError) {
                  return ErrorContainer(snapshot.error.toString());
                }
                return Container();
              }
            )
          ]
        ),
      ),
    );
  }

  _fetch() async {
    setState(() {
      _messages = Database().getMessages(user: currentUser!.uuid, topic: topic);
    });
  }

  _send() async {
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
    try {
      String prompt = sprintf(AppLocalizations.of(context)!.text('chatgpt_model'),
        [ _text, _volume, AppLocalizations.of(context)!.liquid.toLowerCase() ]
      );
      final request = CompleteText(
        prompt: prompt,
        model: TextDavinci3Model(),
        maxTokens: 255
      );

      EasyLoading.show(status: AppLocalizations.of(context)!.text('in_progress'));
      _openAI.onCompletion(request: request).then((value) {
        if (value != null) {
          Database().add(MessageModel(
            topic: topic,
            send: _text,
            response: value.choices.last.text.trim()
          ));
          _fetch();
        }
        EasyLoading.dismiss();
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
        _showSnackbar(error.toString());
        EasyLoading.dismiss();
      });
    } finally {
      // EasyLoading.dismiss();
    }
  }

  _new() async {
    ReceiptModel newModel = ReceiptModel();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormReceiptPage(newModel);
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