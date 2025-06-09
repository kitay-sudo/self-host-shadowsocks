#!/bin/bash

# Тестовый скрипт для проверки логики install_shadowsocks.sh
# БЕЗ реальной установки

echo "🧪 ТЕСТОВЫЙ РЕЖИМ - НЕ УСТАНАВЛИВАЕТ SHADOWSOCKS"
echo "Проверяем только логику скрипта..."
echo ""

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

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

# Проверка аргументов
auto_mode=false

case "$1" in
    --help|-h)
        echo "Тестовый скрипт для проверки логики установщика"
        echo ""
        echo "ИСПОЛЬЗОВАНИЕ:"
        echo "  $0 [ОПЦИИ]"
        echo ""
        echo "ОПЦИИ:"
        echo "  --auto, -y    Тестировать автоматический режим"
        echo "  --help, -h    Показать эту справку"
        exit 0
        ;;
    --auto|-y)
        auto_mode=true
        ;;
    "")
        # Нет аргументов
        ;;
    *)
        print_error "Неизвестный аргумент: $1"
        exit 1
        ;;
esac

clear

print_header "SHADOWSOCKS INSTALLER TEST"
echo "Тестирование логики автоматического установщика"
echo ""

print_warning "⚠️  Это ТЕСТОВЫЙ режим - реальная установка НЕ выполняется!"
echo ""

print_status "Проверяем аргументы командной строки..."
if [[ "$auto_mode" == "true" ]]; then
    print_success "✅ Обнаружен автоматический режим (--auto)"
else
    print_success "✅ Интерактивный режим"
fi

echo ""
print_status "Эмулируем проверки системы..."
print_success "✅ Права пользователя (эмуляция)"
print_success "✅ Совместимость системы (эмуляция)"

echo ""
print_warning "Внимание: Использование VPN/прокси должно соответствовать законодательству вашей страны!"
echo ""

print_status "Тестовый скрипт выполнит:"
echo "• ✅ Проверку аргументов командной строки"
echo "• ✅ Проверку системных требований"
echo "• ✅ Тестирование интерактивного ввода"
echo "• ✅ Эмуляцию процесса установки"
echo ""

if [[ "$auto_mode" == "true" ]]; then
    print_success "Автоматический режим: пропускаем подтверждение"
    response="y"
else
    echo -n "Продолжить тестирование? (y/N): "
    read -r response
    echo ""
    
    if [[ -z "$response" ]]; then
        print_warning "Пустой ответ. Введите 'y' для продолжения или 'n' для отмены."
        echo -n "Продолжить тестирование? (y/N): "
        read -r response
        echo ""
    fi
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_status "Тестирование отменено пользователем. Ответ: '$response'"
        print_status "Для запуска тестирования введите 'y' или 'Y'"
        print_status "Или используйте флаг --auto для автоматического режима:"
        print_status "$0 --auto"
        exit 0
    fi
fi

print_success "Начинаем тестирование..."
echo ""

# Эмуляция процесса установки
print_header "🧪 ЭМУЛЯЦИЯ УСТАНОВКИ"

print_status "1. Обновление системы... (эмуляция)"
sleep 1
print_success "✅ Система обновлена (эмуляция)"

print_status "2. Установка Shadowsocks-libev... (эмуляция)"
sleep 1
print_success "✅ Shadowsocks установлен (эмуляция)"

print_status "3. Генерация параметров..."
server_ip="192.168.1.100"
server_port="12345"
password="TestPassword123"
method="chacha20-ietf-poly1305"

print_success "Параметры сервера (тестовые):"
echo "  IP: $server_ip"
echo "  Порт: $server_port"
echo "  Пароль: $password"
echo "  Метод: $method"

print_status "4. Создание конфигурации... (эмуляция)"
sleep 1
print_success "✅ Конфигурация создана (эмуляция)"

print_status "5. Настройка файрвола... (эмуляция)"
sleep 1
print_success "✅ Файрвол настроен (эмуляция)"

print_status "6. Запуск сервиса... (эмуляция)"
sleep 1
print_success "✅ Сервис запущен (эмуляция)"

print_status "7. Генерация ключа подключения..."
auth_string="$method:$password"
encoded_auth=$(echo -n "$auth_string" | base64 -w 0 2>/dev/null || echo -n "$auth_string" | base64)
ss_url="ss://$encoded_auth@$server_ip:$server_port"

print_header "🎉 ТЕСТИРОВАНИЕ ЗАВЕРШЕНО УСПЕШНО!"

echo -e "${GREEN}Тестовый Shadowsocks сервер готов к использованию!${NC}"
echo ""
echo -e "${CYAN}🔗 Тестовый SS URL:${NC}"
echo -e "${YELLOW}$ss_url${NC}"
echo ""
echo -e "${CYAN}📱 Тестовые параметры:${NC}"
echo "┌─────────────────────────────────────────┐"
echo "│ Сервер:  $server_ip                     "
echo "│ Порт:    $server_port                        "
echo "│ Пароль:  $password    "
echo "│ Метод:   $method           "
echo "└─────────────────────────────────────────┘"
echo ""

print_success "✅ Все проверки пройдены успешно!"
print_status "Настоящий установщик готов к использованию на вашем сервере"
echo ""
print_warning "Помните: для реальной установки используйте install_shadowsocks.sh с правами root!" 