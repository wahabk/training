#!/bin/bash -e

#SBATCH --job-name=unet_G1_B8             # Job name
#SBATCH --nodes=1                    # Number of nodes
#SBATCH --time=24:00:00                   # Time limit hrs:min:sec
#SBATCH --output=out/unet_G1_B8_%j.out  # Standard output and error log (%j expands to jobId)

echo "-------------------------------------------------"
hostname
nvidia-smi
module use $HOME/modulefiles/
# module load nccl cudatoolkit libfabric
module list 
echo "-------------------------------------------------"

export RAW_DATA_DIR=/home/benchmarking/akawafi1.benchmarking/data/mlperf/training/unet3d/kits19/data
export PREPROCESSED_DATA_DIR=/home/benchmarking/akawafi1.benchmarking/data/mlperf/training/unet3d/preprocessed
export RESULTS_DIR=/home/benchmarking/akawafi1.benchmarking/data/mlperf/training/unet3d/results

singularity exec --nv \
    --bind $RAW_DATA_DIR:/raw_data \
    --bind $PREPROCESSED_DATA_DIR:/data \
    --bind $RESULTS_DIR:/results \
    unet3d.sif \
    bash -c "chmod +x run_and_time.sh && ./run_and_time.sh 0"
