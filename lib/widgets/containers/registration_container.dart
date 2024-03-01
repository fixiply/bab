import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/register_page.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/widgets/containers/abstract_container.dart';
// External package

class RegistrationContainer extends AbstractContainer {
  @override
  _RegistrationContainerState createState() => _RegistrationContainerState();
}

class _RegistrationContainerState extends AbstractContainerState with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = DeviceHelper.isMobile(context);
    double? maxHeight;
    TextStyle titleStyle = TextStyle().copyWith(fontSize: 16, fontWeight: FontWeight.bold);
    TextStyle subtitleStyle = TextStyle();
    if (!isMobile) {
      titleStyle = titleStyle.copyWith(fontSize: 28);
      subtitleStyle = subtitleStyle.copyWith(fontSize: 16);
    }
    final padding = MediaQuery.of(context).padding;
    final appbar = Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight;
    var scaffoldBodyHeight = MediaQuery.of(context).size.height - appbar - padding.top;
    if (isMobile) {
      maxHeight = 200;
      scaffoldBodyHeight -= kTextTabBarHeight;
    }
    return Container(
      height: scaffoldBodyHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 8),
          Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16),
              children: <TextSpan>[
                TextSpan(
                    text: AppLocalizations.of(context)!.text('sign_up'),
                    style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16, color: Theme.of(context).primaryColor),
                    recognizer: TapGestureRecognizer()..onTap = () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return RegisterPage();
                      }));
                    }
                ),
                TextSpan(text: ' ' + AppLocalizations.of(context)!.text('to_more_features').toLowerCase())
              ]
            ),
          ),
          const SizedBox(height: foundation.kIsWeb ? 30 : 12),
          Flexible(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _image('assets/images/create_recipe.png', maxHeight),
                      ),
                      const SizedBox(height: foundation.kIsWeb ? 30 : 20),
                      Text(AppLocalizations.of(context)!.text('functionality_1'), textAlign: TextAlign.center, style: titleStyle),
                      const SizedBox(height: 8),
                      Text(AppLocalizations.of(context)!.text('functionality_1_tooltip'), textAlign: TextAlign.center, style: subtitleStyle),
                      const SizedBox(height: foundation.kIsWeb ? 40 : 8),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: _image('assets/images/create_brew.png', maxHeight),
                      ),
                      const SizedBox(height: foundation.kIsWeb ? 30 : 20),
                      Text(AppLocalizations.of(context)!.text('functionality_2'), textAlign: TextAlign.center, style: titleStyle),
                      const SizedBox(height: 8),
                      Text(AppLocalizations.of(context)!.text('functionality_2_tooltip'), textAlign: TextAlign.center, style: subtitleStyle),
                      const SizedBox(height: foundation.kIsWeb ? 40 : 8),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: _image('assets/images/brewing_steps.png', maxHeight),
                      ),
                      const SizedBox(height: foundation.kIsWeb ? 30 : 20),
                      Text(AppLocalizations.of(context)!.text('functionality_3'), textAlign: TextAlign.center, style: titleStyle),
                      const SizedBox(height: 8),
                      Text(AppLocalizations.of(context)!.text('functionality_3_tooltip'), textAlign: TextAlign.center, style: subtitleStyle),
                      const SizedBox(height: foundation.kIsWeb ? 40 : 8),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: _image('assets/images/calendar.png', maxHeight),
                      ),
                      const SizedBox(height: foundation.kIsWeb ? 30 : 20),
                      Text(AppLocalizations.of(context)!.text('functionality_4'), textAlign: TextAlign.center, style: titleStyle),
                      const SizedBox(height: 8),
                      Text(AppLocalizations.of(context)!.text('functionality_4_tooltip'), textAlign: TextAlign.center, style: subtitleStyle),
                      const SizedBox(height: foundation.kIsWeb ? 40 : 8),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: _image('assets/images/tools.png', maxHeight),
                      ),
                      const SizedBox(height: foundation.kIsWeb ? 30 : 20),
                      Text(AppLocalizations.of(context)!.text('functionality_5'), textAlign: TextAlign.center, style: titleStyle),
                      const SizedBox(height: 8),
                      Text(AppLocalizations.of(context)!.text('functionality_5_tooltip'), textAlign: TextAlign.center, style: subtitleStyle),
                      const SizedBox(height: foundation.kIsWeb ? 40 : 10),
                    ],
                  ),
                ),
              ],
            )
          ),
          TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: ShapeDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            tabs: <Widget>[
              Tab(child: Text(AppLocalizations.of(context)!.text('recipe'), style: TextStyle(overflow: TextOverflow.ellipsis, color: Theme.of(context).primaryColor))),
              Tab(child: Text(AppLocalizations.of(context)!.text('brewing'), style: TextStyle(overflow: TextOverflow.ellipsis, color: Theme.of(context).primaryColor))),
              Tab(child: Text(AppLocalizations.of(context)!.text('process'), style: TextStyle(overflow: TextOverflow.ellipsis, color: Theme.of(context).primaryColor))),
              Tab(child: Text(AppLocalizations.of(context)!.text('calendar'), style: TextStyle(overflow: TextOverflow.ellipsis, color: Theme.of(context).primaryColor))),
              Tab(child: Text(AppLocalizations.of(context)!.text('brewing_tools'), style: TextStyle(overflow: TextOverflow.ellipsis, color: Theme.of(context).primaryColor))),
            ],
          ),
          const SizedBox(height: 12),
        ],
      )
    );
  }

  Widget _image(String name, double? maxHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_outlined, size: 12),
            onPressed: () {
              if (_tabController.index == 0) {
                _tabController.animateTo(_tabController.length - 1);
              } else {
                _tabController.animateTo(_tabController.index -1);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Image.asset(name, height: maxHeight)
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
          child: IconButton(
            icon: Icon(Icons.arrow_forward_ios_outlined, size: 12),
            onPressed: () {
              if ((_tabController.index + 1) == _tabController.length) {
                _tabController.animateTo(0);
              } else {
                _tabController.animateTo(_tabController.index + 1);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
      ]
    );
  }
}