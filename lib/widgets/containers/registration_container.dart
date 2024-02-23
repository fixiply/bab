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
                TextSpan(text: ' pour profiter de plus de fonctionnalités')
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _image('assets/images/create_recipe.png', maxHeight),
                      ),
                      const SizedBox(height: foundation.kIsWeb ? 30 : 20),
                      Text('Création de recette', textAlign: TextAlign.center, style: titleStyle),
                      const SizedBox(height: 8),
                      Text("Imaginez et construisez vos recettes de bières. Des centaines d'ingrédients préchargés sont disponibles, céréales, houblons, levures et divers ingrédients. Au fur et à mesure que vous ajoutez des ingrédients, la couleur, la densité et l'amertume sont mises à jour automatiquement.", textAlign: TextAlign.center, style: subtitleStyle),
                      const SizedBox(height: foundation.kIsWeb ? 40 : 8),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: _image('assets/images/create_brew.png', maxHeight),
                      ),
                      const SizedBox(height: foundation.kIsWeb ? 30 : 20),
                      Text('Créer et plannifier vos brassins', textAlign: TextAlign.center, style: titleStyle),
                      const SizedBox(height: 8),
                      Text("En fonction du volume final souhaité et de l'équipement utilisé, le profil du brassin et la quantité des ingrédients sont calculés automatiquement.", textAlign: TextAlign.center, style: subtitleStyle),
                      const SizedBox(height: foundation.kIsWeb ? 40 : 8),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: _image('assets/images/brewing_steps.png', maxHeight),
                      ),
                      const SizedBox(height: foundation.kIsWeb ? 30 : 20),
                      Text('Processus de brassage étape par étape', textAlign: TextAlign.center, style: titleStyle),
                      const SizedBox(height: 8),
                      Text("Pour ne pas oublier un ingredient ou une étape, le logiciel crée automatiquement des instructions étape par étape dans le processus de brassage.", textAlign: TextAlign.center, style: subtitleStyle),
                      const SizedBox(height: foundation.kIsWeb ? 40 : 8),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: _image('assets/images/calendar.png', maxHeight),
                      ),
                      const SizedBox(height: foundation.kIsWeb ? 30 : 20),
                      Text('Calendrier de brassage', textAlign: TextAlign.center, style: titleStyle),
                      const SizedBox(height: 8),
                      Text("Le calendrier vous permet de suivre vos brassins et d'être informé grâce à des notifications lorsqu'une action doit être effectuée (houblonnage à cru, garde à froid, etc.).", textAlign: TextAlign.center, style: subtitleStyle),
                      const SizedBox(height: foundation.kIsWeb ? 40 : 8),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: _image('assets/images/tools.png', maxHeight),
                      ),
                      const SizedBox(height: foundation.kIsWeb ? 30 : 20),
                      Text("Outils d'aide au brassage", textAlign: TextAlign.center, style: titleStyle),
                      const SizedBox(height: 8),
                      Text("Ces outils de brassage sont là pour vous aider lors des étapes de fabrication d'une bière.", textAlign: TextAlign.center, style: subtitleStyle),
                      const SizedBox(height: foundation.kIsWeb ? 40 : 10),
                    ],
                  ),
                ),
              ],
            )
          ),
          TabBar(
            controller: _tabController,
            indicator: ShapeDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            tabs: <Widget>[
              Tab(child: Text('Recette', style: TextStyle(overflow: TextOverflow.ellipsis, color: Theme.of(context).primaryColor))),
              Tab(child: Text('Brassage', style: TextStyle(overflow: TextOverflow.ellipsis, color: Theme.of(context).primaryColor))),
              Tab(child: Text('Processsus', style: TextStyle(overflow: TextOverflow.ellipsis, color: Theme.of(context).primaryColor))),
              Tab(child: Text('Calendrier', style: TextStyle(overflow: TextOverflow.ellipsis, color: Theme.of(context).primaryColor))),
              Tab(child: Text('Outils de brassage', style: TextStyle(overflow: TextOverflow.ellipsis, color: Theme.of(context).primaryColor))),
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