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
## Equilibration
### Surfactant-Water system
```


mpirun gmx grompp -f mdp/em.mdp -c surfactant120_water_solvated.gro -p top/system_surfactant_water.top -o equilibration/emin/emin.tpr
mpirun gmx mdrun -v -deffnm emin
mpirun gmx trjconv -s equilibration/emin/emin.tpr -f equilibration/emin/emin.trr -o equilibration/emin/emin.xtc -pbc mol -center

mpirun gmx grompp -f mdp/nvt_eq.mdp -c equilibration/emin/emin.gro -p top/system_surfactant_water.top -o equilibration/nvt/nvt_eq.tpr
mpirun gmx mdrun -v -deffnm equilibration/nvt/nvt_eq
```
- Use the command `mpirun gmx make_ndx -f surfactant120_water_solvated.gro` to index the different groups/chemicals.
- Use the following commands to make molecules whole and fix jumps due to periodic boundary condtion. Also center the molecules to the box.
    ```
    gmx trjconv -f input.xtc -s topol.tpr -pbc nojump -o nojump.xtc
    gmx trjconv -f nojump.xtc -s topol.tpr -pbc mol -center -o whole.xtc
    ```
- Use the following command to center the whole trajectory: `gmx trjconv -f whole.xtc -s topol.tpr -center -pbc mol -o centered.xtc`



---

# Results / Observations
<!-- Thoughts and ideas related to the research problem -->


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