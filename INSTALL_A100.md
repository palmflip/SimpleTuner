# 🛠️ Установка и настройка для A100 SXM

Подробная инструкция по настройке окружения для тренировки Flux LoRA на A100 SXM.

## 📋 Требования к системе

- **GPU**: A100 SXM 40GB или 80GB
- **CUDA**: 11.8+ или 12.1+
- **Python**: 3.10 или 3.11
- **RAM**: минимум 32GB
- **Диск**: минимум 100GB свободного места

## 🚀 Установка на чистом сервере

### 1. Обновление системы

```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y
sudo apt install -y git wget curl build-essential

# Проверяем CUDA
nvidia-smi
nvcc --version
```

### 2. Установка Python и pip

```bash
# Устанавливаем Python 3.10 с ОБЯЗАТЕЛЬНЫМ пакетом venv
sudo apt install -y python3.10 python3.10-venv python3.10-dev python3-pip

# Создаем алиас для удобства
echo "alias python=python3.10" >> ~/.bashrc
echo "alias pip=pip3" >> ~/.bashrc
source ~/.bashrc
```

**⚠️ ВАЖНО**: Пакет `python3.10-venv` обязателен! Без него создание виртуального окружения не работает.

### 3. Клонирование репозитория

```bash
git clone https://github.com/bghira/SimpleTuner.git
cd SimpleTuner
```

### 4. Создание виртуального окружения

```bash
# Проверяем что venv доступен
python3.10 -m venv --help

# Создаем venv
python3.10 -m venv venv

# Активируем
source venv/bin/activate

# Обновляем pip
pip install --upgrade pip setuptools wheel
```

**🚨 Если ошибка "ensurepip is not available":**
```bash
# Переустановите python3.10-venv
sudo apt install --reinstall python3.10-venv python3.10-dev
# Удалите старое окружение и создайте заново
rm -rf venv
python3.10 -m venv venv
```

### 5. Установка PyTorch с CUDA поддержкой

```bash
# Для CUDA 11.8 (рекомендуется для A100)
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Для CUDA 12.1
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Проверяем установку
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA: {torch.cuda.is_available()}')"
```

### 6. Установка зависимостей SimpleTuner

```bash
# Устанавливаем основные зависимости
pip install -r requirements.txt

# Если requirements.txt нет, устанавливаем через poetry
pip install poetry
poetry install

# Или устанавливаем вручную ключевые пакеты
pip install diffusers transformers accelerate
pip install safetensors datasets 
pip install wandb tensorboard
pip install optimum-quanto
pip install peft lycoris_lora
```

### 7. Проверка установки

```bash
# Проверяем что все работает
python -c "
import torch
import diffusers
import transformers
import accelerate
print('✅ Все пакеты установлены успешно!')
print(f'PyTorch: {torch.__version__}')
print(f'CUDA доступна: {torch.cuda.is_available()}')
print(f'GPU: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"Не найдена\"}')
"
```

## 🔧 Настройка окружения для тренировки

### 1. Создание рабочих директорий

```bash
# Создаем необходимые папки
mkdir -p dataset
mkdir -p cache/vae cache/text_embeds
mkdir -p output/models output/models_fast
mkdir -p logs
mkdir -p workspace/models/unet/flux
```

### 2. Скачивание базовой модели

```bash
# Устанавливаем huggingface-hub если нет
pip install huggingface-hub

# Логинимся в Hugging Face (нужен токен)
huggingface-cli login

# Скачиваем Flux модель
huggingface-cli download black-forest-labs/FLUX.1-dev \
  --local-dir /workspace/models/unet/flux/ \
  --local-dir-use-symlinks False

# Или если модель уже есть, просто скопируйте
# cp /path/to/your/flux_model.safetensors /workspace/models/unet/flux/fluxmania_V.safetensors
```

### 3. Настройка переменных окружения

```bash
# Добавляем в ~/.bashrc
cat >> ~/.bashrc << 'EOF'

# SimpleTuner настройки для A100
export CUDA_VISIBLE_DEVICES=0
export TORCH_CUDA_ARCH_LIST="8.0"
export PYTORCH_CUDA_ALLOC_CONF="max_split_size_mb:256"
export TORCH_CUDNN_V8_API_ENABLED=1
export TRANSFORMERS_CACHE="/workspace/cache/transformers"
export HF_HOME="/workspace/cache/huggingface"

EOF

source ~/.bashrc
```

### 4. Оптимизация системы

```bash
# Увеличиваем лимиты файлов
echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf

# Настройка swap для больших моделей
sudo fallocate -l 16G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

## 🧪 Тестовый запуск

### 1. Подготовка тестового датасета

```bash
# Создаем тестовые файлы
mkdir -p dataset
echo "A realistic photograph of a cat sitting on a chair" > dataset/1.txt
echo "A portrait photo of a dog in a park" > dataset/2.txt

# Скачиваем тестовые изображения (замените на свои)
# wget https://example.com/test1.jpg -O dataset/1.jpg
# wget https://example.com/test2.jpg -O dataset/2.jpg
```

### 2. Быстрый тест

```bash
# Активируем окружение
source venv/bin/activate

# Запускаем быстрый тест
./train_flux_a100_fast.sh
```

## 📦 Автоматическая установка

Используйте готовый скрипт для автоматической установки:

```bash
# Скрипт установки исправлен и учитывает проблему с python3.10-venv
./setup_a100.sh
```

## 🚨 Решение проблем

### Ошибка "ensurepip is not available"
```bash
# Установите обязательный пакет
sudo apt install python3.10-venv python3.10-dev

# Удалите старое окружение и создайте заново
rm -rf venv
python3.10 -m venv venv
source venv/bin/activate
```

### OutOfMemoryError
```bash
# Уменьшите batch size в конфиге
# Или используйте gradient checkpointing
export PYTORCH_CUDA_ALLOC_CONF="max_split_size_mb:128"
```

### Медленная загрузка
```bash
# Используйте SSD для кэша
export TRANSFORMERS_CACHE="/fast/ssd/cache"
export HF_HOME="/fast/ssd/cache"
```

### Проблемы с CUDA
```bash
# Переустановите PyTorch
pip uninstall torch torchvision torchaudio
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
```

### Полная переустановка окружения
```bash
# Если что-то пошло не так, полная переустановка:
rm -rf venv
sudo apt install --reinstall python3.10-venv python3.10-dev
python3.10 -m venv venv
source venv/bin/activate
pip install --upgrade pip setuptools wheel
# ... далее установка пакетов
```

---

**После установки переходите к [QUICKSTART_A100.md](QUICKSTART_A100.md) для запуска тренировки! 🎉** 