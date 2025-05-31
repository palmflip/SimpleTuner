#!/bin/bash
set -e

echo "🚀 Быстрая установка SimpleTuner для A100 (root)..."

# Быстрая установка пакетов
apt update
apt install -y python3.10 python3.10-venv python3.10-dev python3-pip git

# Удаляем старое окружение
rm -rf venv

# Создаем venv
python3.10 -m venv venv
source venv/bin/activate

# Быстро ставим PyTorch
pip install --upgrade pip
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Основные зависимости SimpleTuner
pip install diffusers transformers accelerate
pip install datasets safetensors bitsandbytes
pip install peft lycoris_lora optimum-quanto

# Обязательные библиотеки
pip install ftfy regex requests pillow opencv-python
pip install imageio imageio-ffmpeg tensorboard wandb
pip install compel scipy boto3 pandas torchmetrics
pip install sentencepiece tokenizers huggingface-hub
pip install numpy colorama atomicwrites beautifulsoup4

# Попытка установить xformers (может не сработать на всех системах)
pip install xformers || echo "⚠️ xformers не установлен, продолжаем без него"

# Создаем папки
mkdir -p dataset output/models output/models_fast logs workspace/models/unet/flux

# Делаем скрипты исполняемыми
chmod +x train_flux_a100.sh train_flux_a100_fast.sh

# Экспорт переменных для текущей сессии
export CUDA_VISIBLE_DEVICES=0
export TORCH_CUDA_ARCH_LIST="8.0"
export PYTORCH_CUDA_ALLOC_CONF="max_split_size_mb:256"

echo "✅ Готово! Теперь:"
echo "source venv/bin/activate"
echo "./train_flux_a100_fast.sh" 