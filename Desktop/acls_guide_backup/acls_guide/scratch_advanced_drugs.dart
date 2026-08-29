import 'dart:io';

void main() {
  var file = File(r'c:\Users\danro\Desktop\acls_guide_backup\acls_guide\lib\ui\screens\cpr_dashboard_screen.dart');
  String content = file.readAsStringSync();

  // 1. Locate the _showOtherDrugsModal function and replace it with a call to the new widget.
  // The function starts with: void _showOtherDrugsModal(BuildContext context, CprDynamicNotifier notifier) { ... }
  // And ends right before: Color _hexToColor(String hexString) {

  int startIndex = content.indexOf('void _showOtherDrugsModal(BuildContext context, CprDynamicNotifier notifier) {');
  int endIndex = content.indexOf('Color _hexToColor(String hexString) {');
  
  if (startIndex == -1 || endIndex == -1) {
    print('Error: Could not find _showOtherDrugsModal or _hexToColor');
    return;
  }

  String replacement = '''
  void _showOtherDrugsModal(BuildContext context, CprDynamicNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _AdvancedDrugsModal(notifier: notifier),
    );
  }

  ''';

  content = content.replaceRange(startIndex, endIndex, replacement);

  // 2. Append the new _AdvancedDrugsModal class at the end of the file
  String advancedModalClass = '''

class _AdvancedDrugsModal extends StatefulWidget {
  final CprDynamicNotifier notifier;
  const _AdvancedDrugsModal({required this.notifier});

  @override
  State<_AdvancedDrugsModal> createState() => _AdvancedDrugsModalState();
}

class _AdvancedDrugsModalState extends State<_AdvancedDrugsModal> {
  final TextEditingController _customDrugCtrl = TextEditingController();
  final TextEditingController _customDoseCtrl = TextEditingController();

  final List<Map<String, dynamic>> _drugs = [
    {'name': 'Bicarbonato 8,4%', 'sug': '1 mEq/kg', 'icon': Icons.medication_liquid_rounded, 'color': AppColors.info},
    {'name': 'Gluconato Cálcio 10%', 'sug': '15-30 mL', 'icon': Icons.medication_liquid_rounded, 'color': AppColors.info},
    {'name': 'Cloreto Cálcio 10%', 'sug': '5-10 mL', 'icon': Icons.medication_liquid_rounded, 'color': AppColors.info},
    {'name': 'Sulfato Magnésio 10%', 'sug': '1-2 g', 'icon': Icons.medication_liquid_rounded, 'color': AppColors.info},
    {'name': 'Insulina Regular', 'sug': '10 UI', 'icon': Icons.vaccines_rounded, 'color': AppColors.warning},
    {'name': 'KCl (Cloreto Potássio)', 'sug': '10-20 mEq/h', 'icon': Icons.medication_liquid_rounded, 'color': AppColors.danger},
    {'name': 'SF 0.9%', 'sug': '500-1000 mL', 'icon': Icons.water_drop_rounded, 'color': AppColors.info},
    {'name': 'Ringer Lactato', 'sug': '500-1000 mL', 'icon': Icons.water_drop_rounded, 'color': AppColors.info},
    {'name': 'Plasma-Lyte', 'sug': '500-1000 mL', 'icon': Icons.water_drop_rounded, 'color': AppColors.info},
    {'name': 'Glicose 50%', 'sug': '20-50 mL', 'icon': Icons.medication_liquid_rounded, 'color': AppColors.info},
    {'name': 'Naloxona (Narcan)', 'sug': '0,4-2 mg', 'icon': Icons.vaccines_rounded, 'color': AppColors.warning},
    {'name': 'Alteplase', 'sug': '50 mg bolus', 'icon': Icons.bloodtype_rounded, 'color': AppColors.danger},
  ];

  late List<TextEditingController> _doseCtrls;

  @override
  void initState() {
    super.initState();
    _doseCtrls = List.generate(_drugs.length, (index) => TextEditingController());
  }

  @override
  void dispose() {
    _customDrugCtrl.dispose();
    _customDoseCtrl.dispose();
    for (var ctrl in _doseCtrls) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                'Administrar Drogas',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              
              // Custom Drug Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _customDrugCtrl,
                        decoration: InputDecoration(
                          hintText: 'Droga Customizada',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _customDoseCtrl,
                        decoration: InputDecoration(
                          hintText: 'Dose',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 32),
                      onPressed: () {
                        if (_customDrugCtrl.text.isNotEmpty) {
                          String dose = _customDoseCtrl.text.isNotEmpty ? ' (Dose: \${_customDoseCtrl.text})' : '';
                          widget.notifier.registerDrug('\${_customDrugCtrl.text}\$dose');
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              
              // Predefined Drugs List
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _drugs.length,
                  itemBuilder: (ctx, i) {
                    final drug = _drugs[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Icon(drug['icon'] as IconData, color: drug['color'] as Color),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  drug['name'] as String,
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                ),
                                Text(
                                  'Sugestão: \${drug['sug']}',
                                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _doseCtrls[i],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Dose Real',
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                isDense: true,
                              ),
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                            onPressed: () {
                              String doseStr = _doseCtrls[i].text.trim();
                              String finalLog = doseStr.isNotEmpty
                                  ? '\${drug['name']} (Dose administrada: \$doseStr)'
                                  : '\${drug['name']} (Dose sugerida: \${drug['sug']})';
                              
                              widget.notifier.registerDrug(finalLog);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
''';

  content = content + advancedModalClass;

  file.writeAsStringSync(content);
  print('done - advanced drugs modal implementation written');
}
