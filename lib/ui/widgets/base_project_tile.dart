import 'package:flutter/material.dart';

class BaseProjectTile extends StatelessWidget {
  final int projectId;
  final String title;

  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Function(int, String) onUpdate;
  final Function(int) onExport; 
  
  final TextEditingController input = TextEditingController();
  

  BaseProjectTile({
    super.key,
    required this.title,
    this.onTap,
    this.onDelete,
    required this.onUpdate,
    required this.onExport,
    required this.projectId
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

   // Автоматически берем первую букву названия проекта для аватара
  final String firstLetter = title.isNotEmpty ? title[0].toUpperCase() : 'P';

  return Material(
    color: Colors.transparent,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          // Легкий волновой эффект без изменения фона самой карточки
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 4, // Боковые отступы строго 24px по сетке макета
              vertical: 12,   // Компактный вертикальный отступ
            ),
            child: Row(
              children: [
                // ====== КРУГЛЫЙ АВАТАР ПРОЕКТА ======
                Container(
                  width: 48, // Диаметр 48px (r=24 из вашего SVG)
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEFF6FF), // Нежно-синий фон подложки
                  ),
                  child: Center(
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB), // Яркий фирменный кобальт
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Отступ между аватаром и текстом
                
                // ====== ТЕКСТОВЫЙ БЛОК (ЗАГОЛОВОК + ОПИСАНИЕ) ======
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: '.SF Pro Text',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F141C), // Глубокий антрацит
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 2), // Микро-отступ между строками
                      Text(
                        // Сюда можно передавать переменную описания. Пока оставим ваш текст с макета:
                        title == 'Хюгге: Зелёный остров' 
                            ? 'Хрупкая эко-среда на малень...'
                            : 'Минималистичный менеджер...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: '.SF Pro Text',
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF475569), // Slate 600 для высокой контрастности
                        ),
                      ),
                    ],
                  ),
                ),
                
                // ====== КНОПКА ТРОЕТОЧИЯ (МЕНЮ) ======
                PopupMenuButton<String>(
                  // Увеличиваем размер touch target за счет встроенных паддингов иконки
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.more_vert_rounded, // Скругленное аккуратное троеточие
                    size: 20, 
                    color: Color(0xFF94A3B8), // Серый Slate 400 из макета
                  ),
                  onSelected: (String result) {
                    switch(result){
                      case 'edit':
                        input.text = title;
  showModalBottomSheet(
        context: context,
        isScrollControlled: true, // Позволяет шторке подниматься вместе с клавиатурой
        backgroundColor: Colors.transparent,
        builder: (context) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Новая задача',
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F141C),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: input,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Название задачи...',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        input.clear();
                        Navigator.pop(context);
                      },
                      child: const Text('Отмена', style: TextStyle(color: Color(0xFF64748B))),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                  onUpdate(projectId, input.text);
                                  input.clear();
                                  Navigator.pop(context);
                      },
                      child: const Text('Создать'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
                        /*
                        
                                                      onPressed: () {
                                  onUpdate(projectId, input.text);
                                  input.clear();
                                  Navigator.pop(context);
                                }
                         */
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                      case 'export':
                        onExport(projectId);
                        break;
                      case 'sync':
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                    const PopupMenuItem<String>(value: 'sync', child: Text('Sync')),
                    const PopupMenuItem<String>(value: 'export', child: Text('Export')),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // ====== СИСТЕМНАЯ РАЗДЕЛИТЕЛЬНАЯ ЛИНИЯ ======
        const Padding(
          padding: EdgeInsets.only(left: 88, right: 24), // Линия начинается строго под текстом
          child: Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F5F9), // Ультра-светлый серый Slate 100
          ),
        ),
      ],
    ),
  );
  }
}