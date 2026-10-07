import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'parental_settings_screen.dart';

class ParentGateDialog extends StatefulWidget {
  final VoidCallback? onSuccess;

  const ParentGateDialog({super.key, this.onSuccess});

  static Future<bool?> show(BuildContext context, {VoidCallback? onSuccess}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => ParentGateDialog(onSuccess: onSuccess),
    );
  }

  @override
  State<ParentGateDialog> createState() => _ParentGateDialogState();
}

class _ParentGateDialogState extends State<ParentGateDialog>
    with SingleTickerProviderStateMixin {
  late int _num1;
  late int _num2;
  late int _gateAnswer;
  String _inputDigits = "";
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();
  late AnimationController _shakeController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateEquation();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _generateEquation() {
    setState(() {
      _num1 = _random.nextInt(9) + 1; // 1 to 9
      _num2 = _random.nextInt(9) + 1; // 1 to 9
      _gateAnswer = _num1 + _num2;
      _inputDigits = "";
    });
  }

  void _onDigitPressed(String digit) {
    if (_inputDigits.length < 3) {
      setState(() {
        _inputDigits += digit;
        _errorMessage = null;
      });
    }
  }

  void _onBackspacePressed() {
    if (_inputDigits.isNotEmpty) {
      setState(() {
        _inputDigits = _inputDigits.substring(0, _inputDigits.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _onClearPressed() {
    setState(() {
      _inputDigits = "";
      _errorMessage = null;
    });
  }

  Future<void> _submitAnswer() async {
    final entered = int.tryParse(_inputDigits);
    if (entered != null && entered == _gateAnswer) {
      // Correct!
      Navigator.of(context).pop(true);
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ParentalSettingsScreen(),
          ),
        );
      }
    } else {
      // Incorrect: play sound, shake, clear input, generate new equation
      _shakeController.forward(from: 0.0);
      try {
        await _audioPlayer.play(AssetSource('audio/wrong_code.mp3'));
      } catch (e) {
        debugPrint("Error playing wrong_code.mp3: $e");
      }

      setState(() {
        _errorMessage = "Incorrect! A new problem has been generated.";
        _generateEquation();
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Widget _buildKeypadButton({
    required Widget child,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: Material(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 16,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Header with Lock Icon and Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          color: Color(0xFF6C63FF),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Parents Only",
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF11153B),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Instruction Text
              Text(
                "Please solve this simple problem to enter parental controls:",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),

              // Animated Equation & Answer Box
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final offset = sin(_shakeController.value * pi * 4) * 8;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6C63FF).withOpacity(0.08),
                        const Color(0xFF5A4FCF).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _errorMessage != null
                          ? Colors.redAccent.withOpacity(0.6)
                          : const Color(0xFF6C63FF).withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Equation Text
                      Text(
                        "What is $_num1 + $_num2 ?",
                        style: GoogleFonts.nunito(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF6C63FF),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Input Digits Display
                      Container(
                        constraints: const BoxConstraints(minWidth: 120),
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF6C63FF).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _inputDigits.isEmpty ? "_ _" : _inputDigits,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF11153B),
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.redAccent,
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Classic Numeric Keypad (0-9)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildKeypadButton(
                          child: Text(
                            "1",
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF11153B),
                            ),
                          ),
                          onPressed: () => _onDigitPressed("1"),
                        ),
                      ),
                      Expanded(
                        child: _buildKeypadButton(
                          child: Text(
                            "2",
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF11153B),
                            ),
                          ),
                          onPressed: () => _onDigitPressed("2"),
                        ),
                      ),
                      Expanded(
                        child: _buildKeypadButton(
                          child: Text(
                            "3",
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF11153B),
                            ),
                          ),
                          onPressed: () => _onDigitPressed("3"),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildKeypadButton(
                          child: Text(
                            "4",
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF11153B),
                            ),
                          ),
                          onPressed: () => _onDigitPressed("4"),
                        ),
                      ),
                      Expanded(
                        child: _buildKeypadButton(
                          child: Text(
                            "5",
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF11153B),
                            ),
                          ),
                          onPressed: () => _onDigitPressed("5"),
                        ),
                      ),
                      Expanded(
                        child: _buildKeypadButton(
                          child: Text(
                            "6",
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF11153B),
                            ),
                          ),
                          onPressed: () => _onDigitPressed("6"),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildKeypadButton(
                          child: Text(
                            "7",
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF11153B),
                            ),
                          ),
                          onPressed: () => _onDigitPressed("7"),
                        ),
                      ),
                      Expanded(
                        child: _buildKeypadButton(
                          child: Text(
                            "8",
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF11153B),
                            ),
                          ),
                          onPressed: () => _onDigitPressed("8"),
                        ),
                      ),
                      Expanded(
                        child: _buildKeypadButton(
                          child: Text(
                            "9",
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF11153B),
                            ),
                          ),
                          onPressed: () => _onDigitPressed("9"),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildKeypadButton(
                          backgroundColor: Colors.grey.shade100,
                          child: const Icon(
                            Icons.backspace_outlined,
                            size: 20,
                            color: Color(0xFF11153B),
                          ),
                          onPressed: _onBackspacePressed,
                        ),
                      ),
                      Expanded(
                        child: _buildKeypadButton(
                          child: Text(
                            "0",
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF11153B),
                            ),
                          ),
                          onPressed: () => _onDigitPressed("0"),
                        ),
                      ),
                      Expanded(
                        child: _buildKeypadButton(
                          backgroundColor: Colors.red.shade50,
                          child: Text(
                            "C",
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.red.shade700,
                            ),
                          ),
                          onPressed: _onClearPressed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Action Buttons: Cancel and Submit
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 4,
                        shadowColor: const Color(0xFF6C63FF).withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _submitAnswer,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            "Submit",
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
