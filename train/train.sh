[ -z "$EPOCH" ] && EPOCH=1
[ -z "$DATASET" ] && DATASET=GRA-Alpaca
[ -z "$SEED" ] && SEED=0
[ -z "$MODEL_PATH" ] && MODEL_PATH=pretrained_model_path

DS_CONFIG_PATH=examples/deepspeed/ds_z2_config.json
OUTPUT_PATH=saves/${RUN_NAME}

set -x

START_TIME=`date +%Y%m%d-%H:%M:%S`
source activate GRA
torchrun --nnodes=1 --nproc-per-node=8 src/train.py \
    --deepspeed $DS_CONFIG_PATH \
    --stage sft \
    --do_train \
    --use_fast_tokenizer \
    --flash_attn fa2 \
    --model_name_or_path $MODEL_PATH \
    --dataset $DATASET \
    --template default \
    --seed $SEED \
    --finetuning_type full \
    --output_dir $OUTPUT_PATH \
    --overwrite_cache \
    --overwrite_output_dir \
    --warmup_ratio 0.03 \
    --weight_decay 0. \
    --per_device_train_batch_size 4 \
    --gradient_accumulation_steps 8 \
    --ddp_timeout 9000 \
    --learning_rate 5e-6 \
    --lr_scheduler_type cosine \
    --cutoff_len 4096 \
    --save_steps 400 \
    --logging_steps 1 \
    --plot_loss \
    --resize_vocab \
    --num_train_epochs $EPOCH \
    --bf16 \
    --report_to wandb &


