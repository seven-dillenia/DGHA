import 'package:dgha_brochure/components/appbar.dart';
import 'package:dgha_brochure/components/dgha_icon.dart';
import 'package:dgha_brochure/misc/helper.dart';
import 'package:dgha_brochure/misc/styles.dart';
import 'package:dgha_brochure/models/languages.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_html/flutter_html.dart';

class InfoScreen extends StatefulWidget {
  static const String id = "Info Screen";
  final String appBarTitle;
  final List<Language> texts;

  InfoScreen({this.appBarTitle, this.texts});

  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  String infoText = "";

  // NOTE: App Properties
  double srcWidth;
  double srcHeight;
  double horizontalPadding = 30;

  // NOTE: App Bar Properties
  double appBarHeight;
  double appBarRadius;

  // Pop Menu

  // NOTE: Text

  @override
  void initState() {
    super.initState();
    setLang(0);
  }

  void calcDimensions(Orientation orientation) {
    // NOTE: App
    this.srcWidth = MediaQuery.of(context).size.width;
    this.srcHeight = MediaQuery.of(context).size.height;

    // NOTE: App Bar
    this.appBarHeight = orientation == Orientation.portrait ? srcHeight / 12 : srcWidth / 12;
    // this.appBarTextScale = this.appBarHeight / 70;
    this.appBarRadius = this.appBarHeight / 3.5;

    // NOTE: Popmenu
    // this.popMenuTextScale = this.appBarHeight / 90 < 1.2 ? this.appBarHeight / 90 : 1.2;
    // this.textScale = this.appBarHeight / 90 < 1.2 ? this.appBarHeight / 90 : 1.2;
  }

  void setLang(int index) {
    Helper().loadAsset(context, widget.texts[index].path).then((data) {
      setState(() {
        infoText = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: OrientationBuilder(
        builder: (context, orientation) {
          this.calcDimensions(orientation);
          return Column(
            children: <Widget>[
              DghaAppBar(
                text: widget.appBarTitle,
                appBarHeight: this.appBarHeight,
                srcWidth: this.srcWidth,
                horizontalPadding: this.horizontalPadding,
                borderRadius: this.appBarRadius,
                isMenuScr: false,
                leftChild: Semantics(
                  label: "Back Button",
                  hint: "Double tap to go back to home screen",
                  child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: DghaIcon(icon: Icons.arrow_back_ios)),
                ),
                rightChid: Semantics(
                  label: "Translation Button",
                  hint: "Double to tap to open up translation menu",
                  child: PopupMenuButton(
                    onSelected: (choice) {
                      int newLangIndex = widget.texts.indexWhere((lang) => lang.languageName == choice);
                      setLang(newLangIndex);
                    },
                    child: DghaIcon(icon: Icons.translate),
                    itemBuilder: (BuildContext ctxt) {
                      return widget.texts.map((Language lang) {
                        return PopupMenuItem(
                          value: lang.languageName,
                          child: Semantics(
                            hint: "Double tap to selected ${lang.languageName} translation.",
                            child: Text(lang.languageName, style: Styles.h3LinkStyle),
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  margin: EdgeInsets.symmetric(horizontal: this.horizontalPadding),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Html(
                      data: infoText,
                      defaultTextStyle: Styles.pStyle,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      )),
    );
  }
}
