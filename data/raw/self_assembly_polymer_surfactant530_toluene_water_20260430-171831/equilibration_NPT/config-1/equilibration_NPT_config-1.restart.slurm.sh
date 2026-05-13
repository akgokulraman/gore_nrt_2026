#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=idle
#SBATCH --account=ea-nrtmidas
#SBATCH --time=2:30:00
#SBATCH --job-name="equilibration_NPT_config-1"
#SBATCH --output="equilibration_NPT_config-1.out"
#SBATCH --error="equilibration_NPT_config-1.err"
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

# rerun simulation
srun -n 32 -N 1 --mpi=pmix gmx mdrun -cpi npt_eq_conf1 -s npt_eq_conf1.tpr -deffnm npt_eq_conf1

