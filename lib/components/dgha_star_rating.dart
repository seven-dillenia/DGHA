import 'package:dgha/misc/styles.dart';
import 'package:flutter/material.dart';

class DghaStarRating extends StatefulWidget {
  double rating;
  final double height;
  final int starCount;
  final Function(double rating) onTap;
  final bool changeRatingOnTap;

  DghaStarRating({
    @required this.rating,
    @required this.height,
    this.starCount = 5,
    this.onTap,
    this.changeRatingOnTap = true,
  });

  @override
  _DghaStarRatingState createState() => _DghaStarRatingState();
}

class _DghaStarRatingState extends State<DghaStarRating> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.height * widget.starCount,
      height: widget.height,
      //Required to automatically adjust icon size
      child: LayoutBuilder(
        builder: (context, constraint) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.starCount,
            itemBuilder: (context, index) {
              IconData starIcon;
              //Set the star to either a full star, half star or empty
              if (widget.rating > index) {
                if (widget.rating.roundToDouble() > index)
                  starIcon = Icons.star;
                else
                  starIcon = Icons.star_half;
              } else
                starIcon = Icons.star_border;

              return Stack(
                children: <Widget>[
                  //---------- Star Rating
                  GestureDetector(
                    child: Semantics(
                      hint: widget.changeRatingOnTap
                          ? "Double tap to rate ${index + 1} stars"
                          : "",
                      excludeSemantics: true,
                      child: Icon(
                        starIcon,
                        size: constraint.biggest.height,
                        color: widget.rating > index
                            ? Styles.yellow
                            : Styles.midnightBlue,
                      ),
                    ),
                    onTap: () {
                      //Only change the rating if changeRatingOnTap is true
                      if (widget.changeRatingOnTap) {
                        setState(() {
                          widget.rating = index.toDouble() + 1;
                        });
                      }
                      if (widget.onTap != null) widget.onTap(widget.rating);
                    },
                  ),
                  //----------Star Rating Outline
                  IgnorePointer(
                    child: Icon(
                      Icons.star_border,
                      size: constraint.biggest.height,
                      color: Styles.midnightBlue,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
