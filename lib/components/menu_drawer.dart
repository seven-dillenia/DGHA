import 'package:dgha_brochure/components/menu_expansion_tile.dart';
import 'package:dgha_brochure/components/menu_tile.dart';
import 'package:dgha_brochure/misc/data.dart';
import 'package:dgha_brochure/misc/styles.dart';
import 'package:dgha_brochure/models/menu_tile_data.dart';
import 'package:dgha_brochure/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MenuDrawer extends StatelessWidget {
  final double width;
  final _auth = FirebaseAuth.instance;

  MenuDrawer({this.width});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(Styles.normalRadius),
            bottomRight: Radius.circular(Styles.normalRadius)),
        child: Container(
          width: this.width,
          constraints: BoxConstraints(
            minWidth: 300,
            maxWidth: 500,
          ),
          child: Drawer(
            elevation: 20,
            semanticLabel: "Side bar menu",
            child: ListView(
              padding: EdgeInsets.symmetric(
                  horizontal: Styles.appBarHorizontalPadding),
              children: <Widget>[
                SizedBox(
                  height: Styles.iconSize / 3,
                ),
                MenuTile(tile: Data.guideDogInfoTileData),
                MenuTile(tile: Data.guideDogAccessTileData),
                MenuExpansionTile(tile: Data.lawsTilesListData),
                MenuTile(tile: Data.membershipTitleData),
                MenuTile(tile: Data.donateTileData),
                MenuTile(
                  tile: new MenuTileData(
                    title: "Sign in",
                    icon: FontAwesomeIcons.signInAlt,
                    semanticLabel: "Login",
                    semanticHint: "Double tap to go to the sign in page",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).popAndPushNamed(LoginScreen.id);
                    },
                  ),
                ),
                MenuTile(
                  tile: new MenuTileData(
                    title: "Sign out",
                    icon: FontAwesomeIcons.signOutAlt,
                    semanticLabel: "Log out",
                    semanticHint: "Double tap to sign out",
                    pageToNavigateTo: LoginScreen.id,
                    onTap: () {
                      _auth.signOut();
                      Navigator.pop(context);
                      Navigator.of(context).popAndPushNamed(LoginScreen.id);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
