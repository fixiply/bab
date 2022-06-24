import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/widgets.dart';

// Internal package
import 'package:bb/helpers/model_helper.dart';
import 'package:bb/models/image_model.dart';
import 'package:bb/utils/class_helper.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';

// External package
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as ImageLib;
import 'package:image_picker/image_picker.dart';

class Storage {
  static final storage = FirebaseStorage.instance;

  Future<List<String>> getPaths() async {
    List<String> values = [];
    ListResult result = await storage.ref('images').listAll();
    await Future.forEach(result.prefixes, (Reference ref) async {
      values.add(ref.name);
    });
    return values;
  }

  Future<void> addPath(String path) async {
    await storage.ref('images/$path/.ghostfile').putString('');
  }

  Future<bool> deletePath(String path) async {
    Reference ref = storage.ref('images/$path');
    ListResult result = await ref.listAll();
    if (result.items.length > 1) {
      return false;
    }
    await storage.ref('images/$path/.ghostfile').delete();
    return true;
  }

  Future<List<ImageModel>> getImages(String? path, {String? searchText, ListOptions? options}) async {
    List<ImageModel> values = [];
    try {
      ListResult result = await storage.ref('images/$path').list(options);
      await Future.forEach(result.items, (Reference ref) async {
        bool canBeAdded = ref.name.toLowerCase() != '.ghostfile';
        if (searchText != null && searchText.length > 0) {
          if (!ref.name.toLowerCase().contains(searchText.toLowerCase())) {
            canBeAdded = false;
          }
        }
        if (canBeAdded) {
          ImageModel model = ImageModel(null, name: ref.name, reference: ref);
          values.add(model);
        }
      });
    }
    catch (e, s) {
      debugPrint(s.toString());
      print('[$APP_NAME] Images ERROR: $e');
    }
    return values;
  }

  Future<Reference> refFromURL(String url) async {
    return storage.refFromURL(url);
  }

  Future<ImageModel> fromURL(String url) async {
    Reference ref = await refFromURL(url);
    return ImageModel(url, name: ref.name, reference: ref);
  }

  Future<String?> getUrl(Reference ref) async {
    try {
     return await ref.getDownloadURL();
    }
    catch(e) {
      return null;
    }
  }

  Future<bool> upload(String? path, XFile file) async {
    try {
      String name = file.name;
      if (name.startsWith('scaled_')) {
        name = name.split('scaled_').last;
      }
      final metadata = SettableMetadata(
          contentType: file.mimeType,
          customMetadata: {'picked-file-path': file.path}
      );
      if (Foundation.kIsWeb) {
        ImageLib.Image? image = ImageLib.decodeImage(await file.readAsBytes());
        if (image!.width > 640) {
          image = ImageLib.copyResize(image, width: 640);
        }
        List<int> data = ImageLib.encodeJpg(image, quality: 80);
        await storage.ref('images/$path/${name}').putData(Uint8List.fromList(data), metadata);
      } else {
        await storage.ref('images/$path/${name}').putFile(File(file.path), metadata);
      }
      return true;
    }
    catch (e, s) {
      debugPrint(s.toString());
      print('[$APP_NAME] Upload ERROR: $e');
      return false;
    }
  }

  Future<int> remove(String url, {bool forced = false}) async {
    if (forced == false) {
      List used = await ModelHelper.models(url);
      if (used.length > 0) {
        return used.length;
      }
    }
    try {
      await storage.refFromURL(url).delete();
      return 0;
    }
    catch (e, s) {
      debugPrint(s.toString());
      print('[$APP_NAME] Delete ERROR: $e');
      return 0;
    }
  }

  /// Déplacer l'image dans le "path" indiqué
  Future<bool> move(ImageModel image, String? path) async {
    try {
      Reference? ref = image.reference;
      if (ref != null) {
        FullMetadata metadata = await ref.getMetadata();
        SettableMetadata settable = SettableMetadata(
          contentType: metadata.contentType,
          customMetadata: metadata.customMetadata
        );
        Uint8List? data = await ref.getData();
        await storage.ref('images/$path/${ref.name}').putData(data!, settable).then((TaskSnapshot value) async {
          String newUrl = await value.ref.getDownloadURL();
          await replace(image.url!, newUrl);
          await remove(image.url!);
          return true;
        });
      }
    }
    catch (e, s) {
      debugPrint(s.toString());
      print('[$APP_NAME] Delete ERROR: $e');
      return false;
    }
    return false;
  }

  /// Renommer une image
  Future rename(ImageModel image, {String split = 'scaled_'}) async {
    String? name = image.name;
    if (name != null && name.startsWith(split)) {
      name = name.split(split).last;
      Reference? ref = image.reference;
      if (ref != null) {
        FullMetadata metadata = await ref.getMetadata();
        SettableMetadata settable = SettableMetadata(
            contentType: metadata.contentType,
            customMetadata: metadata.customMetadata
        );
        Uint8List? data = await ref.getData();
        await storage.ref('images/${name}').putData(data!, settable).then((TaskSnapshot value) async {
          String newUrl = await value.ref.getDownloadURL();
          await replace(image.url!, newUrl);
          await remove(image.url!);
          return true;
        });
      }
    }
  }

  /// Remplace dans tous les modèles l'url de l'image
  Future replace(String fromUrl, String toUrl) async {
    ImageModel newImage = ImageModel(toUrl);
    List<dynamic> models = await ModelHelper.models(fromUrl);
    for(dynamic model in models) {
      if (ClassHelper.hasImage(model)) {
        if (model.image != null && ModelHelper.equals(fromUrl, model.image!.url))  {
          model.image = newImage;
          await Database().update(model, updateAll: false);
        }
      } else if (ClassHelper.hasImages(model)) {
        bool found = false;
        for(ImageModel image in model.images!) {
          if (ModelHelper.equals(fromUrl, image.url!))  {
            image.url = toUrl;
            found = true;
            break;
          }
        }
        if (found) {
          await Database().update(model, updateAll: false);
        }
      }
    }
  }

  Future migrate() async {
    try {
      List<dynamic> models = await ModelHelper.all();
      for(dynamic model in models) {
        bool changed = false;
        if (ClassHelper.hasImage(model)) {
          if (model.image != null)  {
            Reference ref = await refFromURL(model.image!.url);
            String? newUrl = await broken(ref);
            if (newUrl != null) {
              model.image!.url = newUrl;
              changed = true;
            }
          }
        } else if (ClassHelper.hasImages(model)) {
          for(ImageModel image in model.images!) {
            Reference ref = await Storage().refFromURL(image.url!);
            String? newUrl = await broken(ref);
            if (newUrl != null) {
              image.url = newUrl;
              changed = true;
            }
          }
        }
        if (changed) {
          try {
            await Database().update(model, updateAll: false);
          }
          catch(e) {
            print('[$APP_NAME] Update ERROR: $e');
          }
        }
      }
    }
    catch (e, s) {
      debugPrint(s.toString());
      print('[$APP_NAME] Image ERROR: $e');
    }
  }

  Future<String?> broken(Reference ref) async {
    if (ref.bucket == BUCKET) {
      return null;
    }
    try {
      String path = ref.fullPath;
      if (path.startsWith('images/')) {
        path.replaceFirst('images/', 'pictures/');
      }
      Reference? newRef = await storage.ref('images').child(path);
      if (newRef != null) {
        return await newRef.getDownloadURL();
      }
    }
    catch(e) {
      print('[$APP_NAME] Image ${ref.bucket} \'${ref.fullPath}\' ERROR: $e');
    }
    return null;
  }

  /// Obtient tous les url's des images non utilisés
  Future<List<ImageModel>> unused(String? path) async {
    List<ImageModel> list = [];
    List<dynamic> models = await ModelHelper.all();
    try {
      ListResult result = await storage.ref('images/$path').listAll();
      await Future.forEach(result.items, (Reference ref) async {
        bool found = false;
        String url = await ref.getDownloadURL();
        for(dynamic model in models) {
          if (ClassHelper.hasImage(model)) {
            if (model.image != null && ModelHelper.equals(url, model.image!.url))  {
              found = true;
              break;
            }
          } else if (ClassHelper.hasImages(model)) {
            for(ImageModel image in model.images!) {
              if (ModelHelper.equals(url, image.url!))  {
                found = true;
                break;
              }
            }
          }
        }
        if (!found) {
          ImageModel model = ImageModel(url, name: ref.name, reference: ref);
          list.add(model);
        }
      });
    }
    catch (e, s) {
      debugPrint(s.toString());
    }
    return list;
  }
}
