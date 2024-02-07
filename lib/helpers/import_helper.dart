import 'dart:convert';
import 'dart:io';

// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/helpers/formula_helper.dart';
import 'package:bab/models/fermentable_model.dart' as fm;
import 'package:bab/models/hop_model.dart' as hm;
import 'package:bab/models/misc_model.dart' as mm;
import 'package:bab/models/recipe_model.dart' as rm;
import 'package:bab/models/style_model.dart' as sm;
import 'package:bab/models/yeast_model.dart' as ym;
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/helpers/color_helper.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/utils/fermentation.dart' as fermentation;
import 'package:bab/utils/localized_text.dart';
import 'package:bab/utils/mash.dart' as mash;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// External package
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:xml/xml.dart';

class ImportHelper {
  static fromBeerXML(BuildContext context, Function() onImported) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xml'],
      );
      if (result != null) {
        try {
          EasyLoading.show(status: AppLocalizations.of(context)!.text('work_in_progress'));

          final XmlDocument? document;
          if(DeviceHelper.isDesktop) {
            document = XmlDocument.parse(utf8.decode(result.files.single.bytes!));
          } else {
            File file = File(result.files.single.path!);
            document = XmlDocument.parse(file.readAsStringSync());
          }

          List<sm.StyleModel> styles = await Database().getStyles();

          final elements = document.findAllElements('RECIPE');
          for (XmlElement element in elements) {
            final model = rm.RecipeModel(
              title: element.getElement(rm.XML_ELEMENT_NAME)!.innerText,
              method: rm.RecipeModel.getTypeByName(element.getElement(rm.XML_ELEMENT_TYPE)!.innerText),
              volume: double.parse(element.getElement(rm.XML_ELEMENT_BATCH_SIZE)!.innerText),
              boil: int.parse(element.getElement(rm.XML_ELEMENT_BOIL_TIME)!.innerText),
              efficiency: double.parse(element.getElement(rm.XML_ELEMENT_EFFICIENCY)!.innerText),
              notes: element.getElement(rm.XML_ELEMENT_NOTES)!.innerText
            );
            XmlElement? style = element.getElement(rm.XML_ELEMENT_STYLE);
            if (style != null) {
              for(sm.StyleModel item in styles) {
                if (item.hasName(style.getElement(sm.XML_ELEMENT_NAME)!.innerText)) {
                  model.style = item;
                  break;
                }
              }
            }

            fermentationsBeerXML(context, element, model);
            await fermentablesBeerXML(element, model);
            await hopsBeerXML(element, model);
            await yeastsBeerXML(element, model);
            await miscBeerXML(element, model);
            mashBeerXML(element, model);

            await model.calculate();
            await Database().add(model, ignoreAuth: currentUser!.isAdmin());
          }
          onImported.call();
        } finally {
          EasyLoading.dismiss();
        }
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Unsupported operation $e"),
              duration: const Duration(seconds: 10)
          )
      );
    } catch (ex) {
      debugPrint(ex.toString());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(ex.toString()),
              duration: const Duration(seconds: 10)
          )
      );
    }
  }

  static fermentationsBeerXML(BuildContext context, XmlElement element, rm.RecipeModel model) {
    List<fermentation.Fermentation> list = [];

    final primary = element.getElement(fermentation.XML_ELEMENT_PRIMARY_AGE);
    if (primary != null) {
      double? primary_temp = double.tryParse(element.getElement(fermentation.XML_ELEMENT_PRIMARY_TEMP)!.innerText);
      if (primary_temp != null) {
        list.add(fermentation.Fermentation(
          name: AppLocalizations.of(context)!.text('primary'),
          duration: int.tryParse(primary.innerText),
          temperature: primary_temp)
        );
      }
    }

    final secondary = element.getElement(fermentation.XML_ELEMENT_SECONDARY_AGE);
    if (secondary != null) {
      double? secondary_temp = double.tryParse(element.getElement(fermentation.XML_ELEMENT_SECONDARY_TEMP)!.innerText);
      if (secondary_temp != null) {
        list.add(fermentation.Fermentation(
          name: AppLocalizations.of(context)!.text('secondary'),
          duration: int.tryParse(secondary.innerText),
          temperature: secondary_temp)
        );
      }
    }

    final tertiary = element.getElement(fermentation.XML_ELEMENT_TERTIARY_AGE);
    if (tertiary != null) {
      double? temp = double.tryParse(element.getElement(fermentation.XML_ELEMENT_TERTIARY_TEMP)!.innerText);
      if (temp != null) {
        list.add(fermentation.Fermentation(
          name: AppLocalizations.of(context)!.text('tertiary'),
          duration: int.tryParse(tertiary.innerText),
          temperature: temp)
        );
      }
    }

    final age = element.getElement(fermentation.XML_ELEMENT_AGE);
    if (age != null) {
      double? temp = double.tryParse(element.getElement(fermentation.XML_ELEMENT_AGE_TEMP)!.innerText);
      if (temp != null) {
        list.add(fermentation.Fermentation(
            name: AppLocalizations.of(context)!.text('bottle'),
            duration: int.tryParse(age.innerText),
            temperature: temp)
        );
      }
    }

    if (list.isNotEmpty) {
      model.fermentation = list;
    }
  }

  static fermentablesBeerXML(XmlElement element, rm.RecipeModel model) async {
    var children = element.findAllElements('FERMENTABLE');
    if (children.isNotEmpty) {
      List<fm.FermentableModel> fermentables = await Database().getFermentables(user: currentUser!.uuid);
      for (XmlElement child in children) {
        bool found = false;
        fm.Type? type = fm.FermentableModel.getTypeByName(child.getElement(rm.XML_ELEMENT_TYPE)!.innerText);
        for(fm.FermentableModel item in fermentables) {
          if (item.hasName(child.getElement(fm.XML_ELEMENT_NAME)!.innerText, ['malt']) && item.type == type) {
            found = true;
            fm.FermentableModel newModel = fm.FermentableModel.fromXML(child, old: item);
            model.addFermentable(newModel);
            break;
          }
        }
        if (!found) {
          fm.FermentableModel newModel = fm.FermentableModel.fromXML(child);
          await Database().add(newModel, ignoreAuth: currentUser!.isAdmin());
          model.addFermentable(newModel);
          fermentables.add(newModel);
        }
      }
    }
  }

  static hopsBeerXML(XmlElement element, rm.RecipeModel model) async {
    var children = element.findAllElements('HOP');
    if (children.isNotEmpty) {
      List<hm.HopModel> hops = await Database().getHops(user: currentUser!.uuid);
      for (XmlElement child in children) {
        bool found = false;
        hm.Hop? form = hm.HopModel.getFormByName(child.getElement(hm.XML_ELEMENT_FORM)!.innerText);
        for(hm.HopModel item in hops) {
          if (item.hasName(child.getElement(hm.XML_ELEMENT_NAME)!.innerText, ['hop']) && item.form == form) {
            found = true;
            hm.HopModel newModel = hm.HopModel.fromXML(child, old: item);
            model.addHop(newModel);
            break;
          }
        }
        if (!found) {
          hm.HopModel newModel = hm.HopModel.fromXML(child);
          await Database().add(newModel, ignoreAuth: currentUser!.isAdmin());
          model.addHop(newModel);
          hops.add(newModel);
        }
      }
    }
  }

  static yeastsBeerXML(XmlElement element, rm.RecipeModel model) async {
    var children = element.findAllElements('YEAST');
    if (children.isNotEmpty) {
      List<ym.YeastModel> yeasts = await Database().getYeasts(user: currentUser!.uuid);
      for (XmlElement child in children) {
        bool found = false;
        ym.Yeast? form = ym.YeastModel.getFormByName(child.getElement(hm.XML_ELEMENT_FORM)!.innerText);
        for(ym.YeastModel item in yeasts) {
          if (item.hasName(child.getElement(hm.XML_ELEMENT_NAME)!.innerText, ['yeast']) && item.form == form) {
            found = true;
            ym.YeastModel newModel = ym.YeastModel.fromXML(child, old: item);
            model.addYeast(newModel);
            break;
          }
        }
        if (!found) {
          ym.YeastModel newModel = ym.YeastModel.fromXML(child);
          await Database().add(newModel, ignoreAuth: currentUser!.isAdmin());
          model.addYeast(newModel);
          yeasts.add(newModel);
        }
      }
    }
  }

  static miscBeerXML(XmlElement element, rm.RecipeModel model) async {
    var children = element.findAllElements('MISC');
    if (children.isNotEmpty) {
      List<mm.MiscModel> miscs = await Database().getMiscellaneous(user: currentUser!.uuid);
      for (XmlElement child in children) {
        bool found = false;
        mm.Misc? form = mm.MiscModel.getFormByName(child.getElement(hm.XML_ELEMENT_FORM)!.innerText);
        for(mm.MiscModel item in miscs) {
          if (item.hasName(child.getElement(hm.XML_ELEMENT_NAME)!.innerText, ['misc']) && item.type == form) {
            found = true;
            mm.MiscModel newModel = mm.MiscModel.fromXML(child, old: item);
            model.addMisc(newModel);
            break;
          }
        }
        if (!found) {
          mm.MiscModel newModel = mm.MiscModel.fromXML(child);
          await Database().add(newModel, ignoreAuth: currentUser!.isAdmin());
          model.addMisc(newModel);
          miscs.add(newModel);
        }
      }
    }
  }

  static mashBeerXML(XmlElement element, rm.RecipeModel model) {
    var children = element.findAllElements('MASH_STEP');
    if (children.isNotEmpty) {
      List<mash.Mash> list = [];
      for (XmlElement child in children) {
        list.add(mash.Mash(
          name: child.getElement(mash.XML_ELEMENT_NAME)!.innerText,
          duration: int.tryParse(child.getElement(mash.XML_ELEMENT_STEP_TIME)!.innerText),
          temperature: double.tryParse(child.getElement(mash.XML_ELEMENT_STEP_TEMP)!.innerText)
        ));
      }
      if (list.isNotEmpty) {
        model.mash = list;
      }
    }
  }

  static styles(BuildContext context, Function() onImported) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result != null) {
        try {
          EasyLoading.show(status: AppLocalizations.of(context)!.text('work_in_progress'));
          List<dynamic> list;
          if (DeviceHelper.isDesktop) {
            list = json.decode(utf8.decode(result.files.single.bytes!));
          } else {
            File file = File(result.files.single.path!);
            list = json.decode(file.readAsStringSync());
          }
          for(dynamic item in list) {
            final Map map = Map.from(item);
            final model = sm.StyleModel(
              name: LocalizedText(map: { 'en': map['name']}),
              number: map['number'],
              category: LocalizedText(map: { 'en': map['category']}),
              overallimpression: LocalizedText(map: { 'en': map['overallimpression']}),
              aroma: LocalizedText(map: { 'en': map['aroma']}),
              appareance: LocalizedText(map: { 'en': map['appareance']}),
              flavor: LocalizedText(map: { 'en': map['flavor']}),
              mouthfeel: LocalizedText(map: { 'en': map['mouthfeel']}),
              comments: LocalizedText(map: { 'en': map['comments']}),
            );
            if (map['ogmin'] != null) model.ogmin = double.tryParse(map['ogmin']);
            if (map['ogmax'] != null) model.ogmax = double.tryParse(map['ogmax']);
            if (map['fgmin'] != null) model.fgmin = double.tryParse(map['fgmin']);
            if (map['fgmax'] != null) model.fgmax = double.tryParse(map['fgmax']);
            if (map['abvmin'] != null) model.abvmin = double.tryParse(map['abvmin']);
            if (map['abvmax'] != null) model.abvmax = double.tryParse(map['abvmax']);
            if (map['ibumin'] != null) model.ibumin = double.tryParse(map['ibumin']);
            if (map['ibumax'] != null) model.ibumax = double.tryParse(map['ibumax']);
            if (map['srmmin'] != null) model.ebcmin = ColorHelper.toEBC(int.tryParse(map['srmmin']));
            if (map['srmmax'] != null) model.ebcmax = ColorHelper.toEBC(int.tryParse(map['srmmax']));
            List<sm.StyleModel> list = await Database().getStyles(number: model.number);
            if (list.isEmpty) {
              Database().add(model, ignoreAuth: true);
            } else {
              if (list.length == 1) {
                // list.first.mouthfeel.add(const Locale('en', 'US'), model.mouthfeel.get(const Locale('en', 'US')));
                // list.first.comments.add(const Locale('en', 'US'), model.comments.get(const Locale('en', 'US')));
                // Database().update(list.first, updateAll: false);
              }
            }
          }
          onImported.call();
        } finally {
          EasyLoading.dismiss();
        }
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Unsupported operation $e"),
            duration: const Duration(seconds: 10)
        )
      );
    } catch (ex) {
      debugPrint(ex.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(ex.toString()),
            duration: const Duration(seconds: 10)
        )
      );
    }
  }

  static fermentables(BuildContext context, Function() onImported) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xml'],
      );
      if (result != null) {
        try {
          EasyLoading.show(status: AppLocalizations.of(context)!.text('work_in_progress'));

          final XmlDocument? document;
          if(DeviceHelper.isDesktop) {
            document = XmlDocument.parse(utf8.decode(result.files.single.bytes!));
          } else {
            File file = File(result.files.single.path!);
            document = XmlDocument.parse(file.readAsStringSync());
          }
          final elements = document.findAllElements('Grain');
          for (XmlElement element in elements) {
            final model = fm.FermentableModel(
                name: LocalizedText(map: { 'en': element.getElement('F_G_NAME')!.innerText}),
                origin: LocalizedText.country(element.getElement('F_G_ORIGIN')!.innerText),
                efficiency: double.tryParse(element.getElement('F_G_YIELD')!.innerText)
            );
            final color = element.getElement('F_G_COLOR');
            if (color != null && color.innerText.isNotEmpty) {
              model.ebc = ColorHelper.toEBC(double.tryParse(color.innerText)!.toInt());
            }
            final desc = element.getElement('F_G_NOTES');
            if (desc != null && desc.innerText.isNotEmpty) {
              String text = desc.innerText.replaceAll(RegExp(r'\n'), '');
              text = desc.innerText.replaceAll(RegExp(r'\r'), '');
              text = desc.innerText.replaceAll('  ', '');
              model.notes = LocalizedText(map: { 'en': text.trim()});
            }
            int type = int.parse(element.getElement('F_G_TYPE')!.innerText);
            switch (type) {
              case 0:
                model.type = fm.Type.grain;
                break;
              case 1:
                model.type = fm.Type.extract;
                break;
              case 2:
                model.type = fm.Type.sugar;
                break;
              case 3:
                model.type = fm.Type.adjunct;
                break;
              case 4:
                model.type = fm.Type.dry_extract;
                break;
              case 5:
                model.type = fm.Type.fruit;
                break;
              case 6:
                model.type = fm.Type.juice;
                break;
              case 7:
                model.type = fm.Type.honey;
                break;
            }
            List<fm.FermentableModel> list = await Database().getFermentables(name: model.name.toString());
            if (list.isEmpty) {
              Database().add(model, ignoreAuth: true);
            }
          }
          onImported.call();
        } finally {
          EasyLoading.dismiss();
        }
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Unsupported operation $e"),
            duration: const Duration(seconds: 10)
        )
      );
    } catch (ex) {
      debugPrint(ex.toString());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(ex.toString()),
              duration: const Duration(seconds: 10)
          )
      );
    }
  }

  static hops(BuildContext context, Function() onImported) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xml'],
      );
      if (result != null) {
        try {
          EasyLoading.show(status: AppLocalizations.of(context)!.text('work_in_progress'));

          final XmlDocument document;
          if(DeviceHelper.isDesktop) {
            document = XmlDocument.parse(utf8.decode(result.files.single.bytes!));
          } else {
            File file = File(result.files.single.path!);
            document = XmlDocument.parse(file.readAsStringSync());
          }
          final elements = document.findAllElements('Hops');
          for(XmlElement element in elements) {
            final model = hm.HopModel(
              name: LocalizedText( map: { 'en': element.getElement('F_H_NAME')!.innerText}),
              alpha: double.tryParse(element.getElement('F_H_ALPHA')!.innerText),
              beta: double.tryParse(element.getElement('F_H_BETA')!.innerText),
              origin: LocalizedText.country(element.getElement('F_H_ORIGIN')!.innerText),
            );
            final desc = element.getElement('F_H_NOTES');
            if (desc != null && desc.innerText.isNotEmpty) {
              String text = desc.innerText.replaceAll(RegExp(r'\n'), '');
              text = desc.innerText.replaceAll(RegExp(r'\r'), '');
              text = desc.innerText.replaceAll('  ', '');
              model.notes = LocalizedText(map: { 'en': text.trim()});
            }
            int form = int.parse(element.getElement('F_H_FORM')!.innerText);
            switch (form) {
              case 2:
                model.form = hm.Hop.leaf;
                break;
              case 0:
                model.form = hm.Hop.pellet;
                break;
              case 1:
                model.form = hm.Hop.plug;
                break;
              default:
                model.form = hm.Hop.other;
                break;
            }
            int type = int.parse(element.getElement('F_H_TYPE')!.innerText);
            switch (type) {
              case 1:
                model.type = hm.Type.aroma;
                break;
              case 0:
                model.type = hm.Type.bittering;
                break;
              case 2:
                model.type = hm.Type.both;
                break;
            }
            List<hm.HopModel> list = await Database().getHops(name: model.name.toString());
            if (list.isEmpty) {
              Database().add(model, ignoreAuth: true);
            }
          }
          onImported.call();
        } finally {
          EasyLoading.dismiss();
        }
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Unsupported operation$e"),
              duration: const Duration(seconds: 10)
          )
      );
    } catch (ex) {
      debugPrint(ex.toString());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(ex.toString()),
              duration: const Duration(seconds: 10)
          )
      );
    }
  }

  static yeasts(BuildContext context, Function() onImported) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xml'],
      );
      if (result != null) {
        try {
          EasyLoading.show(status: AppLocalizations.of(context)!.text('work_in_progress'));

          final XmlDocument document;
          if(DeviceHelper.isDesktop) {
            document = XmlDocument.parse(utf8.decode(result.files.single.bytes!));
          } else {
            File file = File(result.files.single.path!);
            document = XmlDocument.parse(file.readAsStringSync());
          }
          final elements = document.findAllElements('Yeast');
          for(XmlElement element in elements) {
            final model = ym.YeastModel(
                name: LocalizedText( map: { 'en': element.getElement('F_Y_NAME')!.innerText}),
                product: element.getElement('F_Y_PRODUCT_ID')!.innerText,
                laboratory: element.getElement('F_Y_LAB')!.innerText,
                cells: double.tryParse(element.getElement('F_Y_CELLS')!.innerText),
                attmin: double.tryParse(element.getElement('F_Y_MIN_ATTENUATION')!.innerText),
                attmax: double.tryParse(element.getElement('F_Y_MAX_ATTENUATION')!.innerText),
                tempmin: FormulaHelper.convertFarenheitToCelcius(double.tryParse(element.getElement('F_Y_MIN_TEMP')!.innerText)),
                tempmax: FormulaHelper.convertFarenheitToCelcius(double.tryParse(element.getElement('F_Y_MAX_TEMP')!.innerText))
            );
            final desc = element.getElement('F_Y_NOTES');
            if (desc != null && desc.innerText.isNotEmpty) {
              String text = desc.innerText.replaceAll(RegExp(r'\n'), '');
              text = desc.innerText.replaceAll(RegExp(r'\r'), '');
              text = desc.innerText.replaceAll('  ', '');
              model.notes = LocalizedText(map: { 'en': text.trim()});
            }
            int form = int.parse(element.getElement('F_Y_FORM')!.innerText);
            switch (form) {
              case 0:
                model.form = ym.Yeast.liquid;
                break;
              case 1:
                model.form = ym.Yeast.dry;
                break;
              case 2:
                model.form = ym.Yeast.slant;
                break;
              case 3:
                model.form = ym.Yeast.culture;
                break;
            }
            int type = int.parse(element.getElement('F_Y_TYPE')!.innerText);
            switch (type) {
              case 0:
                model.type = Style.hight;
                break;
              case 1:
                model.type = Style.low;
                break;
              case 4:
                model.type = Style.spontaneous;
                break;
            }
            if (type != 2 && type != 3) {
              List<ym.YeastModel> list = await Database().getYeasts(name: model.name.toString(), reference: model.product, laboratory: model.laboratory);
              if (list.isEmpty) {
                Database().add(model, ignoreAuth: true);
              }
            }
          }
          onImported.call();
        } finally {
          EasyLoading.dismiss();
        }
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Unsupported operation $e"),
              duration: const Duration(seconds: 10)
          )
      );
    } catch (ex) {
      debugPrint(ex.toString());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(ex.toString()),
              duration: const Duration(seconds: 10)
          )
      );
    }
  }

  static miscellaneous(BuildContext context, Function() onImported) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xml'],
      );
      if (result != null) {
        try {
          EasyLoading.show(status: AppLocalizations.of(context)!.text('work_in_progress'));

          final XmlDocument document;
          if(DeviceHelper.isDesktop) {
            document = XmlDocument.parse(utf8.decode(result.files.single.bytes!));
          } else {
            File file = File(result.files.single.path!);
            document = XmlDocument.parse(file.readAsStringSync());
          }
          final elements = document.findAllElements('Misc');
          for(XmlElement element in elements) {
            final model = mm.MiscModel(
                name: LocalizedText( map: { 'en': element.getElement('F_M_NAME')!.innerText})
            );
            int? time = int.tryParse(element.getElement('F_M_TIME')!.innerText);
            if (time != null) {
              model.duration = time;
            }
            final desc = element.getElement('F_M_NOTES');
            if (desc != null && desc.innerText.isNotEmpty) {
              String text = desc.innerText.replaceAll(RegExp(r'\n'), '');
              text = desc.innerText.replaceAll(RegExp(r'\r'), '');
              text = desc.innerText.replaceAll('  ', '');
              model.notes = LocalizedText(map: { 'en': text.trim()});
            }
            int type = int.parse(element.getElement('F_M_TYPE')!.innerText);
            switch (type) {
              case 0:
                model.type = mm.Misc.spice;
                break;
              case 1:
                model.type = mm.Misc.fining;
                break;
              case 2:
                model.type = mm.Misc.herb;
                break;
              case 3:
                model.type = mm.Misc.flavor;
                break;
              case 4:
                model.type = mm.Misc.other;
                break;
              case 5:
                model.type = mm.Misc.water_agent;
                break;
            }
            int use = int.parse(element.getElement('F_M_USE')!.innerText);
            switch (use) {
              case 0:
                model.use = mm.Use.boil;
                break;
              case 1:
                model.use = mm.Use.mash;
                break;
              case 2:
                model.use = mm.Use.primary;
                break;
              case 3:
                model.use = mm.Use.secondary;
                break;
              case 4:
                model.use = mm.Use.bottling;
                break;
              case 5:
                model.use = mm.Use.sparge;
                break;
            }
            List<mm.MiscModel> list = await Database().getMiscellaneous(name: model.name.toString());
            if (list.isEmpty) {
              Database().add(model, ignoreAuth: true);
            }
          }
          onImported.call();
        } finally {
          EasyLoading.dismiss();
        }
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Unsupported operation $e"),
              duration: const Duration(seconds: 10)
          )
      );
    } catch (ex) {
      debugPrint(ex.toString());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(ex.toString()),
              duration: const Duration(seconds: 10)
          )
      );
    }
  }
}