import 'package:flutter/material.dart';
import '../../models/court-finder/court_filter.dart';
import '../../models/court-finder/province.dart';

class FilterBottomSheet extends StatefulWidget {
  final CourtFilter currentFilter;
  final List<Province> provinces;

  const FilterBottomSheet({
    Key? key,
    required this.currentFilter,
    required this.provinces,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late List<String> selectedTypes;
  late String? selectedProvince;
  late TextEditingController minPriceController;
  late TextEditingController maxPriceController;

  final List<Map<String, String>> courtTypes = [
    {'value': 'basketball', 'label': 'Basketball'},
    {'value': 'badminton', 'label': 'Badminton'},
    {'value': 'futsal', 'label': 'Futsal'},
    {'value': 'tennis', 'label': 'Tennis'},
    {'value': 'baseball', 'label': 'Baseball'},
    {'value': 'volleyball', 'label': 'Volleyball'},
    {'value': 'soccer', 'label': 'Soccer'},
    {'value': 'padel', 'label': 'Padel'},
    {'value': 'golf', 'label': 'Golf'},
    {'value': 'football', 'label': 'Football'},
    {'value': 'softball', 'label': 'Softball'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void initState() {
    super.initState();
    selectedTypes = List.from(widget.currentFilter.courtTypes ?? []);

    selectedProvince = widget.currentFilter.province;
    minPriceController = TextEditingController(
      text: widget.currentFilter.priceMin?.toString() ?? '',
    );
    maxPriceController = TextEditingController(
      text: widget.currentFilter.priceMax?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    minPriceController.dispose();
    maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'FILTER',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Type Section
            const Text(
              'TYPE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: courtTypes.map((type) {
                final isSelected = selectedTypes.contains(type['value']);
                return FilterChip(
                  label: Text(type['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedTypes.add(type['value']!);
                      } else {
                        selectedTypes.remove(type['value']!);
                      }
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Colors.green.shade100,
                  checkmarkColor: Colors.green.shade700,
                  side: BorderSide(
                    color: isSelected ? Colors.green : Colors.grey.shade300,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Province Section
            const Text(
              'PROVINCE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedProvince,
              decoration: InputDecoration(
                hintText: '-- All Provinces --',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('-- All Provinces --'),
                ),
                ...widget.provinces.map((province) {
                  return DropdownMenuItem<String>(
                    value: province.name,
                    child: Text(province.name),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  selectedProvince = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Price Section
            const Text(
              'PRICE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Min price',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Max price',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Apply Button
            ElevatedButton(
              onPressed: () {
                final filter = CourtFilter(
                  courtTypes: selectedTypes,
                  province: selectedProvince,
                  priceMin: minPriceController.text.isNotEmpty
                      ? double.tryParse(minPriceController.text)
                      : null,
                  priceMax: maxPriceController.text.isNotEmpty
                      ? double.tryParse(maxPriceController.text)
                      : null,
                  latitude: widget.currentFilter.latitude,
                  longitude: widget.currentFilter.longitude,
                );
                Navigator.pop(context, filter);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'APPLY FILTER',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}