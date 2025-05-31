#!/bin/bash

# Быстрая экспериментальная тренировка для H100 SXM
export CUDA_VISIBLE_DEVICES=0
export TORCH_CUDA_ARCH_LIST="9.0"

# Основные оптимизации
export PYTORCH_CUDA_ALLOC_CONF="max_split_size_mb:512"
export TORCH_CUDNN_V8_API_ENABLED=1

echo "🚀 Запуск быстрой экспериментальной тренировки Flux LoRA..."

# Создаем директории
mkdir -p output/models_fast
mkdir -p logs

# Проверяем датасет
if [ ! "$(ls -A dataset)" ]; then
    echo "❌ Датасет не найден в папке dataset/"
    exit 1
fi

IMAGE_COUNT=$(find dataset -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" | wc -l)
echo "📊 Изображений в датасете: $IMAGE_COUNT"

# Быстрая тренировка - меньше шагов
TOTAL_STEPS=$((IMAGE_COUNT * 16))  # 16 повторений для быстрой тренировки
echo "🎯 Количество шагов: $TOTAL_STEPS (быстрая тренировка)"

# Обновляем шаги в конфиге
sed -i "s/\"--max_train_steps\": [0-9]*/\"--max_train_steps\": $TOTAL_STEPS/" config_alternative_fast.json

echo "📋 Параметры быстрой тренировки:"
echo "   - Batch Size: 16 (большой для скорости)"
echo "   - Learning Rate: 1.0 (Prodigy автоматически)"
echo "   - LoRA Rank: 16 (меньше для скорости)"
echo "   - Resolution: 768x768"
echo "   - Precision: fp8-quanto (экономия VRAM)"
echo "   - Optimizer: Prodigy (автоподбор LR)"
echo "   - Время: ~$((TOTAL_STEPS / 120)) минут"

# Запуск быстрой тренировки
python train.py \
    --config=config_alternative_fast.json \
    2>&1 | tee logs/fast_training_$(date +%Y%m%d_%H%M%S).log

echo "✅ Быстрая тренировка завершена!"
echo "📁 Результаты: output/models_fast/"
echo "💡 Для полноценной тренировки используйте: ./train_flux_h100.sh" 