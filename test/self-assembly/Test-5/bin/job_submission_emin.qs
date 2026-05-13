#!/bin/bash -l
#SBATCH --job-name=Test5_EM_Surfactant-Solvent
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1G
#SBATCH --partition=idle
#SBATCH --time=0-6:00:00
#SBATCH --mail-user=gokul@udel.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --export=NONE
#UD_QUIET_JOB_SETUP=YES
#UD_MACHINE_FILE_FORMAT='%h%[:]C'
#export UD_JOB_EXIT_FN_SIGNALS="SIGTERM EXIT"

# Packages
vpkg_require anaconda/2024.02
conda activate md
vpkg_require gromacs
. /opt/shared/slurm/templates/libexec/openmpi.sh

# User-Defined variables
no=5

# Copy relavant data and navigate to the desired folder
cd /lustre/ea-nrtmidas/users/3770/emulsion_stability/test/
mkdir -p Test-$no
cd Test-$no
cd surfactant_water

# NVT Equilibration
mpirun gmx grompp -f mdp/em.mdp -c surfactant120_water_solvated.gro -p top/system_surfactant_water.top -o equilibration/emin/emin.tpr
mpirun gmx mdrun -v -deffnm equilibration/emin/emin -cpt 15
