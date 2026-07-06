import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Country {
  final String name;
  final String flag;
  final String code;
  const Country(this.name, this.flag, this.code);
}

class CountryPicker {
  // Popular countries shown at top (great for Morocco tourism!)
  static const List<Country> popularCountries = [
    Country('Morocco', '🇲🇦', 'MA'),
    Country('France', '🇫🇷', 'FR'),
    Country('Spain', '🇪🇸', 'ES'),
    Country('United States', '🇺🇸', 'US'),
    Country('United Kingdom', '🇬🇧', 'GB'),
    Country('Germany', '🇩🇪', 'DE'),
    Country('Italy', '🇮🇹', 'IT'),
    Country('Canada', '🇨🇦', 'CA'),
  ];

  static const List<Country> allCountries = [
    Country('Afghanistan', '🇦🇫', 'AF'),
    Country('Albania', '🇦🇱', 'AL'),
    Country('Algeria', '🇩🇿', 'DZ'),
    Country('Andorra', '🇦🇩', 'AD'),
    Country('Angola', '🇦🇴', 'AO'),
    Country('Argentina', '🇦🇷', 'AR'),
    Country('Armenia', '🇦🇲', 'AM'),
    Country('Australia', '🇦🇺', 'AU'),
    Country('Austria', '🇦🇹', 'AT'),
    Country('Azerbaijan', '🇦🇿', 'AZ'),
    Country('Bahrain', '🇧🇭', 'BH'),
    Country('Bangladesh', '🇧🇩', 'BD'),
    Country('Belarus', '🇧🇾', 'BY'),
    Country('Belgium', '🇧🇪', 'BE'),
    Country('Bolivia', '🇧🇴', 'BO'),
    Country('Bosnia and Herzegovina', '🇧🇦', 'BA'),
    Country('Brazil', '🇧🇷', 'BR'),
    Country('Bulgaria', '🇧🇬', 'BG'),
    Country('Cambodia', '🇰🇭', 'KH'),
    Country('Cameroon', '🇨🇲', 'CM'),
    Country('Canada', '🇨🇦', 'CA'),
    Country('Chile', '🇨🇱', 'CL'),
    Country('China', '🇨🇳', 'CN'),
    Country('Colombia', '🇨🇴', 'CO'),
    Country('Costa Rica', '🇨🇷', 'CR'),
    Country('Croatia', '🇭🇷', 'HR'),
    Country('Cuba', '🇨🇺', 'CU'),
    Country('Cyprus', '🇨🇾', 'CY'),
    Country('Czech Republic', '🇨🇿', 'CZ'),
    Country('Denmark', '🇩🇰', 'DK'),
    Country('Dominican Republic', '🇩🇴', 'DO'),
    Country('Ecuador', '🇪🇨', 'EC'),
    Country('Egypt', '🇪🇬', 'EG'),
    Country('Estonia', '🇪🇪', 'EE'),
    Country('Ethiopia', '🇪🇹', 'ET'),
    Country('Finland', '🇫🇮', 'FI'),
    Country('France', '🇫🇷', 'FR'),
    Country('Georgia', '🇬🇪', 'GE'),
    Country('Germany', '🇩🇪', 'DE'),
    Country('Ghana', '🇬🇭', 'GH'),
    Country('Greece', '🇬🇷', 'GR'),
    Country('Guatemala', '🇬🇹', 'GT'),
    Country('Honduras', '🇭🇳', 'HN'),
    Country('Hong Kong', '🇭🇰', 'HK'),
    Country('Hungary', '🇭🇺', 'HU'),
    Country('Iceland', '🇮🇸', 'IS'),
    Country('India', '🇮🇳', 'IN'),
    Country('Indonesia', '🇮🇩', 'ID'),
    Country('Iran', '🇮🇷', 'IR'),
    Country('Iraq', '🇮🇶', 'IQ'),
    Country('Ireland', '🇮🇪', 'IE'),
    Country('Israel', '🇮🇱', 'IL'),
    Country('Italy', '🇮🇹', 'IT'),
    Country('Ivory Coast', '🇨🇮', 'CI'),
    Country('Jamaica', '🇯🇲', 'JM'),
    Country('Japan', '🇯🇵', 'JP'),
    Country('Jordan', '🇯🇴', 'JO'),
    Country('Kazakhstan', '🇰🇿', 'KZ'),
    Country('Kenya', '🇰🇪', 'KE'),
    Country('Kuwait', '🇰🇼', 'KW'),
    Country('Latvia', '🇱🇻', 'LV'),
    Country('Lebanon', '🇱🇧', 'LB'),
    Country('Libya', '🇱🇾', 'LY'),
    Country('Lithuania', '🇱🇹', 'LT'),
    Country('Luxembourg', '🇱🇺', 'LU'),
    Country('Malaysia', '🇲🇾', 'MY'),
    Country('Mali', '🇲🇱', 'ML'),
    Country('Malta', '🇲🇹', 'MT'),
    Country('Mauritania', '🇲🇷', 'MR'),
    Country('Mexico', '🇲🇽', 'MX'),
    Country('Moldova', '🇲🇩', 'MD'),
    Country('Monaco', '🇲🇨', 'MC'),
    Country('Mongolia', '🇲🇳', 'MN'),
    Country('Montenegro', '🇲🇪', 'ME'),
    Country('Morocco', '🇲🇦', 'MA'),
    Country('Mozambique', '🇲🇿', 'MZ'),
    Country('Myanmar', '🇲🇲', 'MM'),
    Country('Nepal', '🇳🇵', 'NP'),
    Country('Netherlands', '🇳🇱', 'NL'),
    Country('New Zealand', '🇳🇿', 'NZ'),
    Country('Nicaragua', '🇳🇮', 'NI'),
    Country('Niger', '🇳🇪', 'NE'),
    Country('Nigeria', '🇳🇬', 'NG'),
    Country('North Korea', '🇰🇵', 'KP'),
    Country('Norway', '🇳🇴', 'NO'),
    Country('Oman', '🇴🇲', 'OM'),
    Country('Pakistan', '🇵🇰', 'PK'),
    Country('Palestine', '🇵🇸', 'PS'),
    Country('Panama', '🇵🇦', 'PA'),
    Country('Paraguay', '🇵🇾', 'PY'),
    Country('Peru', '🇵🇪', 'PE'),
    Country('Philippines', '🇵🇭', 'PH'),
    Country('Poland', '🇵🇱', 'PL'),
    Country('Portugal', '🇵🇹', 'PT'),
    Country('Qatar', '🇶🇦', 'QA'),
    Country('Romania', '🇷🇴', 'RO'),
    Country('Russia', '🇷🇺', 'RU'),
    Country('Saudi Arabia', '🇸🇦', 'SA'),
    Country('Senegal', '🇸🇳', 'SN'),
    Country('Serbia', '🇷🇸', 'RS'),
    Country('Singapore', '🇸🇬', 'SG'),
    Country('Slovakia', '🇸🇰', 'SK'),
    Country('Slovenia', '🇸🇮', 'SI'),
    Country('Somalia', '🇸🇴', 'SO'),
    Country('South Africa', '🇿🇦', 'ZA'),
    Country('South Korea', '🇰🇷', 'KR'),
    Country('Spain', '🇪🇸', 'ES'),
    Country('Sri Lanka', '🇱🇰', 'LK'),
    Country('Sudan', '🇸🇩', 'SD'),
    Country('Sweden', '🇸🇪', 'SE'),
    Country('Switzerland', '🇨🇭', 'CH'),
    Country('Syria', '🇸🇾', 'SY'),
    Country('Taiwan', '🇹🇼', 'TW'),
    Country('Tanzania', '🇹🇿', 'TZ'),
    Country('Thailand', '🇹🇭', 'TH'),
    Country('Tunisia', '🇹🇳', 'TN'),
    Country('Turkey', '🇹🇷', 'TR'),
    Country('Uganda', '🇺🇬', 'UG'),
    Country('Ukraine', '🇺🇦', 'UA'),
    Country('United Arab Emirates', '🇦🇪', 'AE'),
    Country('United Kingdom', '🇬🇧', 'GB'),
    Country('United States', '🇺🇸', 'US'),
    Country('Uruguay', '🇺🇾', 'UY'),
    Country('Uzbekistan', '🇺🇿', 'UZ'),
    Country('Venezuela', '🇻🇪', 'VE'),
    Country('Vietnam', '🇻🇳', 'VN'),
    Country('Yemen', '🇾🇪', 'YE'),
    Country('Zimbabwe', '🇿🇼', 'ZW'),
  ];

  /// Show the bottom sheet country picker
  static Future<Country?> show(BuildContext context, {String? selectedCountry}) {
    return showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CountryPickerSheet(selectedCountry: selectedCountry),
    );
  }

  /// Find a country by its name (returns null if not found)
  static Country? findByName(String? name) {
    if (name == null || name.isEmpty) return null;
    try {
      return allCountries.firstWhere(
        (c) => c.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

class _CountryPickerSheet extends StatefulWidget {
  final String? selectedCountry;
  const _CountryPickerSheet({this.selectedCountry});

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Country> _filteredCountries = CountryPicker.allCountries;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = CountryPicker.allCountries;
      } else {
        _filteredCountries = CountryPicker.allCountries
            .where((c) => c.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchController.text.isNotEmpty;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

   return Container(
  height: MediaQuery.of(context).size.height * 0.85,
  decoration: BoxDecoration(
    color: theme.cardColor,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
  ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
  'Select Country',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Theme.of(context).textTheme.titleLarge?.color,
  ),
),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
  controller: _searchController,
  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
  decoration: InputDecoration(
    hintText: 'Search country...',
    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryOrange),
    filled: true,
    fillColor: isDark ? AppTheme.darkBackground : AppTheme.softBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
),
          ),
          const Divider(height: 1),
          // List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (!isSearching) ...[
                  _sectionLabel(theme, 'POPULAR'),
                  ...CountryPicker.popularCountries.map(_buildTile),
                  const SizedBox(height: 8),
                  _sectionLabel(theme, 'ALL COUNTRIES'),
                ],
                ..._filteredCountries.map(_buildTile),
                if (_filteredCountries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off,
                              size: 48, color: theme.textTheme.bodyMedium?.color?.withAlpha(150)),
                          const SizedBox(height: 12),
                          Text(
                            'No country found',
                            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(ThemeData theme, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: theme.textTheme.bodySmall?.color,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTile(Country country) {
  final isSelected = widget.selectedCountry == country.name;
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      return ListTile(
        leading: Text(country.flag, style: const TextStyle(fontSize: 28)),
        title: Text(
          country.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? AppTheme.primaryOrange
                : theme.textTheme.titleLarge?.color,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppTheme.primaryOrange)
            : null,
        onTap: () => Navigator.pop(context, country),
      );
    },
  );
}
}