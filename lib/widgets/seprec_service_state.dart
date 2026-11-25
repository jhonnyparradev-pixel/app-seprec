import 'package:flutter/material.dart';

class SeprecServiceState extends StatelessWidget {
  final bool isError;
  final String? details;
  final VoidCallback? onRetry;

  const SeprecServiceState({
    super.key,
    this.isError = false,
    this.details,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor =
        isError ? const Color(0xFFE8B86D) : const Color(0xFF50E4D6);

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xCC061523),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accentColor.withValues(alpha: 0.22)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isError ? Icons.cloud_off_rounded : Icons.search_off_rounded,
                  color: accentColor,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isError
                            ? 'No se pudieron cargar los datos'
                            : 'No hay datos disponibles',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isError) ...[
                        const SizedBox(height: 1),
                        Text(
                          'Comprueba tu conexión e inténtalo nuevamente.',
                          style: const TextStyle(
                            color: Color(0xFFD0E3DA),
                            fontSize: 10,
                          ),
                        ),
                        if (onRetry != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: onRetry,
                              icon: const Icon(Icons.refresh_rounded, size: 14),
                              label: const Text('Volver a cargar'),
                              style: TextButton.styleFrom(
                                foregroundColor: accentColor,
                                visualDensity: VisualDensity.compact,
                                minimumSize: const Size(0, 24),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                textStyle: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                      ] else if (details != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          details!,
                          style: const TextStyle(
                            color: Color(0xFFD0E3DA),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
