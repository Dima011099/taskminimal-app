import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
     appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  scrolledUnderElevation: 0,
  automaticallyImplyLeading: false, 
  titleSpacing: 0, 
  title: Padding(
    padding: const EdgeInsets.only(left: 20.0), 
    child: GestureDetector(
      onTap: () => Navigator.pop(context),
      behavior: HitTestBehavior.opaque, 
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        // ИСПРАВЛЕНО: Указано верное перечисление CrossAxisAlignment.center
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
          Icon(
            Icons.arrow_back_ios_new_rounded, 
            color: Color(0xFF0F1115), 
            size: 18, 
          ),
          SizedBox(width: 10), 
          Text(
            'Профиль',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F1115),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    ),
  ),
),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        children: [
          // ====== БЛОК ПОЛЬЗОВАТЕЛЯ ======
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEF3FF),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'Д',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B66FF),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Дмитрий',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F1115),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'uengein4@yandex.ru',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF7A818A),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          const Divider(height: 1, color: Color(0xFFEEF1F6)),
          const SizedBox(height: 32),

          // ====== БЛОК АКТИВНОСТИ ======
          _buildSectionHeader('АКТИВНОСТЬ'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '142',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F1115),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'выполнено задач',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFA0A7B0),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '5',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F1115),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'проектов',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFA0A7B0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 54),

          // ====== БЛОК НАСТРОЕК ======
          _buildSectionHeader('НАСТРОЙКИ'),
          const SizedBox(height: 8),
          _buildSettingRow('Тарифный план', 'Pro'),
          _buildSettingRow('Базы данных', 'OK'),
          _buildSettingRow('Безопасность', 'Включена', isLast: true),

          const SizedBox(height: 54),

          // ====== КНОПКА ВЫХОДА ======
          GestureDetector(
            onTap: () {
              print('Выход из аккаунта');
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Выйти из аккаунта',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFE5484D), // Благородный красный
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Заголовок категории (АКТИВНОСТЬ, НАСТРОЙКИ)
  Widget _buildSectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        color: Color(0xFF8F98A3),
        letterSpacing: 1.0,
      ),
    );
  }

  // Строка настройки с разделителем line
  Widget _buildSettingRow(String title, String value, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F1115),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF7A818A),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFEEF1F6)),
      ],
    );
  }
}