#!/bin/bash
set -e

# runs benchmark and reports time to convergence
# to use the script:
#   run_and_time.sh <random seed 1-5>

SEED=${1:--1}

N_GPU_PER_NODE=1
MAX_EPOCHS=4000
QUALITY_THRESHOLD="0.908"
START_EVAL_AT=1000
EVALUATE_EVERY=20
LEARNING_RATE="2.0"
LR_WARMUP_EPOCHS=1000
DATASET_DIR="/data"
BATCH_SIZE=8
GRADIENT_ACCUMULATION_STEPS=1
NUM_WORKERS=72

echo MAX_EPOCHS $MAX_EPOCHS
echo QUALITY_THRESHOLD $QUALITY_THRESHOLD
echo START_EVAL_AT $START_EVAL_AT
echo EVALUATE_EVERY $EVALUATE_EVERY
echo LEARNING_RATE $LEARNING_RATE
echo LR_WARMUP_EPOCHS $LR_WARMUP_EPOCHS
echo DATASET_DIR $DATASET_DIR
echo BATCH_SIZE $BATCH_SIZE
echo GRADIENT_ACCUMULATION_STEPS $GRADIENT_ACCUMULATION_STEPS
echo NUM_WORKERS $NUM_WORKERS
echo OMP_NUM_THREADS $OMP_NUM_THREADS
echo NUM_GPUS $N_GPU_PER_NODE
echo SLURM_NNODES $SLURM_NNODES

if [ -d ${DATASET_DIR} ]
then
    # start timing
    start=$(date +%s)
    start_fmt=$(date +%Y-%m-%d\ %r)
    echo "STARTING TIMING RUN AT $start_fmt"

# CLEAR YOUR CACHE HERE
  python -c "
from mlperf_logging.mllog import constants
from runtime.logging import mllog_event
mllog_event(key=constants.CACHE_CLEAR, value=True)"

  OMP_NUM_THREADS=18 torchrun --nnodes $SLURM_NNODES --nproc-per-node $N_GPU_PER_NODE main.py --data_dir ${DATASET_DIR} \
    --epochs ${MAX_EPOCHS} \
    --evaluate_every ${EVALUATE_EVERY} \
    --start_eval_at ${START_EVAL_AT} \
    --quality_threshold ${QUALITY_THRESHOLD} \
    --batch_size ${BATCH_SIZE} \
    --optimizer lamb \
    --ga_steps ${GRADIENT_ACCUMULATION_STEPS} \
    --learning_rate ${LEARNING_RATE} \
    --seed ${SEED} \
    --lr_warmup_epochs ${LR_WARMUP_EPOCHS} \
    --num_workers ${NUM_WORKERS} \
    --loader "synthetic"

	# end timing
	end=$(date +%s)
	end_fmt=$(date +%Y-%m-%d\ %r)
	echo "ENDING TIMING RUN AT $end_fmt"

	# report result
	result=$(( $end - $start ))
	result_name="image_segmentation"

	echo "RESULT,$result_name,$SEED,$result,$USER,$start_fmt"
else
	echo "Directory ${DATASET_DIR} does not exist"
fi