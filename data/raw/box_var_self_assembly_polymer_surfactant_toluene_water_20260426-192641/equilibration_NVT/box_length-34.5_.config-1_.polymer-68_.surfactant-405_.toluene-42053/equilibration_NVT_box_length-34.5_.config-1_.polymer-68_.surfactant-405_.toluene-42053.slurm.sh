#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=idle
#SBATCH --account=ea-nrtmidas
#SBATCH --time=04:30:00
#SBATCH --job-name="equilibration_NVT_box_length-34.5_.config-1_.polymer-68_.surfactant-405_.toluene-42053"
#SBATCH --output="equilibration_NVT_box_length-34.5_.config-1_.polymer-68_.surfactant-405_.toluene-42053.out"
#SBATCH --error="equilibration_NVT_box_length-34.5_.config-1_.polymer-68_.surfactant-405_.toluene-42053.err"
#SBATCH --comment "Equilibrate the system using NVT ensemble."

#SBATCH --ntasks-per-node=32
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=gokul@udel.edu
#SBATCH --mail-type=FAIL
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
cp ../../model_system/box_length-34.5_.config-1_.polymer-68_.surfactant-405_.toluene-42053/top/surfactant-405_polymer-68_toluene-42053_water_conf1.top top
cp ../../equilibration_EM/box_length-34.5_.config-1_.polymer-68_.surfactant-405_.toluene-42053/emin_conf1.gro .

# simulation                
srun -n 32 -N 1 --mpi=pmix gmx grompp -f /lustre/ea-nrtmidas/users/3770/emulsion_stability/data/input/polymer_surfactant_solvent/mdp/nvt_eq.mdp -c emin_conf1.gro -p top/surfactant-405_polymer-68_toluene-42053_water_conf1.top -o nvt_eq_conf1.tpr
srun -n 32 -N 1 --mpi=pmix gmx mdrun -v -deffnm nvt_eq_conf1  -cpt 15

