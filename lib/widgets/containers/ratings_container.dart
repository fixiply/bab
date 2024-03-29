import 'package:flutter/material.dart';

// Internal package
import 'package:bab/helpers/date_helper.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/rating.dart';
import 'package:bab/widgets/dialogs/rating_dialog.dart';

// External package
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RatingsContainer extends StatefulWidget {
  dynamic model;
  RatingsContainer(this.model);
  @override
  State<StatefulWidget> createState() {
    return _RatingsContainerState();
  }
}

class _RatingsContainerState extends State<RatingsContainer> {

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(AppLocalizations.of(context)!.text('summary_reviews'), style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.model.ratings.length == 0) TextButton(
                child: Text(AppLocalizations.of(context)!.text('your_opinion')),
                onPressed: currentUser != null ? () async {
                  dynamic rating = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return RatingDialog(
                            Rating(
                                creator: currentUser!.uuid,
                                name: FirebaseAuth.instance.currentUser!.displayName ,
                                rating: 0
                            ),
                            title: widget.model.title,
                            maxLines: 3
                        );
                      }
                  );
                  if (rating != null) {
                    setState(() {
                      widget.model.ratings!.add(rating);
                    });
                  }
                } : null,
              ),
              if (widget.model.ratings.length > 0) Row(
                children: [
                  Text(widget.model.rating.toStringAsPrecision(2), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  Padding(padding: const EdgeInsets.only(left: 12),
                      child: Column(
                        children: [
                          RatingBar.builder(
                            initialRating: widget.model.rating,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 18,
                            itemPadding: EdgeInsets.zero,
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            ignoreGestures: false,
                            onRatingUpdate: (rating) async {
                            },
                          ),
                          // Text('${widget.model.notices} ${AppLocalizations.of(context)!.text(widget.model.notices > 1 ? 'ratings' : 'rating')}'),
                        ],
                      )
                  )
                ],
              ),
              ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for(Rating model in widget.model.ratings) Container(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                dense: true,
                                contentPadding : EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: Colors.black12,
                                  child: Text(model.name != null ? model.name![0] : '', style: const TextStyle(color: Colors.black)),
                                ),
                                title: Text(model.name ?? '?', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Row(
                                  children: [
                                    RatingBar.builder(
                                      initialRating: model.rating!,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemSize: 18,
                                      itemPadding: EdgeInsets.zero,
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      ignoreGestures: false,
                                      onRatingUpdate: (rating) async {
                                      },
                                    ),
                                    const Text(' - ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text('${AppLocalizations.of(context)!.text('the')} ${DateHelper.formatShortDate(context, model.inserted_at)}'),
                                  ],
                                ),
                              ),
                              if (model.comment != null) Text(model.comment!),
                            ]
                        )
                    )
                  ]
              ),
              if (widget.model.ratings.length > 0) const SizedBox(height: 8),
              if (widget.model.ratings.length > 0) TextButton(
                child: Text(AppLocalizations.of(context)!.text('give_its_opinion')),
                onPressed: () async {
                  dynamic rating = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return RatingDialog(
                            Rating(
                                creator: currentUser!.uuid,
                                name: FirebaseAuth.instance.currentUser!.displayName,
                                rating: 0
                            ),
                            title: widget.model.title,
                            maxLines: 3
                        );
                      }
                  );
                  if (rating != null) {
                    setState(() {
                      widget.model.ratings!.add(rating);
                    });
                  }
                },
              ),
            ],
          ),
        )
      ]
    );
  }
}
