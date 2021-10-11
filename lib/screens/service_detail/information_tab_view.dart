import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:recase/recase.dart';
import 'package:users/models/nearby_service/db_nearby_service.model.dart';
import 'package:users/models/place/db_place.model.dart';
import 'package:users/utils/format_duration.dart';

class InformationTabView extends StatelessWidget {
  const InformationTabView({
    Key? key,
    required this.serviceId,
    required this.serviceData,
    required this.placeData,
  }) : super(key: key);

  final String serviceId;
  final DbNearbyService serviceData;
  final DbPlace placeData;

  @override
  Widget build(BuildContext context) {
    final priceTag = serviceData.priceTag;
    String valueText = '';
    String typeText = describeEnum(priceTag.type).titleCase;
    switch (priceTag.type) {
      case PriceType.fixed:
      case PriceType.startingAt:
      case PriceType.hourly:
        valueText = '\$${priceTag.value}';
        typeText = ' ($typeText)';
        break;
      default:
    }
    return Scrollbar(
      interactive: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: ContinuousRectangleBorder(
                side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    title: Text(
                      serviceData.serviceName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: Row(
                      children: [
                        RatingBarIndicator(
                          rating: serviceData.rating,
                          itemCount: 5,
                          itemSize: 10,
                          itemBuilder: (_, __) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                            '${serviceData.rating} (${serviceData.ratingsTotal})'),
                      ],
                    ),
                    trailing: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyText2,
                        children: [
                          const WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(Icons.timer_outlined),
                          ),
                          TextSpan(text: formatDuration(serviceData.duration)),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyText2,
                      children: [
                        const WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.only(left: 12, right: 4),
                            child: Icon(Icons.attach_money_outlined),
                          ),
                        ),
                        TextSpan(text: valueText + typeText),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyText2,
                      children: [
                        const WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(left: 12, right: 4),
                            child: Icon(Icons.place),
                          ),
                        ),
                        TextSpan(text: 'At ${placeData.name}'),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyText2,
                      children: [
                        const WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(left: 12, right: 4),
                            child: Icon(Icons.map_outlined),
                          ),
                        ),
                        TextSpan(text: placeData.address),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Service Description',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(height: 8),
                    Text(serviceData.description),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Business Contact Info',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyText2,
                        children: [
                          const WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.phone_outlined),
                            ),
                          ),
                          TextSpan(text: placeData.phoneNumber),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyText2,
                        children: [
                          const WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.email_outlined),
                            ),
                          ),
                          TextSpan(text: placeData.email),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Material(
              elevation: 4,
              child: TextButton.icon(
                onPressed: () {},
                icon: Text('See reviews'),
                label: Icon(Icons.arrow_right_alt_outlined),
              ),
            )
          ],
        ),
      ),
    );
  }
}
