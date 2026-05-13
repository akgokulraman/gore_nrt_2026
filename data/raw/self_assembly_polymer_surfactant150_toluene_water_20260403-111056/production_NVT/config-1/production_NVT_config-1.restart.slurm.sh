#!/bin/bash
#SBATCH --nodes=2
#SBATCH --partition=standard
#SBATCH --account=ea-nrtmidas
#SBATCH --time=24:00:00
#SBATCH --job-name="production_NVT_config-1"
#SBATCH --output="production_NVT_config-1.out"
#SBATCH --error="production_NVT_config-1.err"
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

# rerun simulation
srun -n 32 -N 2 --mpi=pmix gmx mdrun -cpi nvt_prod_conf1 -s nvt_prod_conf1.tpr -deffnm nvt_prod_conf1

