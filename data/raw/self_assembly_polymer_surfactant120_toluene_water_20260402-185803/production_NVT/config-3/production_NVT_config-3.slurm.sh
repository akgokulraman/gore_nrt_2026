#!/bin/bash
#SBATCH --nodes=2
#SBATCH --partition=standard
#SBATCH --account=ea-nrtmidas
#SBATCH --time=24:00:00
#SBATCH --job-name="production_NVT_config-3"
#SBATCH --output="production_NVT_config-3.out"
#SBATCH --error="production_NVT_config-3.err"
#SBATCH --comment "Equilibrate the system using NPT ensemble."

#SBATCH --ntasks-per-node=32
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=gokul@udel.edu
#SBATCH --mail-type=END,FAIL
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
cp ../../model_system/config-3/top/surfactant-120_polymer-20_toluene-12460_water_conf3.top top
cp ../../equilibration_NPT/config-3/npt_eq_conf3.gro .

# simulation                
srun -n 32 -N 2 --mpi=pmix gmx grompp -f /lustre/ea-nrtmidas/users/3770/emulsion_stability/data/input/polymer_surfactant_solvent/mdp/nvt_prod.mdp -c npt_eq_conf3.gro -p top/surfactant-120_polymer-20_toluene-12460_water_conf3.top -o nvt_prod_conf3.tpr
srun -n 32 -N 2 --mpi=pmix gmx mdrun -v -deffnm nvt_prod_conf3  -cpt 15

