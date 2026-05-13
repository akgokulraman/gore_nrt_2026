#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=standard
#SBATCH --account=ea-nrtmidas
#SBATCH --time=00:15:00
#SBATCH --job-name="equilibration_EM_config-3"
#SBATCH --output="equilibration_EM_config-3.out"
#SBATCH --error="equilibration_EM_config-3.err"
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
cp ../../model_system/config-3/top/surfactant-60_polymer-20_toluene-12460_water_conf3.top top
cp ../../model_system/config-3/solvated_surfactant-60_polymer-20_toluene-12460_water_conf3.gro .

# simulation                
srun -n 1 -N 1 --mpi=pmix gmx grompp -f /lustre/ea-nrtmidas/users/3770/emulsion_stability/data/input/polymer_surfactant_solvent/mdp/em.mdp -c solvated_surfactant-60_polymer-20_toluene-12460_water_conf3.gro -p top/surfactant-60_polymer-20_toluene-12460_water_conf3.top -o emin_conf3.tpr
srun -n 1 -N 1 --mpi=pmix gmx mdrun -v -deffnm emin_conf3  -cpt 15

