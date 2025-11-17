import 'package:bmi_calculator/widget/app_input_field.dart';
import 'package:flutter/material.dart';

enum WeightUnit { kg, lb }
enum HeightType { meter, cm, feetInch }

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  WeightUnit weightUnit = WeightUnit.kg;
  HeightType heightType = HeightType.meter;

  // TWO WEIGHT CONTROLLERS
  final TextEditingController _kgController = TextEditingController();
  final TextEditingController _lbController = TextEditingController();

  // HEIGHT CONTROLLERS
  final TextEditingController _meterController = TextEditingController();
  final TextEditingController _cmController = TextEditingController();
  final TextEditingController _feetController = TextEditingController();
  final TextEditingController _inchController = TextEditingController();

  String bmiResult = '';
  String category = '';
  Color categoryColor = Colors.grey;

  @override
  void initState() {
    super.initState();

    // Weight controllers
    _kgController.addListener(_clearResultsOnInput);
    _lbController.addListener(_clearResultsOnInput);

    // Height controllers
    _meterController.addListener(_clearResultsOnInput);
    _cmController.addListener(_clearResultsOnInput);
    _feetController.addListener(_clearResultsOnInput);
    _inchController.addListener(_clearResultsOnInput);
  }

  @override
  void dispose() {
    _kgController.removeListener(_clearResultsOnInput);
    _lbController.removeListener(_clearResultsOnInput);
    _meterController.removeListener(_clearResultsOnInput);
    _cmController.removeListener(_clearResultsOnInput);
    _feetController.removeListener(_clearResultsOnInput);
    _inchController.removeListener(_clearResultsOnInput);

    _kgController.dispose();
    _lbController.dispose();
    _meterController.dispose();
    _cmController.dispose();
    _feetController.dispose();
    _inchController.dispose();

    super.dispose();
  }

  void _clearResultsOnInput() {
    if (bmiResult.isNotEmpty) {
      _clearResults();
    }
  }

  // ----------------------
  // NORMALIZE INPUT
  // (handles Bangla digits, commas, extra characters)
  // ----------------------
  String _normalizeNumberInput(String raw) {
    String text = raw.trim();

    // Bangla → English digits
    const banglaDigits = '০১২৩৪৫৬৭৮৯';
    const latinDigits = '0123456789';
    for (int i = 0; i < banglaDigits.length; i++) {
      text = text.replaceAll(banglaDigits[i], latinDigits[i]);
    }

    // Replace comma with dot
    text = text.replaceAll(',', '.');

    // Keep only digits, dot and minus
    text = text.replaceAll(RegExp(r'[^0-9\.\-]'), '');

    return text;
  }

  // ----------------------
  // WEIGHT
  // ----------------------
  double? _convertWeightToKg() {
    // Use controller depending on selected unit
    final String rawText =
    (weightUnit == WeightUnit.kg) ? _kgController.text : _lbController.text;

    final normalized = _normalizeNumberInput(rawText);

    if (normalized.isEmpty) {
      return null;
    }

    final value = double.tryParse(normalized);
    if (value == null || value <= 0) {
      return null;
    }

    // Convert to kg if needed
    if (weightUnit == WeightUnit.kg) {
      return value;
    } else {
      // LB → KG
      return value * 0.45359237;
    }
  }

  // ----------------------
  // HEIGHT
  // ----------------------
  double? _meterToM() {
    final normalized = _normalizeNumberInput(_meterController.text);
    if (normalized.isEmpty) return null;

    final v = double.tryParse(normalized);
    if (v == null || v <= 0) return null;

    return v;
  }

  double? _cmToM() {
    final normalized = _normalizeNumberInput(_cmController.text);
    if (normalized.isEmpty) return null;

    final v = double.tryParse(normalized);
    if (v == null || v <= 0) return null;

    return v / 100.0;
  }

  double? _feetInchToM() {
    final feetNorm = _normalizeNumberInput(_feetController.text);
    final inchNorm = _normalizeNumberInput(_inchController.text);

    final double feet =
    feetNorm.isEmpty ? 0.0 : (double.tryParse(feetNorm) ?? -1.0);
    final double inch =
    inchNorm.isEmpty ? 0.0 : (double.tryParse(inchNorm) ?? -1.0);

    if (feet < 0 || inch < 0) {
      return null;
    }

    final totalInches = (feet * 12.0) + inch;
    if (totalInches <= 0) {
      return null;
    }

    return totalInches * 0.0254;
  }

  double? _getHeightInMeters() {
    switch (heightType) {
      case HeightType.meter:
        return _meterToM();
      case HeightType.cm:
        return _cmToM();
      case HeightType.feetInch:
        return _feetInchToM();
    }
  }

  // ----------------------
  // CATEGORY
  // ----------------------
  void _setCategory(double bmi) {
    if (bmi < 18.5) {
      category = "Underweight";
      categoryColor = Colors.blue;
    } else if (bmi < 25.0) {
      category = "Normal";
      categoryColor = Colors.green;
    } else if (bmi < 30.0) {
      category = "Overweight";
      categoryColor = Colors.orange;
    } else {
      category = "Obese";
      categoryColor = Colors.red;
    }
  }

  void _clearResults() {
    setState(() {
      bmiResult = '';
      category = '';
      categoryColor = Colors.grey;
    });
  }

  // ----------------------
  // CALCULATE BMI
  // ----------------------
  void _calculateBMI() {
    final weightKg = _convertWeightToKg();
    if (weightKg == null) {
      _showError("Please enter a valid, positive weight.");
      _clearResults();
      return;
    }

    final heightM = _getHeightInMeters();
    if (heightM == null) {
      _showError("Please enter a valid, positive height.");
      _clearResults();
      return;
    }

    final bmi = weightKg / (heightM * heightM);

    setState(() {
      bmiResult = bmi.toStringAsFixed(1); // 1 decimal place
      _setCategory(bmi);
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ----------------------
  // UI
  // ----------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // WEIGHT UNIT SELECTOR
            const Text(
              'Select weight unit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SegmentedButton<WeightUnit>(
              segments: const [
                ButtonSegment(value: WeightUnit.kg, label: Text("KG")),
                ButtonSegment(value: WeightUnit.lb, label: Text("LB")),
              ],
              selected: {weightUnit},
              onSelectionChanged: (newSelection) {
                setState(() {
                  weightUnit = newSelection.first;
                  // Keep text in both controllers, only clear result
                  _clearResults();
                });
              },
            ),

            const SizedBox(height: 12),

            // WEIGHT INPUT FIELD (changes with unit)
            if (weightUnit == WeightUnit.kg)
              AppInputField(
                hintText: 'Enter weight in kg',
                controller: _kgController,
                textInputType:
                const TextInputType.numberWithOptions(decimal: true),
              )
            else
              AppInputField(
                hintText: 'Enter weight in lb',
                controller: _lbController,
                textInputType:
                const TextInputType.numberWithOptions(decimal: true),
              ),

            const SizedBox(height: 24),

            // HEIGHT UNIT SELECTOR
            const Text(
              'Select height unit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SegmentedButton<HeightType>(
              segments: const [
                ButtonSegment(value: HeightType.meter, label: Text('Meter')),
                ButtonSegment(value: HeightType.cm, label: Text('CM')),
                ButtonSegment(
                  value: HeightType.feetInch,
                  label: Text('Feet/Inch'),
                ),
              ],
              selected: {heightType},
              onSelectionChanged: (newSelection) {
                setState(() {
                  heightType = newSelection.first;
                  _meterController.clear();
                  _cmController.clear();
                  _feetController.clear();
                  _inchController.clear();
                  _clearResults();
                });
              },
            ),

            const SizedBox(height: 12),

            // HEIGHT INPUT FIELDS
            if (heightType == HeightType.meter)
              AppInputField(
                hintText: "Enter height in meters",
                controller: _meterController,
                textInputType:
                const TextInputType.numberWithOptions(decimal: true),
              )
            else if (heightType == HeightType.cm)
              AppInputField(
                hintText: "Enter height in cm",
                controller: _cmController,
                textInputType:
                const TextInputType.numberWithOptions(decimal: true),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: AppInputField(
                      hintText: 'Feet',
                      controller: _feetController,
                      textInputType:
                      const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppInputField(
                      hintText: 'Inches',
                      controller: _inchController,
                      textInputType:
                      const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 32),

            // CALCULATE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculateBMI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Calculate BMI",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // RESULT CARD
            if (bmiResult.isNotEmpty)
              Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 32,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Your BMI is',
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          bmiResult,
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
