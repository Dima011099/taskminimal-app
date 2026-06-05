import 'package:flutter/material.dart';
import 'package:task_minimal/net/local_sync_client.dart';


class WifiSyncClientScreen extends StatefulWidget {
  const WifiSyncClientScreen({super.key});

  @override
  State<WifiSyncClientScreen> createState() => _WifiSyncClientScreenState();
}

class _WifiSyncClientScreenState extends State<WifiSyncClientScreen> {
  final LocalSyncClient _syncClient = LocalSyncClient();
  final TextEditingController _ipController = TextEditingController();
  
  bool _isLoading = false;
  String _statusMessage = "Введите IP-адрес раздающего устройства";

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  void _startSync() async {
    final ip = _ipController.text.trim();
    
    // Простейшая валидация на заполненность поля
    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите корректный IP')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = "Подключение к серверу Wi-Fi...";
    });

    // Вызываем созданный ранее метод клиента
    bool success = await _syncClient.syncFromWifi(ip, (log) {
      if (mounted) {
        setState(() => _statusMessage = log);
      }
    });

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        // Возвращаемся на главный экран при успешном импорте
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка синхронизации. Проверьте сеть Wi-Fi.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF191C21), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Прием по Wi-Fi',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF191C21), fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Поле ввода IP адреса
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'IP-адрес сервера:',
                  style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14, color: const Color(0xFF191C21).withValues(alpha:0.6)),
                ),
              ),
              const SizedBox(height: 10),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _ipController,
                  keyboardType: TextInputType.text, // Текст, так как адрес может быть '192.168.1.50'
                  style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, color: Color(0xFF191C21)),
                  decoration: const InputDecoration(
                    hintText: 'Например: 192.168.1.50',
                    hintStyle: TextStyle(color: Color(0xFF909AAB)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: InputBorder.none,
                  ),
                  enabled: !_isLoading,
                ),
              ),

              const Spacer(),

              // Анимированный статус/индикатор
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: _isLoading ? const Color(0xFF1E68F6).withValues(alpha:0.08) : const Color(0xFF909AAB).withValues(alpha:  0.08),
                  shape: BoxShape.circle,
                ),
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(28.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E68F6)),
                        ),
                      )
                    : const Icon(Icons.downloading_rounded, size: 40, color: Color(0xFF909AAB)),
              ),
              const SizedBox(height: 24),

              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400, fontSize: 14, height: 1.4, color: Color(0xFF909AAB)),
              ),

              const Spacer(),

              // Кнопка запуска процесса синхронизации
              GestureDetector(
                onTap: _isLoading ? null : _startSync,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _isLoading ? const Color(0xFFE2E8F0) : const Color(0xFF1E68F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _isLoading ? 'Синхронизация...' : 'Подключиться и скачать',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: _isLoading ? const Color(0xFF64748B) : Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}