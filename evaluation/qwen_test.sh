
[ -z "$MODEL_PATH" ] && MODEL_PATH=pretrained_model_path

source activate GRA
sleep 2


START_TIME=`date +%Y%m%d-%H:%M:%S`



output_file="~/opencompass/configs/models/hf_llama/hf_llama3_1_8b_instruct_${START_TIME}.py"
mkdir -p "~/opencompass/logs/"


cat << EOF > $output_file
from opencompass.models import HuggingFacewithChatTemplate

models = [
    dict(
        type=HuggingFacewithChatTemplate,
        abbr='llama-3_1-8b-instruct-hf',
        path='${MODEL_PATH}',
        max_out_len=4096,
        batch_size=1,
        run_cfg=dict(num_gpus=1),
        stop_words=['<|end_of_text|>'],
    )
]
EOF
echo "YAML CONFIG FILE HAS BEEN CREATED: $output_file"


CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 opencompass \
    --datasets \
    gsm8k_gen math_gen \
    humaneval_gen mbpp_gen \
    hellaswag_gen bbh_gen ARC_c_gen gpqa_gen \
    mmlu_zero_shot_gen_47e2c0  IFEval_gen \
    --hf-type chat --models hf_llama3_1_8b_instruct_${START_TIME} --max-num-worker 8 -a vllm
