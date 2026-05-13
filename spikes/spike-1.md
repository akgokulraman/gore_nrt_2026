---
Subject: Model molecule(s) and topology using Polyply, PACKMOL and Gromacs
Date: 2026-03-08 / 2026-03-30
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

### Polymer interaction
We leverage the previous studies [1,2] to capture the interactions (force-field) of the desired monomer Lauryl Methacrylate. The `.itp` of the monomer is as follows:
```
[ moleculetype ]
LMA 1
;
[ atoms ]
;  nr    type            resnr   residu    atom     cgnr        charge   
   1     SC1             1       LMA       MB       1           0.0   
   2     Na              1       LMA       ME       2           0.0 
   3     SC1             1       LMA       MT       3           0.0   
   4     C1              1       LMA       E1       4           0.0   
   5     C1              1       LMA       E2       5           0.0  
;
[ bonds ]
;  ai    aj   funct  bo(nm)   kb(kJ mol−1 nm−2)
   1     2    1      0.282    17000
   2     3    1      0.383    5000
   3     4    1      0.460    2000
   4     5    1      0.460    2000
   1     6    1      0.289    21100   
;
[ angles ]
;  ai    aj   ak     funct  theta_o(deg)   k_theta(kJ mol−1 nm−2)
   1     2    3      2      144            67
   2     3    4      2      180            25
   3     4    5      2      180            25
   1     6    11     2      175            13
```
where, we used the force-field interactions from Poly(butyl methacrylate)[1] and Poly(ethylene)[2]. The monomer force-field interaction can also be found in this [file](../data/input/polymer_surfactant_solvent/itp/plma.martini2.itp). 

Use the following steps to model the polymer's force-field from the monomer force-field.
1.  Store the file in `polyply_1.0/polyply/data/martini2`, so that `polyply` can access the `.itp` file readily when invoked *martini2* library.
2. Create polymer's (with specific repeating units) force-field  using `polyply` using the *LMA* monomer from the above step. A sample example is given here: 
    `polyply gen_params -lib martini2 -o plma25.martini2.itp -name PLMA25 -seq LMA:25`
    - This line uses the *LMA* monomer from the *martini2* library.
    - We create the interaction force-field parameter file for Poly(Lauryl Methacrylate) with 25 repeating units. The new chain hereforth is known as *PLMA25*.
    - Refer to the file instance [here](../data/input/polymer_surfactant_solvent/itp/plma25.martini2.itp).

### Surfactant interaction
We refer to [3] to get the interaction between the different beads in the surfactant Tween 80 (Polysorbate 80) 4H-D. Create a `.itp` file for the surfactant ( Refer [Tween 80](../data/input/polymer_surfactant_solvent/itp/tween80.martini2.itp) file). 
<!-- Store the file in `polyply_1.0/polyply/data/martini2`, so that `polyply` can access the `.itp` file readily when invoked *martini2* library. -->

### Organic solvent interaction
We refer to [4,5] to formulate the grouping of beads in toluene. The actual values to represent toluene is inspired from analysing the benzene and chloro benzene interactions, given in [MARTINI](https://cgmartini.nl/docs/downloads/force-field-parameters/martini2/solvents.html) website. 

Create a `.itp` file for the organic solvent (Refer [toluene](../data/input/polymer_surfactant_solvent/itp/toluene.martini2.itp) file).
The modified `.itp` file looks like this:
```
[moleculetype]
; molname       nrexcl
Toluene              1

[atoms]
; id    type    resnr   residu  atom    cgnr    charge
  1      SC4      1     Toluene       R1      1      0
  2      SC4      1     Toluene       R2      2      0
  3      SC4      1     Toluene       R3      3      0

[constraints]
; i j   funct   length
  1 2       1     0.27
  2 3       1     0.27
  1 3       1     0.27
```
where we assume toluene is made of three beads, with all having saving MARTINI non-bonded interaction type and constraints.

```{note} 
This approach was based on the suggestion from Dr. Soham (meeting on 27th Feb), where he mentioned to use the force field of solvent chlorobenzene from the `.itp` file and modify it accordingly.
```

### Water interaction
Water interactions (non-polar) are available through the martini2.2 interaction file provided in the official [martini website](https://cgmartini.nl/docs/downloads/force-field-parameters/martini2/particle-definitions.html). Create a `.itp` file for water as given in [water](../data/input/itp/water.martini2.itp) file. 

```{note}
On the good side, water's interaction is not needed, as there is readymade `.gro` file available in the MARTINI webpage. 
```
## Creating initial coordinates (Initial Configuration of the system)
Once the polymer/surfactant/solvent force-field is modeled, we then need to create a coordinate file for our system. 

### Surfactant-Water system
The surfactant-water system was already done in [3]. We are following the simulation setup: $23^3 \text{nm}^2$ box with $120$ surfactants. Recreating the results from [3] can verify the model and system credibility. 
#### Mixture configuration (leading to self-assembly)
Follow the steps below to create the coordinate file of the surfactant-water mixture system.

1. First, we need to obtain the coordinates file (`.gro`) of the surfactant. For this, execute `polyply gen_coords -p top/system_surfactant.top -o surfactant.gro -name surfactant -box 5 5 5` . Here `5` denotes $5 \text{ nm}$ - box dimension. The generated coordinate file is included [here](../data/input/surfactant_water/surfactant.gro). The structure of `.top` file used to create the coordinate file is given below:
    ```
    #include "../itp/martini_v2.0_PEO_PS_CNP.itp"
    #include "../itp/tween80.martini2.itp"
    ;#include "water.martini2.itp"

    [ system ]
    ; name
    Surfactant in water system

    [ molecules ]
    ; name  number
    PS8B 1
    ```
2. Execute `mpirun gmx insert-molecules -ci surfactant.gro  -nmol 120  -box 23 23 23 -o surfactant120.gro` to create the box of $23^3\text{ nm}^3$ with 120 molecules of surfactant. The `insert-molecules` gromacs command, helps in randomly inserting molecules in the given box.
3. Create a `system_surfactant_water.top` file where we need to include (using `#include`) the martini2.2 interaction file and other interaction files of the respective chemicals. One can download martini2.2 interaction file from official [martini website](https://cgmartini.nl/docs/downloads/force-field-parameters/martini2/particle-definitions.html). The initial `system_surfactant_water.top` should look like this.
    ```
    #include "martini_v2.0_PEO_PS_CNP.itp"
    #include "tween80.martini2.itp"
    ;#include "water.martini2.itp"

    [ system ]
    ; name
    Surfactant in water system

    [ molecules ]
    ; name  number
    PS8B 120
    ```
    ```{note}
    Since our surfactant is modeled based on ethylene oxide (*EO*) bead, which by default is not included in the link, we refer to the interaction file provided for [PEO](https://cgmartini.nl/docs/downloads/force-field-parameters/martini2/polymers.html) (click [here](https://cgmartini-library.s3.ca-central-1.amazonaws.com/1_Downloads/ff_parameters/martini2/polymers/peg/martini_v2.0_PEO_PS_CNP.itp) for downloadable link), which includes all the interactions and *EO* related interactions. The martini2.2 interaction file (with *EO*) is also included [here](../data/input/surfactant_water/itp/martini_v2.0_PEO_PS_CNP.itp).
    ```
    ```{attention}
    Ensure the files are there in the same directory or the location for these interaction files are mentioned in the `#include`.
    ```
4. There are representations of water solvent box from the official [martini webpage](https://cgmartini.nl/docs/downloads/example-applications/solvent-systems.html). The obtained `.gro` file for water is included [here](../data/input/surfactant_water/water.gro)
5. To solvate the system of surfactants with water, we are going to use gromacs and run the command - `mpirun gmx solvate -cp surfactant120.gro -cs water.gro -o surfactant120_water_solvated -p top/system_surfactant_water.top` which outputs [surfactant120_water_solvated.gro](../data/input/surfactant_water/surfactant120_water_solvated.gro). The command also modifies [system_surfactant_water.top](../data/input/surfactant_water/top/system_surfactant_water.top) to include number of water molecules. In this case, the number of water molecules added due to solvation is 102715. The immediate state after this step can be seen through this [image](../data/input/surfactant_water/after_solvation_immediate_state.png).

#### Assembled configuration
To create a pre-assembled configuration (or a coordinates file), we are going to use the software PACKMOL. Refer to the installation page [here](https://m3g.github.io/packmol/userguide.shtml). 
A short summary of the installation is as follows:
1. After downloading the files from [this link](http://m3g.iqm.unicamp.br/packmol) in your local directory, expand the files using `tar -xvzf packmol-packmol-21.2.1.tar.gz`.
2. After the files are extracted, go to the extracted directory `cd packmol-21.2.1` and execute `make`. This creates the `packmol` executable.
```{note}
`packmol` executable can either be copied to the directory where you are building the assembled model, or you refer to the `packmol` executable with its address. Here, I refer to `packmol` as `/lustre/ea-nrtmidas/users/3770/packmol-21.2.1/packmol`
```
To execute packmol and create assembled structure the command is `packmol -i packmol.inp -o output.pdb`, where `packmol.inp` is the input file designing how the structure should be arranged and the output configuration is in `.pdb` format. 
```{note}
We can convert `.gro` to `.pdb` format using `mpirun gmx editconf -f output.gro -o output.pdb`. We can also convert `.pdb` to `.gro` format using `mpirun gmx pdb2gmx -f output.pdb -o output.gro`. 
```
To talk about the input file itself, deep illustrations in [PACKMOL website](https://m3g.github.io/packmol/userguide.shtml) itself is useful. A sample input script can be seen below (all the numerics are in Angstorms):
```
tolerance 2.0
output interface.pdb
pbc 0 0 0 230 230 230
structure water.pdb
  number 2000
  inside sphere 2.30 3.40 4.50 8.0
end structure
```
where `a = 2.30`, `b = 3.40`, `c = 4.50` and `d = 8.0` denotes to the spherical equation
$$
(x-a)^2+(y-b)^2+(z-c)^2=d^2
$$

For our case, we can obtain a self-assmebled structure, following the protocol below:
1. A sample input file with 10 spheres of 12 surfactant molecules is given below, (which can be accessed [here](../data/input/surfactant_water/packmol_input.inp))
    ```
    tolerance 2.0
    output micelle.pdb
    pbc 0 0 0 230 230 230
    structure surfactant.pdb
        number 12
        inside sphere 52.7 71.1 67.5 40
    end structure
    structure surfactant.pdb
        number 12
        inside sphere 114.3 123.0 57.0 40
    end structure
    structure surfactant.pdb
        number 12
        inside sphere 60.5 94.5 169.1 40
    end structure
    structure surfactant.pdb
        number 12
        inside sphere 187.2 46.1 131.2 40
    end structure
    structure surfactant.pdb
        number 12
        inside sphere 144.7 133.4 177.2 40
    end structure
    structure surfactant.pdb
        number 12
        inside sphere 69.6 174.7 171.9 40
    end structure
    structure surfactant.pdb
        number 12
        inside sphere 167.0 183.2 59.8 40
    end structure
    structure surfactant.pdb
        number 12
        inside sphere 60.9 182.6 90.2 40
    end structure
    structure surfactant.pdb
        number 12
        inside sphere 137.7 46.8 42.8 40
    end structure
    structure surfactant.pdb
        number 12
        inside sphere 130.5 43.0 189.5 40
    end structure
    ```

2. Run the command `packmol -i packmol_input.inp` to get the self-assembled structure.

3. To solvate the system of surfactants with water, we are going to use gromacs and run the command - `mpirun gmx solvate -cp micelle.pdb -cs water.gro -o assembled_surfactant120_water_solvated -p top/assembled_system_surfactant_water.top` which outputs [assembled_surfactant120_water_solvated.gro](../data/input/assembled_surfactant_water/assembled_surfactant120_water_solvated.gro). The command also modifies [assembled_system_surfactant_water.top](../data/input/surfactant_water/top/assembled_system_surfactant_water.top) to include number of water molecules. In this case, the number of water molecules added due to solvation is 102734. 

### Polymer-Surfactant-Solvent system (Mixture configuration (leading to self-assembly))
We are following the simulation setup as provided in [3]: $23^3 \text{nm}^2$ box with $120$/$180$/$60$ surfactants and solvated water beads. As we consider $10\%$ (wt percentage) of the polymer-solvent solution to be of polymer, we can say that for each PLMA25 molecule, we should fix number of toluene to be at $623$. 
```{important}
PLMA repeating unit mass is 254.4g/mol and with 25 repeating units, the molar mass is $6360$ g/mol. For considering one polymer molecule in the solution, $6360$ g is around $10\%$ of the tolunen solution, meaning mass of toluenen to hold one molecule of PLMA_25 is $57240$ g. Thus, the total number of tolunen molecules in the solution to hold one polymer molecule will be $622.14 \sim 623$. To begin with let's consider $20$ polymer molecules, leading to $12460$ toluene molecules. 
```
Follow the steps below to create the mixture topology of the polymer-toluene-surfactant-water system.

1. Create `.gro` files for the three chemicals - polymer/surfactant/toluene through
    ```
    polyply gen_coords -p top/polymer.top -o polymer.gro -name polymer -box 2.5 2.5 2.5
    polyply gen_coords -p top/surfactant.top -o polymer.gro -name surfactant -box 2.5 2.5 2.5
    polyply gen_coords -p top/toluene.top -o polymer.gro -name toluene -box 2.5 2.5 2.5
    ```
    where the `.top` files are available [here](../../data/input/polymer_surfactant_solvent/top/). Refer [here](../../data/input/polymer_surfactant_solvent/) for the created `.gro` files. A sample `.top` file is given below (for creating one polymer) for your reference:
    ```
    #include "../itp/plma25.martini2.itp"
    #include "../itp/martini_v2.0_PEO_PS_CNP.itp"

    [ system ]
    ; name
    Polymer

    [ molecules ]
    ; name  number
    PLMA25 1
    ```

2. To assemble the chemicals together, we are going to use gromacs `insert-molecules`.
    ```
    mpirun gmx insert-molecules -ci surfactant.gro -nmol 120  -box 23.00 23.00 23.00 -o surfactant120_conf1.gro
    mpirun gmx insert-molecules -ci polymer.gro -nmol 20 -f surfactant120_conf$(config).gro -o polymer20_surfactant120_conf1.gro
    mpirun gmx insert-molecules -ci toluene.gro -nmol 12460 -f polymer20_surfactant120_conf1.gro -o toluene12460_polymer20_surfactant120_conf1.gro
    ```
    Repeat the commands to get threee initial configurations (void of water) with names: `toluene12460_polymer20_surfactant120_conf1.gro`, `toluene12460_polymer20_surfactant120_conf2.gro`, and `toluene12460_polymer20_surfactant120_conf3.gro`.

3. Create a `surfactant-120_polymer-30_toluene-12460_water.top` file where we need to include (using `#include`) the martini2.2 interaction file and other interaction files of the respective chemicals. One can download martini2.2 interaction file from official [martini website](https://cgmartini.nl/docs/downloads/force-field-parameters/martini2/particle-definitions.html). The initial `surfactant-120_polymer-30_toluene-12460_water_conf1.top` should look like this.

    ```
    #include "../top/martini_v2.2refP_PEO.itp"
    #include "../top/tween80.martini2.itp"
    #include "../top/plma25.martini2.itp"
    #include "../top/toluene.martini2.itp"

    [ system ]
    ; name
    Polymer, Surfactant, Toluene solvated in water

    [ molecules ]
    ; name  number
    PS8B 120
    PLMA25 20
    TOLUENE 12460
    ```

    ```{note}
    Since our surfactant is modeled based on ethylene oxide (*EO*) bead, which by default is not included in the link, we refer to the interaction file provided for [PEO](https://cgmartini.nl/docs/downloads/force-field-parameters/martini2/polymers.html) (click [here](https://cgmartini-library.s3.ca-central-1.amazonaws.com/1_Downloads/ff_parameters/martini2/polymers/peg/martini_v2.0_PEO_PS_CNP.itp) for downloadable link), which includes all the interactions and *EO* related interactions. The martini2.2 interaction file (with *EO*) is also included [here](../data/input/surfactant_water/itp/martini_v2.0_PEO_PS_CNP.itp).
    ```
    ```{attention}
    Ensure the files are there in the same directory or the location for these interaction files are mentioned in the `#include`.
    ```

    ```{note}
    We use `_conf1` to represent initial structural configuration with index *1*. In case of different initial structural configurations, we refer them with different indices, like *2* and *3*. Thus the different topology files thus created are `surfactant-120_polymer-30_toluene-12460_water_conf1.top`, `surfactant-120_polymer-30_toluene-12460_water_conf2.top`, and `surfactant-120_polymer-30_toluene-12460_water_conf3.top`.
    ```
4. There are representations of water solvent box from the official [martini webpage](https://cgmartini.nl/docs/downloads/example-applications/solvent-systems.html). The obtained `.gro` file for water is included [here](../data/input/polymer_surfactant_water/water.gro)

5. To solvate the system of surfactants with water, we are going to use gromacs and run the command - `mpirun gmx solvate -cp toluene12460_polymer20_surfactant120_conf1.gro -cs water.gro -o solvated_surfactant-120_polymer-20_toluene-12460_water_conf1.gro -p top/surfactant-120_polymer-20_toluene-12460_water_conf1.top` which outputs the necessary initial configuration of the system - solvated with water. Repeat the process to get the three configurations of the solvated systems: `solvated_surfactant-120_polymer-20_toluene-12460_water_conf1.gro`, `solvated_surfactant-120_polymer-20_toluene-12460_water_conf2.gro`, and `solvated_surfactant-120_polymer-20_toluene-12460_water_conf3.gro`.

---
# Notes
<!-- Notes from seminars, meetings, discussions -->
## Understanding chemicals
### Polymer
- Dr. Vasu in today's meeting (20th Feb), highlighted to use a hydrophobic side-chain (with number of units to be atleast 8). Correspondingly the backbone should be chosen as something which is reasonable.
- I found that the SMILES representation of the interested polymer PLMA (with four repeating units) is `CC(C(=O)OCCCCCCCCCCCC)(C)CC(C(=O)OCCCCCCCCCCCC)(C)CC(C(=O)OCCCCCCCCCCCC)(C)CC(C(=O)OCCCCCCCCCCCC)(C)`. Used [leskoff](https://www.leskoff.com/s01810-0) to experiment with the right SMILES. Using this SMILES, I was able to obtain the all atom representation through [LigParGen](https://zarbi.chem.yale.edu/ligpargen/)
### Surfactant
- Another name for Tween 80 is Polysurbate 80.[6]
- 4H strcuture of the surfactant is considered dominant compared to 3H.[3] Refer to [image](../figures/4H-3H_comparison_Tween80.png) for 4H and 3H structures.
- Luz et al. [6] worked on the water/Tween 80/Decane interace. They used a CG modeling with MARTINI force field. Here, only water is considered polar and other two chemicals are considered non-polar.
    - In essence, the paper talks about how Tween 80 was modeled in CG, from atomistic representation, and assigned necessary parameter values.
    - For a particular research problem discussed in this paper - about interface interaction between the three chemical constituents, the equilibration and production runs were made cleverly specific.
        - Use of barostat to equilibrate
        - Semi-Isotropic barostat used to obtain surface tension
- Lou et al. [3] worked on understanding the structure of Tween 80 (PS80) (a) through the micelle formation and (b) interaction with other drugs and protein like EDOL.
    - For the micelle formation, PS80 was solavated in water.
        - NPT production run to get micelle formation
        - Quantitative analysis through solvent-accesible surface area to calculate self assembly.
    - PS80/EDOL interaction setup (refer [image](../figures/PS80-PDOL_representation.png)) uses the above micelle configuration.
## Initial Assembly
- Dr. Soham mentioned about using the montecarlo [7] package to arrange the molecule in a spherical system for the initial process. Another interesting software he mention was PACKMOL [8].
- In addition to the above point, self-assembly of the system was also suggested to verify the formed micelle radius.

---
# References
[1] https://doi.org/10.1021/acs.jpcb.5b03611
[2] https://doi.org/10.1039/C8ME00064F
[3] https://pubs.acs.org/doi/10.1021/acs.molpharmaceut.4c00461
[4] https://advanced.onlinelibrary.wiley.com/doi/10.1002/adma.202008635
[5] https://pubs.acs.org/doi/10.1021/jacs.6b11717
[6] https://doi.org/10.1021/acs.langmuir.2c03001
[7] https://montecarlo.sourceforge.net/emc/Welcome.html
[8] https://m3g.github.io/packmol/userguide.shtml#basic

---
__Wrap-Up__
<!-- Mention any related or unrelated thoughts here -->