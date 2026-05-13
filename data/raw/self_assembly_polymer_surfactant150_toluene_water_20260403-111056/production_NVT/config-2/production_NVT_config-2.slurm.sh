#!/bin/bash
#SBATCH --nodes=2
#SBATCH --partition=standard
#SBATCH --account=ea-nrtmidas
#SBATCH --time=24:00:00
#SBATCH --job-name="production_NVT_config-2"
#SBATCH --output="production_NVT_config-2.out"
#SBATCH --error="production_NVT_config-2.err"
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
cp ../../model_system/config-2/top/surfactant-150_polymer-20_toluene-12460_water_conf2.top top
cp ../../equilibration_NPT/config-2/npt_eq_conf2.gro .

# simulation                
srun -n 32 -N 2 --mpi=pmix gmx grompp -f /lustre/ea-nrtmidas/users/3770/emulsion_stability/data/input/polymer_surfactant_solvent/mdp/nvt_prod.mdp -c npt_eq_conf2.gro -p top/surfactant-150_polymer-20_toluene-12460_water_conf2.top -o nvt_prod_conf2.tpr
srun -n 32 -N 2 --mpi=pmix gmx mdrun -v -deffnm nvt_prod_conf2  -cpt 15

