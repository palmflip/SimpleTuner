# 🚀 Быстрый старт - Тренировка Flux LoRA на A100 SXM

Этот репозиторий адаптирован для оптимальной тренировки LoRA персонажа на A100 SXM с разрешением 1024x1024.

## ⚡ За 5 минут до запуска

### 0. Установка (если нужно)

```bash
# Для root пользователя (быстро):
./setup_a100_root.sh

# Для обычного пользователя:
./setup_a100.sh

# Если ошибка "ensurepip is not available":
# Root: apt install python3.10-venv python3.10-dev && rm -rf venv && ./setup_a100_root.sh
# User: sudo apt install python3.10-venv python3.10-dev && rm -rf venv && ./setup_a100.sh
```

### 1. Подготовьте датасет локально

```bash
# Активируйте окружение
source venv/bin/activate

# Создайте папку dataset и поместите туда:
mkdir dataset

# Ваши файлы должны выглядеть так:
dataset/
├── 1.jpg + 1.txt
├── 2.jpg + 2.txt
├── ...
└── 50.jpg + 50.txt
```

### 2. Скопируйте на A100 сервер

```bash
git clone <your-repo>
cd SimpleTuner

# Запустите установку (выберите версию)
./setup_a100_root.sh  # для root
# или
./setup_a100.sh       # для обычного пользователя

# Скопируйте папку dataset на сервер
# scp -r dataset/ user@server:/path/to/SimpleTuner/
```

### 3. Убедитесь, что модель на месте

```bash
# Автоматическая загрузка Flux модели
source venv/bin/activate
huggingface-cli login  # введите ваш HF токен

# Скачайте модель
huggingface-cli download black-forest-labs/FLUX.1-dev \
  --local-dir /workspace/models/unet/flux/ \
  --local-dir-use-symlinks False

# Переименуйте если нужно
mv /workspace/models/unet/flux/flux1-dev.safetensors /workspace/models/unet/flux/fluxmania_V.safetensors
```

### 4. Запустите тренировку

```bash
# Активируйте окружение
source venv/bin/activate

# Для экспериментов (быстро, 20 минут)
./train_flux_a100_fast.sh

# Для продакшна (качественно, 45 минут)
./train_flux_a100.sh
```

## 📊 Что вы получите

- **Быстрая тренировка**: LoRA rank 16, 1024px, ~20 минут
- **Качественная тренировка**: LoRA rank 32, 1024px, ~45 минут
- **Результат**: файл `pytorch_lora_weights.safetensors` готовый к использованию

## 🔧 Настройки оптимизированы для A100:

- **A100 SXM 40GB/80GB** - эффективное использование VRAM
- **CUDA 8.0** - правильная архитектура для A100
- **Разрешение 1024x1024** - полное качество Flux
- **Batch Size 4** - баланс скорости и VRAM
- **Gradient Accumulation** - имитация больших батчей
- **bf16 precision** - оптимально для A100
- **Автоустановка** - всё настраивается автоматически

## 🎯 Результаты для A100

| Параметр | Быстро | Качественно |
|----------|--------|-------------|
| Время | 20 мин | 45 мин |
| Размер LoRA | ~50MB | ~150MB |
| Качество | Хорошее | Отличное |
| VRAM | ~32-36GB | ~35-38GB |
| Подходит для | A100 40GB+ | A100 40GB+ |

## 🚨 Если что-то не работает

1. **"ensurepip is not available"** → Root: `apt install python3.10-venv && rm -rf venv && ./setup_a100_root.sh`
2. **Нет пакетов** → Запустите `./setup_a100_root.sh` (root) или `./setup_a100.sh`
3. **Out of Memory** → Уменьшите batch_size до 2 в конфиге
4. **Медленно** → Убедитесь что используете CUDA 8.0 (не 9.0)
5. **Плохое качество** → Увеличьте количество повторений
6. **Нет совместимости** → Все LoRA работают с ComfyUI/A1111

## 💡 Особенности A100

- **Меньше VRAM чем H100**: используем gradient accumulation
- **CUDA 8.0**: правильная архитектура (не 9.0 как у H100)
- **Медленнее H100**: но все равно очень быстро
- **40GB/80GB варианты**: конфиги подходят для обеих
- **Автоустановка**: скрипт настройки всё делает сам
- **python3.10-venv**: частая проблема на Ubuntu, исправлена в скрипте
- **Root версия**: setup_a100_root.sh без sudo для экономии времени

## 📖 Подробная документация

- **Установка**: [INSTALL_A100.md](INSTALL_A100.md)
- **Тренировка**: [README_TRAINING.md](README_TRAINING.md)
- **Примеры**: [dataset_example.txt](dataset_example.txt)

---

**A100 SXM отлично подходит для Flux LoRA! Качественные результаты гарантированы! 🎉** 