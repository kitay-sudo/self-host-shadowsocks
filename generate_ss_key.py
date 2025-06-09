#!/usr/bin/env python3
"""
Shadowsocks Key Generator
Генератор ключей для Shadowsocks сервера
"""
import base64
import json
import os
import subprocess
import sys

def get_external_ip():
    """Получение внешнего IP адреса"""
    try:
        result = subprocess.run(['curl', '-s', '-4', 'ifconfig.me'], 
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0 and result.stdout.strip():
            return result.stdout.strip()
    except:
        pass
    
    try:
        result = subprocess.run(['curl', '-s', '-4', 'icanhazip.com'], 
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0 and result.stdout.strip():
            return result.stdout.strip()
    except:
        pass
    
    return None

def generate_ss_key():
    """Генерация Shadowsocks ключа"""
    config_path = '/etc/shadowsocks-libev/config.json'
    
    print("🔑 Генератор Shadowsocks ключей")
    print("=" * 40)
    
    # Проверяем существование файла конфигурации
    if os.path.exists(config_path):
        try:
            with open(config_path, 'r') as f:
                config = json.load(f)
            
            method = config.get('method', 'aes-256-gcm')
            password = config.get('password')
            server_port = config.get('server_port', 8388)
            
            print(f"📋 Найдена конфигурация:")
            print(f"   Метод: {method}")
            print(f"   Порт: {server_port}")
            print(f"   Пароль: {password}")
            
        except Exception as e:
            print(f"❌ Ошибка чтения конфигурации: {e}")
            return False
    else:
        print("⚠️  Файл конфигурации не найден. Введите параметры:")
        method = input("Метод шифрования [chacha20-ietf-poly1305]: ").strip() or "chacha20-ietf-poly1305"
        password = input("Пароль: ").strip()
        server_port_input = input("Порт [8388]: ").strip() or "8388"
        try:
            server_port = int(server_port_input)
        except ValueError:
            print("❌ Неверный формат порта!")
            return False
    
    if not password:
        print("❌ Пароль обязателен!")
        return False
    
    # Автоматическое получение IP
    print(f"\n🌐 Определение внешнего IP адреса...")
    auto_ip = get_external_ip()
    
    if auto_ip:
        print(f"   Найден IP: {auto_ip}")
        use_auto = input(f"Использовать {auto_ip}? [Y/n]: ").strip().lower()
        if use_auto in ['', 'y', 'yes', 'да']:
            server_ip = auto_ip
        else:
            server_ip = input("Введите IP адрес сервера: ").strip()
    else:
        print("   Не удалось автоматически определить IP")
        server_ip = input("Введите IP адрес сервера: ").strip()
    
    if not server_ip:
        print("❌ IP адрес обязателен!")
        return False
    
    # Генерация SS URL
    auth_string = f"{method}:{password}"
    encoded_auth = base64.b64encode(auth_string.encode()).decode()
    ss_url = f"ss://{encoded_auth}@{server_ip}:{server_port}"
    
    print(f"\n" + "=" * 50)
    print(f"🔑 ВАШ SHADOWSOCKS КЛЮЧ:")
    print(f"=" * 50)
    print(f"{ss_url}")
    print(f"=" * 50)
    
    print(f"\n📱 Параметры для ручного ввода:")
    print(f"┌─────────────────────────────────────────┐")
    print(f"│ Сервер:  {server_ip:<30} │")
    print(f"│ Порт:    {server_port:<30} │") 
    print(f"│ Пароль:  {password:<30} │")
    print(f"│ Метод:   {method:<30} │")
    print(f"└─────────────────────────────────────────┘")
    
    print(f"\n💡 Инструкции по использованию:")
    print(f"📱 Android: Установите 'Shadowsocks' → '+' → Вставьте ss:// ссылку")
    print(f"📱 iOS: Установите 'Shadowrocket' → '+' → Вставьте ss:// ссылку")  
    print(f"🖥️  Windows: Скачайте Shadowsocks-Windows → Импорт по ss:// ссылке")
    print(f"🍎 macOS: Используйте ShadowsocksX-NG → Импорт по ss:// ссылке")
    
    # Проверка корректности
    try:
        decoded = base64.b64decode(encoded_auth).decode()
        if decoded == auth_string:
            print(f"\n✅ Ключ сгенерирован корректно!")
        else:
            print(f"\n❌ Ошибка генерации ключа")
            return False
    except Exception as e:
        print(f"\n❌ Ошибка проверки: {e}")
        return False
    
    # Сохранение в файл
    try:
        with open('shadowsocks_key.txt', 'w') as f:
            f.write(f"Shadowsocks Connection Info\n")
            f.write(f"==========================\n\n")
            f.write(f"SS URL: {ss_url}\n\n")
            f.write(f"Manual Settings:\n")
            f.write(f"Server: {server_ip}\n")
            f.write(f"Port: {server_port}\n")
            f.write(f"Password: {password}\n")
            f.write(f"Method: {method}\n")
        print(f"\n💾 Ключ сохранен в файл: shadowsocks_key.txt")
    except:
        print(f"\n⚠️  Не удалось сохранить в файл")
    
    return True

if __name__ == "__main__":
    try:
        if generate_ss_key():
            print(f"\n🎉 Готово! Используйте ключ в своем Shadowsocks клиенте.")
        else:
            print(f"\n❌ Произошла ошибка при генерации ключа.")
            sys.exit(1)
    except KeyboardInterrupt:
        print(f"\n\n⏹️  Прервано пользователем.")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ Неожиданная ошибка: {e}")
        sys.exit(1) 