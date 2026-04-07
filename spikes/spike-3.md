---
Subject: Stability of Emulsion
Date: 02-13-2026
---
---
# Protocols to reproduce results
<!-- - pointers (links) to all data files that are created or processed;
- pointers (links) to all input files and parameters;
- pointers (links) to the exact versions of all analysis and plotting routines;
- pointers (links) to the exact versions of all software used; -->
## Analysis
### Create Index for better management
- Create index groups of head: `mpirun gmx make_ndx -f npt_eq-10.gro -o custom.ndx`
    - For surfactant
        - Select the necessary atoms to label them together as *Head_3_4*: `"PS8B" & a B5 | a B6 | a B7 | a B8 | a B9 | a B11 | a B12 | a B13 | a B14 | a B15` and `name 4 Head_3_4`
        - Select the necessary atoms to label them together as *Head_1_2*: `"PS8B" & a B19 | a B20 | a B21 | a B22 | a B24 | a B25 | a B26 | a B27` and `name 5 Head_1_2`
        - Select the necessary atoms to label them together as *Tail*: `"PS8B" & a C32 | a C33 | a C0 | a C1` and `name 6 Tail`
        ```
        echo -e '"PS8B" & a B5 | a B6 | a B7 | a B8 | a B9 | a B11 | a B12 | a B13 | a B14 | a B15\nname 6 Head_3_4\n"PS8B"  & a B19 | a B20 | a B21 | a B22 | a B24 | a B25 | a B26 | a B27\nname 7 Head_1_2\n"PS8B" & a C32 | a C33 | a C0 | a C1\nname 8 Tail\nq' | mpirun gmx make_ndx -f nvt_prod_conf1.gro -o custom.ndx
        ```
    - For polymer
        - Select individual type of atoms: *MA*, *MB*, *ME*, *MT*, *E1*, *E2* and name them accordingly as *Poly_MA*, *Poly_MB*, *Poly_ME*, *Poly_MT*, *Poly_E1*, *Poly_E2*
            ```
            echo -e '"LMA" & a MB\nname 8 Poly_MB\n"LMA" & a ME\nname 9 Poly_ME\n"LMA" & a MT\nname 10 Poly_MT\n"LMA" & a E1\nname 11 Poly_E1\n"LMA" & a E2\nname 12 Poly_E2\nq' | mpirun gmx make_ndx -f nvt_prod_conf1.gro -n custom.ndx -o new.ndx
            ```
            In the above command, we are appending on top of the file `custom.ndx`.
    In a single command, to define the atom groups for both surfactant and polymer, we can use
    ```
    echo -e '"PS8B" & a B5 | a B6 | a B7 | a B8 | a B9 | a B11 | a B12 | a B13 | a B14 | a B15\nname 6 Head_3_4\n"PS8B"  & a B19 | a B20 | a B21 | a B22 | a B24 | a B25 | a B26 | a B27\nname 7 Head_1_2\n"PS8B" & a C32 | a C33 | a C0 | a C1\nname 8 Tail\n"LMA" & a MB\nname 9 Poly_MB\n"LMA" & a ME\nname 10 Poly_ME\n"LMA" & a MT\nname 11 Poly_MT\n"LMA" & a E1\nname 12 Poly_E1\n"LMA" & a E2\nname 13 Poly_E2\nq' | mpirun gmx make_ndx -f nvt_prod_conf1.gro -o custom.ndx
    ```    
### RDF   
- RDF calculation - between *Tail* and other groups (including W and Tolue): `mpirun gmx rdf -f nvt_prod_conf1.gro -s nvt_prod_conf1.tpr -n custom.ndx -ref Tail -sel Head_1_2 Head_3_4 Poly_MB Poly_ME Poly_MT Poly_E1 Poly_E2 W Tolue -o rdf_ref_tail.xvg -bin 0.05`
- RDF calculation - between *Head_1_2* and other groups (including W and Tolue): `mpirun gmx rdf -f npt_eq-2.gro -s npt_eq-2.tpr -n custom.ndx -ref Head_1_2 -sel Tail Head_3_4 Poly_MA Poly_MB Poly_ME Poly_MT Poly_E1 Poly_E2 W Tolue -o rdf_head12_tail.xvg -bin 0.05`
- RDF calculation - between *Head_3_4* and other groups (including W and Tolue): `mpirun gmx rdf -f npt_eq-2.gro -s npt_eq-2.tpr -n custom.ndx -ref Head_3_4 -sel Tail Head_1_2 Poly_MA Poly_MB Poly_ME Poly_MT Poly_E1 Poly_E2 W Tolue -o rdf_head12_tail.xvg -bin 0.05`
- RDF calculation - between *W* and other groups: `mpirun gmx rdf -f npt_eq-2.gro -s npt_eq-2.tpr -n custom.ndx -ref W -sel Tail Head_1_2  Head_3_4 Poly_MA Poly_MB Poly_ME Poly_MT Poly_E1 Poly_E2 Tolue -o rdf_head12_tail.xvg -bin 0.05`
- RDF calculation - between *Tolue* and other groups: `mpirun gmx rdf -f npt_eq-2.gro -s npt_eq-2.tpr -n custom.ndx -ref Tolue -sel Tail Head_1_2  Head_3_4 Poly_MA Poly_MB Poly_ME Poly_MT Poly_E1 Poly_E2 W -o rdf_head12_tail.xvg -bin 0.05`
- RDF calculation - between COM and head groups: `mpirun gmx rdf -f npt_eq-2.gro -s npt_eq-2.tpr -n custom.ndx -ref 'com of group "PS8B"' -sel Head_1_2 -o rdf_micelle.xvg`

### Thermodynamic Properties
Use the below command to output the necessary thermodynamic properties. We have specified all the properties we need and different ensembles will have different property available.
```
echo -e "Temperature\nPressure\nDensity\nTotal-Energy\nPotential\nKinetic-En.\nBox-Vol\n0" | mpirun gmx energy -f nvt_prod_conf1.edr -o thermo.xvg
```

> Automate the above three steps of analysis (obtain index, rdf and thermo files) using [jupyter notebook](../../notebooks/obtain_gromacs_analysis.ipynb), which passes through all the available data files and performs the necessary analysis through GROMACS. To execute the notebook, you can also use SLURM job script, as given [here](../../bin/gromacs_correction_analysis.sh).

---

# Results / Observations
<!-- Thoughts and ideas related to the research problem -->
## Equilibration of pure surfactant system
As such, we can do equilibration multiple ways. Below are some tests, which performs equilibration in all the many ways.
**Test-2** ([folder](../test/equilibration/Test-2))
- Create box of $23.00^3$ and perform EM -> NVT -> NPT
- Keep velocity generation during NVT
- NPT simulation done in staggered form from high P (350 bar) to lower P (1 bar)
    - Keep velocity generation during  NPT
    - Remove velocity generation during NPT
- NPT simulation straightaway done at 1 bar pressure (Remove velocity generation during NPT)

**Test-3** ([folder](../test/equilibration/Test-3))
- Create box of $23.70^3$ and perform EM -> NVT -> NPT
- Only NVT has velocity generation and not NPT

**Test-4** ([folder](../test/equilibration/test/Test-4))
- Create box of $23.70^3$ and perform EM -> NPT -> NVT
- Only NPT has velocity generation and not NVT

**Test-5** ([folder](../test/equilibration/test/Test-5))
- Create box of $23.00^3$ and perform EM -> NVT -> NPT
- NVT and NPT ensemble using tc_grps as *System* using $23.00$^3 box
- Changing temperature t to $298$ K
- Increase simulation time from 20ns to 100ns fopr NPT equilibration

## Equilibration and production of polymer/surfactant/solvent(s) system
### 

---
# Notes
<!-- Notes from seminars, meetings, discussions -->
- Liu et al. [1] explained the emulsification and de-emulsification process associated with emulsions. 
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
[1] Liu, X., Li, Y., Tian, S., & Yan, H. (2019). Molecular Dynamics Simulation of Emulsification/Demulsification with a Gas Switchable Surfactant. The Journal of Physical Chemistry C, 123(41), 25246–25254. https://doi.org/10.1021/acs.jpcc.9b07652

---
__Wrap-Up__
<!-- Mention any related or unrelated thoughts here -->