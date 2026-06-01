import 'package:flutter/material.dart';

class MinimalDesktopSidePanel extends StatelessWidget {
  final VoidCallback onProfilePressed;
  final VoidCallback onFolderPressed;
  final VoidCallback onSyncPressed;
  final VoidCallback onImportPressed;
  final VoidCallback onAddProjectPressed;

  const MinimalDesktopSidePanel({
    super.key,
    required this.onProfilePressed,
    required this.onFolderPressed,
    required this.onSyncPressed,
    required this.onImportPressed,
    required this.onAddProjectPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Паддинги строго по сетке вашего макета десктопа
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 28, top: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        // Сверху делаем тонкую разделительную черту, чтобы отделить панель от списка проектов
        border: Border(
          top: BorderSide(
            color: Color(0xFFF1F5F9), // Светлый Slate 100 из вашего разделителя
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ====== КНОПКА ДОБАВЛЕНИЯ ПРОЕКТА ======
          SizedBox(
            width: double.infinity,
            height: 44, // Высота 44px соответствует высоте мобильного таббара
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB), // Ваш фирменный синий кобальт
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Скругление из вашей дизайн-системы
                ),
              ),
              onPressed: onAddProjectPressed,
              icon: const Icon(Icons.add_box_outlined, size: 20),
              label: const Text(
                'добавить проект',
                style: TextStyle(
                  fontFamily: '.SF Pro Text', // Системный шрифт Apple
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16), // Отступ между кнопкой и иконками

          // ====== СИСТЕМНЫЕ НАВИГАЦИОННЫЕ КНОПКИ ======
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Равномерно распределяем по ширине (300px)
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.person_outline_rounded, color: Color(0xFF64748B), size: 25), // Slate 500
                onPressed: onProfilePressed,
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.analytics_outlined, color: Color(0xFF64748B), size: 25),
                onPressed: onFolderPressed,
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.sync_rounded, color: Color(0xFF64748B), size: 25),
                onPressed: onSyncPressed,
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.vertical_align_bottom_rounded, color: Color(0xFF64748B), size: 25),
                onPressed: onImportPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
