// Internal package
import 'package:bab/models/event_model.dart';
import 'package:bab/models/image_model.dart';
import 'package:bab/models/recipe_model.dart';
import 'package:bab/models/style_model.dart';
import 'package:bab/helpers/class_helper.dart';
import 'package:bab/utils/database.dart';

class ModelHelper {
  /// Obtient tous les modèles
  static Future<List<dynamic>> all() async {
    List list = [];
    List<EventModel> events = await Database().getEvents(all: true);
    for(EventModel model in events) {
      list.add(model);
    }
    List<RecipeModel> recipes = await Database().getRecipes(all: true);
    for(RecipeModel model in recipes) {
      list.add(model);
    }
    List<StyleModel> articles = await Database().getStyles();
    for(StyleModel model in articles) {
      list.add(model);
    }
    return list;
  }

  /// Obtient tous les modèles utilisant l'url de l'image
  static Future<List<dynamic>> models(String url) async {
    List list = [];
    List<dynamic> models = await ModelHelper.all();
    for(dynamic model in models) {
      if (ClassHelper.hasImage(model)) {
        if (model.image != null && equals(url, model.image!.url))  {
          list.add(model);
        }
      } else if (ClassHelper.hasImages(model)) {
        for(ImageModel image in model.model!) {
          if (equals(url, image.url!))  {
            list.add(model);
            break;
          }
        }
      }
    }
    return list;
  }

  static bool equals(String url1, String url2) {
    Uri uri1 = Uri.parse(url1);
    Uri uri2 = Uri.parse(url2);
    return uri1.path == uri2.path;
  }
}
