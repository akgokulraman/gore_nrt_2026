#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=idle
#SBATCH --account=ea-nrtmidas
#SBATCH --time=01:20:00
#SBATCH --job-name="equilibration_NVT_config-1"
#SBATCH --output="equilibration_NVT_config-1.out"
#SBATCH --error="equilibration_NVT_config-1.err"
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
cp ../../model_system/config-1/top/surfactant-530_polymer-20_toluene-12460_water_conf1.top top
cp ../../equilibration_EM/config-1/emin_conf1.gro .

# simulation                
srun -n 32 -N 1 --mpi=pmix gmx grompp -f /lustre/ea-nrtmidas/users/3770/emulsion_stability/data/input/polymer_surfactant_solvent/mdp/nvt_eq.mdp -c emin_conf1.gro -p top/surfactant-530_polymer-20_toluene-12460_water_conf1.top -o nvt_eq_conf1.tpr
srun -n 32 -N 1 --mpi=pmix gmx mdrun -v -deffnm nvt_eq_conf1  -cpt 15

