#!/bin/bash

export OMP_NUM_THREADS=72
GRANK=$SLURM_PROCID
LRANK=$(echo "$GRANK % 4" | bc)

# echo GRANK $GRANK
# echo LRANK $LRANK
# echo OMP_NUM_THREADS $OMP_NUM_THREADS

LCPU=$(echo "$LRANK * 72" | bc)
UCPU=$(echo "$LCPU + $OMP_NUM_THREADS - 1" | bc)

echo "Rank: " $GRANK "Local Rank:" $LRANK "cpu list: ${LCPU}-${UCPU} omp_num_threads: " $OMP_NUM_THREADS
numactl --physcpubind=${LCPU}-${UCPU} $@