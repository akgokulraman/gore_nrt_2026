---
Subject: Simulation protocol (Equilibration and Production) for emulsion stability
Date: 2026-02-15 / 2026-05-11
---
---
# Protocols to reproduce simulations
<!-- - pointers (links) to all data files that are created or processed;
- pointers (links) to all input files and parameters;
- pointers (links) to the exact versions of all analysis and plotting routines;
- pointers (links) to the exact versions of all software used; -->
## Surfactant-Water system
For the surfactant-water system, we worked with two initial models, (a) random placement of molecules to make a mixture which later self-assembles during the simulation, and (b) pre-assembled structure(s). For both the cases, we perform three steps of equilibration to equilibrate the structure and finally go with production. The three steps of equilibration will include
1. Energy Minimization
2. NVT Equilibration
3. NPT Equilibration
Following the equilibration, we will perform a NVT production.

The reasoning and alloted timeframe (`dt` is kept at 0.02ps for steps 2-4) for each step is as follows:
| Step No | Ensemble/Step       | Reasoning                                                                                                                | Timeframe |
| ------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------ | --------- |
| 1       | Energy Minimization | Modify the molecules position to prevent position overlapping. Helpful to start simulation with reasonable energy state. | NA        |
| 2       | NVT Equilibration   | To bring the molecules velocity to that of the fixed temperature, based on canonical ensemble.                           | 10ns      |
| 3       | NPT Equilibration   | To equilibrate the box to a given pressure, thus attaining the corresponding density required for the system.            | 10ns      |
| 4       | NVT Production      | The actual simulation we are interested to for the dynamics and other observations.                                      | 1000ns    |

```{note}
For running simulations in GROMACS, the following things are needed (apart from the software itself):
1. `.top` file: defining the topological data of the system, connecting the chemicals chemical interaction data or the force field parameters (`.itp`) with the coordinates data (`.gro`)
2. `.gro` file(s): coordinate files of the chemical(s) in either (a) mixture model, or (b) pre-assembled model.
3. `.itp` file(s): force field parameters of the chemicals, containing the data of the bonded (bond and angle) interaction. It also contains the non-bonded interaction, given through the MARTINI code (like `SNa`).
4. `.mdp` file: GROMACS based file, with the parameters needed to do the simulation. All the steps mention in the tabulation will have its own `.mdp` file.
```

The location for each of the files described above, can be accesed through the following hyper links: [.top files](../data/input/surfactant_water/top), [.gro files](../data/input/surfactant_water), [.itp files](../data/input/surfactant_water/itp), and [.mdp files](../data/input/surfactant_water/mdp). 

```{seealso}
Refer to [spike-1](./spike-1.md) for instructioins on how to create `.top`, .`gro` and `.itp` files. As such we use the standard parameter definitions for the `.mdp` files, whose definition can be seen from the GROMACS [documentaiton](https://manual.gromacs.org/current/user-guide/mdp-options.html).
```
Once the files are created, we then proceed with our simulation.

The following commands, which will be used repeatedly is `grompp` and `mdrun` in GROMACS. Using them we can run ensemble of each step (from the above table). An example of how the commands will be executed is given below for energy minimization and NVT equilibration (steps 1 and 2).

```
mpirun gmx grompp -f mdp/em.mdp -c surfactant120_water_solvated.gro -p top/system_surfactant_water.top -o equilibration/emin/emin.tpr
mpirun gmx mdrun -v -deffnm emin

mpirun gmx grompp -f mdp/nvt_eq.mdp -c equilibration/emin/emin.gro -p top/system_surfactant_water.top -o equilibration/nvt/nvt_eq.tpr
mpirun gmx mdrun -v -deffnm equilibration/nvt/nvt_eq
```
For our project, we used DARWIN hpc cluster. Thus the corresponding batch scripts used to run the simulations are given here for [self-assembly](../bin/surfactant_water/self-assembly/) and [pre-assembled](../bin/surfactant_water/pre-assembled/) model(s).

Since the primary objective of the project is not to probe into surfactant water system, which was already done in other literature [3], we consider this sytem mostly to be a test case to understand GROMACS. Thus the files of the system will not be shared through GITHUB channels.
<!-- Thus the simulation files for this system can be accessed through the directories mentioned through the below table.
| System                       | Directory Location (Hyperlink)             |
| ---------------------------- | ------------------------------------------ |
| self-assembly (from mixture) | [directory](../test/self-assembly/Test-5/) |
| pre-assembled                | [directory](../test/pre-assembled/Test-1/) | -->
## Polymer-solvent-Surfactant-Water system
Similar to the previous case, but with the addition of polymer and solvent. For this case, we only did self-assembly of the system and varied the surfactant count (to find the stable emulsion) and box size (to account for finite size effects).

Below is the tabulation for different ensemble/step in the simulation process. The reasoning and alloted timeframe (`dt` is kept at 0.02ps for steps 2-4) for each step is as follows:
| Step No | Ensemble/Step       | Reasoning                                                                                                                | Timeframe |
| ------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------ | --------- |
| 1       | Energy Minimization | Modify the molecules position to prevent position overlapping. Helpful to start simulation with reasonable energy state. | NA        |
| 2       | NVT Equilibration   | To bring the molecules velocity to that of the fixed temperature, based on canonical ensemble.                           | 50ns      |
| 3       | NPT Equilibration   | To equilibrate the box to a given pressure, thus attaining the corresponding density required for the system.            | 100ns     |
| 4       | NVT Production      | The actual simulation we are interested to for the dynamics and other observations.                                      | 1000ns    |

Owing to the big data of the different files, refer to .gitignore, the skeleton of different simulation setup only will be shared, which is located in the [data](../data/raw/) directory. Below is the tabulation of different systems which have been simulated with their corresponding executable and simulation directory locations. 

| Index | System         | Box Size (${\text{nm}}^3$) | Executable Location (Hyperlink)                                  | Directory Location (Hyperlink)                                                                   |
| ----- | -------------- | -------------------------- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| S1    | surfactant 60  | $23^3$                     | [maestrowf executable](../bin/self_assemble_surfactant60.yaml)   | [directory](../data/raw/self_assembly_polymer_surfactant60_toluene_water_20260401-143905/)       |
| S2    | surfactant 120 | $23^3$                     | [maestrowf executable](../bin/self_assemble_surfactant120.yaml)  | [directory](../data/raw/self_assembly_polymer_surfactant120_toluene_water_20260402-185803/)      |
| S3    | surfactant 150 | $23^3$                     | [maestrowf executable](../bin/self_assemble_surfactant150.yaml)  | [directory](../data/raw/self_assembly_polymer_surfactant150_toluene_water_20260403-111056/)      |
| S4    | surfactant 180 | $23^3$                     | [maestrowf executable](../bin/self_assemble_surfactant180.yaml)  | [directory](../data/raw/self_assembly_polymer_surfactant180_toluene_water_20260401-163540/)      |
| S5    | surfactant 530 | $23^3$                     | [maestrowf executable](../bin/self_assemble_surfactant530.yaml)  | [directory](../data/raw/self_assembly_polymer_surfactant530_toluene_water_20260430-171831/)      |
| S6    | surfactant 405 | $34.5^3$                   | [maestrowf executable](../bin/box_var_self_assemble_scale.yaml)  | [directory](../data/raw/box_var_self_assembly_polymer_surfactant_toluene_water_20260426-192641/) |
|       | surfactant 608 | $34.5^3$                   |                                                                  |                                                                                                  |
| S7    | surfactant 120 | $34.5^3$                   | [maestrowf executable](../bin/box_var_self_assemble_dilute.yaml) | [directory](../data/raw/box_var_self_assembly_polymer_surfactant_toluene_water_20260501-192849/) |
|       | surfactant 180 | $34.5^3$                   |                                                                  |                                                                                                  |

```{note}
Till **S5**, each system with specific surfactant count was handled individually with separate base directory. Only for **S6** and **S7**, owing to find the presence of finite size effects, different surfactant systems are present in the same base directory.
```

For this project, for the Polymer-solvent-Surfactant-Water system, I went with using [maestro workflow conductor](https://maestrowf.readthedocs.io/en/latest/) or maestrowf, a python package, which helps in automating multiple aspects of the project from a single comamnd execution. For simulations in Darwin, I would encourage one to install maestrowf in their conda environment or python environment (`pip install maestrowf`). Maestrowf helps in creating a study (through the help of a `.yaml` script) and running the study. 
In our case, the study script is the different maestrowf executables mentioned in the above table. To run the script, use the single line command `maestro run self_assemble_surfactant120.yaml -a 2 -r 2`, where the flag `-a` denotes the maximum number of submission attempts before a step is marked as failed and `-r` denotes the maximum number of restarts allowed for the given file (provided restart option is separately handled in the `.yaml` file - which is handled in the provided `.yaml` files).

---
# Analysis
For the analysis, refer to the [notebooks](../notebooks/) directory. We can biverigate analysis into three parts: (a) post-simulation analysis, (b) property analysis, and (c) case-comparitive analysis.

## Post-Simulation analysis
In the case of post-simulation analysis, we leverage the functionalities of GROMACS to obtain certain key important features, like the theormodynamic properties (Potential Energy, Kinetic Energy, Temperature, Pressure, Density), structural properties (number of clusters, Radial Distribution Function). Except for Radial Distribution function, all the other properties are obtained as time dependent properties. For Radial Distribution Function, we obtain the data for the last timestep from the production run.

To obtain the respective data through the GROMACS analysis, we automate the process through executing a python file named [properties.py](../notebooks/properties.py). The command follows 
```{code}
python notebooks/properties.py data/raw/self_assembly_polymer_surfactant180_toluene_water_20260401-163540
```
where the arguement passed will be the location of the simulation base directory. The command will create necessary sub-directories and files to obtain the necessary properties.

## Property Analysis
Once the relavant features (or properties) of the desired simulation directory is obtained, we then proceed with obtaining the standard plots like the thermodynamic data plots of PE, density (only for equilibration_NPT), Pressure, Temperature and also of that of Number of Clusters over time. These plots are quite standard and will help in deciding if the system is properly equilibrated and if the resulting emulsion is stable. We again automate this plotting by using the command
```{code}
python notebooks/thermo_analysis.py data/raw/box_var_self_assembly_polymer_surfactant_toluene_water_20260426-192641 production_NVT figures box_length-34.5_.config-1_.polymer-68_.surfactant-608_.toluene-42053
```
where the arguements passed will be (1) location of the simulation base directory, (2) stage of the simulation you want to anlayse (options are equilibration_NPT, production_NVT), and (3) location where you want to save the plots and (4) which sub-directories (like `config-1`, `config-2`, `box_length-34.5_.config-1_.polymer-68_.surfactant-608_.toluene-42053`) you want to plot for. For the cases where there are three configurations (`config-1`, `config-2`, `config-3`), we want to plot their average and standard deviations. Then, we use `'*'` for the last arguement, as shown below. 
```{code}
python thermo_analysis.py data/raw/self_assembly_polymer_surfactant180_toluene_water_20260401-163540 production_NVT figures '*'
```
As the examples suggests, the directory where the plots are stored is [figures](../figures/).

## Case-Comparitive Analysis
As the name suggests, through this analysis, we compare different cases. We mostly use this type of analysis to analyse the Radial Distribution Fucntions of the different systems and understand the effect of sufactant concentration in the system. Some notable analysis done under this subsection includes, RDF analysis to compare the distribution between different surfactant counts (refer [Figure](../figures/RDF_vary_surfactant_MB-Head12.png)), and to plot the variation of the peak of polymer-surfactant distribution function with respect to the surfactant count (refer [Figure](../figures/g_r_peak_clusters_vary_surfactant.png)). Both these analysis help in describing how surfactants influence the structural property of the emulsion.

---
# Notes
<!-- Notes from seminars, meetings, discussions -->
- For the equilibration we do NVT simulation so that temperature is finalized like about 10-20 ns with 5-15 fs as timestep. 
    - Why not NPT? "The purpose of doing NVT before NPT is typically based on algorithmic stability. Velocity generation at the outset of a simulation is imperfect, and if coupled with a barostat, can frequently crash. So equilibration is often done under NVT for a short time to get the velocity distribution reasonable, followed by NPT to get the density right."[2]
- Lou et al.[3] suggested using energy minimization (about 125ps) followed by NPT ensemble of 1000ns.
- Liu et al. [3] explained the emulsification and de-emulsification process associated with emulsions. 
  - In their research, they explain how they characterize de-emulsification: (a) Distance variation between two droplet, (b) Number of clusters
  - For their simulation they used intrinsic $H2O$
- Dr. Vasu recommended (on 13th Feb 2026) using (a) the total PE, (b) variation in rdf over time as metrics to determine the stability of the emulsion. The emulsion is stable when the value remains constant over time.
- Dr. Vasu during the weekly meeting on 20th Feb, reiterated the background behind the need for simulation. (Industry needs to prepare large batches of emulsion for coating - Emulsions should be stable for a longer time frame, before being applied on top of the surfaces). Since emulsion stability then becomes the criterion to decide the composition, he suggested to run simulations in batch, thus identifying the necessary compositions useful for Gore.
  - Unstable emulsions usually need lower timeframe simulations, to know that they will undergo demulsification process in that limited timeframe, like 10-15 ns.
  - Stable emulsions on the other hand can be judged by running simulations for longer time frame, like 500ns. For longer simulations, we can use `restart` command accordignly.
  - We can **judge the state of the simulation after each batch runs, and plan further simulations accordingly**.
  - "For the production run in general will use NPT ensemble with 15fs ranging from 10-15ns to 300ns."
---
# References
[1] https://montecarlo.sourceforge.net/emc/Welcome.html
[2] [Could it be NVT ensembles followed by NPT ensembles during the molecular dynamics simulation?, ResearchGate](https://www.researchgate.net/post/Could_it_be_NVT_ensembles_followed_by_NPT_ensembles_during_the_molecular_dynamics_simulation#:~:text=The%20purpose%20of%20doing%20NVT%20before%20NPT,by%20NPT%20to%20get%20the%20density%20right.)
[3] https://pubs.acs.org/doi/10.1021/acs.molpharmaceut.4c00461

---
__Wrap-Up__
<!-- Mention any related or unrelated thoughts here -->