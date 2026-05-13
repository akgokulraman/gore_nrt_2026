#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=standard
#SBATCH --account=ea-nrtmidas
#SBATCH --time=01:20:00
#SBATCH --job-name="equilibration_NVT_config-3"
#SBATCH --output="equilibration_NVT_config-3.out"
#SBATCH --error="equilibration_NVT_config-3.err"
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

# rerun simulation
srun -n 32 -N 1 --mpi=pmix gmx mdrun -cpi nvt_eq_conf3 -s nvt_eq_conf3.tpr -deffnm nvt_eq_conf3

