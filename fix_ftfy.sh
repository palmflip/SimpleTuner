#!/bin/bash

echo "🔧 Быстрое исправление недостающих пакетов..."

source venv/bin/activate

# Устанавливаем все возможные недостающие пакеты
pip install ftfy regex requests pillow opencv-python
pip install imageio imageio-ffmpeg tensorboard wandb
pip install compel scipy boto3 pandas torchmetrics
pip install sentencepiece tokenizers huggingface-hub
pip install numpy colorama atomicwrites beautifulsoup4
pip install bitsandbytes

# xformers может не работать на всех системах
pip install xformers || echo "⚠️ xformers не установлен, но это не критично"

echo "✅ Готово! Запускайте тренировку." 