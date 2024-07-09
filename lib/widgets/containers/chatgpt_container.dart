import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;

// Internal package
import 'package:bab/controller/forms/form_recipe_page.dart';
import 'package:bab/controller/login_page.dart';
import 'package:bab/extensions/string_extensions.dart';
import 'package:bab/helpers/date_helper.dart';
import 'package:bab/models/fermentable_model.dart' as fm;
import 'package:bab/models/hop_model.dart' as hm;
import 'package:bab/models/message_model.dart';
import 'package:bab/models/misc_model.dart' as mm;
import 'package:bab/models/recipe_model.dart';
import 'package:bab/models/yeast_model.dart' as ym;
import 'package:bab/utils/amount.dart';
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
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';


class ChatGPTContainer extends AbstractContainer {
  ChatGPTContainer({String? company, String? recipe, int? product}) : super(
    company: company,
    recipe: recipe,
    product: product
  );

  @override
  _ChatGPTContainerState createState() => _ChatGPTContainerState();
}

class RegExpAmount {
  final RegExp regExp;
  final Measurement measurement;
  final String symbol;
  RegExpAmount(this.regExp, this.measurement, this.symbol);

  Amount? parse(String text, Locale locale) {
    final format = NumberFormat.decimalPattern('$locale');
    if(text.contains(regExp)) {
      final match = regExp.firstMatch(text);
      List<String> values = match![0]!.split(RegExp(symbol, caseSensitive: false));
      double amount = 0;
      try {
        amount = format.parse(values.first) as double;
      } catch(e) {
        amount = double.parse(values.first);
      }
      return Amount(
          amount,
          measurement
      );
    }
    return null;
  }
}

class RegExpDuration {
  final RegExp regExp;
  final Time time;
  RegExpDuration(this.regExp, this.time);

  Duration? parse(String text) {
    if(text.contains(regExp)) {
      final match = regExp.firstMatch(text);
      List<String> values = match![0]!.split(time.name);
      final num =  int.tryParse(values.first);
      if (num != null) {
        switch (time) {
          case Time.minutes:
            return  Duration(minutes: num);
          case Time.hours:
            return Duration(hours: num);
          case Time.days:
            return Duration(days: num);
          case Time.weeks:
            // TODO: Handle this case.
          case Time.month:
            // TODO: Handle this case.
        }
      }
    }
    return null;
  }
}

class _ChatGPTContainerState extends AbstractContainerState {
  OpenAI? _openAI;
  String? _openAI_api_key;
  Future<List<MessageModel>>? _messages;
  double _volume = 23;
  String _default_malt = 'Pale ale';
  String _default_yeast = 'Safale S-04';
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
                if (currentUser == null) const SizedBox(height: 4),
                if (currentUser == null) Align(
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
                  expandedAlignment: Alignment.centerLeft,
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
                if (snapshot.data!.isNotEmpty) Padding(
                  padding: EdgeInsets.all(8),
                    child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _bubble(snapshot.data![index]);
                    },
                  )
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
                  child: IntrinsicWidth(
                    // child: Text(model.response ?? ''),
                    child: TextFormField(
                      controller: TextEditingController(text: model.response ?? '' ),
                      // initialValue: model.response ?? '' ,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: FormDecoration(
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        model.response = value;
                        setState(() {
                          model.isEdited = true;
                        });
                      },
                    )
                  ),
                )
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: AppLocalizations.of(context)!.text('new_recipe'),
                    onPressed: model.response != null ? () => _new(model.response!) : null
                  ),
                  if (model.isEdited == true) IconButton(
                    icon: const Icon(Icons.save_outlined),
                    tooltip: AppLocalizations.of(context)!.text('modify'),
                    onPressed: () {
                      Database().update(model).then((value) async {
                        _showSnackbar(AppLocalizations.of(context)!.text('saved_item'));
                      }).onError((e, s) {
                        _showSnackbar(e.toString());
                      });
                      setState(() {
                        model.isEdited = false;
                      });
                    }
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                    onPressed: () => _delete(model)
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
            model: Gpt3TurboInstruct(),
            maxTokens: 2048
        );
        EasyLoading.show(status: AppLocalizations.of(context)!.text('work_in_progress'));
          _openAI!.onCompletion(request: request).then((value) async {
          if (value != null) {
            String text = value.choices.last.text.trim();
            await Database().add(MessageModel(
                topic: topic,
                send: message,
                response: text
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
              height: 240,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: AppLocalizations.of(context)!.volumeFormat(_volume, symbol: false) ?? '',
                    onChanged: (value) => setState(() {
                      _volume = AppLocalizations.of(context)!.volume(AppLocalizations.of(context)!.decimal(value))!;
                    }),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.text('mash_volume'),
                      suffixText: AppLocalizations.of(context)!.liquid.toLowerCase(),
                      suffixIcon: Tooltip(
                        message: AppLocalizations.of(context)!.text('final_volume'),
                        child: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                      ),
                      border: InputBorder.none,
                      fillColor: FillColor, filled: true
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!.text('validator_field_required');
                      }
                      return null;
                    }
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: _default_malt,
                    onChanged: (value) => setState(() {
                      _default_malt = value;
                    }),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.text('default_malt'),
                      border: InputBorder.none,
                      fillColor: FillColor, filled: true
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!.text('validator_field_required');
                      }
                      return null;
                    }
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                      initialValue: _default_yeast,
                      onChanged: (value) => setState(() {
                        _default_yeast = value;
                      }),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.text('default_yeast'),
                      border: InputBorder.none,
                      fillColor: FillColor, filled: true
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!.text('validator_field_required');
                      }
                      return null;
                    }
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

  _new(String response) async {
    RecipeModel? newModel = await _import(context, response);
    if (newModel != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return FormRecipePage(newModel);
      })).then((value) {
        _fetch();
      });
    }
  }

  Future<RecipeModel?> _import(BuildContext context, String text) async {
    try {
      EasyLoading.show(status: AppLocalizations.of(context)!.text('work_in_progress'));

      final RegExp instructions = RegExp(r''+ AppLocalizations.of(context)!.text('instructions') +'}?:', caseSensitive: false);

      List<String> fermentableLabels = [
        AppLocalizations.of(context)!.text('barley_malt'),
        AppLocalizations.of(context)!.text('malts'),
        AppLocalizations.of(context)!.text('malt'),
      ];
      List<String> hopLabels = [
        AppLocalizations.of(context)!.text('hopping'),
        AppLocalizations.of(context)!.text('hops'),
        AppLocalizations.of(context)!.text('hop'),
      ];
      List<String> yeastLabels = [
        AppLocalizations.of(context)!.text('yeasts'),
        AppLocalizations.of(context)!.text('yeast'),
      ];
      List<String> miscLabels = [
        AppLocalizations.of(context)!.text('miscellaneous'),
        AppLocalizations.of(context)!.text('others'),
      ];

      List<fm.FermentableModel> fermentables = await Database().getFermentables(user: currentUser!.uuid);
      List<hm.HopModel> hops = await Database().getHops(user: currentUser!.uuid);
      List<ym.YeastModel> yeasts = await Database().getYeasts(user: currentUser!.uuid);
      List<mm.MiscModel> miscs = await Database().getMiscellaneous(user: currentUser!.uuid);

      final locale = Localizations.localeOf(context);
      Amount? amount;
      Duration? time;
      Ingredient? ingredient;
      List<String> missing = [];
      final model = RecipeModel(
        volume: _volume
      );
      for(String line in text.split('\n')) {
        final original = line;
        line = line.withoutDiacriticalMarks;
        line = line.replaceAll(RegExp(' ${AppLocalizations.of(context)!.text('of')} ', caseSensitive: false),  ' ');
        line = line.replaceAll(RegExp(' ${AppLocalizations.of(context)!.text('at')} ', caseSensitive: false),  ' ');
        amount = null;
        time = null;
        if (line.contains(instructions)) {
          model.notes = text.substring(text.indexOf(instructions));
          break;
        } else if (line.containsOccurrence(fermentableLabels)) {
          ingredient = Ingredient.fermentable;
        } else if (line.containsOccurrence(hopLabels)) {
          ingredient = Ingredient.hops;
        } else if (line.containsOccurrence(yeastLabels)) {
          ingredient = Ingredient.yeast;
        } else if (line.containsOccurrence(miscLabels)) {
          ingredient = Ingredient.misc;
        }
        final regExpAmount = hasAmount(line);
        if (regExpAmount != null) {
          amount = regExpAmount.parse(line, locale);
          line = line.replaceAll(regExpAmount.regExp, '');
        }
        final regExpDuration = hasDuration(line);
        if (regExpDuration != null) {
          time = regExpDuration.parse(line);
          line = line.replaceAll(regExpDuration.regExp, '');
        }
        if (line.isNotEmpty) {
          switch(ingredient) {
            case Ingredient.fermentable:
              bool found = false;
              line = line.clean(fermentableLabels);
              line = line.clean(['2row', '6row', '2rp', '6rp']);
              if (line.isEmpty) {
                if (amount == null) break;
                line = _default_malt.withoutDiacriticalMarks.clean([]);
              }
              debugPrint('fermentable $line');
              for(fm.FermentableModel item in fermentables) {
                if (item.hasName(line, fermentableLabels)) {
                  found = true;
                  fm.FermentableModel newModel = item.copy();
                  newModel.amount = amount!.measurement == Measurement.gram ?  (amount.amount! / 1000) : amount.amount;
                  // newModel.measurement = amount.measurement;
                  model.addFermentable(newModel);
                  debugPrint('fermentable ${newModel.name} ${amount} ');
                  break;
                }
              }
              if (!found) {
                missing.add(original);
              }
              break;
            case Ingredient.hops:
              bool found = false;
              line = line.clean(hopLabels);
              line = line.clean([
                AppLocalizations.of(context)!.text(hm.Hop.leaf.toString().toLowerCase()).toLowerCase(),
                AppLocalizations.of(context)!.text(hm.Hop.pellet.toString().toLowerCase()).toLowerCase(),
              ]);
              if (line.isEmpty) break;
              debugPrint('hop $line');
              for(hm.HopModel item in hops) {
                if (item.hasName(line, hopLabels)) {
                  found = true;
                  hm.HopModel newModel = item.copy();
                  newModel.amount = amount!.measurement == Measurement.gram ?  (amount.amount! / 1000) : amount.amount;
                  newModel.measurement = amount.measurement;
                  newModel.use = hm.Use.boil;
                  newModel.duration = time != null ? time.inMinutes : null;
                  model.addHop(newModel);
                  break;
                }
              }
              if (!found) {
                missing.add(original);
              }
              break;
            case Ingredient.yeast:
              bool found = false;
              line = line.clean(yeastLabels);
              if (line.isEmpty) {
                if (amount == null) break;
                line = _default_yeast.withoutDiacriticalMarks.clean([]);
              }
              debugPrint('yeast $line');
              for(ym.YeastModel item in yeasts) {
                if (item.hasName(line, yeastLabels)) {
                  found = true;
                  ym.YeastModel newModel = item.copy();
                  if (amount != null) {
                    newModel.amount = amount.measurement == Measurement.gram || amount.measurement == Measurement.milliliter ?  (amount.amount! / 1000) : amount.amount;
                    newModel.measurement = amount.measurement ;
                  }
                  model.addYeast(newModel);
                  break;
                }
              }
              if (!found) {
                missing.add(original);
              }
              break;
            case Ingredient.misc:
              bool found = false;
              line = line.clean(miscLabels);
              if (line.isEmpty) break;
              debugPrint('misc $line');
              for(mm.MiscModel item in miscs) {
                if (item.hasName(line, miscLabels)) {
                  found = true;
                  mm.MiscModel newModel = item.copy();
                  newModel.amount = amount!.measurement == Measurement.gram || amount.measurement == Measurement.milliliter  ?  (amount.amount! / 1000) : amount.amount;
                  newModel.measurement = amount.measurement;
                  model.addMisc(newModel);
                  break;
                }
              }
              if (!found) {
                missing.add(original);
              }
              break;
            case null:
              // TODO: Handle this case.
          }
        }
      }
      model.calculate();
      EasyLoading.dismiss();
      if (missing.isNotEmpty) {
        bool confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return ConfirmDialog(
              title: AppLocalizations.of(context)!.text('missing_ingredients'),
              ok: MaterialLocalizations.of(context).continueButtonLabel,
              content: SizedBox(
                width: 420,
                height: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.text('missing_ingredients_continue'), style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: missing.map((e) => Text(e)).toList()
                        )
                      )
                    )
                  ]
                )
              )
            );
          }
        );
        if (confirm) {
          missing.insert(0, AppLocalizations.of(context)!.text('missing_ingredients') + ':');
          model.notes = missing.join('\n') + (model.notes != null ? '\n\n' + model.notes : '');
          return model;
        }
        return null;
      }
      return model;
    } catch (e, s) {
      debugPrint(s.toString());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              duration: const Duration(seconds: 10)
          )
      );
    } finally {
      EasyLoading.dismiss();
    }
    return null;
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

  RegExpAmount? hasAmount(String text) {
    for (Measurement  measurement in Measurement.values) {
      List<String> symboles = measurement.symbol != null ? [measurement.symbol!] : [];
      if (measurement == Measurement.packages) {
        symboles.add(AppLocalizations.of(context)!.text('packages'));
        symboles.add(AppLocalizations.of(context)!.text('sachets'));
        symboles.add(AppLocalizations.of(context)!.text('package'));
        symboles.add(AppLocalizations.of(context)!.text('sachet'));
      }
      for (String symbol in symboles) {
        final regExp = RegExp(r'(\d*(?:[.,]?\d+)).' + symbol + '+', caseSensitive: false);
        if (text.contains(regExp)) return RegExpAmount(regExp, measurement, symbol);
      }
    }
    return null;
  }

  RegExpDuration? hasDuration(String text) {
    for (Time time in [Time.minutes, Time.hours, Time.days]) {
      final regExp = RegExp(r'(\d*).' + time.name + '+');
      if (text.contains(regExp)) return RegExpDuration(regExp, time);
    }
    return null;
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