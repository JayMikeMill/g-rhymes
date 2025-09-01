import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dialogs/dict_builder_dialog.dart';

class AppBarMenuItem {
  final String label;
  final IconData? icon;
  final VoidCallback action;

  AppBarMenuItem({
    required this.label,
    this.icon,
    required this.action,
  });
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final void Function(String) onSearch;

  const MyAppBar({
    super.key,
    required this.onSearch,

  });

  @override
  Widget build(BuildContext context) {
    final items = _menuItems(context);
    TextEditingController searchController = TextEditingController();

    return AppBar(
      backgroundColor: _backgroundColor(context),
      centerTitle: true,
      title: SizedBox(
        height: 40,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Find Rhymes...',
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: onSearch,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => onSearch(searchController.text),
              icon: const Icon(Icons.search),
            ),
          ],
        ),
      ),
      actions: [
        PopupMenuButton<AppBarMenuItem>(
          itemBuilder: (context) {
            return items.map((item) {
              return PopupMenuItem<AppBarMenuItem>(
                value: item,
                child: Row(
                  children: [
                    if (item.icon != null) ...[
                      Icon(item.icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(item.label),
                  ],
                ),
              );
            }).toList();
          },
          onSelected: (item) => item.action(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Color _backgroundColor(BuildContext context) =>
      Theme.of(context).colorScheme.inversePrimary;

  List<AppBarMenuItem> _menuItems(BuildContext context) {
    List<AppBarMenuItem> menu = [
      AppBarMenuItem(
        label: 'Settings',
        icon: Icons.settings,
        action: () => _showDialog(context, 'Settings', 'Settings dialog'),
      ),
      AppBarMenuItem(
        label: 'Help',
        icon: Icons.help,
        action: () => _showDialog(context, 'Help', 'Help dialog'),
      ),
    ];

    if (kDebugMode && Platform.isWindows) {
      menu.add(AppBarMenuItem(
        label: 'Build Dictionaries',
        icon: Icons.dataset_outlined,
        action: () => DictBuilderDialog(context).show(),
      ));
    }

    return menu;
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
