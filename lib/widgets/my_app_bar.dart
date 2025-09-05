/*
 * Copyright (c) 2025 GWorks
 *
 * Licensed under the GWorks Non-Commercial License.
 * You may view, copy, and modify the source code.
 * You may redistribute the source code under the same terms.
 * You may build and use the code for personal or educational purposes.
 * You may NOT sell or redistribute the built binaries.
 *
 * For the full license text, see LICENSE file in this repository.
 *
 * File: my_app_bar.dart
 * Description: Custom AppBar widget with integrated menu items,
 *              and optional dictionary-building shortcut in debug mode.
 */

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dialogs/dict_builder_dialog.dart';

// -----------------------------------------------------------------------------
// Class: AppBarMenuItem
// Description: Represents a single menu item for the AppBar, with optional icon
//              and an action callback when selected.
// -----------------------------------------------------------------------------
class AppBarMenuItem {
  final String label;        /// Display label
  final IconData? icon;      /// Optional icon
  final VoidCallback action; /// Action invoked when selected

  AppBarMenuItem({
    required this.label,
    this.icon,
    required this.action,
  });
}

// -----------------------------------------------------------------------------
// Class: MyAppBar
// Description: Custom AppBar widget including:
//              - Search field with callback
//              - Popup menu items
//              - Optional debug menu for building dictionaries (Windows only)
// -----------------------------------------------------------------------------
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {

  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final items = _menuItems(context);

    return AppBar(
      backgroundColor: _backgroundColor(context),
      centerTitle: true,
      title: Row (
        children: [
          const Text(
            "G-RHYMES",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white, // main text color
              shadows: [
                Shadow(offset: Offset(-1, -1), color: Colors.black),
                Shadow(offset: Offset(1, -1), color: Colors.black),
                Shadow(offset: Offset(1, 1), color: Colors.black),
                Shadow(offset: Offset(-1, 1), color: Colors.black),
              ]
            ),
          ),
        ],
      ),
      // AppBar menu actions
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

  // ---------------------------------------------------------------------------
  /// Returns background color based on current theme
  Color _backgroundColor(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  // ---------------------------------------------------------------------------
  /// Returns the list of menu items for the AppBar
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

    // Add debug-only menu option for Windows
    if (kDebugMode && Platform.isWindows) {
      menu.add(AppBarMenuItem(
        label: 'Build Dictionaries',
        icon: Icons.dataset_outlined,
        action: () => DictBuilderDialog(context).show(),
      ));
    }

    return menu;
  }

  // ---------------------------------------------------------------------------
  /// Shows a simple dialog with title and content
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
