import 'dart:async';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/helpers/image_helper.dart';
import 'package:bab/helpers/model_helper.dart';
import 'package:bab/models/image_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/storage.dart';
import 'package:bab/widgets/custom_state.dart';
import 'package:bab/widgets/containers/empty_container.dart';
import 'package:bab/widgets/containers/error_container.dart';
import 'package:bab/widgets/dialogs/confirm_dialog.dart';
import 'package:bab/widgets/dialogs/delete_dialog.dart';
import 'package:bab/widgets/dialogs/dropdown_dialog.dart';
import 'package:bab/widgets/dialogs/text_input_dialog.dart';

// External package
import 'package:extended_image/extended_image.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';

class GalleryPage extends StatefulWidget {
  final List<ImageModel> images;
  final bool only;
  final bool close;
  GalleryPage(this.images, {this.only = false, this.close = true});

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class AppBarParams {
  final Widget? leading;
  final Widget? title;

  AppBarParams({
    this.leading,
    this.title,
  });
}

class _GalleryPageState extends CustomState<GalleryPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<GalleryPage> {
  String _path = 'pictures';
  AppBarParams? _appBar;
  List<ImageModel> _selected = [];
  final _picker = ImagePicker();
  final TextEditingController _searchQueryController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController? _controller;
  Future<List<ImageModel>>? _images;
  Sort _sort = Sort.asc_name;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _selected = widget.images;
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0.0,
        leading: _appBar != null ? _appBar!.leading : null,
        title: _appBar != null ? _appBar!.title : Text(toBeginningOfSentenceCase(_path)!),
        actions: [
          if (widget.close == true) IconButton(
            icon: const Icon(Icons.close),
            tooltip: AppLocalizations.of(context)!.text('close'),
            onPressed:() async {
              Navigator.pop(context, widget.only ? (_selected.isNotEmpty ? _selected.first : null) : _selected);
            }
          ),
          IconButton(
            padding: EdgeInsets.zero,
            tooltip: AppLocalizations.of(context)!.text('search'),
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _appBar = AppBarParams(
                  leading: IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed:() async {
                      setState(() {
                        _appBar = null;
                        _searchQueryController.clear();
                        _fetch();
                      });
                    }
                  ),
                  title: _buildSearchField(),
                );
              });
            }
          ),
          PopupMenuButton(
            padding: EdgeInsets.zero,
            tooltip: AppLocalizations.of(context)!.text('sort'),
            icon: const Icon(Icons.sort),
            onSelected: (Sort value) async {
              setState(() {
                _sort = value;
                _images = sortFutures(_images!, value);
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Sort>>[
              CheckedPopupMenuItem(
                child: Text(AppLocalizations.of(context)!.text('asc_date')),
                value: Sort.asc_date,
                checked: _sort == Sort.asc_date,
              ),
              CheckedPopupMenuItem(
                child: Text(AppLocalizations.of(context)!.text('desc_date')),
                value: Sort.desc_date,
                checked: _sort == Sort.desc_date,
              ),
              CheckedPopupMenuItem(
                child: Text(AppLocalizations.of(context)!.text('asc_name')),
                value: Sort.asc_name,
                checked: _sort == Sort.asc_name,
              ),
              CheckedPopupMenuItem(
                child: Text(AppLocalizations.of(context)!.text('desc_name')),
                value: Sort.desc_name,
                checked: _sort == Sort.desc_name,
              ),
              CheckedPopupMenuItem(
                child: Text(AppLocalizations.of(context)!.text('asc_size')),
                value: Sort.asc_size,
                checked: _sort == Sort.asc_size,
              ),
              CheckedPopupMenuItem(
                child: Text(AppLocalizations.of(context)!.text('desc_size')),
                value: Sort.desc_size,
                checked: _sort == Sort.desc_size,
              )
            ]
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert, size: 24.0, color: Theme.of(context).primaryColor),
            onSelected: (value) async {
              if (value == 'unused') {
                try {
                  EasyLoading.show(status: AppLocalizations.of(context)!.text('work_in_progress'));
                  List<ImageModel> selected = await Storage().unused(_path);
                  setState(() {
                    _selected = selected;
                  });
                  _applyChange();
                } catch (e) {
                  showSnackbar(e.toString());
                } finally {
                  EasyLoading.dismiss();
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                value: 'unused',
                child: Text(AppLocalizations.of(context)!.text('unused_images')),
              ),
            ]
          )
        ],
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        titleTextStyle: Theme.of(context).textTheme.titleLarge,
        backgroundColor: Colors.transparent,
        // bottomOpacity: 0.0,
        elevation: 0.0,
      ),
      drawer: _drawer(),
      body: RefreshIndicator(
        onRefresh: () => _fetch(),
        child: FutureBuilder<List<ImageModel>>(
          future: _images,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return EmptyContainer(message: AppLocalizations.of(context)!.text('no_image'));
              }
              return GridView.builder(
                controller: _controller,
                padding: const EdgeInsets.all(4),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: getDeviceAxisCount(),
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0
                ),
                itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                itemBuilder: (context, index) {
                  ImageModel image = snapshot.data![index];
                  return item(image);
                }
              );
            }
            if (snapshot.hasError) {
              return ErrorContainer(snapshot.error.toString());
            }
            return const Center(child: CircularProgressIndicator(strokeWidth: 2.0, valueColor:AlwaysStoppedAnimation<Color>(Colors.black38)));
          }
        )
      ),
      bottomNavigationBar: _bottomBar(),
      floatingActionButton: !DeviceHelper.isDesktop || _path != 'camera' ? FloatingActionButton(
        heroTag: null,
        onPressed: _add,
        tooltip: AppLocalizations.of(context)!.text('add_image'),
        child: Icon(_path == 'camera' ? Icons.camera : Icons.add_photo_alternate_rounded)
      ) : null
    );
  }

  Widget _drawer() {
    return Drawer(
      child: FutureBuilder<List<String>>(
        future: Storage().getPaths(),
        builder: (context, snapshot) {
          List<Widget> items = [
            SizedBox(
                height : 120.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Text(AppLocalizations.of(context)!.text('image_gallery'),
                      style: const TextStyle(color: Colors.white, fontSize: 25)
                  ),
                )
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(AppLocalizations.of(context)!.text('add_folder')),
              onTap: () async {
                String? path = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return TextInputDialog(
                        title: AppLocalizations.of(context)!.text('folder'),
                      );
                    }
                );
                if (path != null) {
                  await Storage().addPath(path.toLowerCase());
                  setState(() {
                    _path = path.toLowerCase();
                  });
                  _fetch();
                  Navigator.pop(context);
                }
              },
            ),
            const Divider()
          ];
          if (snapshot.data != null) {
            snapshot.data!.sort((a, b) {
              if(a == 'pictures' || a == 'camera') {
                return -1;
              }
              if(b == 'pictures' || b == 'camera') {
                return 1;
              }
              return a.toLowerCase().compareTo(b.toLowerCase());
            });
            for(String path in snapshot.data!) {
              Icon? icon;
              if (path == 'pictures') {
                icon = const Icon(Icons.photo_library);
              } else if (path == 'camera') {
                icon = const Icon(Icons.camera);
              }
              items.add(ListTile(
                leading: icon,
                trailing: icon == null ? IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    bool confirm = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return DeleteDialog();
                        }
                    );
                    if (confirm) {
                      bool result = await Storage().deletePath(path);
                      if (result) {
                        setState(() {
                          _path = 'pictures';
                        });
                        _fetch();
                      } else {
                        showSnackbar(AppLocalizations.of(context)!.text('unable_delete_folder'));
                      }
                      Navigator.pop(context);
                    }
                  }
                ) : null,
                title: Text(toBeginningOfSentenceCase(path)!),
                onTap: () {
                  setState(() {
                    _sort = Sort.asc_name;
                    _path = path;
                  });
                  _fetch();
                  Navigator.pop(context);
                },
              ));
            }
          }
          return ListView(
            padding: EdgeInsets.zero,
            children: items,
          );
        }
      )
    );
  }

  Widget _buildSearchField() {
    return  Container(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: const BoxDecoration(
            color: FillColor
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
                child: TextField(
                  controller: _searchQueryController,
                  decoration: InputDecoration(
                      icon: const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Icon(Icons.search)
                      ),
                      hintText: AppLocalizations.of(context)!.text('search_hint'),
                      border: InputBorder.none
                  ),
                  style: const TextStyle(fontSize: 16.0),
                  onChanged: (query) {
                    _fetch();
                  },
                )
            ),
            if (_searchQueryController.text.isNotEmpty) IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchQueryController.clear();
                _fetch();
              }
            )
          ],
        )
    );
  }

  int getDeviceAxisCount() {
    if (DeviceHelper.isDesktop) {
      return 8;
    }
    return !DeviceHelper.isMobile || DeviceHelper.landscapeOrientation(context) ? 4 : 2;
  }

  Widget item(ImageModel image) {
    return Card(
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          if(_selected.isNotEmpty) {
            _select(image);
          }
        },
        onLongPress:(){
          _select(image);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: image.getUrl(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                Widget child = Container();
                if (snapshot.hasData) {
                  child = ExtendedImage.network(snapshot.data);
                }
                return Expanded(
                  flex: 1,
                  child: child
                );
              }
            ),
            Flexible(
              fit: FlexFit.loose,
              child: ListTile(
                dense: true,
                leading: GestureDetector(
                  child: FutureBuilder<bool>(
                    future: _isSelected(image),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData && snapshot.data) {
                        return const Icon(Icons.check_circle, color: PrimaryColor, size: 32);
                      }
                      return const Icon(Icons.image, color: Colors.red, size: 32);
                    }
                  ),
                  onTapDown: (TapDownDetails details) {
                    _onPointerDown(details.globalPosition, image);
                  }
                ),
                title: Tooltip(
                  message: image.name!,
                  child: Text(
                    image.name!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                ),
                subtitle: FutureBuilder<int?>(
                  future: image.getSize(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    String text = '';
                    if (snapshot.hasData) {
                      text = ImageHelper.size(snapshot.data, 0);
                    }
                    return Text(text, overflow: TextOverflow.ellipsis);
                  }
                ),
              )
            )
          ]
        ),
      )
    );
  }

  Widget _bottomBar() {
    if (_selected.isEmpty) {
      return BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
                icon: const Icon(Icons.check_circle_outline_outlined),
                label: Text(DeviceHelper.isDesktop ? AppLocalizations.of(context)!.text('select_all') : ''),
                onPressed: () async {
                  List<ImageModel>? list = await _images;
                  setState(() {
                    _selected.addAll(list!);
                    _applyChange();
                  });
                }
            ),
          ]
        )
      );
    } else {
      return BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.highlight_off_outlined),
              label: Text(DeviceHelper.isDesktop ? AppLocalizations.of(context)!.text('deselect') : ''),
              onPressed: () {
                setState(() {
                  _selected.clear();
                  _applyChange();
                });
              }
            ),
            TextButton.icon(
              icon: const Icon(Icons.drive_file_move),
              label: Text(DeviceHelper.isDesktop ? AppLocalizations.of(context)!.text('move') : ''),
              onPressed: () {
                _move();
              }
            ),
            TextButton.icon(
              icon: const Icon(Icons.delete),
              label: Text(DeviceHelper.isDesktop ? AppLocalizations.of(context)!.text('remove') : ''),
              onPressed: () {
                _delete();
              }
            ),
          ]
        )
      );
    }
  }

  _fetch() async {
    setState(() {
      _images = Storage().getImages(_path, searchText: _searchQueryController.value.text);
      _images = sortFutures(_images!, _sort);
    });
    Future.delayed(Duration.zero, () async {
      _applyChange();
    });
  }

  Future<bool> _isSelected(ImageModel image) async {
    String url1 = await image.getUrl();
    for (ImageModel item in _selected) {
      String url2 = await item.getUrl();
      if (ModelHelper.equals(url1, url2)) {
        return true;
      }
    }
    return false;
  }

  _select(ImageModel image) async {
    bool selected = await _isSelected(image);
    setState(() {
      if (widget.only) {
        _selected.clear();
      }
      if (selected) {
        _selected.remove(image);
      } else {
        _selected.add(image);
      }
    });
    _applyChange();
  }

  _applyChange() {
    if (!mounted) return false;
    bool checked = _selected.isNotEmpty;
    if (checked) {
      setState(() {
        int count = _selected.length;
        String title = '$count selected';
        if (count > 1) {
          title = '$count selected';
        }
        if (_appBar == null || _appBar!.leading == null) {
          _appBar = AppBarParams(
              title: Text(title)
          );
        }
      });
    } else {
      if (_appBar != null && _appBar!.leading == null) {
        setState(() {
          _appBar = null;
        });
      }
    }

  }

  _add() {
    if (_path == 'camera') {
      _imgFromCamera();
    } else {
      _imgFromGallery();
    }
  }

  _imgFromCamera() async {
    final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 640,
        // maxHeight: 480,
        imageQuality: 80
    );
    if (pickedFile != null) {
      Storage().upload('camera', pickedFile).then((value) => _fetch());
    }
  }

  _imgFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 640,
        // maxHeight: 480,
        imageQuality: 80
    );
    if (images != null) {
      EasyLoading.show(status: AppLocalizations.of(context)!.text('image_processing'));
      for(XFile image in images) {
        await Storage().upload(_path, image);
      }
      EasyLoading.dismiss();
      _fetch();
    }
  }

  _imgFromUrl() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConfirmDialog(
            content: const Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                        labelText: 'Image URL'),
                  ),
                )
              ],
            )
          );
        }
    );
  }

  _delete() async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog(
          title: AppLocalizations.of(context)!.text('delete_items_title'),
          displayBody: false);
      }
    );
    if (confirm) {
      try {
        EasyLoading.show(status: AppLocalizations.of(context)!.text('work_in_progress'));
        for (ImageModel image in _selected) {
          int count = await Storage().remove(image.url!);
          if (count > 0) {
            bool force = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  String message = AppLocalizations.of(context)!.text('cannot_delete_image');
                  return DeleteDialog(title: sprintf(message, [image.name]));
                }
            );
            if (force) {
              await Storage().remove(image.url!, forced: true);
            }
          }
        }
        setState(() {
          _selected.clear();
        });
        _fetch();
      } catch (e) {
        showSnackbar(e.toString());
      } finally {
        EasyLoading.dismiss();
      }
    }
  }

  _move() async {
    List<String> paths = await Storage().getPaths();
    paths.remove(_path);
    String? path = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return DropdownDialog(
            title: AppLocalizations.of(context)!.text('move_images'),
            initialValue: paths.isNotEmpty ? paths[0] : null,
            items: paths.map((value) {
              return DropdownMenuItem<String>(
                  value: value,
                  child: Text(toBeginningOfSentenceCase(value)!));
            }).toList(),
          );
        }
    );
    if (path != null) {
      try {
        EasyLoading.show(status: AppLocalizations.of(context)!.text('work_in_progress'));
        for (ImageModel image in _selected) {
          await Storage().move(image, path);
        }
        setState(() {
          _selected.clear();
        });
        _fetch();
      } catch (e) {
        showSnackbar(e.toString());
      } finally {
        EasyLoading.dismiss();
      }
    }
  }

  _analyze() async {
    bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConfirmDialog(
            content: Text(AppLocalizations.of(context)!.text('analyze_images')),
          );
        }
    );
    if (confirm) {
      try {
        EasyLoading.show(status: AppLocalizations.of(context)!.text('work_in_progress'));
        for (ImageModel image in _selected) {
          await Storage().rename(image);
        }
        setState(() {
          _selected.clear();
        });
        _fetch();
      } catch (e) {
        showSnackbar(e.toString());
      } finally {
        EasyLoading.dismiss();
      }
    }
  }

  Comparator getComparator(Sort sort) {
    if (sort == Sort.asc_date) {
      return (a, b) {
        return a.updated_at!.compareTo(b.updated_at!);
      };
    } else if (sort == Sort.desc_date) {
      return (a, b) {
        return b.updated_at!.compareTo(a.updated_at!);
      };
    } else if (sort == Sort.desc_name) {
      return (a, b) {
        return b.name!.toLowerCase().compareTo(a.name!.toLowerCase());
      };
    } else if (sort == Sort.asc_size) {
      return (a, b) {
        return a.mash_volume!.compareTo(b.mash_volume!);
      };
    } else if (sort == Sort.desc_size) {
      return (a, b) {
        return b.mash_volume!.compareTo(a.mash_volume!);
      };
    }
    return (a, b) {
      return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
    };
  }

  Future<List<ImageModel>> sortFutures<T>(Future<List<ImageModel>> input, Sort sort) async {
    List<ImageModel>? list = await input;
    if (sort != Sort.asc_name && sort != Sort.desc_name) {
      EasyLoading.show(status: AppLocalizations.of(context)!.text('work_in_progress'));
      for (ImageModel image in list) {
        await image.getUpdated();
      }
    }
    list.sort(getComparator(_sort));
    if (sort != Sort.asc_name && sort != Sort.desc_name) {
      EasyLoading.dismiss();
    }
    return list;
  }

  /// Callback when mouse clicked on `Listener` wrapped widget.
  Future<void> _onPointerDown(Offset position, ImageModel image) async {
    // Check if right mouse button clicked
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final menuItem = await showMenu<int>(
        context: context,
        items: [
          PopupMenuItem(child: Text(AppLocalizations.of(context)!.text('use(s)')), value: 1),
          PopupMenuItem(child: Text(AppLocalizations.of(context)!.text('view_image')), value: 2),
          // PopupMenuItem(child: Text(AppLocalizations.of(context)!.text('analyze')), value: 3),
        ],
        position: RelativeRect.fromSize(position & const Size(48.0, 48.0), overlay.size));
    // Check if menu item clicked
    switch (menuItem) {
      case 1:
        List<dynamic> used = await ModelHelper.models(image.url!);
        if (used.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.text('not_found')),
            behavior: SnackBarBehavior.floating,
          ));
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.text('use(s)')),
                content: SizedBox(
                  // height: 300.0, // Change as per your requirement
                  // width: 300.0, // Change as per your requirement
                  width: double.maxFinite,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: used.length,
                    itemBuilder: (BuildContext context, int index) {
                      var model = used[index];
                      return ListTile(
                        title: Text(model.toString()),
                      );
                    },
                  ),
                )
              );
            });
        }

        break;
      case 2:
        if (await canLaunch(image.url!)) {
          await launch(image.url!, webOnlyWindowName: image.name);
        }
        break;
      case 3:
        await Storage().rename(image);
        _fetch();
        break;
      default:
    }
  }
}
