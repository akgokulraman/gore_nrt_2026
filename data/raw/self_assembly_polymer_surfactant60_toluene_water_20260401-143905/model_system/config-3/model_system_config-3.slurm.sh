#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=standard
#SBATCH --account=ea-nrtmidas
#SBATCH --time=00:10:00
#SBATCH --job-name="model_system_config-3"
#SBATCH --output="model_system_config-3.out"
#SBATCH --error="model_system_config-3.err"
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
cp /lustre/ea-nrtmidas/users/3770/emulsion_stability/data/input/polymer_surfactant_solvent/top/surfactant-60_polymer-20_toluene-12460_water_conf3.top top
cp  /lustre/ea-nrtmidas/users/3770/emulsion_stability/data/input/polymer_surfactant_solvent/*.gro .

# create topology of the system
srun -n 1 -N 1 --mpi=pmix gmx insert-molecules -ci surfactant.gro -nmol 60  -box 23.0 23.0 23.0 -o surfactant60_conf3.gro
srun -n 1 -N 1 --mpi=pmix gmx insert-molecules -ci polymer.gro -nmol 20 -f surfactant60_conf3.gro -o polymer20_surfactant60_conf3.gro
srun -n 1 -N 1 --mpi=pmix gmx insert-molecules -ci toluene.gro -nmol 12460 -f polymer20_surfactant60_conf3.gro -o toluene12460_polymer20_surfactant60_conf3.gro

# solvate the system with water
srun -n 1 -N 1 --mpi=pmix gmx solvate -cp toluene12460_polymer20_surfactant60_conf3.gro -cs water.gro -o solvated_surfactant-60_polymer-20_toluene-12460_water_conf3.gro -p top/surfactant-60_polymer-20_toluene-12460_water_conf3.top

