#!/bin/bash
set -e

echo "🚀 Автоматическая настройка SimpleTuner для A100 SXM..."

# Проверяем NVIDIA GPU
if ! nvidia-smi > /dev/null 2>&1; then
    echo "❌ NVIDIA GPU не найдена. Убедитесь что драйверы установлены."
    exit 1
fi

echo "✅ GPU найдена: $(nvidia-smi --query-gpu=name --format=csv,noheader,nounits | head -1)"

# Обновляем систему и устанавливаем базовые пакеты
echo "📦 Обновляем систему и устанавливаем необходимые пакеты..."
sudo apt update
sudo apt install -y git wget curl build-essential

# Проверяем и устанавливаем Python 3.10 с venv
if ! command -v python3.10 &> /dev/null; then
    echo "📦 Устанавливаем Python 3.10..."
    sudo apt install -y python3.10 python3.10-venv python3.10-dev python3-pip
else
    echo "🐍 Python 3.10 найден, проверяем python3.10-venv..."
    # Устанавливаем venv если его нет
    sudo apt install -y python3.10-venv python3.10-dev python3-pip
fi

# Проверяем что venv работает
echo "🧪 Проверяем возможность создания виртуального окружения..."
if ! python3.10 -m venv --help > /dev/null 2>&1; then
    echo "❌ python3.10-venv не работает. Переустанавливаем..."
    sudo apt install --reinstall -y python3.10-venv python3.10-dev
fi

echo "🐍 Создаем виртуальное окружение..."
# Удаляем старое окружение если есть
if [ -d "venv" ]; then
    echo "🗑️  Удаляем старое виртуальное окружение..."
    rm -rf venv
fi

# Создаем новое окружение
python3.10 -m venv venv

# Проверяем что окружение создалось успешно
if [ ! -f "venv/bin/activate" ]; then
    echo "❌ Не удалось создать виртуальное окружение."
    echo "🔧 Попробуйте вручную:"
    echo "   sudo apt install python3.10-venv python3.10-dev"
    echo "   python3.10 -m venv venv"
    exit 1
fi

source venv/bin/activate

echo "⬆️  Обновляем pip..."
pip install --upgrade pip setuptools wheel

echo "🔥 Устанавливаем PyTorch для A100 (CUDA 8.0)..."
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

echo "📚 Устанавливаем зависимости SimpleTuner..."
pip install diffusers transformers accelerate
pip install safetensors datasets 
pip install wandb tensorboard
pip install optimum-quanto
pip install peft lycoris_lora
pip install huggingface-hub

echo "📁 Создаем рабочие директории..."
mkdir -p dataset
mkdir -p cache/vae cache/text_embeds cache/transformers cache/huggingface
mkdir -p output/models output/models_fast
mkdir -p logs
mkdir -p workspace/models/unet/flux

echo "🔧 Настраиваем переменные окружения..."
cat >> ~/.bashrc << 'ENV_EOF'

# SimpleTuner настройки для A100
export CUDA_VISIBLE_DEVICES=0
export TORCH_CUDA_ARCH_LIST="8.0"
export PYTORCH_CUDA_ALLOC_CONF="max_split_size_mb:256"
export TORCH_CUDNN_V8_API_ENABLED=1
export TRANSFORMERS_CACHE="/workspace/cache/transformers"
export HF_HOME="/workspace/cache/huggingface"

ENV_EOF

echo "⚡ Делаем скрипты исполняемыми..."
chmod +x train_flux_a100.sh train_flux_a100_fast.sh

echo "🧪 Проверяем установку..."
python -c "
import torch
import diffusers
import transformers
print('✅ Все пакеты установлены успешно!')
print(f'PyTorch: {torch.__version__}')
print(f'CUDA доступна: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'GPU: {torch.cuda.get_device_name(0)}')
    print(f'VRAM: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.1f} GB')
"

echo ""
echo "🎉 Установка завершена успешно!"
echo ""
echo "📋 Следующие шаги:"
echo "1. Активируйте окружение: source venv/bin/activate"
echo "2. Поместите ваш датасет в папку dataset/"
echo "3. Скачайте Flux модель в /workspace/models/unet/flux/fluxmania_V.safetensors"
echo "4. Запустите быструю тренировку: ./train_flux_a100_fast.sh"
echo "5. Или качественную тренировку: ./train_flux_a100.sh"
echo ""
echo "📖 Подробная инструкция: INSTALL_A100.md"
echo "🚀 Быстрый старт: QUICKSTART_A100.md"
echo "" 