import 'dart:convert';
import 'dart:io';

// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/helpers/formula_helper.dart';
import 'package:bab/models/fermentable_model.dart' as fm;
import 'package:bab/models/hop_model.dart' as hm;
import 'package:bab/models/misc_model.dart' as mm;
import 'package:bab/models/style_model.dart';
import 'package:bab/models/yeast_model.dart' as ym;
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/helpers/color_helper.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/utils/localized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// External package
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:xml/xml.dart';

class ImportHelper {
  static styles(BuildContext context, Function() onImported) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result != null) {
        try {
          EasyLoading.show(status: AppLocalizations.of(context)!.text('in_progress'));
          List<dynamic> list;
          if (DeviceHelper.isDesktop) {
            list = json.decode(utf8.decode(result.files.single.bytes!));
          } else {
            File file = File(result.files.single.path!);
            list = json.decode(file.readAsStringSync());
          }
          for(dynamic item in list) {
            final Map map = Map.from(item);
            final model = StyleModel(
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
            List<StyleModel> list = await Database().getStyles(number: model.number);
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
          EasyLoading.show(status: AppLocalizations.of(context)!.text('in_progress'));

          final XmlDocument? document;
          if(DeviceHelper.isDesktop) {
            document = XmlDocument.parse(utf8.decode(result.files.single.bytes!));
          } else {
            File file = File(result.files.single.path!);
            document = XmlDocument.parse(file.readAsStringSync());
          }
          final fermentables = document.findAllElements('Grain');
          for (XmlElement element in fermentables) {
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
          EasyLoading.show(status: AppLocalizations.of(context)!.text('in_progress'));

          final XmlDocument document;
          if(DeviceHelper.isDesktop) {
            document = XmlDocument.parse(utf8.decode(result.files.single.bytes!));
          } else {
            File file = File(result.files.single.path!);
            document = XmlDocument.parse(file.readAsStringSync());
          }
          final hops = document.findAllElements('Hops');
          for(XmlElement element in hops) {
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
          EasyLoading.show(status: AppLocalizations.of(context)!.text('in_progress'));

          final XmlDocument document;
          if(DeviceHelper.isDesktop) {
            document = XmlDocument.parse(utf8.decode(result.files.single.bytes!));
          } else {
            File file = File(result.files.single.path!);
            document = XmlDocument.parse(file.readAsStringSync());
          }
          final fermentables = document.findAllElements('Yeast');
          for(XmlElement element in fermentables) {
            final model = ym.YeastModel(
                name: LocalizedText( map: { 'en': element.getElement('F_Y_NAME')!.innerText}),
                reference: element.getElement('F_Y_PRODUCT_ID')!.innerText,
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
                model.type = Fermentation.hight;
                break;
              case 1:
                model.type = Fermentation.low;
                break;
              case 4:
                model.type = Fermentation.spontaneous;
                break;
            }
            if (type != 2 && type != 3) {
              List<ym.YeastModel> list = await Database().getYeasts(name: model.name.toString(), reference: model.reference, laboratory: model.laboratory);
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
          EasyLoading.show(status: AppLocalizations.of(context)!.text('in_progress'));

          final XmlDocument document;
          if(DeviceHelper.isDesktop) {
            document = XmlDocument.parse(utf8.decode(result.files.single.bytes!));
          } else {
            File file = File(result.files.single.path!);
            document = XmlDocument.parse(file.readAsStringSync());
          }
          final fermentables = document.findAllElements('Misc');
          for(XmlElement element in fermentables) {
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