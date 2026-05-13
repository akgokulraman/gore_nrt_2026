#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=idle
#SBATCH --account=ea-nrtmidas
#SBATCH --time=01:00:00
#SBATCH --job-name="equilibration_EM_box_length-34.5_.config-1_.polymer-68_.surfactant-608_.toluene-42053"
#SBATCH --output="equilibration_EM_box_length-34.5_.config-1_.polymer-68_.surfactant-608_.toluene-42053.out"
#SBATCH --error="equilibration_EM_box_length-34.5_.config-1_.polymer-68_.surfactant-608_.toluene-42053.err"
#SBATCH --comment "Perform energy minimization on the system."

#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --export=NONE
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
cp ../../model_system/box_length-34.5_.config-1_.polymer-68_.surfactant-608_.toluene-42053/top/surfactant-608_polymer-68_toluene-42053_water_conf1.top top
cp ../../model_system/box_length-34.5_.config-1_.polymer-68_.surfactant-608_.toluene-42053/solvated_surfactant-608_polymer-68_toluene-42053_water_conf1.gro .

# simulation                
srun -n 1 -N 1 --mpi=pmix gmx grompp -f /lustre/ea-nrtmidas/users/3770/emulsion_stability/data/input/polymer_surfactant_solvent/mdp/em.mdp -c solvated_surfactant-608_polymer-68_toluene-42053_water_conf1.gro -p top/surfactant-608_polymer-68_toluene-42053_water_conf1.top -o emin_conf1.tpr
srun -n 1 -N 1 --mpi=pmix gmx mdrun -v -deffnm emin_conf1  -cpt 15

