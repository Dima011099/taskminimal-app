import 'package:flutter/material.dart';

class EmptyTasksWidget extends StatelessWidget {
  const EmptyTasksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Иконка
      /*      Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.checklist_rounded,
                size: 36,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 20),

            // Заголовок
            Text(
              'Задач пока нет',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 10),

          
           Text('Добавтьте первую задачу, чтобы\n начать работу',
                        style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
    

             const SizedBox(height: 12),

            Text('Нажмите + внизу справа',
                        style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: Colors.blue.shade800,
              ),
            ),*/
    


    // Традиционный для скандинавского минимализма увеличенный отступ после графики
    const SizedBox(height: 32), 

    // 2. Главный заголовок: Акцент на чистый цвет текста без лишней жирности
    Text(
      'Задач пока нет',
      style: TextStyle(
        fontFamily: 'Inter', // Идеально подходит под закругленные гротески макета
        fontWeight: FontWeight.w500, // В макете нет жирного черного, везде Medium/Regular
        fontSize: 20, // Крупный кегль для компенсации легкого начертания
        letterSpacing: -0.3, // Отрицательный трекинг для собранности заголовка
        color: const Color(0xFF191C21), // Глубокий антрацитовый вместо черного
      ),
    ),

    const SizedBox(height: 12), // Разреженный отступ между строками

    // 3. Подзаголовок: Строгая иерархия и много воздуха
    Text(
      'Добавьте первую задачу, чтобы\nначать работу',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        fontSize: 14,
        letterSpacing: -0.1,
        height: 1.5, // Увеличенный интерлиньяж (line-height) — ключевая фишка макета
        color: const Color(0xFF909AAB), // Светло-серый, как у тегов "Low" на доске
      ),
    ),

    const SizedBox(height: 28), // Отдаление подсказки от основного блока текста

    // 4. Инструкция-подсказка: Вынесена в самый низ на безопасное расстояние
    Text(
      'Нажмите + внизу справа',
      style: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        fontSize: 13,
        letterSpacing: 0.1,
        color: const Color(0xFF1E68F6).withOpacity(0.8), // Приглушенный синий (как "In Progress")
      ),
    ),

      
          ],
        ),
      ),
    );
  }
}