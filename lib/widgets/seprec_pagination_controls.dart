import 'package:flutter/material.dart';

class SeprecPaginationControls extends StatelessWidget {
  final int currentPage;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const SeprecPaginationControls({
    super.key,
    required this.currentPage,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PageButton(
            icon: Icons.chevron_left_rounded,
            tooltip: 'Página anterior',
            onPressed: onPrevious,
          ),
          const SizedBox(width: 14),
          Text(
            'Página $currentPage',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 14),
          _PageButton(
            icon: Icons.chevron_right_rounded,
            tooltip: 'Página siguiente',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _PageButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return SizedBox(
      width: 40,
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF102B3D),
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? const Color(0xFF50E4D6) : Colors.white24,
            width: 0.8,
          ),
        ),
        child: IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(
            width: 40,
            height: 40,
          ),
          icon: Icon(
            icon,
            size: 20,
            color: enabled ? Colors.white : Colors.white38,
          ),
        ),
      ),
    );
  }
}
