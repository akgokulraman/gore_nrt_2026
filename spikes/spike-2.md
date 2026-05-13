---
Subject: Simulation protocol (Equilibration and Production) for emulsion stability
Date: 02-20-2026
---
---
# Protocols to reproduce results
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
mpirun gmx trjconv -s equilibration/emin/emin.tpr -f equilibration/emin/emin.trr -o equilibration/emin/emin.xtc -pbc mol -center

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

---
# Notes
<!-- Notes from seminars, meetings, discussions -->

## Equilibration
- For the equilibration we do NVT simulation so that temperature is finalized like about 10-20 ns with 5-15 fs as timestep. 
    - Why not NPT? "The purpose of doing NVT before NPT is typically based on algorithmic stability. Velocity generation at the outset of a simulation is imperfect, and if coupled with a barostat, can frequently crash. So equilibration is often done under NVT for a short time to get the velocity distribution reasonable, followed by NPT to get the density right."[2]
- Lou et al.[3] suggested using energy minimization (about 125ps) followed by NPT ensemble of 1000ns.
---
# References
[1] https://montecarlo.sourceforge.net/emc/Welcome.html

[2] [Could it be NVT ensembles followed by NPT ensembles during the molecular dynamics simulation?, ResearchGate](https://www.researchgate.net/post/Could_it_be_NVT_ensembles_followed_by_NPT_ensembles_during_the_molecular_dynamics_simulation#:~:text=The%20purpose%20of%20doing%20NVT%20before%20NPT,by%20NPT%20to%20get%20the%20density%20right.)

[3] https://pubs.acs.org/doi/10.1021/acs.molpharmaceut.4c00461

---
__Wrap-Up__
<!-- Mention any related or unrelated thoughts here -->