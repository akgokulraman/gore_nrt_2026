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
srun -n 1 -N 1 --mpi=pmix gmx mdrun -cpi emin_conf1 -s emin_conf1.tpr -deffnm emin_conf1

