# README
This project is a collaboration between [W.L.Gore](https://www.gore.com/) and [University of Delaware](https://www.udel.edu/), as part of the NRT Hackathon course in Spring 2026. In brief, the aim of the project is to identify the required concentration (or mol ratio) where the emulsion is meta-stable in bulk. The findings of this objective, can then help characterize if the same mol ratio results in meta-stable emulsion when contact with a surface (preferably a fabric). The detailed explanation is provided through this [PDF document](./GORE-UD_NRT_Spring_2026_EmulsionStability.pdf).  

Since, the future direction of the project is to understand the emulsion interaction with surface, where chemistry is important, and in the same time, dynamics of the emulsion is also of equal importance (to characterize the timescale when the emulsion becomes unstable), we used Coarse Grained Molecular Dynamics to model and simulate the emulsion system. Our emulsion components include Poly(laurly methacrylate) with a repating units of 25, Toluene (the polymer solvent), Tween80 (surfactant), and water. We consider the bulk solvent as water, meaning the system is water-rich. For modeling the system, we used [MARTINI 2.2](https://cgmartini.nl/) and for the simulation we used [GROMACS](https://www.gromacs.org/) software. Refer [spike-1](./spikes/spike-1.md) for the documentation of the modeling aspect of the emulsion system and [spike-2](./spikes/spike-2.md) for the emulsion protocol.
In essence, for a $23^3\text{nm}^3$ box, we fixed, the molecule count of the following: polymer-20, toluene-12460, thus varying the surfactant count. Water since its bulk will be filled at the last using the GROAMCS command `solvate`. In essence water molecule count was about ~95000. 

For the simulation, [Maestro workflow conductor](https://maestrowf.readthedocs.io/en/latest/) or Maestrowf, a python package, which helps in automating multiple aspects of the project from a single comamnd execution, which is very useful from the standpoint of high performance computers. Maestrowf helps in creating a study (through the help of a `.yaml` script, refer to [bin](./bin/)) and running the study. More on how to use Maesrowf for our project can be found in [spike-2](./spikes/spike-2.md).

The raw data are stored in the [raw](./data/) directory. Each sub-directory within the [raw](./data/raw/) directory refers to the different simulation setups (like changing the surfactant count, changing the box size by scaling up or diluting the box) whose description can also be found in [spike-2](./spikes/spike-2.md) as a tabulation. 
The commonly used simulation input files (for surfactant-water, polymer-solvent-surfactant-water) are stored in the [input](./data/input/) directory. These input scripts are also copied to respective sub-directories within the [raw](./data/raw/) directory for ease of operation. Thus, one can re-run the simulation, by executing the bash script in the subdirectories in [raw](./data/raw/), without needing to copy any files or such.

One important thing to note is that, each simulation directory or sub-directory within [raw](./data/raw/) has the following organization(s):

(a) simulation of $23^3\text{nm}^3$ system with fixed polymer and toluene molecules count (polymer-20, toluene-12460), varying the surfactant count accordingly. Below is the file directory listing for surfactant-60.
```
self_assembly_polymer_surfactant60_toluene_water_20260401-143905/
|-model_system/
    |-config-1
    |-config-2
    |-config-3
|-equilibration_EM/
    |-config-1
    |-config-2
    |-config-3
|-equilibration_NVT/
    |-config-1
    |-config-2
    |-config-3
|-equilibration_NPT/
    |-config-1
    |-config-2
    |-config-3
|-production_NVT/
    |-config-1
    |-config-2
    |-config-3
```
(b) simulation of $34.5^3\text{nm}^3$ system with fixed polymer and toluene molecules count (polymer-68, toluene-42053) i.e, system scaleup by a factor of $1.5^3$, varying the surfactant count accordingly. Below is the file directory listing for surfactant-405,608.
```
box_var_self_assembly_polymer_surfactant_toluene_water_20260426-192641/
|-model_system/
|    |-box_length-34.5_.config-1_.polymer-68_.surfactant-405_.toluene-42053
|    |-box_length-34.5_.config-1_.polymer-68_.surfactant-608_.toluene-42053
|-equilibration_EM/
|    |-box_length-34.5_.config-1_.polymer-68_.surfactant-405_.toluene-42053
|    |-box_length-34.5_.config-1_.polymer-68_.surfactant-608_.toluene-42053
|-equilibration_NVT/
|    |-box_length-34.5_.config-1_.polymer-68_.surfactant-405_.toluene-42053
|    |-box_length-34.5_.config-1_.polymer-68_.surfactant-608_.toluene-42053
|-equilibration_NPT/
|    |-box_length-34.5_.config-1_.polymer-68_.surfactant-405_.toluene-42053
|    |-box_length-34.5_.config-1_.polymer-68_.surfactant-608_.toluene-42053
|-production_NVT/
|    |-box_length-34.5_.config-1_.polymer-68_.surfactant-405_.toluene-42053
|    |-box_length-34.5_.config-1_.polymer-68_.surfactant-608_.toluene-42053
```
The bash scripts, input files (.top, .itp, .mdp) and other relavant things to get the simulation started can be found in the end of the listed subdirectories.

The modeling of the chemicals was made possible through [polyply](https://github.com/akgokulraman/polyply_1.0.git), where the interaction files of the chemicals are used to build the coordinate file. 

All the post-processing analysis to obtain thermodynamics and structural features are found in [notebooks](./notebooks/) directory. The following tabulation describes the role of each file:
| File                                                           | Description                                                                                                                                                                                              |
| -------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [properties.py](./notebooks/properties.py)                     | Analysis to obtain the (a) thermodynamic data (of PE, density (only for equilibration_NPT), Pressure, Temperature), Number of Clusters w.r.t time and (b) obtain RDF data between chemical constituents. |
| [thermo_analysis.py](./notebooks/thermo_analysis.py)           | Obtain the repetative plots of (a) thermodynamic properties, and (b) number of clusters w,r,t time                                                                                                       |
| [emulsion_analysis.ipynb](./notebooks/emulsion_analysis.ipynb) | Jupyter notebook to (a) analyse RDF plots between different surfactant count cases, (b) combine number of clusters and RDF to characterize structural features of different surfactant count cases       |

The required python packages for this project is provided through this [requirement.txt](./requirements.txt) file.

The general file structure for the repository is as follows:
```
emulsion_stability/
|-bin/
|-data/
|    |-input/
|        |-polymer_surfactant_solvent/
|        |-surface_emulsion_interaction/
|        |-surfactant_water/
|    |-raw/
|        |-box_var_self_assembly_polymer_surfactant_toluene_water_20260426-192641/
|        |-box_var_self_assembly_polymer_surfactant_toluene_water_20260501-192849/
|        |-self_assembly_polymer_surfactant60_toluene_water_20260401-143905/
|        |-self_assembly_polymer_surfactant120_toluene_water_20260402-185803/
|        |-self_assembly_polymer_surfactant150_toluene_water_20260403-111056/
|        |-self_assembly_polymer_surfactant180_toluene_water_20260401-163540/
|        |-self_assembly_polymer_surfactant530_toluene_water_20260430-171831/
|-figures/
|   |-box_var_self_assembly_polymer_surfactant_toluene_water_20260426-192641/
|   |-box_var_self_assembly_polymer_surfactant_toluene_water_20260501-192849/
|   |-self_assembly_polymer_surfactant60_toluene_water_20260401-143905/
|   |-self_assembly_polymer_surfactant120_toluene_water_20260402-185803/
|   |-self_assembly_polymer_surfactant150_toluene_water_20260403-111056/
|   |-self_assembly_polymer_surfactant180_toluene_water_20260401-163540/
|   |-self_assembly_polymer_surfactant530_toluene_water_20260430-171831/
|-notebooks/
|-spikes/
|-test/
```
where the `test` directory is for surfactant-water system, used to replicate the micelle formation through surfactant-water system, described in detail in [spike-1](./spikes/spike-1.md) and [spike-2](./spikes/spike-2.md).

The project also briefly touched upon creating a surface with nylon monomer molecules using PACKMOL, whose input scripts and coordinates file are in the [input/surface_emulsion_interaction](./data/input/surface_emulsion_interaction/) directory, about which has also been discussed in [spike-4](./spikes/spike-4.md).

The project was made possible through the resources used in [DARWIN high performance computing](http://dsi.udel.edu/core/computational-resources/darwin/) present in University of Delaware.

# Team and Contact
Project Members: Gokul Raman Arumugam Kumar, Rudy DiMura, and Abigail Sicher

Project Mentors: Dr. Vasudevan Venkateshwaran, Dr. Soham Jariwala

If any questions/discussion with regards to the project, please reach out to Gokul Raman at *gokul@udel.edu* or through [Linkedin](https://www.linkedin.com/in/gokul-raman/). 

