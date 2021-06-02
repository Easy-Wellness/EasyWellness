import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:recase/recase.dart';
import 'package:users/constants/specialties.dart';

class SearchServicesForm extends StatefulWidget {
  @override
  _SearchServicesFormState createState() => _SearchServicesFormState();
}

class _SearchServicesFormState extends State<SearchServicesForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          FormField<String>(
            validator: (value) => value == null || value.isEmpty
                ? 'Please select a specialty'
                : null,
            builder: (fieldState) => DropdownSearch<String>(
              mode: Mode.MENU,
              showSelectedItem: true,
              showClearButton: true,
              items: SPECIALTIES,
              itemAsString: (value) => value.titleCase,
              label: 'Specialty',
              popupItemDisabled: (value) => value == fieldState.value,
              onChanged: fieldState.didChange,
              popupItemBuilder: (_, value, isSelected) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(0),
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
          ),
          SizedBox(
            height: 4,
          ),
          TextButton(
            onPressed: () => {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 340,
                  child: Text(
                    '1600 Pennsylvania Avenue NW, Washington, DC 20500',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Icon(Icons.keyboard_arrow_right),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => {if (_formKey.currentState!.validate()) {}},
            icon: Icon(Icons.search_sharp),
            label: Text('Search'),
          )
        ],
      ),
    );
  }
}
