import 'package:dgha/components/dgha_icon.dart';
import 'package:dgha/components/rating_breadcrumbs.dart';
import 'package:dgha/misc/dgha_api.dart';
import 'package:dgha/misc/styles.dart';
import 'package:dgha/components/user_rating_container.dart';
import 'package:dgha/models/place.dart';
import 'package:dgha/screens/place_details_screen.dart';
import 'package:flutter/material.dart';

enum RatingPagesEnum {
  Overall,
  CustomerService,
  Amenities,
  Location,
  Comment,
}

class UserRatingScreen extends StatefulWidget {
  static const String id = "Rating Screen";

  final PlaceData placeData;

  UserRatingScreen(this.placeData);
  @override
  _UserRatingScreenState createState() => _UserRatingScreenState();
}

class _UserRatingScreenState extends State<UserRatingScreen> {
  bool isSubmittingReview = false;
  RatingPagesEnum currentRatingPage = RatingPagesEnum.Overall;

  int maxNavPos = 0;
  int currentNavPos = 0;
  Widget currentPage;
  final pageController = PageController(
    initialPage: 0,
    keepPage: false,
  );

  //Initialize ratingPages
  UserRatingContainer overallRatingScreen;
  UserRatingContainer customerServiceRatingScreen;
  UserRatingContainer amenitiesRatingScreen;
  UserRatingContainer locationRatingScreen;
  CommentSection commentSectionScreen;

  //Store Rating Vairables
  double overallRating = 0;
  double customerServiceRating = 0;
  double amenitiesRating = 0;
  double locationRating = 0;
  String comment = "";

  //Comment Text Controller
  TextEditingController commentController = new TextEditingController();

  //Loading screen variables
  bool isLoading = false;
  bool showLoadingText = false;
  String loadingText = "Sending...";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //-------------------- Rating PageView Screens --------------------//
    //----------Overall Rating
    overallRatingScreen = new UserRatingContainer(
      title: "Overall",
      buttonTitle: "Next",
      hintText:
          "Give an overall rating out of 5 on your experience at this location.",
      //If the page already has a rating, grab that from the object
      rating: overallRatingScreen != null ? overallRatingScreen.rating : 0,
      nextPageName: "Customer Service rating",
      onPressed: () {
        if (overallRatingScreen.rating != 0) {
          setState(() {
            if (maxNavPos < 1) maxNavPos = 1;
            currentNavPos = 1;

            overallRating = overallRatingScreen.rating;
            currentRatingPage = RatingPagesEnum.CustomerService;
          });
          //pageController.jumpToPage(1);
        }
      },
    );
    //----------Customer Service Rating
    customerServiceRatingScreen = new UserRatingContainer(
      title: "Customer Service",
      buttonTitle: "Next",
      hintText:
          "Give a score out of 5 on the customer service provided to you at this location.",
      //If the page already has a rating, grab that from the object
      rating: customerServiceRatingScreen != null
          ? customerServiceRatingScreen.rating
          : 0,
      nextPageName: "Amenities rating",
      onPressed: () {
        if (customerServiceRatingScreen.rating != 0) {
          setState(() {
            if (maxNavPos < 2) maxNavPos = 2;
            currentNavPos = 2;

            customerServiceRating = customerServiceRatingScreen.rating;
            currentRatingPage = RatingPagesEnum.Amenities;
          });
          //pageController.jumpToPage(2);
        }
      },
    );
    //----------Amenities Rating
    amenitiesRatingScreen = new UserRatingContainer(
      title: "Amenities",
      buttonTitle: "Next",
      hintText: "Give a score out of 5 on the amenities here at this location.",
      //If the page already has a rating, grab that from the object
      rating: amenitiesRatingScreen != null ? amenitiesRatingScreen.rating : 0,
      nextPageName: "Location rating",
      onPressed: () {
        if (amenitiesRatingScreen.rating != 0) {
          setState(() {
            if (maxNavPos < 3) maxNavPos = 3;
            currentNavPos = 3;

            amenitiesRating = amenitiesRatingScreen.rating;
            currentRatingPage = RatingPagesEnum.Location;
          });
          //pageController.jumpToPage(3);
        }
      },
    );
    //----------Location Rating
    locationRatingScreen = new UserRatingContainer(
      title: "Location",
      buttonTitle: "Next",
      hintText:
          "Give a score out of 5 on the accessibility and ease of access to this location.",
      //If the page already has a rating, grab that from the object
      rating: locationRatingScreen != null ? locationRatingScreen.rating : 0,
      nextPageName: "Comment",
      onPressed: () {
        if (locationRatingScreen.rating != 0) {
          setState(() {
            if (maxNavPos < 4) maxNavPos = 4;
            currentNavPos = 4;

            locationRating = locationRatingScreen.rating;
            currentRatingPage = RatingPagesEnum.Comment;
          });
          //pageController.jumpToPage(4);
        }
      },
    );
    //---------- NOTE: Comment Section
    commentSectionScreen = new CommentSection(
      title: "Comment (Optional)",
      controller: commentController,
      hintText:
          "Add a comment to your review to give more detail on your experience. This is optional.",
      btnColor: isLoading ? Styles.grey : Styles.midnightBlue,
      // --------- NOTE: Submission
      onPressed: () async {
        setState(() {
          this.isLoading = true;
          this.showLoadingText = true;
          this.loadingText = "Sending...";
        });

        if (!this.isSubmittingReview) {
          setState(() {
            this.isSubmittingReview = true;
          });

          comment = commentController.text;

          await DghaApi.postReview(
            widget.placeData.placeId,
            overallRating.toInt(),
            locationRating.toInt(),
            amenitiesRating.toInt(),
            customerServiceRating.toInt(),
            comment,
          ).then((response) {

            // new review is added
            if (response.statusCode == 201) {

              // send back the Place Details Screen if user has left a comment
              // true = user have left a comment
              Navigator.pop(context, comment != "" ? true : false); 
              setState(() {
                this.isLoading = false;
                this.showLoadingText = false;
              });
            } else if (response.statusCode == 409) {
              setState(() {
                this.isLoading = false;
                this.loadingText = "You have already left a review";
              });
            } else {
              setState(() {
                this.isLoading = false;
                this.loadingText = response.reasonPhrase;
              });
            }
          });

          setState(() {
            this.isSubmittingReview = false;
          });
        }
      },
    );

    Widget buildLoadingWidget() {
      if (this.showLoadingText) {
        return Container(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              this.loadingText,
              style: Styles.h2Style,
              textAlign: TextAlign.center,
            ),
          ),
        );
      } else {
        return Container(
          height: 0,
        );
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          child: ListView(
            children: <Widget>[
              //----------App Bar
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  child: Semantics(
                    button: true,
                    label: "Close",
                    hint: "Double tap to cancel your review",
                    excludeSemantics: true,
                    child: DghaIcon(
                      size: 35,
                      padding: 4,
                      backgroundColor: Styles.midnightBlue,
                      iconColor: Styles.yellow,
                      icon: Icons.close,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, false);
                  },
                ),
              ),
              //----------Loading Text
              buildLoadingWidget(),
              //----------Page Navigation
              Padding(
                padding: const EdgeInsets.only(
                    left: 15, right: 15, top: 20, bottom: 20),
                child: RatingBreadcrumbs(
                  maxNavPos: maxNavPos,
                  currentNavPos: currentNavPos,
                  iconColor: Colors.white,
                  backgroundColor: Styles.grey,
                  highlightedIconColor: Styles.yellow,
                  highlightedBackgroundColor: Styles.midnightBlue,
                  onTapFirst: () {
                    setState(() {
                      currentRatingPage = RatingPagesEnum.Overall;
                      currentNavPos = 0;
                    });
                  },
                  onTapSecond: () {
                    setState(() {
                      currentRatingPage = RatingPagesEnum.CustomerService;
                      currentNavPos = 1;
                    });
                  },
                  onTapThird: () {
                    setState(() {
                      currentRatingPage = RatingPagesEnum.Amenities;
                      currentNavPos = 2;
                    });
                  },
                  onTapForth: () {
                    setState(() {
                      currentRatingPage = RatingPagesEnum.Location;
                      currentNavPos = 3;
                    });
                  },
                  onTapFith: () {
                    setState(() {
                      currentRatingPage = RatingPagesEnum.Comment;
                      currentNavPos = 4;
                    });
                  },
                ),
              ),

              //-------------------------- NOTE: PAGES
              currentRatingPage == RatingPagesEnum.Overall
                  ? overallRatingScreen
                  : currentRatingPage == RatingPagesEnum.CustomerService
                      ? customerServiceRatingScreen
                      : currentRatingPage == RatingPagesEnum.Amenities
                          ? amenitiesRatingScreen
                          : currentRatingPage == RatingPagesEnum.Location
                              ? locationRatingScreen
                              : currentRatingPage == RatingPagesEnum.Comment
                                  ? commentSectionScreen
                                  : Container(height: 0),

              // PageView(
              //   controller: pageController,
              //   physics: NeverScrollableScrollPhysics(),
              //   children: <Widget>[
              //     overallRatingScreen,
              //     customerServiceRatingScreen,
              //     amenitiesRatingScreen,
              //     locationRatingScreen,
              //     commentSectionScreen,
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
