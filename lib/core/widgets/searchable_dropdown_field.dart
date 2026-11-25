import 'package:flutter/material.dart';

/// Desplegable con buscador integrado.
///
/// Muestra un input normal con icono opcional. Al tocarlo se abre un diálogo
/// con campo de búsqueda, contador de resultados y lista filtrada.
class SearchableDropdownField<TItem, TValue> extends StatelessWidget {
  final String label;
  final TValue? value;
  final List<TItem> items;
  final String Function(TItem) itemName;
  final TValue Function(TItem) itemId;
  final void Function(TValue?) onChanged;
  final String? hint;
  final IconData? prefixIcon;
  final String emptyLabel;

  const SearchableDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemName,
    required this.itemId,
    required this.onChanged,
    this.hint,
    this.prefixIcon,
    this.emptyLabel = 'No hay resultados',
  });

  @override
  Widget build(BuildContext context) {
    final selectedName = value == null
        ? null
        : items.firstWhere(
            (item) => itemId(item) == value,
            orElse: () => items.first,
          );

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _showPicker(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, size: 20)
              : const Icon(Icons.search, size: 20),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                selectedName == null
                    ? (hint ?? 'Selecciona $label')
                    : itemName(selectedName),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    String query = '';
    TValue? selected = value;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogCtx, setState) {
            final filtered = items.where((item) {
              final name = itemName(item).toLowerCase();
              return query.isEmpty || name.contains(query.toLowerCase());
            }).toList();

            final total = items.length;
            final showing = filtered.length;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Encabezado
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            prefixIcon ?? Icons.search,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Selecciona $label',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Campo de búsqueda
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Buscar $label...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: query.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => setState(() => query = ''),
                                )
                              : null,
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (val) => setState(() => query = val),
                      ),
                    ),

                    // Contador
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              showing == total
                                  ? '$showing $label${total != 1 ? 's' : ''}'
                                  : '$showing de $total $label${total != 1 ? 's' : ''}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                    ),

                    // Lista
                    Expanded(
                      child: showing == 0
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 48,
                                    color: Colors.grey.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    emptyLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: showing,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                final isSelected = itemId(item) == selected;
                                return Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 4,
                                    ),
                                    title: Text(itemName(item)),
                                    trailing: isSelected
                                        ? Icon(
                                            Icons.check_circle_rounded,
                                            color: Theme.of(context).colorScheme.primary,
                                          )
                                        : null,
                                    onTap: () {
                                      selected = itemId(item);
                                      Navigator.pop(dialogContext);
                                      onChanged(selected);
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
