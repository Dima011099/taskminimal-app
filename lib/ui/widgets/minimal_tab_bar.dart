import 'package:flutter/material.dart';

class MinimalTabBar extends StatelessWidget {
  final VoidCallback onProfilePressed;
  final VoidCallback onFolderPressed;
  final VoidCallback onSyncPressed;
  final VoidCallback onExportPressed;
  final VoidCallback onAddPressed;

  const MinimalTabBar({
    super.key,
    required this.onProfilePressed,
    required this.onFolderPressed,
    required this.onSyncPressed,
    required this.onExportPressed,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 45, right: 45, bottom: 28),
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(32),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Боковые навигационные кнопки
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.person_outline_rounded, color: Color(0xFF64748B), size: 25),
                onPressed: onProfilePressed,
              ),
              IconButton(
                icon: const Icon(Icons.folder_open_rounded, color: Color(0xFF64748B), size: 25),
                onPressed: onFolderPressed,
              ),
              
              // Разделитель для центральной кнопки (52px)
              const SizedBox(width: 52),
              
              IconButton(
                icon: const Icon(Icons.sync_rounded, color: Color(0xFF64748B), size: 25),
                onPressed: onSyncPressed,
              ),
              IconButton(
                icon: const Icon(Icons.upload_rounded, color: Color(0xFF64748B), size: 25),
                onPressed: onExportPressed,
              ),
            ],
          ),

          // Центральная акцентная кнопка «Плюс»
         Positioned(
  top: -8, // Немного увеличили смещение вверх для лучшего объема
  left: 0,
  right: 0,
  child: Center(
    child: GestureDetector(
      onTap: onAddPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Смещаем точки начала и конца, чтобы градиент шел строго из верхнего левого угла в самый низ
          gradient: const LinearGradient(
            begin: Alignment(-0.05, -0.05), 
            end: Alignment(0.05, 0.05),
            colors: [
             /* Color(0xFF1D4ED8)*/
             Color(0xFF3B82F6), // Яркий кобальт на самом пике света
              Color(0xFF3B82F6), // Глубокий ультрамарин в тени для объема
            ],
          ),
          boxShadow: [
            // Та самая «крутая» светящаяся неоновая тень, которая приподнимает кнопку
            BoxShadow(
              color: const Color(0xFF2563EB),
              blurRadius: 5,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_task,
          color: Colors.white,
          size: 30,
        ),
      ),
    ),
  ),
),

        ],
      ),
    );
  }
}
