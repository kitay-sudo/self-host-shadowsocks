#!/bin/bash

# Shadowsocks Automatic Installation Script
# Автоматическая установка Shadowsocks сервера на Ubuntu

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Функция вывода с цветом
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${CYAN}=================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}=================================${NC}"
}

# Проверка прав root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Этот скрипт должен запускаться с правами root"
        print_status "Запустите: sudo $0"
        exit 1
    fi
}

# Генерация случайного пароля
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}

# Получение внешнего IP
get_external_ip() {
    local ip=""
    
    # Пробуем разные сервисы
    for service in "ifconfig.me" "icanhazip.com" "ipecho.net/plain"; do
        ip=$(curl -s -4 --connect-timeout 5 "$service" 2>/dev/null | tr -d '\n\r')
        if [[ -n "$ip" && "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            echo "$ip"
            return 0
        fi
    done
    
    print_warning "Не удалось автоматически определить внешний IP"
    return 1
}

# Генерация случайного порта
generate_port() {
    # Генерируем порт в диапазоне 10000-65000
    echo $((RANDOM % 55000 + 10000))
}

# Основная функция установки
install_shadowsocks() {
    print_header "🚀 АВТОМАТИЧЕСКАЯ УСТАНОВКА SHADOWSOCKS"
    
    # 1. Обновление системы
    print_status "Обновление системы..."
    apt update && apt upgrade -y
    
    # 2. Установка необходимых пакетов
    print_status "Установка зависимостей..."
    apt install -y curl wget python3 python3-pip ufw
    
    # 3. Установка Shadowsocks
    print_status "Установка Shadowsocks-libev..."
    apt install -y shadowsocks-libev
    
    # 4. Генерация параметров
    print_status "Генерация конфигурации..."
    
    local server_ip
    local server_port
    local password
    local method="chacha20-ietf-poly1305"
    
    # Получаем внешний IP
    server_ip=$(get_external_ip)
    if [[ -z "$server_ip" ]]; then
        print_error "Не удалось определить внешний IP адрес"
        exit 1
    fi
    
    # Генерируем порт и пароль
    server_port=$(generate_port)
    password=$(generate_password)
    
    print_success "Параметры сервера:"
    echo "  IP: $server_ip"
    echo "  Порт: $server_port"
    echo "  Пароль: $password"
    echo "  Метод: $method"
    
    # 5. Создание конфигурационного файла
    print_status "Создание конфигурации..."
    
    cat > /etc/shadowsocks-libev/config.json << EOF
{
    "server": "0.0.0.0",
    "mode": "tcp_and_udp",
    "server_port": $server_port,
    "local_port": 1080,
    "password": "$password",
    "timeout": 86400,
    "method": "$method"
}
EOF
    
    # 6. Настройка файрвола
    print_status "Настройка файрвола..."
    
    # Включаем UFW
    ufw --force enable
    
    # Разрешаем SSH
    ufw allow ssh
    
    # Разрешаем наш порт
    ufw allow $server_port/tcp
    ufw allow $server_port/udp
    
    # 7. Запуск сервиса
    print_status "Запуск Shadowsocks сервиса..."
    
    systemctl enable shadowsocks-libev
    systemctl restart shadowsocks-libev
    
    # Ждем запуска
    sleep 3
    
    # Проверяем статус
    if systemctl is-active --quiet shadowsocks-libev; then
        print_success "Shadowsocks сервис успешно запущен!"
    else
        print_error "Ошибка запуска сервиса!"
        systemctl status shadowsocks-libev --no-pager
        exit 1
    fi
    
    # 8. Оптимизация производительности
    print_status "Применение оптимизаций..."
    
    # TCP BBR
    if ! grep -q "net.core.default_qdisc=fq" /etc/sysctl.conf; then
        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    fi
    
    if ! grep -q "net.ipv4.tcp_congestion_control=bbr" /etc/sysctl.conf; then
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    fi
    
    # TCP Fast Open
    if ! grep -q "net.ipv4.tcp_fastopen=3" /etc/sysctl.conf; then
        echo "net.ipv4.tcp_fastopen=3" >> /etc/sysctl.conf
    fi
    
    sysctl -p >/dev/null 2>&1
    
    # 9. Генерация ключа подключения
    print_status "Генерация ключа подключения..."
    
    # Создаем строку аутентификации
    auth_string="$method:$password"
    encoded_auth=$(echo -n "$auth_string" | base64 -w 0)
    ss_url="ss://$encoded_auth@$server_ip:$server_port"
    
    # 10. Сохранение информации
    cat > /root/shadowsocks_info.txt << EOF
Shadowsocks Server Information
==============================

Connection Details:
Server IP: $server_ip
Port: $server_port
Password: $password
Method: $method

SS URL: $ss_url

Client Setup Instructions:
- Android: Install 'Shadowsocks' app → Add server with SS URL
- iOS: Install 'Shadowrocket' → Add server with SS URL  
- Windows: Download Shadowsocks-Windows → Import SS URL
- macOS: Use ShadowsocksX-NG → Import SS URL

Generated: $(date)
EOF
    
    # 11. Финальный вывод
    print_header "🎉 УСТАНОВКА ЗАВЕРШЕНА УСПЕШНО!"
    
    echo -e "${GREEN}Ваш Shadowsocks сервер готов к использованию!${NC}"
    echo ""
    echo -e "${CYAN}🔗 SS URL для подключения:${NC}"
    echo -e "${YELLOW}$ss_url${NC}"
    echo ""
    echo -e "${CYAN}📱 Параметры для ручного ввода:${NC}"
    echo "┌─────────────────────────────────────────┐"
    echo "│ Сервер:  $server_ip                     "
    echo "│ Порт:    $server_port                        "
    echo "│ Пароль:  $password    "
    echo "│ Метод:   $method           "
    echo "└─────────────────────────────────────────┘"
    echo ""
    echo -e "${CYAN}💾 Информация сохранена в:${NC} /root/shadowsocks_info.txt"
    echo ""
    echo -e "${CYAN}📱 Приложения для клиентов:${NC}"
    echo "• Android: Shadowsocks (Max Lv)"
    echo "• iOS: Shadowrocket / Potatso Lite"
    echo "• Windows: Shadowsocks-Windows"
    echo "• macOS: ShadowsocksX-NG"
    echo ""
    echo -e "${GREEN}✅ Сервер работает и готов к подключениям!${NC}"
    
    # Проверка работы порта
    if netstat -tlnp 2>/dev/null | grep -q ":$server_port "; then
        print_success "Порт $server_port прослушивается корректно"
    else
        print_warning "Порт $server_port может быть недоступен"
    fi
}

# Функция проверки совместимости
check_system() {
    # Проверяем Ubuntu
    if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
        print_warning "Скрипт оптимизирован для Ubuntu."
        print_status "Обнаружена система: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2 2>/dev/null || echo 'Неизвестная')"
        echo -n "Продолжить установку? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_status "Установка отменена пользователем"
            exit 0
        fi
    else
        print_success "Обнаружена Ubuntu - совместимая система"
    fi
}

# Функция показа помощи
show_help() {
    echo "Shadowsocks Auto Installer"
    echo ""
    echo "ИСПОЛЬЗОВАНИЕ:"
    echo "  sudo $0 [ОПЦИИ]"
    echo ""
    echo "ОПЦИИ:"
    echo "  --auto, -y    Автоматическая установка без запросов подтверждения"
    echo "  --help, -h    Показать эту справку"
    echo ""
    echo "ПРИМЕРЫ:"
    echo "  sudo $0                    # Интерактивная установка"
    echo "  sudo $0 --auto            # Автоматическая установка"
    echo "  sudo $0 -y                # Автоматическая установка (краткая форма)"
    echo ""
}

# Основная логика
main() {
    # Проверка аргументов командной строки
    local auto_mode=false
    
    case "$1" in
        --help|-h)
            show_help
            exit 0
            ;;
        --auto|-y)
            auto_mode=true
            ;;
        "")
            # Нет аргументов - интерактивный режим
            ;;
        *)
            print_error "Неизвестный аргумент: $1"
            show_help
            exit 1
            ;;
    esac
    
    clear
    
    print_header "SHADOWSOCKS AUTO INSTALLER"
    echo "Автоматическая установка и настройка Shadowsocks сервера"
    echo ""
    
    # Проверки
    check_root
    check_system
    
    # Предупреждение
    print_warning "Внимание: Использование VPN/прокси должно соответствовать законодательству вашей страны!"
    echo ""
    print_status "Этот скрипт выполнит:"
    echo "• Обновление системы"
    echo "• Установку Shadowsocks-libev"
    echo "• Автоматическую генерацию пароля"
    echo "• Настройку файрвола"
    echo "• Оптимизацию производительности"
    echo "• Генерацию ключа подключения"
    echo ""
    
    if [[ "$auto_mode" == "true" ]]; then
        print_success "Автоматический режим: пропускаем подтверждение"
    else
        echo -n "Продолжить установку? (y/N): "
        read -r response
        echo "" # Добавляем пустую строку для лучшего форматирования
        
        if [[ -z "$response" ]]; then
            print_warning "Пустой ответ. Введите 'y' для продолжения или 'n' для отмены."
            echo -n "Продолжить установку? (y/N): "
            read -r response
            echo ""
        fi
        
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_status "Установка отменена пользователем. Ответ: '$response'"
            print_status "Для запуска скрипта введите 'y' или 'Y' при запросе подтверждения"
            print_status "Или используйте флаг --auto для автоматической установки:"
            print_status "sudo ./install_shadowsocks.sh --auto"
            exit 0
        fi
    fi
    
    print_success "Начинаем установку..."
    
    # Запуск установки
    install_shadowsocks
}

# Запуск
main "$@" 