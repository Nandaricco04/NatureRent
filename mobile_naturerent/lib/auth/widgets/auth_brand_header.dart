import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF2B8A35),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset('assets/images/Logo.png'),
          ),
          const SizedBox(width: 10),
          RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              children: const [
                TextSpan(
                  text: 'Nature',
                  style: TextStyle(color: Color(0xFF297B2D)),
                ),
                TextSpan(
                  text: 'Rent',
                  style: TextStyle(color: Color(0xFFFB8C00)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
