# 🔧 Решение проблемы "ensurepip is not available"

## Проблема

При запуске `./setup_a100.sh` или создании виртуального окружения вы получаете ошибку:

```
The virtual environment was not created successfully because ensurepip is not
available.  On Debian/Ubuntu systems, you need to install the python3-venv
package using the following command.

    apt install python3.10-venv

You may need to use sudo with that command.  After installing the python3-venv
package, recreate your virtual environment.

Failing command: /workspace/SimpleTuner/venv/bin/python3.10
```

## Быстрое решение

```bash
# 1. Установите обязательный пакет
sudo apt install python3.10-venv python3.10-dev

# 2. Удалите поврежденное окружение
rm -rf venv

# 3. Запустите установку заново
./setup_a100.sh
```

## Альтернативное решение

```bash
# Переустановите все Python пакеты
sudo apt install --reinstall python3.10 python3.10-venv python3.10-dev python3-pip

# Удалите старое окружение
rm -rf venv

# Создайте новое окружение вручную
python3.10 -m venv venv
source venv/bin/activate

# Обновите pip
pip install --upgrade pip setuptools wheel

# Продолжите установку
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
# ... остальные пакеты
```

## Причина проблемы

На Ubuntu/Debian системах Python разделен на отдельные пакеты:
- `python3.10` - основной интерпретатор
- `python3.10-venv` - модуль для создания виртуальных окружений
- `python3.10-dev` - заголовочные файлы для компиляции

Без `python3.10-venv` команда `python3.10 -m venv` не работает.

## Проверка

После исправления проверьте что всё работает:

```bash
# Проверка что venv доступен
python3.10 -m venv --help

# Создание тестового окружения
python3.10 -m venv test_env
source test_env/bin/activate
deactivate
rm -rf test_env

echo "✅ venv работает корректно!"
```

## Обновленная установка

Скрипт `setup_a100.sh` теперь автоматически устанавливает все необходимые пакеты и проверяет их работу. Просто запустите:

```bash
./setup_a100.sh
```

---

**Эта проблема решена в обновленных скриптах установки! 🎉** 