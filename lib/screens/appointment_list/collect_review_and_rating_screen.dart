import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:users/models/review/db_review.model.dart';

class CollectReviewAndRatingScreen extends StatelessWidget {
  static const String routeName = '/collect_review_and_rating';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Rating & Review'),
        ),
        body: Body(),
      ),
    );
  }
}

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _formKey = GlobalKey<FormState>();
  double rating = 0;
  String? review;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    final apptId = args['apptId'] as String;
    final placeId = args['placeId'] as String;
    final placeName = args['placeName'] as String;
    final serviceId = args['serviceId'] as String;
    final serviceName = args['serviceName'] as String;
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            title: Text(
              serviceName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            subtitle: Text(placeName),
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
                      if (value == null) return 'Please rate your experience';
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
                              .copyWith(color: Theme.of(context).errorColor),
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
                            .doc(placeId);
                        await placeRef
                            .collection('services')
                            .doc(serviceId)
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
                                placeId: placeId,
                                serviceId: serviceId,
                                rating: rating,
                                review: review,
                                createdAt: Timestamp.now(),
                              ),
                            );
                        await placeRef
                            .collection('appointments')
                            .doc(apptId)
                            .update({'is_reviewed': true}).catchError(print);
                        Navigator.pop(context, true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Your rating and review is successfully submitted'),
                            duration: const Duration(seconds: 4),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        );
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
    );
  }
}
