import 'dart:convert';
import 'dart:io';

// Internal package
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/helpers/formula_helper.dart';
import 'package:bb/models/fermentable_model.dart' as fermentable;
import 'package:bb/models/hop_model.dart' as hop;
import 'package:bb/models/misc_model.dart' as misc;
import 'package:bb/models/style_model.dart';
import 'package:bb/models/yeast_model.dart' as yeast;
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/helpers/color_helper.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/localized_text.dart';
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
            final model = fermentable.FermentableModel(
                name: LocalizedText(map: { 'en': element.getElement('F_G_NAME')!.text}),
                origin: LocalizedText.country(element.getElement('F_G_ORIGIN')!.text),
                efficiency: double.tryParse(element.getElement('F_G_YIELD')!.text)
            );
            final color = element.getElement('F_G_COLOR');
            if (color != null && color.text.isNotEmpty) {
              model.ebc = ColorHelper.toEBC(double.tryParse(color.text)!.toInt());
            }
            final desc = element.getElement('F_G_NOTES');
            if (desc != null && desc.text.isNotEmpty) {
              String text = desc.text.replaceAll(RegExp(r'\n'), '');
              text = desc.text.replaceAll(RegExp(r'\r'), '');
              text = desc.text.replaceAll('  ', '');
              model.notes = LocalizedText(map: { 'en': text.trim()});
            }
            int type = int.parse(element.getElement('F_G_TYPE')!.text);
            switch (type) {
              case 0:
                model.type = fermentable.Type.grain;
                break;
              case 1:
                model.type = fermentable.Type.extract;
                break;
              case 2:
                model.type = fermentable.Type.sugar;
                break;
              case 3:
                model.type = fermentable.Type.adjunct;
                break;
              case 4:
                model.type = fermentable.Type.dry_extract;
                break;
              case 5:
                model.type = fermentable.Type.fruit;
                break;
              case 6:
                model.type = fermentable.Type.juice;
                break;
              case 7:
                model.type = fermentable.Type.honey;
                break;
            }
            List<fermentable.FermentableModel> list = await Database().getFermentables(name: model.name.toString());
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
            final model = hop.HopModel(
              name: LocalizedText( map: { 'en': element.getElement('F_H_NAME')!.text}),
              alpha: double.tryParse(element.getElement('F_H_ALPHA')!.text),
              beta: double.tryParse(element.getElement('F_H_BETA')!.text),
              origin: LocalizedText.country(element.getElement('F_H_ORIGIN')!.text),
            );
            final desc = element.getElement('F_H_NOTES');
            if (desc != null && desc.text.isNotEmpty) {
              String text = desc.text.replaceAll(RegExp(r'\n'), '');
              text = desc.text.replaceAll(RegExp(r'\r'), '');
              text = desc.text.replaceAll('  ', '');
              model.notes = LocalizedText(map: { 'en': text.trim()});
            }
            int form = int.parse(element.getElement('F_H_FORM')!.text);
            switch (form) {
              case 2:
                model.form = hop.Hop.leaf;
                break;
              case 0:
                model.form = hop.Hop.pellet;
                break;
              case 1:
                model.form = hop.Hop.plug;
                break;
              default:
                model.form = hop.Hop.other;
                break;
            }
            int type = int.parse(element.getElement('F_H_TYPE')!.text);
            switch (type) {
              case 1:
                model.type = hop.Type.aroma;
                break;
              case 0:
                model.type = hop.Type.bittering;
                break;
              case 2:
                model.type = hop.Type.both;
                break;
            }
            List<hop.HopModel> list = await Database().getHops(name: model.name.toString());
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
            final model = yeast.YeastModel(
                name: LocalizedText( map: { 'en': element.getElement('F_Y_NAME')!.text}),
                reference: element.getElement('F_Y_PRODUCT_ID')!.text,
                laboratory: element.getElement('F_Y_LAB')!.text,
                cells: double.tryParse(element.getElement('F_Y_CELLS')!.text),
                attmin: double.tryParse(element.getElement('F_Y_MIN_ATTENUATION')!.text),
                attmax: double.tryParse(element.getElement('F_Y_MAX_ATTENUATION')!.text),
                tempmin: FormulaHelper.convertFarenheitToCelcius(double.tryParse(element.getElement('F_Y_MIN_TEMP')!.text)),
                tempmax: FormulaHelper.convertFarenheitToCelcius(double.tryParse(element.getElement('F_Y_MAX_TEMP')!.text))
            );
            final desc = element.getElement('F_Y_NOTES');
            if (desc != null && desc.text.isNotEmpty) {
              String text = desc.text.replaceAll(RegExp(r'\n'), '');
              text = desc.text.replaceAll(RegExp(r'\r'), '');
              text = desc.text.replaceAll('  ', '');
              model.notes = LocalizedText(map: { 'en': text.trim()});
            }
            int form = int.parse(element.getElement('F_Y_FORM')!.text);
            switch (form) {
              case 0:
                model.form = yeast.Yeast.liquid;
                break;
              case 1:
                model.form = yeast.Yeast.dry;
                break;
              case 2:
                model.form = yeast.Yeast.slant;
                break;
              case 3:
                model.form = yeast.Yeast.culture;
                break;
            }
            int type = int.parse(element.getElement('F_Y_TYPE')!.text);
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
              List<yeast.YeastModel> list = await Database().getYeasts(name: model.name.toString(), reference: model.reference, laboratory: model.laboratory);
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
            final model = misc.MiscModel(
                name: LocalizedText( map: { 'en': element.getElement('F_M_NAME')!.text})
            );
            int? time = int.tryParse(element.getElement('F_M_TIME')!.text);
            if (time != null) {
              model.duration = time;
            }
            final desc = element.getElement('F_M_NOTES');
            if (desc != null && desc.text.isNotEmpty) {
              String text = desc.text.replaceAll(RegExp(r'\n'), '');
              text = desc.text.replaceAll(RegExp(r'\r'), '');
              text = desc.text.replaceAll('  ', '');
              model.notes = LocalizedText(map: { 'en': text.trim()});
            }
            int type = int.parse(element.getElement('F_M_TYPE')!.text);
            switch (type) {
              case 0:
                model.type = misc.Misc.spice;
                break;
              case 1:
                model.type = misc.Misc.fining;
                break;
              case 2:
                model.type = misc.Misc.herb;
                break;
              case 3:
                model.type = misc.Misc.flavor;
                break;
              case 4:
                model.type = misc.Misc.other;
                break;
              case 5:
                model.type = misc.Misc.water_agent;
                break;
            }
            int use = int.parse(element.getElement('F_M_USE')!.text);
            switch (use) {
              case 0:
                model.use = misc.Use.boil;
                break;
              case 1:
                model.use = misc.Use.mash;
                break;
              case 2:
                model.use = misc.Use.primary;
                break;
              case 3:
                model.use = misc.Use.secondary;
                break;
              case 4:
                model.use = misc.Use.bottling;
                break;
              case 5:
                model.use = misc.Use.sparge;
                break;
            }
            List<misc.MiscModel> list = await Database().getMiscellaneous(name: model.name.toString());
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