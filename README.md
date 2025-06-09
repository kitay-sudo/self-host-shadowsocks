# Настройка Shadowsocks сервера на Ubuntu

## Содержание
1. [Требования](#требования)
2. [Установка сервера](#установка-сервера)
3. [Настройка Shadowsocks](#настройка-shadowsocks)
4. [Запуск и управление сервисом](#запуск-и-управление-сервисом)
5. [Получение ключа подключения](#получение-ключа-подключения)
6. [Настройка клиента](#настройка-клиента)
7. [Устранение неполадок](#устранение-неполадок)

## Требования

- VPS или сервер с Ubuntu 18.04/20.04/22.04
- Root доступ или пользователь с sudo привилегиями
- Внешний IP адрес
- Открытые порты в файрволе

## Установка сервера

### Шаг 1: Обновление системы

```bash
sudo apt update && sudo apt upgrade -y
```

### Шаг 2: Установка Python и pip

```bash
sudo apt install python3 python3-pip -y
```

### Шаг 3: Установка Shadowsocks-libev (рекомендуется)

```bash
sudo apt install shadowsocks-libev -y
```

### Альтернативный способ - установка через pip

```bash
pip3 install shadowsocks
```

## Настройка Shadowsocks

### Шаг 1: Создание конфигурационного файла

Создайте файл конфигурации:

```bash
sudo nano /etc/shadowsocks-libev/config.json
```

### Шаг 2: Заполнение конфигурации

Вставьте следующую конфигурацию в файл:

```json
{
    "server": "0.0.0.0",
    "server_port": 8388,
    "local_address": "127.0.0.1",
    "local_port": 1080,
    "password": "ВАШ_ПАРОЛЬ_ЗДЕСЬ",
    "timeout": 300,
    "method": "aes-256-gcm",
    "fast_open": false
}
```

**Важные параметры:**
- `server_port`: порт, на котором будет работать сервер (можно изменить)
- `password`: ваш пароль (обязательно смените!)
- `method`: метод шифрования (рекомендуется aes-256-gcm)

### Шаг 3: Генерация безопасного пароля

```bash
openssl rand -base64 32
```

Скопируйте сгенерированный пароль и вставьте в конфигурацию.

## Запуск и управление сервисом

### Шаг 1: Включение автозапуска

```bash
sudo systemctl enable shadowsocks-libev
```

### Шаг 2: Запуск сервиса

```bash
sudo systemctl start shadowsocks-libev
```

### Шаг 3: Проверка статуса

```bash
sudo systemctl status shadowsocks-libev
```

### Полезные команды управления

```bash
# Перезапуск сервиса
sudo systemctl restart shadowsocks-libev

# Остановка сервиса
sudo systemctl stop shadowsocks-libev

# Просмотр логов
sudo journalctl -u shadowsocks-libev -f
```

## Настройка файрвола

### UFW (Ubuntu Firewall)

```bash
# Включение UFW
sudo ufw enable

# Разрешение SSH (важно!)
sudo ufw allow ssh

# Разрешение порта Shadowsocks
sudo ufw allow 8388/tcp

# Проверка статуса
sudo ufw status
```

### iptables (альтернативный способ)

```bash
# Разрешение входящих соединений на порт 8388
sudo iptables -I INPUT -p tcp --dport 8388 -j ACCEPT

# Сохранение правил
sudo iptables-save > /etc/iptables/rules.v4
```

## Получение ключа подключения

### Автоматическая генерация ключа

Создайте скрипт для генерации ключа:

```bash
nano generate_ss_url.py
```

Вставьте следующий код:

```python
#!/usr/bin/env python3
import base64
import json

# Параметры из вашего config.json
server_ip = "ВАШ_IP_АДРЕС"  # Замените на IP вашего сервера
server_port = 8388
method = "aes-256-gcm"
password = "ВАШ_ПАРОЛЬ"  # Замените на ваш пароль

# Создание строки для кодирования
auth_string = f"{method}:{password}"
encoded_auth = base64.b64encode(auth_string.encode()).decode()

# Генерация SS URL
ss_url = f"ss://{encoded_auth}@{server_ip}:{server_port}"

print("Ваш Shadowsocks ключ:")
print(ss_url)
print("\nДля импорта в приложение скопируйте строку выше")
```

Запустите скрипт:

```bash
python3 generate_ss_url.py
```

### Ручная генерация ключа

1. **Создайте строку аутентификации:**
   ```
   метод_шифрования:пароль
   ```
   Например: `aes-256-gcm:mySecretPassword123`

2. **Закодируйте в Base64:**
   ```bash
   echo -n "aes-256-gcm:mySecretPassword123" | base64
   ```

3. **Создайте финальный URL:**
   ```
   ss://ЗАКОДИРОВАННАЯ_СТРОКА@IP_АДРЕС:ПОРТ
   ```
   Например: `ss://YWVzLTI1Ni1nY206bXlTZWNyZXRQYXNzd29yZDEyMw==@192.168.1.100:8388`

## Настройка клиента

### Android
1. Установите приложение "Shadowsocks" из Google Play
2. Нажмите "+" для добавления сервера
3. Сканируйте QR код или вставьте ss:// ссылку

### iOS
1. Установите "Shadowrocket" или "Potatso Lite"
2. Добавьте сервер через ss:// ссылку

### Windows
1. Скачайте Shadowsocks-Windows с GitHub
2. Импортируйте настройки через ss:// ссылку

### macOS
1. Используйте ShadowsocksX-NG
2. Импортируйте через ss:// URL

## Оптимизация производительности

### TCP BBR (рекомендуется)

```bash
# Добавление BBR в модули ядра
echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf

# Применение изменений
sudo sysctl -p

# Проверка
sysctl net.ipv4.tcp_congestion_control
```

### Оптимизация файрвола

```bash
# Добавление правил оптимизации
echo 'net.ipv4.tcp_fastopen = 3' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_tw_reuse = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## Устранение неполадок

### Проверка подключения

```bash
# Проверка порта
sudo netstat -tlnp | grep :8388

# Тест подключения
telnet localhost 8388
```

### Просмотр логов

```bash
# Логи systemd
sudo journalctl -u shadowsocks-libev --no-pager

# Запуск в режиме отладки
sudo ss-server -c /etc/shadowsocks-libev/config.json -v
```

### Частые проблемы

1. **Сервис не запускается:**
   - Проверьте синтаксис JSON конфигурации
   - Убедитесь, что порт не занят другим процессом

2. **Клиент не может подключиться:**
   - Проверьте настройки файрвола
   - Убедитесь, что сервер доступен извне

3. **Медленная скорость:**
   - Включите TCP BBR
   - Попробуйте другой метод шифрования
   - Проверьте загрузку сервера

## Безопасность

### Смена порта по умолчанию

```bash
# Измените server_port в конфигурации на нестандартный
# Например: 443, 80, или любой другой свободный порт
```

### Регулярное обновление

```bash
# Автоматическое обновление системы
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure -plow unattended-upgrades
```

### Мониторинг

```bash
# Установка htop для мониторинга
sudo apt install htop -y

# Мониторинг соединений
watch 'ss -tuln | grep :8388'
```

## Заключение

После выполнения всех шагов у вас будет работающий Shadowsocks сервер. Сохраните сгенерированную ss:// ссылку и используйте её в клиентских приложениях.

### Контакты и поддержка

- [Официальная документация Shadowsocks](https://shadowsocks.org/)
- [GitHub репозиторий](https://github.com/shadowsocks/shadowsocks-libev)

---
**Внимание:** Использование VPN/прокси сервисов должно соответствовать законодательству вашей страны. 