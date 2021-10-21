import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:recase/recase.dart';
import 'package:users/constants/specialties.dart';
import 'package:users/services/location_service/identify_device_current_location.service.dart';
import 'package:users/widgets/pick_location_screen.dart';

import 'search_services_screen.dart';

class SearchServicesForm extends StatefulWidget {
  @override
  _SearchServicesFormState createState() => _SearchServicesFormState();
}

class _SearchServicesFormState extends State<SearchServicesForm> {
  final _formKey = GlobalKey<FormState>();

  GeoLocation? _pickedLocation;
  String chosenSpecialty = '';

  @override
  void initState() {
    super.initState();
    identifyDeviceCurrentLocation().then((location) {
      if (mounted) setState(() => _pickedLocation = location);
    });
  }

  _navigateToGetUserLocation(BuildContext context) async {
    final location = await Navigator.push(
      context,
      MaterialPageRoute<GeoLocation>(builder: (_) => PickLocationScreen()),
    );
    if (location != null && mounted) setState(() => _pickedLocation = location);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DropdownSearch<String>(
            validator: (value) =>
                value == null ? 'Please select a specialty' : null,
            onSaved: (value) => chosenSpecialty = value!,
            mode: Mode.MENU,
            showSelectedItems: true,
            showClearButton: true,
            items: specialties,
            itemAsString: (value) => value!.titleCase,
            scrollbarProps: ScrollbarProps(interactive: true),
            dropdownSearchDecoration: const InputDecoration(
              labelText: 'Specialty*',
              contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
              border: OutlineInputBorder(),
              helperText: '',
            ),
            popupItemBuilder: (_, value, isSelected) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: SizedBox(
                    height: 32,
                    width: 32,
                    child: SvgPicture.asset(
                      'assets/icons/specialty_${value.snakeCase}_icon.svg',
                    ),
                  ),
                  title: Text(
                    value.titleCase,
                    style: isSelected
                        ? TextStyle(
                            color: Theme.of(context).colorScheme.primary)
                        : null,
                  ),
                ),
              );
            },
          ),
          const SizedBox(
            height: 8,
          ),
          TextButton(
            onPressed: () => _navigateToGetUserLocation(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    _pickedLocation?.address ??
                        'Cannot access your location, tap here to enter',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_right),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          ElevatedButton.icon(
            onPressed: _pickedLocation != null
                ? () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SearchServicesScreen(
                            center: _pickedLocation!,
                            specialty: chosenSpecialty,
                          ),
                        ),
                      );
                    }
                  }
                : null,
            icon: const Icon(Icons.search_sharp),
            label: const Text('Search'),
          )
        ],
      ),
    );
  }
}
