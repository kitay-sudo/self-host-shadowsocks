# Shadowsocks Self-Host Server

![Ubuntu](https://img.shields.io/badge/Ubuntu-18.04%20%7C%2020.04%20%7C%2022.04-E95420?style=flat&logo=ubuntu&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.6%2B-3776AB?style=flat&logo=python&logoColor=white)
![Shadowsocks](https://img.shields.io/badge/Shadowsocks-libev-512BD4?style=flat&logo=shadowsocks&logoColor=white)
![License](https://img.shields.io/badge/License-CC%20BY--ND%204.0-lightgrey.svg)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)

**⚠️ Внимание:** Использование VPN/прокси сервисов должно соответствовать законодательству вашей страны.

Пошаговая инструкция по развертыванию собственного Shadowsocks сервера на Ubuntu с автоматической генерацией ключей подключения.

## 🚀 Автоматическая установка (1 команда)

**Рекомендуется для новичков** - полностью автоматическая установка и настройка:

```bash
# Скачиваем и запускаем автоматический установщик
curl -O https://raw.githubusercontent.com/kitay-sudo/self-host-shadowsocks/refs/heads/main/install_shadowsocks.sh
chmod +x install_shadowsocks.sh

# Интерактивная установка (с подтверждением)
sudo ./install_shadowsocks.sh

# ИЛИ автоматическая установка (без подтверждений)
sudo ./install_shadowsocks.sh --auto
```

**Альтернативно одной командой:**
```bash
# Интерактивная установка
curl -sSL https://raw.githubusercontent.com/kitay-sudo/self-host-shadowsocks/refs/heads/main/install_shadowsocks.sh | sudo bash

# Автоматическая установка
curl -sSL https://raw.githubusercontent.com/kitay-sudo/self-host-shadowsocks/refs/heads/main/install_shadowsocks.sh | sudo bash -s -- --auto
```

**Что делает автоматический скрипт:**
- ✅ Обновляет систему
- ✅ Устанавливает Shadowsocks-libev
- ✅ Генерирует безопасный пароль
- ✅ Автоматически определяет IP сервера
- ✅ Создает оптимальную конфигурацию
- ✅ Настраивает файрвол
- ✅ Применяет оптимизации производительности
- ✅ Генерирует готовый ss:// ключ

После выполнения скрипта вы получите готовый ключ для подключения!

---

## 📋 Ручная установка

### 🔧 Быстрая установка

Для тех, кто хочет больше контроля над процессом:

#### Шаг 1: Подготовка системы
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y shadowsocks-libev python3 ufw
```

#### Шаг 2: Создание конфигурации
```bash
sudo nano /etc/shadowsocks-libev/config.json
```

Вставьте конфигурацию:
```json
{
    "server": "0.0.0.0",
    "mode": "tcp_and_udp",
    "server_port": 8388,
    "local_port": 1080,
    "password": "ВАШ_ПАРОЛЬ_ЗДЕСЬ",
    "timeout": 86400,
    "method": "chacha20-ietf-poly1305"
}
```

#### Шаг 3: Запуск сервиса
```bash
sudo systemctl enable shadowsocks-libev
sudo systemctl start shadowsocks-libev
```

#### Шаг 4: Настройка файрвола
```bash
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 8388/tcp
sudo ufw allow 8388/udp
```

#### Шаг 5: Генерация ключа
```bash
python3 generate_ss_key.py
```

#### Шаг 6: Оптимизация производительности (рекомендуется)

**TCP BBR для улучшения скорости:**
```bash
echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

**TCP Fast Open для ускорения соединений:**
```bash
echo "net.ipv4.tcp_fastopen=3" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

**Дополнительные оптимизации:**
```bash
echo 'net.ipv4.tcp_tw_reuse = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### 🔧 Ручная генерация ключа (альтернативный способ)

Если скрипт `generate_ss_key.py` недоступен:

1. **Создайте строку аутентификации:**
   ```
   метод_шифрования:пароль
   ```
   Например: `chacha20-ietf-poly1305:mySecretPassword123`

2. **Закодируйте в Base64:**
   ```bash
   echo -n "chacha20-ietf-poly1305:mySecretPassword123" | base64
   ```

3. **Создайте финальный URL:**
   ```
   ss://ЗАКОДИРОВАННАЯ_СТРОКА@IP_АДРЕС:ПОРТ
   ```
   Например: `ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTpteVNlY3JldFBhc3N3b3JkMTIz@192.168.1.100:8388`

---

## 📱 Настройка клиентов

### Android
1. Установите приложение **"Shadowsocks"** (Max Lv) из Google Play
2. Нажмите **"+"** для добавления сервера
3. Вставьте ss:// ссылку или введите параметры вручную

### iOS
1. Установите **"Shadowrocket"** или **"Potatso Lite"**
2. Добавьте сервер через ss:// ссылку

### Windows
1. Скачайте **Shadowsocks-Windows** с GitHub
2. Импортируйте настройки через ss:// ссылку

### macOS
1. Используйте **ShadowsocksX-NG**
2. Импортируйте через ss:// URL

---

## 🔧 Устранение неполадок

### Частые проблемы

1. **Сервис не запускается:**
   - Проверьте синтаксис JSON конфигурации
   - Убедитесь, что порт не занят другим процессом

2. **Клиент не может подключиться:**
   - Проверьте настройки файрвола: `sudo ufw allow 8388/tcp`
   - Убедитесь, что в конфигурации указано `"server": "0.0.0.0"`
   - Проверьте, что сервер доступен извне

3. **Медленная скорость:**
   - Включите TCP BBR (см. раздел оптимизации)
   - Попробуйте другой метод шифрования
   - Проверьте загрузку сервера

### Проверка работы сервера

```bash
# Статус сервиса
sudo systemctl status shadowsocks-libev

# Проверка порта
sudo netstat -tlnp | grep :8388

# Просмотр логов
sudo journalctl -u shadowsocks-libev -f
```

---

## 🔒 Безопасность

### Рекомендации

- Используйте сложные пароли
- Меняйте порт по умолчанию
- Регулярно обновляйте систему
- Мониторьте подключения

### Смена порта

```bash
# Измените server_port в конфигурации на нестандартный
# Например: 443, 993, или любой другой свободный порт
```

### Регулярное обновление

```bash
# Автоматическое обновление системы
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure -plow unattended-upgrades
```

---

## 📚 Дополнительная информация

### Контакты и поддержка

- [Официальная документация Shadowsocks](https://shadowsocks.org/)
- [GitHub репозиторий Shadowsocks-libev](https://github.com/shadowsocks/shadowsocks-libev)

### Лицензия

Этот проект распространяется под лицензией **Creative Commons Attribution-NoDerivatives 4.0 International**.

**Что это значит:**
- ✅ **Можно:** свободно использовать, копировать, распространять для любых целей
- ❌ **Нельзя:** изменять код и распространять измененные версии

Подробности в файле [LICENSE](LICENSE).

---

**🎉 Поздравляем!** Ваш собственный Shadowsocks сервер готов к использованию! 