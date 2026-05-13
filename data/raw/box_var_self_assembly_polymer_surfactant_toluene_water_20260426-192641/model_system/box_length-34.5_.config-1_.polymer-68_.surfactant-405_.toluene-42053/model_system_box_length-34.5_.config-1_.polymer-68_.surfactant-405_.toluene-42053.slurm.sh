#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=idle
#SBATCH --account=ea-nrtmidas
#SBATCH --time=00:30:00
#SBATCH --job-name="model_system_box_length-34.5_.config-1_.polymer-68_.surfactant-405_.toluene-42053"
#SBATCH --output="model_system_box_length-34.5_.config-1_.polymer-68_.surfactant-405_.toluene-42053.out"
#SBATCH --error="model_system_box_length-34.5_.config-1_.polymer-68_.surfactant-405_.toluene-42053.err"
#SBATCH --comment "Model the initial configuration of the system. Create three initial configurations to ensure the validity, reproducibility, and statistical significance of the simulation results."

#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#UD_QUIET_JOB_SETUP=YES
#UD_MACHINE_FILE_FORMAT='%h%[:]C'
#export UD_JOB_EXIT_FN_SIGNALS="SIGTERM EXIT"  
#UD_QUIET_JOB_SETUP=YES
#UD_MACHINE_FILE_FORMAT='%h%[:]C'
#export UD_JOB_EXIT_FN_SIGNALS="SIGTERM EXIT"  

# adding necessary packages
vpkg_require gromacs  
. /opt/shared/slurm/templates/libexec/openmpi.sh  
vpkg_require conda
conda activate md

# copy relavant files
cp -r /lustre/ea-nrtmidas/users/3770/emulsion_stability/data/input/polymer_surfactant_solvent/itp .
mkdir top
cp /lustre/ea-nrtmidas/users/3770/emulsion_stability/data/input/polymer_surfactant_solvent/top/surfactant-405_polymer-68_toluene-42053_water_conf1.top top
cp  /lustre/ea-nrtmidas/users/3770/emulsion_stability/data/input/polymer_surfactant_solvent/*.gro .

# create topology of the system
srun -n 1 -N 1 --mpi=pmix gmx insert-molecules -ci surfactant.gro -nmol 405  -box 34.5 34.5 34.5 -o surfactant405_conf1.gro
srun -n 1 -N 1 --mpi=pmix gmx insert-molecules -ci polymer.gro -nmol 68 -f surfactant405_conf1.gro -o polymer68_surfactant405_conf1.gro
srun -n 1 -N 1 --mpi=pmix gmx insert-molecules -ci toluene.gro -nmol 42053 -f polymer68_surfactant405_conf1.gro -o toluene42053_polymer68_surfactant405_conf1.gro

# solvate the system with water
srun -n 1 -N 1 --mpi=pmix gmx solvate -cp toluene42053_polymer68_surfactant405_conf1.gro -cs water.gro -o solvated_surfactant-405_polymer-68_toluene-42053_water_conf1.gro -p top/surfactant-405_polymer-68_toluene-42053_water_conf1.top

