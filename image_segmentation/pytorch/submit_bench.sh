#!/bin/bash -e

#SBATCH --job-name=unet_32             # Job name
#SBATCH --nodes=1                    # Number of nodes
#SBATCH --time=24:00:00                   # Time limit hrs:min:sec
#SBATCH --output=out/unet_32_%j.out  # Standard output and error log (%j expands to jobId)

echo "-------------------------------------------------"
hostname
nvidia-smi
module use $HOME/modulefiles/
module load nccl cudatoolkit libfabric
module list 
echo "-------------------------------------------------"

./wrapper.sh singularity exec --nv \
    --bind $RAW_DATA_DIR:/raw_data \
    --bind $PREPROCESSED_DATA_DIR:/data \
    --bind $RESULTS_DIR:/results \
    unet3d.sif \
    bash run_and_time.sh 0