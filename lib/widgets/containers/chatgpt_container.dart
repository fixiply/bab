import 'package:bb/widgets/dialogs/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as Foundation;

// Internal package
import 'package:bb/utils/constants.dart';
import 'package:bb/widgets/containers/abstract_container.dart';
import 'package:bb/utils/app_localizations.dart';

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

  _ChatGPTContainerState createState() => new _ChatGPTContainerState();
}


class _ChatGPTContainerState extends AbstractContainerState {
  late OpenAI openAI;
  Future<CTResponse?>? _translateFuture;
  final _formKey = GlobalKey<FormState>();
  List<String> messages = [];
  String? _text;
  double _volume = 23;

  @override
  void initState() {
    openAI = OpenAI.instance.build(
      token: dotenv.env["OPEN_AI_API_KEY"],
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 20),
        connectTimeout: const Duration(seconds: 20)
        ),
        enableLog: Foundation.kDebugMode
      );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(12.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(AppLocalizations.of(context)!.text('mash_volume') + ' :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade200,
              ),
              padding: EdgeInsets.all(8),
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
            SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.text('description_beer') + " :", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade200,
              ),
              padding: EdgeInsets.all(8),
              child: TextFormField(
                maxLines: 8, //or null
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.text('description_beer_hint'),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                    tooltip: AppLocalizations.of(context)!.text(messages.isNotEmpty ? 'resend' : 'send'),
                    onPressed: _text != null ? _send : null
                  )
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
            if (messages.isNotEmpty) SizedBox(height: 20),
            if (messages.isNotEmpty) ListView.builder(
              itemCount: messages.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index){
                return Container(
                  // padding: EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: SecondaryColorLight,
                    ),
                    padding: EdgeInsets.all(8),
                    child: Text(messages[index], style: TextStyle(fontSize: 15)),
                  ),
                );
              },
            ),
          ]
        ),
      )
    );
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
      debugPrint('prompt $prompt');
      final request = CompleteText(
          prompt: prompt,
          model: Model.textDavinci3,
          maxTokens: 255
      );

      EasyLoading.show(status: AppLocalizations.of(context)!.text('in_progress'));
      openAI.onCompletion(request: request).then((value) {
        if (value != null) {
          setState(() {
            messages.add(value.choices.last.text);
          });
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

  // _send2() async {
  //   try {
  //     EasyLoading.show(status: AppLocalizations.of(context)!.text('in_progress'));
  //     final request = EmbedRequest(
  //         model: EmbedModel.embedTextModel,
  //         input: 'The food was delicious and the waiter');
  //
  //     final response = await openAI.embed.embedding(request);
  //     setState(() {
  //       response.data.last.embedding
  //     });
  //     EasyLoading.dismiss();
  //   } finally {
  //     EasyLoading.dismiss();
  //   }
  // }

  _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message),
            duration: Duration(seconds: 10)
        )
    );
  }
}