import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../providers/maps_provider.dart';

class LocationSearchWidget extends ConsumerStatefulWidget {
  final void Function(LatLng) onLocationSelected;

  const LocationSearchWidget({
    super.key,
    required this.onLocationSelected,
  });

  @override
  ConsumerState<LocationSearchWidget> createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends ConsumerState<LocationSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final geocodingState = ref.watch(geocodingNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Buscar ubicación...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: geocodingState.when(
            data: (_) => _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      _focusNode.unfocus();
                    },
                  )
                : null,
            loading: () => const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => const Icon(Icons.error, color: Colors.red),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onSubmitted: _searchLocation,
      ),
    );
  }

  void _searchLocation(String query) {
    if (query.trim().isEmpty) return;

    ref.read(geocodingNotifierProvider.notifier).geocodeAddress(query);

    ref.listen(geocodingNotifierProvider, (previous, next) {
      next.when(
        data: (coordinates) {
          if (coordinates != null) {
            widget.onLocationSelected(coordinates);
            _focusNode.unfocus();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ubicación encontrada: $query'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        loading: () {},
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo encontrar la ubicación: $query'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });
  }
}