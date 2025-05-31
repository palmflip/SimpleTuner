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

# Минимальные зависимости для запуска
pip install diffusers transformers accelerate safetensors datasets huggingface-hub peft lycoris_lora optimum-quanto

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