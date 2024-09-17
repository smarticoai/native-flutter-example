import 'package:flutter/material.dart';
import 'package:flutter_application_1/managers/components/dropdown/constants.dart';

class CustomDropdown extends StatefulWidget {
  final int? initialValue;
  final List<CustomDropdownItem> items;
  final void Function(int?)? onChanged;

  const CustomDropdown({
    super.key,
    this.initialValue,
    required this.items,
    this.onChanged,
  });

  @override
  CustomDropdownState createState() => CustomDropdownState();
}

class CustomDropdownState extends State<CustomDropdown> {
  int? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<int>(
        value: selectedValue,
        onChanged: (value) {
          setState(() {
            selectedValue = value;
          });
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        },
        items: widget.items.map((CustomDropdownItem item) {
          return DropdownMenuItem<int>(
            value: item.value,
            child: Text(item.label),
          );
        }).toList(),
      ),
    );
  }
}
