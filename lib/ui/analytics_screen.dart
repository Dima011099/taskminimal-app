import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
          appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false, // Отключаем дефолтную стрелку Flutter
        titleSpacing: 0, // Сбрасываем дефолтный отступ
        title: Padding(
          padding: const EdgeInsets.only(left: 20.0), // Отступ от края экрана
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque, // Кликабельная область для всей строки
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center, // Идеальное выравнивание по центру оси
              children: [
                Icon(
                  Icons.arrow_back_ios_new_rounded, 
                  color: Color(0xFF111318), 
                  size: 18, // Компактная b2b стрелочка
                ),
                const SizedBox(width: 10), // Зазор до текста
                Text(
                  'Аналитика',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111318),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        children: [
          // ====== БЛОК ГЕРОЯ (ПРОДУКТИВНОСТЬ) ======
          const Text(
            '84%',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 58,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111318),
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Продуктивность',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF7A818A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '+12% за 7 дней',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2B66FF),
            ),
          ),
          
          const SizedBox(height: 42),

          // ====== МЕТРИКИ (KPI) ======
          _buildSectionHeader('МЕТРИКИ'),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildKpiItem('34', 'выполнено'),
              const SizedBox(width: 24),
              _buildKpiItem('6', 'осталось'),
              const SizedBox(width: 24),
              _buildKpiItem('12', 'стрик'),
            ],
          ),

          const SizedBox(height: 48),

          // ====== ГРАФИК НЕДЕЛИ ======
          _buildSectionHeader('НЕДЕЛЯ'),
          const SizedBox(height: 24),
          _buildChartSection(),

          const SizedBox(height: 48),

          // ====== БЛОК ИНСАЙТА ======
          _buildSectionHeader('ИНСАЙТ'),
          const SizedBox(height: 16),
          const Text(
            'Основной пик — пятница',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111318),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Рост продуктивности формируется за счёт середины недели.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF7A818A),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 48),

          // ====== СПИСОК ПРОЕКТОВ ======
          _buildSectionHeader('ПРОЕКТЫ'),
          const SizedBox(height: 8),
          _buildProjectRow('DIMGI+', '90%'),
          _buildProjectRow('UsefulDecor', '75%', isLast: true),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Заголовок секций маленькими буквами
  Widget _buildSectionHeader(String text) {
    return Text(
      text.toLowerCase(),
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF9AA0AA),
        letterSpacing: 1.0,
      ),
    );
  }

  // Элемент строки метрик (KPI)
  Widget _buildKpiItem(String value, String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111318),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xFF7A818A),
          ),
        ),
      ],
    );
  }

  // Конструктор кастомного графика недели
  Widget _buildChartSection() {
    final List<Map<String, dynamic>> chartData = [
      {'day': 'ПН', 'height': 50.0, 'active': false},
      {'day': 'ВТ', 'height': 80.0, 'active': false},
      {'day': 'СР', 'height': 40.0, 'active': false},
      {'day': 'ЧТ', 'height': 70.0, 'active': false},
      {'day': 'ПТ', 'height': 130.0, 'active': true},
      {'day': 'СБ', 'height': 35.0, 'active': false},
      {'day': 'ВС', 'height': 30.0, 'active': false},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: chartData.map((data) {
            final bool isActive = data['active'] as bool;
            return Column(
              children: [
                Container(
                  width: 14,
                  height: data['height'] as double,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF2B66FF) : const Color(0xFFDCE5FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data['day'] as String,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? const Color(0xFF2B66FF) : const Color(0xFFA0A7B0),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        const Divider(height: 1, color: Color(0xFFEEF1F6)),
      ],
    );
  }

  // Строка проекта
  Widget _buildProjectRow(String title, String percentage, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111318),
                ),
              ),
              Text(
                percentage,
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