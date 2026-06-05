import 'package:flutter/material.dart';
import 'package:task_minimal/net/local_sync_client.dart';
import 'dart:io';

import 'package:task_minimal/net/local_sync_server.dart';

class SyncSettingsScreen extends StatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  State<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends State<SyncSettingsScreen> {
  final LocalSyncServer _syncServer = LocalSyncServer();
  final LocalSyncClient _syncClient = LocalSyncClient();
  final TextEditingController _urlController = TextEditingController();

  // Состояния активных серверов
  bool _isCloudSynced = true;
  bool _isLocalServerRunning = false;
  String _localServerIp = "Определяем IP...";

  @override
  void initState() {
    super.initState();
    _getIpAddress();
  }

  Future<void> _getIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      if (interfaces.isNotEmpty && interfaces.first.addresses.isNotEmpty) {
        setState(() {
          _localServerIp = interfaces.first.addresses.first.address;
        });
      } else {
        setState(() => _localServerIp = "Wi-Fi не подключен");
      }
    } catch (e) {
      setState(() => _localServerIp = "Ошибка сети");
    }
  }

  // Переключение состояния локального сервера (раздачи)
  void _toggleLocalServer() async {
    if (_isLocalServerRunning) {
      await _syncServer.stopServer();
      setState(() => _isLocalServerRunning = false);
    } else {
      setState(() => _isLocalServerRunning = true);
      
      // ИСПРАВЛЕНО: Теперь запускаем без ID, сервер сам заберет всю БД
      await _syncServer.startServer((log) {
        debugPrint(log);
      });
    }
  }

  // Запуск ручного подключения к приватному узлу (прием данных)
  /*
  void _connectToPrivateNode() async {
    final ip = _urlController.text.trim();
    if (ip.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Синхронизация с приватным узлом...'), duration: Duration(seconds: 1)),
    );

    bool success = await _syncClient.syncFromWifi(ip, (log) => print(log));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Синхронизация успешна!' : 'Ошибка подключения'),
          backgroundColor: success ? const Color(0xFF1E68F6) : Colors.redAccent,
        ),
      );
    }
  }
  */
    void _connectToPrivateNode() async {
    final ip = _urlController.text.trim();
    if (ip.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Синхронизация...'), duration: Duration(seconds: 1)),
    );

    // 1. Сначала строго скачиваем чужие изменения (GET)
    bool pullSuccess = await _syncClient.syncFromWifi(ip, (log) => debugPrint(log));
    
    if (!pullSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка загрузки данных'), backgroundColor: Colors.redAccent),
        );
      }
      return; // Если первый шаг упал, прерываем, чтобы не затереть базу
    }

    // ЖЕСТКАЯ ПАУЗА в 300 мс — даем однопоточному серверу php -S закрыть файлы на диске
    await Future.delayed(const Duration(milliseconds: 300));

    // 2. Только теперь пушим объединенную локальную базу обратно на сервер (POST)
    bool pushSuccess = await _syncClient.sendDataToRemoteNode(ip, (log) => debugPrint(log));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pushSuccess ? 'Синхронизация успешна!' : 'Ошибка отправки изменений'),
          backgroundColor: pushSuccess ? const Color(0xFF1E68F6) : Colors.redAccent,
        ),
      );
      
      // Закрываем экран только если ОБА шага прошли успешно
      if (pushSuccess) {
        Navigator.pop(context, true); 
      }
    }
  }

/*
     void _connectToPrivateNode() async {
    final ip = _urlController.text.trim();
    if (ip.isEmpty) return;


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Синхронизация (скачивание с узла)...'), duration: Duration(seconds: 1)),
    );

    bool success = await _syncClient.syncFromWifi(ip, (log) => print(log));
     success = await _syncClient.sendDataToRemoteNode(ip, (log) => print(log));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Синхронизация успешна!' : 'Ошибка подключения'),
          backgroundColor: success ? const Color(0xFF1E68F6) : Colors.redAccent,
        ),
      );
      if (success) {
        Navigator.pop(context, true); // Возвращаем true для обновления UI главного экрана
      }
    }
  }*/
/*
    void _connectToPrivateNode() async {
    final ip = _urlController.text.trim();
    if (ip.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Синхронизация...'), duration: Duration(seconds: 1)),
    );

    // ТВОЙ РАБОЧИЙ ПОРЯДОК:
    // 1. Сначала стягиваем чужие изменения с сервера и вливаем в свою SQLite по времени
    bool success = await _syncClient.syncFromWifi(ip, (log) => print(log));
    
    // 2. Затем берем получившуюся общую локальную базу и пушим ее обратно на сервер
    //success = await _syncClient.sendDataToRemoteNode(ip, (log) => print(log));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Синхронизация успешна!' : 'Ошибка подключения'),
          backgroundColor: success ? const Color(0xFF1E68F6) : Colors.redAccent,
        ),
      );
      
      if (success) {
        Navigator.pop(context, true); // Возвращаем true для обновления главного экрана
      }
    }
  }
*/


  @override
  void dispose() {
    _urlController.dispose();
    _syncServer.stopServer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF191C21), size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Синхронизация',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, color: Color(0xFF191C21), fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        children: [
          // --- КАТЕГОРИЯ 1 ---
          _buildSectionHeader('ОФИЦИАЛЬНЫЙ ОБЛАЧНЫЙ СЕРВЕР'),
          _buildSyncTile(
            icon: Icons.cloud_outlined,
            title: 'Minimal Cloud',
            subtitle: 'По умолчанию • Синхронизировано',
            isActive: _isCloudSynced,
            onTap: () => setState(() => _isCloudSynced = !_isCloudSynced),
          ),
          const SizedBox(height: 32),

          // --- КАТЕГОРИЯ 2 ---
          _buildSectionHeader('ВЕРИФИЦИРОВАННЫЕ БАЗЫ ДАННЫХ'),
          _buildDatabaseTile(
            icon: Icons.dns_outlined,
            title: 'Supabase Community Node',
            subtitle: 'Одобрено разработчиком • PostgreSQL',
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 56),
          _buildDatabaseTile(
            icon: Icons.credit_card_outlined, // Похожая иконка слотов из макета
            title: 'Euro Core Team Cluster',
            subtitle: 'Одобрено разработчиком • CouchDB',
          ),
          const SizedBox(height: 32),

          // --- КАТЕГОРИЯ 3 ---
          _buildSectionHeader('ОФИЦИАЛЬНЫЙ ОБЛАЧНЫЙ СЕРВЕР'), // Дублирует заголовок как на скриншоте
          _buildSyncTile(
            icon: Icons.computer_rounded,
            title: 'LocalServer',
            subtitle: _isLocalServerRunning ? 'Раздача: http://$_localServerIp:8080' : 'Локальный сервер • Остановлен',
            isActive: _isLocalServerRunning,
            onTap: _toggleLocalServer,
          ),
          const SizedBox(height: 32),

          // --- КАТЕГОРИЯ 4 ---
          _buildSectionHeader('ПРИВАТНЫЙ УЗЕЛ'),
          const SizedBox(height: 8),
          
          // Поле ввода в стиле макета
          Container(
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.circular(28), // Максимальное скругление капсулы
            ),
            padding: const EdgeInsets.only(left: 20, right: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 15, color: Color(0xFF191C21)),
                    decoration: const InputDecoration(
                      hintText: 'Введите IP или URL сервера...',
                      hintStyle: TextStyle(color: Color(0xFFADB5BD), fontWeight: FontWeight.w400),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                // Синяя круглая кнопка подтверждения
                GestureDetector(
                  onTap: _connectToPrivateNode,
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFF007AFF), // Насыщенный синий Apple/Minimal
                    child: Icon(Icons.check, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Кастомный заголовок секции
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0, left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.8,
          color: const Color(0xFF191C21).withValues(alpha:0.4),
        ),
      ),
    );
  }

  // Строка выбора с галочкой (Minimal Cloud / LocalServer)
  Widget _buildSyncTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
        child: Row(
          children: [
            Icon(icon, size: 28, color: const Color(0xFF007AFF)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF007AFF))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400, fontSize: 12, color: const Color(0xFF191C21).withValues(alpha:0.4))),
                ],
              ),
            ),
            if (isActive)
              const Icon(Icons.check_rounded, color: Color(0xFF007AFF), size: 24),
          ],
        ),
      ),
    );
  }

  // Строка верифицированных баз данных с плюсиком
  Widget _buildDatabaseTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 28, color: const Color(0xFF191C21)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF191C21))),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400, fontSize: 12, color: const Color(0xFF191C21).withValues(alpha: 0.4))),
              ],
            ),
          ),
          const Icon(Icons.add_rounded, color: Color(0xFF007AFF), size: 24),
        ],
      ),
    );
  }
}