'''
Analysis to obtain the thermodynamic data of PE, Number of Clusters, density (only for equilibration_NPT), Pressure, Temperature.
Analysis to also obtain RDF data between chemical constituents.
The python file takes one arguement:
1. DIR: location of the raw file directory. ex: /lustre/ea-nrtmidas/users/3770/emulsion_stability/data/raw/self_assembly_polymer_surfactant180_toluene_water_20260401-163540

examples:
python properties.py /lustre/ea-nrtmidas/users/3770/emulsion_stability/data/raw/box_var_self_assembly_polymer_surfactant_toluene_water_20260426-192641
'''
import glob
import os, sys
import subprocess
import shutil

DIR = sys.argv[1] # raw data directory
stages = glob.glob(f'{DIR}/equilibration_NPT') + glob.glob(f'{DIR}/production_NVT') # different stages or intersted ensembles
notebook_dir = '/lustre/ea-nrtmidas/users/3770/emulsion_stability/notebooks'
os.chdir(notebook_dir)

# diff_systems = glob.glob(f'{DIR}')
# diff_systems = [item for item in diff_systems if 'surfactant240' not in item] # ignoring systems where simulations are in progress

'''
analysis for thermo properties
'''
for stage in stages:
    for config in glob.glob(f'{stage}/*'):
        xtc_files = glob.glob(f'{config}/*.xtc')
        gro_files = glob.glob(f'{config}/*.gro')
        gro_files = [item for item in gro_files if item.split('/')[-3].split('_')[-1].lower() in item.split('/')[-1].lower()] # ensuring the copied files to each directory is not counted multiple times
        
        # frequency checker if using .xtc file
        if 'production' in stage:
            freq = 500000
        elif 'equilibration_NVT' in stage:
            freq = 25000
        elif 'equilibration_NPT' in stage:
            freq = 50000
        
        # check if thermo analysis files are already run for this directory
        thermo_files = glob.glob(f'{config}/thermo/thermo.xvg')
        if(len(thermo_files)==1):
            continue
        else:
            xtc_file = xtc_files[0] # assuming only one .xtc file present in {config}
            gro_file = xtc_file[:-4]+'.gro'
            tpr_file = xtc_file[:-4]+'.tpr'
            edr_file = xtc_file[:-4]+'.edr'
            bash_script = f"""
            echo "Starting automation..."
            vpkg_require gromacs

            # thermo properties
            mkdir {config}/thermo
            echo -e "Temperature\nPressure\nDensity\nTotal-Energy\nPotential\nKinetic-En.\nBox-Vol\n0" | mpirun gmx energy -f {edr_file} -o {config}/thermo/thermo.xvg

            # remove backup files
            rm \#*

            echo "Done."
            """
            subprocess.run(bash_script, shell=True, executable='/bin/bash')

'''
analysis for number of clusters
'''
for stage in stages:
    for config in glob.glob(f'{stage}/*'):
        xtc_files = glob.glob(f'{config}/*.xtc')
        gro_files = glob.glob(f'{config}/*.gro')
        gro_files = [item for item in gro_files if item.split('/')[-3].split('_')[-1].lower() in item.split('/')[-1].lower()] # ensuring the copied files to each directory is not counted multiple times

        # frequency checker if using .xtc file
        if 'production' in stage:
            freq = 500000
        elif 'equilibration_NVT' in stage:
            freq = 25000
        elif 'equilibration_NPT' in stage:
            freq = 50000

        # check if analysis files are already run for this directory
        cluster_files = glob.glob(f'{config}/cluster/my_num_clusters.xvg')
        if(len(cluster_files)==1):
            continue
        else:
            xtc_file = xtc_files[0]
            gro_file = xtc_file[:-4]+'.gro'
            tpr_file = xtc_file[:-4]+'.tpr'
            edr_file = xtc_file[:-4]+'.edr'

            bash_script = f"""
            echo "Starting automation..."
            vpkg_require gromacs

            # Create necessary index file for grouping atoms
            echo -e '"PS8B" & a B5 | a B6 | a B7 | a B8 | a B9 | a B11 | a B12 | a B13 | a B14 | a B15\nname 6 Head_3_4\n"PS8B"  & a B19 | a B20 | a B21 | a B22 | a B24 | a B25 | a B26 | a B27\nname 7 Head_1_2\n"PS8B" & a C32 | a C33 | a C0 | a C1\nname 8 Tail\n"LMA" & a MB\nname 9 Poly_MB\n"LMA" & a ME\nname 10 Poly_ME\n"LMA" & a MT\nname 11 Poly_MT\n"LMA" & a E1\nname 12 Poly_E1\n"LMA" & a E2\nname 13 Poly_E2\nq' | mpirun gmx make_ndx -f {gro_file} -o {config}/custom.ndx
            
            # make molecules whole
            # echo -e '0' | mpirun gmx trjconv -f {xtc_file} -s {tpr_file} -pbc whole -o {config}/whole.xtc

            # thermo properties
            rm -r {config}/cluster {config}/cluster_whole # removing any residual directories
            mkdir -p {config}/cluster
            # mkdir -p {config}/cluster_whole # to check if there is any difference than the actual calculation

            echo -e '3' | mpirun gmx clustsize -f {xtc_file} -s {tpr_file} -nc {config}/cluster/my_num_clusters.xvg -mc {config}/cluster/my_max_size.xvg -n {config}/custom.ndx -cut 2.2
            # echo -e '3' | mpirun gmx clustsize -f {config}/whole.xtc -s {tpr_file} -nc {config}/cluster_whole/my_num_clusters.xvg -mc {config}/cluster_whole/my_max_size.xvg -n {config}/custom.ndx

            # remove backup files
            rm \#*

            echo 'Done.'
            """
            subprocess.run(bash_script, shell=True, executable='/bin/bash')

'''
analysis for rdf
'''
for stage in stages:
    for config in glob.glob(f'{stage}/*'):
        xtc_files = glob.glob(f'{config}/*.xtc')
        gro_files = glob.glob(f'{config}/*.gro')
        gro_files = [item for item in gro_files if item.split('/')[-3].split('_')[-1].lower() in item.split('/')[-1].lower()] # ensuring the copied files to each directory is not counted multiple times
        
        # rdf analysis frequency checker if using .xtc file
        if 'production' in stage:
            freq = 500000
        elif 'equilibration_NVT' in stage:
            freq = 25000
        elif 'equilibration_NPT' in stage:
            freq = 50000
        
        # check if thermo analysis files are already run for this directory
        rdf_files = glob.glob(f'{config}/rdf_analysis/*.xvg')
        if(len(rdf_files)==7):
            continue
        else:
            xtc_file = xtc_files[0]
            gro_file = xtc_file[:-4]+'.gro'
            tpr_file = xtc_file[:-4]+'.tpr'
            edr_file = xtc_file[:-4]+'.edr'

            bash_script = f"""
            echo "Starting automation..."
            vpkg_require gromacs

            # Create necessary index file for grouping atoms
            echo -e '"PS8B" & a B5 | a B6 | a B7 | a B8 | a B9 | a B11 | a B12 | a B13 | a B14 | a B15\nname 6 Head_3_4\n"PS8B"  & a B19 | a B20 | a B21 | a B22 | a B24 | a B25 | a B26 | a B27\nname 7 Head_1_2\n"PS8B" & a C32 | a C33 | a C0 | a C1\nname 8 Tail\n"LMA" & a MB\nname 9 Poly_MB\n"LMA" & a ME\nname 10 Poly_ME\n"LMA" & a MT\nname 11 Poly_MT\n"LMA" & a E1\nname 12 Poly_E1\n"LMA" & a E2\nname 13 Poly_E2\nq' | mpirun gmx make_ndx -f {gro_file} -o {config}/custom.ndx

            # rdf analysis
            mkdir {config}/rdf_analysis
            mpirun gmx rdf -f {gro_file} -s {tpr_file} -n {config}/custom.ndx -ref Tail -sel Tail Head_1_2 Head_3_4 Poly_MB Poly_ME Poly_MT Poly_E1 Poly_E2 W Tolue -o {config}/rdf_analysis/rdf_ref_Tail.xvg -bin 0.05
            mpirun gmx rdf -f {gro_file} -s {tpr_file} -n {config}/custom.ndx -ref Head_1_2 -sel Head_1_2 Tail Head_3_4 Poly_MB Poly_ME Poly_MT Poly_E1 Poly_E2 W Tolue -o {config}/rdf_analysis/rdf_ref_Head12.xvg -bin 0.05
            mpirun gmx rdf -f {gro_file} -s {tpr_file} -n {config}/custom.ndx -ref Head_3_4 -sel Head_3_4 Tail Head_1_2 Poly_MB Poly_ME Poly_MT Poly_E1 Poly_E2 W Tolue -o {config}/rdf_analysis/rdf_Head34.xvg -bin 0.05
            mpirun gmx rdf -f {gro_file} -s {tpr_file} -n {config}/custom.ndx -ref W -sel Tail Head_1_2  Head_3_4 Poly_MB Poly_ME Poly_MT Poly_E1 Poly_E2 Tolue -o {config}/rdf_analysis/rdf_ref_W.xvg -bin 0.05
            mpirun gmx rdf -f {gro_file} -s {tpr_file} -n {config}/custom.ndx -ref Tolue -sel Tolue Tail Head_1_2  Head_3_4 Poly_MB Poly_ME Poly_MT Poly_E1 Poly_E2 W -o {config}/rdf_analysis/rdf_ref_Tolue.xvg -bin 0.05
            mpirun gmx rdf -f {gro_file} -s {tpr_file} -n {config}/custom.ndx -ref Poly_MB -sel Poly_MB Tolue Tail Head_1_2  Head_3_4 Poly_ME Poly_MT Poly_E1 Poly_E2 W -o {config}/rdf_analysis/rdf_ref_MB.xvg -bin 0.05
            mpirun gmx rdf -f {gro_file} -s {tpr_file} -n {config}/custom.ndx -ref Poly_E2 -sel Poly_MB Tolue Tail Head_1_2  Head_3_4 Poly_ME Poly_MT Poly_E1 Poly_E2 W -o {config}/rdf_analysis/rdf_ref_E2.xvg -bin 0.05

            # remove backup files
            rm \#*    

            echo "Done."
            """
            subprocess.run(bash_script, shell=True, executable='/bin/bash')