#!/bin/bash

echo "🔧 Исправляем проблему с xformers..."

source venv/bin/activate

# Удаляем проблемный xformers
pip uninstall xformers -y

# Переустанавливаем правильную версию для CUDA 11.8
pip install xformers --index-url https://download.pytorch.org/whl/cu118

# Если не помогло, удаляем xformers совсем
if ! python -c "import xformers" 2>/dev/null; then
    echo "⚠️ Удаляем xformers, работаем без него"
    pip uninstall xformers -y
fi

echo "✅ Готово! Пробуйте запускать." 