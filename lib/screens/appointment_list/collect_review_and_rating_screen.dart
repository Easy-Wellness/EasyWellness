import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:users/models/review/db_review.model.dart';
import 'package:users/utils/show_custom_snack_bar.dart';

class CollectReviewAndRatingScreen extends StatefulWidget {
  CollectReviewAndRatingScreen({
    Key? key,
    required this.apptId,
    required this.serviceId,
    required this.serviceName,
    required this.placeId,
    required this.placeName,
  }) : super(key: key);

  final String apptId;
  final String serviceId;
  final String serviceName;
  final String placeId;
  final String placeName;

  @override
  State<CollectReviewAndRatingScreen> createState() =>
      _CollectReviewAndRatingScreenState();
}

class _CollectReviewAndRatingScreenState
    extends State<CollectReviewAndRatingScreen> {
  final _formKey = GlobalKey<FormState>();
  double rating = 0;
  String? review;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Rating & Review'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                title: Text(
                  widget.serviceName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                subtitle: Text(widget.placeName),
              ),
              Divider(thickness: 1),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FormField<double>(
                        validator: (value) {
                          if (value == null)
                            return 'Please rate your experience';
                        },
                        onSaved: (value) => rating = value!,
                        builder: (fieldState) => Column(
                          children: [
                            RatingBar.builder(
                              minRating: 1,
                              itemCount: 5,
                              glow: false,
                              tapOnlyMode: true,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (_, __) =>
                                  Icon(Icons.star, color: Colors.amber),
                              onRatingUpdate: (rating) =>
                                  fieldState.didChange(rating),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              fieldState.hasError ? fieldState.errorText! : '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                      color: Theme.of(context).errorColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        onSaved: (value) => review = value,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText:
                              'Share your experience and help others make better choices!',
                          helperText: '',
                        ),
                        minLines: 6,
                        maxLines: 6,
                        maxLength: 250,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final placeRef = FirebaseFirestore.instance
                                .collection('places')
                                .doc(widget.placeId);
                            await placeRef
                                .collection('services')
                                .doc(widget.serviceId)
                                .collection('reviews')
                                .withConverter<DbReview>(
                                  fromFirestore: (snapshot, _) =>
                                      DbReview.fromJson(snapshot.data()!),
                                  toFirestore: (review, _) => review.toJson(),
                                )
                                .add(
                                  DbReview(
                                    accountId:
                                        FirebaseAuth.instance.currentUser!.uid,
                                    placeId: widget.placeId,
                                    serviceId: widget.serviceId,
                                    rating: rating,
                                    review: review,
                                    createdAt: Timestamp.now(),
                                  ),
                                );
                            await placeRef
                                .collection('appointments')
                                .doc(widget.apptId)
                                .update({'is_reviewed': true}).catchError(
                                    print);
                            Navigator.pop(context);
                            showCustomSnackBar(context,
                                'Your rating and review is successfully submitted');
                          }
                        },
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
