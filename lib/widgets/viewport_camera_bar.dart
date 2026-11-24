import 'package:flutter/material.dart';
import '../controllers/tshirt_controller.dart';

class ViewportCameraBar extends StatelessWidget {
  const ViewportCameraBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TshirtController.to;

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF14171F).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCamButton('Front', () => controller.setCameraView('front')),
              _buildCamButton('Back', () => controller.setCameraView('back')),
              _buildCamButton('Left Sleeve', () => controller.setCameraView('left-sleeve')),
              _buildCamButton('Right Sleeve', () => controller.setCameraView('right-sleeve')),
              _buildCamButton('Reset', () => controller.setCameraView('reset')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCamButton(String label, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70),
        ),
      ),
    );
  }
}
