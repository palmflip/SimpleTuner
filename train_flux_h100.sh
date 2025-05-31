#!/bin/bash

# Настройки для H100 SXM - максимальная производительность
export CUDA_VISIBLE_DEVICES=0
export TORCH_CUDA_ARCH_LIST="9.0"
export CUDA_LAUNCH_BLOCKING=0
export NCCL_P2P_DISABLE=0
export NCCL_IB_DISABLE=0

# Оптимизации CUDA для H100
export TORCH_CUDNN_USE_HEURISTIC_MODE_B=1
export TORCH_CUDNN_V8_API_ENABLED=1
export PYTORCH_CUDA_ALLOC_CONF="max_split_size_mb:512"

# Логирование
export WANDB_DISABLED=true
export TRANSFORMERS_VERBOSITY=error

# Проверяем структуру директорий
echo "🔍 Проверяем структуру проекта..."

# Создаем необходимые директории
mkdir -p dataset
mkdir -p cache/vae
mkdir -p cache/text_embeds
mkdir -p output/models
mkdir -p logs

echo "📁 Структура директорий готова"

# Проверяем наличие датасета
if [ ! "$(ls -A dataset)" ]; then
    echo "⚠️  ВНИМАНИЕ: Папка dataset пуста!"
    echo "📋 Поместите ваши изображения (1.jpg, 2.jpg, ...) и текстовые файлы (1.txt, 2.txt, ...) в папку dataset/"
    echo "💡 Пример структуры:"
    echo "   dataset/"
    echo "   ├── 1.jpg"
    echo "   ├── 1.txt"
    echo "   ├── 2.jpg"
    echo "   ├── 2.txt"
    echo "   └── ..."
    exit 1
fi

# Проверяем наличие базовой модели
if [ ! -f "/workspace/models/unet/flux/fluxmania_V.safetensors" ]; then
    echo "❌ Базовая модель не найдена по пути: /workspace/models/unet/flux/fluxmania_V.safetensors"
    echo "📥 Убедитесь, что модель загружена в правильную директорию"
    exit 1
fi

echo "✅ Базовая модель найдена"

# Считаем количество изображений в датасете
IMAGE_COUNT=$(find dataset -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" | wc -l)
echo "📊 Найдено изображений в датасете: $IMAGE_COUNT"

if [ $IMAGE_COUNT -lt 10 ]; then
    echo "⚠️  Рекомендуется минимум 10 изображений для качественной тренировки"
fi

# Рассчитываем оптимальное количество шагов
TOTAL_STEPS=$((IMAGE_COUNT * 40))  # 40 повторений на изображение
echo "🎯 Общее количество шагов тренировки: $TOTAL_STEPS"

echo "🚀 Запускаем тренировку Flux LoRA на H100 SXM..."
echo "⏱️  Примерное время тренировки: $((TOTAL_STEPS / 60)) минут"

# Обновляем количество шагов в конфиге
sed -i "s/\"--max_train_steps\": [0-9]*/\"--max_train_steps\": $TOTAL_STEPS/" config/config.json

# Логируем параметры
echo "📋 Параметры тренировки:"
echo "   - Batch Size: 8"
echo "   - Learning Rate: 8e-5"
echo "   - LoRA Rank: 32"
echo "   - Resolution: 1024x1024"
echo "   - Target: all layers"
echo "   - Precision: bf16"
echo "   - Optimizer: adamw_bf16"
echo "   - Scheduler: cosine_with_restarts"

# Запускаем тренировку
python train.py \
    --config=config/config.json \
    2>&1 | tee logs/training_$(date +%Y%m%d_%H%M%S).log

echo "✅ Тренировка завершена!"
echo "📁 Результаты сохранены в: output/models/"
echo "📊 Логи доступны в: logs/" 