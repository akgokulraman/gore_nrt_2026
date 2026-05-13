---
Subject: Modeling of the porous media
Date: 2026-05-08 / 2026-05-11
---
---
# Protocols to reproduce chemical interaction files and structures
<!-- - pointers (links) to all data files that are created or processed;
- pointers (links) to all input files and parameters;
- pointers (links) to the exact versions of all analysis and plotting routines;
- pointers (links) to the exact versions of all software used; -->
## Obtain interactions/force-field of the chemicals
We use [polyply](https://github.com/marrink-lab/polyply_1.0) as it enables to create polymer with specific repeating units and even help in creating a .gro file, which can be a direct input to GROMACS to perform ensemble based simulations. 
```{note}
Polyply is a python package. For our project, we used the latest version of polyply, polyply_1.0.
Since we are modifying/adding to the `polyply` source files, it is recommended that we git clone the repository from [github](https://github.com/marrink-lab/polyply_1.0), modify the files as necessary or as described in the sections below. Later to install the modified `polyply` we use pip install method,
```{code}
python -m pip install <POLYPLY_DIR>
```
```{note}
If you want to use the already modified version of the polyply with all the interactions for the chemicals already included, use the [fork](https://github.com/akgokulraman/polyply_1.0) from github.
```

Since we want the surface to resemble fabric, and nylon is a good representation of the fabric, we model nylon force-field interaction.s
```
[ moleculetype ]
Nylon 1

[ atoms ]
1 C1 1 Ny6 R1 1 0.0 
2 P4 1 Ny6 R2 2 0.0 

[ bonds ]
1 2 1 0.383 5000
```
where, we used the force-field interactions from Poly(butyl methacrylate)[2] to assume the bonded interaction between the beads of Nylon monomer. The non-bonded interaction are based on [1], which is for the actual Nylon monomer molecule. The monomer force-field interaction can also be found in this [file](../data/input/surface_emulsion_interaction/itp/nylon.martini2.itp). 

## Creating topology (Initial Configuration of the system)
Once we have the force-field, we then need to create a topology for our system. 

Follow the steps below to create the coordinate file of the film layer.

1. First, we need to obtain the coordinates file (`.gro`) of nylon. For this, execute `polyply gen_coords -p top/system_surfactant.top -o nylon.gro -name nylon -box 5 5 5` . Here `5` denotes $5 \text{ nm}$ - box dimension. The generated coordinate file is included [here](../data/input/surface_emulsion_interaction/nylon.gro). The structure of `.top` file used to create the coordinate file is given below:
    ```
    #include "../itp/martini_v2.0_PEO_PS_CNP.itp"
    #include "../itp/tween80.martini2.itp"
    #include "../itp/nylon.martini2.itp"

    [ system ]
    ; name
    Surfactant in water system

    [ molecules ]
    ; name  number
    Nylon 1
    ```
2. Execute `mpirun gmx editconf -f nylon.gro -o nylon.pdb` to create `.pdb` file, as this extension will be needed for the next step. 
3. Following the previous step 2, we then use PACKMOL to create the thin layer. The idea is to create a thin layer at the bottom of the box of size $23^3\text{nm}^3$, which is a pre-assembled structure.
    ```{seealso}
    Description of PACKMOL was described in [spike-1](./spike-1.md). Please refer it for installation.
    ```
    For our case, we will need to create a layer filled with nylon molecules. Since one of the objective is to understand the chemical preferability of the emulsion on the surface, we can fine tune the surface chemistry, by either pointing the hydrophobic or hydrophilic side to the major portion of the box. Thus we use the keyword `atom 1` and `atom 2` which corresponds to R1 and R2 respectively, with R1 being hydrophobic than R2 (amide).
    ```
    tolerance 2.0
    output layer.pdb
    pbc 0 0 0 230 230 230
    structure nylon.pdb
    number 5000
    atoms 1
        below plane 0. 0. 1. 4
    end atoms
    atoms 2
        above plane 0. 0. 1. 5.6
    end atoms
    end structure
    ```
4. Run the command `packmol -i packmol_input.inp` to get the desired layer structure.

---
# Notes
<!-- Notes from seminars, meetings, discussions -->
- To model the Nylon-6 polymer for substrate porous media, we refer to Milani et al. [1] who used MARTINI forcfe field to model Nylon-6 nanofibers.
- To create a surface, Elder and Jayaraman [2] used self-assembled monoloyaers. These monolayers are designed to be less or more hydrophobic, based on the choice of end chain - $OH$ for less hydrophobic and $OMe$ for more hydrophobic. To create the surface, the monnolayers are stacked or self assembled suich that the ends are sticking top. The top and bottom heavy atom are constrained to a specific z-value, so to fix the surface location.

---
# References
[1] Milani, A., Casalegno, M., Castiglioni, C., & Raos, G. (2011). Coarse‐Grained Simulations of Model Polymer Nanofibres. Macromolecular Theory and Simulations, 20(5), 305–319. https://doi.org/10.1002/mats.201100010
[2] https://doi.org/10.1039/C8ME00064F

---
__Wrap-Up__
<!-- Mention any related or unrelated thoughts here -->