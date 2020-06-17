#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: Example of setting up a simulation system
doc: |
  Common Workflow Language example that illustrate the process of setting up a
  simulation system containing a protein, step by step, using the BioExcel
  Building Blocks library (biobb). The particular example used is the Lysozyme
  protein (PDB code 1AKI).

inputs:
  step1_pdb_name: string
  step1_pdb_config: string
  step4_editconf_config: string
  step6_gppion_config: string
  step7_genion_config: string
  step8_gppmin_config: string
  step10_energy_min_config: string
  step10_energy_min_name: string
  step11_gppnvt_config: string
  step13_energy_nvt_config: string
  step13_energy_nvt_name: string
  step14_gppnpt_config: string
  step16_energy_npt_config: string
  step16_energy_npt_name: string
  step17_gppmd_config: string
  step19_rmsfirst_config: string
  step19_rmsfirst_name: string
  step20_rmsexp_config: string
  step20_rmsexp_name: string
  step21_rgyr_config: string
  step22_image_config: string
  step23_dry_config: string

outputs:
  trr:
    label: Trajectories - Raw trajectory
    doc: |
      Raw trajectory from the free simulation step
    type: File
    outputSource: step18_mdrun_md/output_trr_file
    
  trr_imaged_dry:
    label: Trajectories - Post-processed trajectory
    doc: |
      Post-processed trajectory, dehydrated, imaged (rotations and translations
      removed) and centered.
    type: File
    outputSource: step22_image/output_traj_file
    
  gro_dry:
    label: Resulting protein structure
    doc: |
      Resulting protein structure taken from the post-processed trajectory, to
      be used as a topology, usually for visualization purposes.
    type: File
    outputSource: step23_dry/output_str_file
    
  gro:
    label: Structures - Raw structure
    doc: |
      Raw structure from the free simulation step.
    type: File
    outputSource: step18_mdrun_md/output_gro_file

  cpt:
    label: Checkpoint file
    doc: |
      GROMACS portable checkpoint file, allowing to restore (continue) the
      simulation from the last step of the setup process.
    type: File
    outputSource: step18_mdrun_md/output_cpt_file

  tpr:
    label: Topologies GROMACS portable binary run
    doc: |
      GROMACS portable binary run input file, containing the starting structure
      of the simulation, the molecular topology and all the simulation parameters.
    type: File
    outputSource: step17_grompp_md/output_tpr_file

  top:
    label: GROMACS topology file
    doc: |
      GROMACS topology file, containing the molecular topology in an ASCII
      readable format.
    type: File
    outputSource: step7_genion/output_top_zip_file
    
  xvg_min:
    label: System Setup Observables - Potential Energy
    doc: |
      Potential energy of the system during the minimization step.
    type: File
    outputSource: step10_energy_min/output_xvg_file

  xvg_nvt:
    label: System Setup Observables - Temperature
    doc: |
      Temperature of the system during the NVT equilibration step.
    type: File
    outputSource: step13_energy_nvt/output_xvg_file
    
  xvg_npt:
    label: System Setup Observables - Pressure and density 
    type: File
    outputSource: step16_energy_npt/output_xvg_file
    
  xvg_rmsfirst:
    label: Simulation Analysis
    doc: |
      Root Mean Square deviation (RMSd) throughout the whole free simulation
      step against the first snapshot of the trajectory (equilibrated system).
    type: File
    outputSource: step19_rmsfirst/output_xvg_file
  xvg_rmsexp:
    label: Simulation Analysis
    doc: |
      Root Mean Square deviation (RMSd) throughout the whole free simulation
      step against the experimental structure (minimized system).
    type: File
    outputSource: step20_rmsexp/output_xvg_file
    
  xvg_rgyr:
    label: Simulation Analysis
    doc: |
      Radius of Gyration (RGyr) of the molecule throughout the whole free simulation step
    type: File
    outputSource: step21_rgyr/output_xvg_file

steps:
  step1_pdb:
    label: Fetch PDB Structure
    run: biobb_adapters/pdb.cwl
    in:
      output_pdb_path: step1_pdb_name
      config: step1_pdb_config
    out: [output_pdb_file]

  step2_fixsidechain:
    label: Fix Protein structure
    run: biobb_adapters/fix_side_chain.cwl
    in:
      input_pdb_path: step1_pdb/output_pdb_file
    out: [output_pdb_file]

  step3_pdb2gmx:
    label: Create Protein System Topology
    run: biobb_adapters/pdb2gmx.cwl
    in:
      input_pdb_path: step2_fixsidechain/output_pdb_file
    out: [output_gro_file, output_top_zip_file]

  step4_editconf:
    label: Create Solvent Box
    run: biobb_adapters/editconf.cwl
    in:
      input_gro_path: step3_pdb2gmx/output_gro_file
    out: [output_gro_file]

  step5_solvate:
    label: Fill the Box with Water Molecules
    run: biobb_adapters/solvate.cwl
    in:
      input_solute_gro_path: step4_editconf/output_gro_file
      input_top_zip_path: step3_pdb2gmx/output_top_zip_file
    out: [output_gro_file, output_top_zip_file]

  step6_grompp_genion:
    label: Add Ions - part 1
    run: biobb_adapters/grompp.cwl
    in:
      config: step6_gppion_config
      input_gro_path: step5_solvate/output_gro_file
      input_top_zip_path: step5_solvate/output_top_zip_file
    out: [output_tpr_file]

  step7_genion:
    label: Add Ions - part 2
    run: biobb_adapters/genion.cwl
    in:
      config: step7_genion_config
      input_tpr_path: step6_grompp_genion/output_tpr_file
      input_top_zip_path: step5_solvate/output_top_zip_file
    out: [output_gro_file, output_top_zip_file]

  step8_grompp_min:
    label: Energetically Minimize the System - part 1
    run: biobb_adapters/grompp.cwl
    in:
      config: step8_gppmin_config
      input_gro_path: step7_genion/output_gro_file
      input_top_zip_path: step7_genion/output_top_zip_file
    out: [output_tpr_file]

  step9_mdrun_min:
    label: Energetically Minimize the System - part 2
    run: biobb_adapters/mdrun.cwl
    in:
      input_tpr_path: step8_grompp_min/output_tpr_file
    out: [output_trr_file, output_gro_file, output_edr_file, output_log_file]

  step10_energy_min:
    label: Energetically Minimize the System - part 3
    run: biobb_adapters/gmx_energy.cwl
    in:
      config: step10_energy_min_config
      output_xvg_path: step10_energy_min_name
      input_energy_path: step9_mdrun_min/output_edr_file
    out: [output_xvg_file]

  step11_grompp_nvt:
    label: Equilibrate the System (NVT) - part 1
    run: biobb_adapters/grompp.cwl
    in:
      config: step11_gppnvt_config
      input_gro_path: step9_mdrun_min/output_gro_file
      input_top_zip_path: step7_genion/output_top_zip_file
    out: [output_tpr_file]

  step12_mdrun_nvt:
    label: Equilibrate the System (NVT) - part 2
    run: biobb_adapters/mdrun.cwl
    in:
      input_tpr_path: step11_grompp_nvt/output_tpr_file
    out: [output_trr_file, output_gro_file, output_edr_file, output_log_file, output_cpt_file]

  step13_energy_nvt:
    label: Equilibrate the System (NVT) - part 3
    run: biobb_adapters/gmx_energy.cwl
    in:
      config: step13_energy_nvt_config
      output_xvg_path: step13_energy_nvt_name
      input_energy_path: step12_mdrun_nvt/output_edr_file
    out: [output_xvg_file]

  step14_grompp_npt:
    label: Equilibrate the System (NPT) - part 1
    run: biobb_adapters/grompp.cwl
    in:
      config: step14_gppnpt_config
      input_gro_path: step12_mdrun_nvt/output_gro_file
      input_top_zip_path: step7_genion/output_top_zip_file
      input_cpt_path:  step12_mdrun_nvt/output_cpt_file
    out: [output_tpr_file]

  step15_mdrun_npt:
    label: Equilibrate the System (NPT) - part 2
    run: biobb_adapters/mdrun.cwl
    in:
      input_tpr_path: step14_grompp_npt/output_tpr_file
    out: [output_trr_file, output_gro_file, output_edr_file, output_log_file, output_cpt_file]

  step16_energy_npt:
    label: Equilibrate the System (NPT) - part 3
    run: biobb_adapters/gmx_energy.cwl
    in:
      config: step16_energy_npt_config
      output_xvg_path: step16_energy_npt_name
      input_energy_path: step15_mdrun_npt/output_edr_file
    out: [output_xvg_file]

  step17_grompp_md:
    label: Free Molecular Dynamics Simulation - part 1
    run: biobb_adapters/grompp.cwl
    in:
      config: step17_gppmd_config
      input_gro_path: step15_mdrun_npt/output_gro_file
      input_top_zip_path: step7_genion/output_top_zip_file
      input_cpt_path:  step15_mdrun_npt/output_cpt_file
    out: [output_tpr_file]

  step18_mdrun_md:
    label: Free Molecular Dynamics Simulation - part 2
    run: biobb_adapters/mdrun.cwl
    in:
      input_tpr_path: step17_grompp_md/output_tpr_file
    out: [output_trr_file, output_gro_file, output_edr_file, output_log_file, output_cpt_file]

  step19_rmsfirst:
    label: Post-processing Resulting 3D Trajectory - part 1
    run: biobb_adapters/gmx_rms.cwl
    in:
      config: step19_rmsfirst_config
      output_xvg_path: step19_rmsfirst_name
      input_structure_path: step17_grompp_md/output_tpr_file
      input_traj_path: step18_mdrun_md/output_trr_file
    out: [output_xvg_file]

  step20_rmsexp:
    label: Post-processing Resulting 3D Trajectory - part 2
    run: biobb_adapters/gmx_rms.cwl
    in:
      config: step20_rmsexp_config
      output_xvg_path: step20_rmsexp_name
      input_structure_path: step8_grompp_min/output_tpr_file
      input_traj_path: step18_mdrun_md/output_trr_file
    out: [output_xvg_file]

  step21_rgyr:
    label: Post-processing Resulting 3D Trajectory - part 3
    run: biobb_adapters/gmx_rgyr.cwl
    in:
      config: step21_rgyr_config
      input_structure_path: step8_grompp_min/output_tpr_file
      input_traj_path: step18_mdrun_md/output_trr_file
    out: [output_xvg_file]

  step22_image:
    label: Post-processing Resulting 3D Trajectory - part 4
    run: biobb_adapters/gmx_image.cwl
    in:
      config: step22_image_config
      input_top_path: step17_grompp_md/output_tpr_file
      input_traj_path: step18_mdrun_md/output_trr_file
    out: [output_traj_file]

  step23_dry:
    label: Post-processing Resulting 3D Trajectory - part 5
    run: biobb_adapters/gmx_trjconv_str.cwl
    in:
      config: step23_dry_config
      input_structure_path: step18_mdrun_md/output_gro_file
      input_top_path: step17_grompp_md/output_tpr_file
    out: [output_str_file]
