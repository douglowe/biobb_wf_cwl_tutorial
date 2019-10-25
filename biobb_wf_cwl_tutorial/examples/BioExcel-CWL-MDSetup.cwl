#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
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
    type: File
    outputSource: step18_mdrun_md/output_trr_file
  trr_imaged_dry:
    type: File
    outputSource: step22_image/output_traj_file
  gro_dry:
    type: File
    outputSource: step23_dry/output_str_file
  gro:
    type: File
    outputSource: step18_mdrun_md/output_gro_file
  cpt:
    type: File
    outputSource: step18_mdrun_md/output_cpt_file
  tpr:
    type: File
    outputSource: step17_grompp_md/output_tpr_file
  top:
    type: File
    outputSource: step7_genion/output_top_zip_file
  xvg_min:
    type: File
    outputSource: step10_energy_min/output_xvg_file
  xvg_nvt:
    type: File
    outputSource: step13_energy_nvt/output_xvg_file
  xvg_npt:
    type: File
    outputSource: step16_energy_npt/output_xvg_file
  xvg_rmsfirst:
    type: File
    outputSource: step19_rmsfirst/output_xvg_file
  xvg_rmsexp:
    type: File
    outputSource: step20_rmsexp/output_xvg_file
  xvg_rgyr:
    type: File
    outputSource: step21_rgyr/output_xvg_file

steps:
  step1_pdb:
    run: biobb_adapters/pdb.cwl
    in:
      output_pdb_path: step1_pdb_name
      config: step1_pdb_config
    out: [output_pdb_file]

  step2_fixsidechain:
    run: biobb_adapters/fix_side_chain.cwl
    in:
      input_pdb_path: step1_pdb/output_pdb_file
    out: [output_pdb_file]

  step3_pdb2gmx:
    run: biobb_adapters/pdb2gmx.cwl
    in:
      input_pdb_path: step2_fixsidechain/output_pdb_file
    out: [output_gro_file, output_top_zip_file]

  step4_editconf:
    run: biobb_adapters/editconf.cwl
    in:
      input_gro_path: step3_pdb2gmx/output_gro_file
    out: [output_gro_file]

  step5_solvate:
    run: biobb_adapters/solvate.cwl
    in:
      input_solute_gro_path: step4_editconf/output_gro_file
      input_top_zip_path: step3_pdb2gmx/output_top_zip_file
    out: [output_gro_file, output_top_zip_file]

  step6_grompp_genion:
    run: biobb_adapters/grompp.cwl
    in:
      config: step6_gppion_config
      input_gro_path: step5_solvate/output_gro_file
      input_top_zip_path: step5_solvate/output_top_zip_file
    out: [output_tpr_file]

  step7_genion:
    run: biobb_adapters/genion.cwl
    in:
      config: step7_genion_config
      input_tpr_path: step6_grompp_genion/output_tpr_file
      input_top_zip_path: step5_solvate/output_top_zip_file
    out: [output_gro_file, output_top_zip_file]

  step8_grompp_min:
    run: biobb_adapters/grompp.cwl
    in:
      config: step8_gppmin_config
      input_gro_path: step7_genion/output_gro_file
      input_top_zip_path: step7_genion/output_top_zip_file
    out: [output_tpr_file]

  step9_mdrun_min:
    run: biobb_adapters/mdrun.cwl
    in:
      input_tpr_path: step8_grompp_min/output_tpr_file
    out: [output_trr_file, output_gro_file, output_edr_file, output_log_file]

  step10_energy_min:
    run: biobb_adapters/energy.cwl
    in:
      config: step10_energy_min_config
      output_xvg_path: step10_energy_min_name
      input_energy_path: step9_mdrun_min/output_edr_file
    out: [output_xvg_file]

  step11_grompp_nvt:
    run: biobb_adapters/grompp.cwl
    in:
      config: step11_gppnvt_config
      input_gro_path: step9_mdrun_min/output_gro_file
      input_top_zip_path: step7_genion/output_top_zip_file
    out: [output_tpr_file]

  step12_mdrun_nvt:
    run: biobb_adapters/mdrun.cwl
    in:
      input_tpr_path: step11_grompp_nvt/output_tpr_file
    out: [output_trr_file, output_gro_file, output_edr_file, output_log_file, output_cpt_file]

  step13_energy_nvt:
    run: biobb_adapters/energy.cwl
    in:
      config: step13_energy_nvt_config
      output_xvg_path: step13_energy_nvt_name
      input_energy_path: step12_mdrun_nvt/output_edr_file
    out: [output_xvg_file]

  step14_grompp_npt:
    run: biobb_adapters/grompp.cwl
    in:
      config: step14_gppnpt_config
      input_gro_path: step12_mdrun_nvt/output_gro_file
      input_top_zip_path: step7_genion/output_top_zip_file
      input_cpt_path:  step12_mdrun_nvt/output_cpt_file
    out: [output_tpr_file]

  step15_mdrun_npt:
    run: biobb_adapters/mdrun.cwl
    in:
      input_tpr_path: step14_grompp_npt/output_tpr_file
    out: [output_trr_file, output_gro_file, output_edr_file, output_log_file, output_cpt_file]

  step16_energy_npt:
    run: biobb_adapters/energy.cwl
    in:
      config: step16_energy_npt_config
      output_xvg_path: step16_energy_npt_name
      input_energy_path: step15_mdrun_npt/output_edr_file
    out: [output_xvg_file]

  step17_grompp_md:
    run: biobb_adapters/grompp.cwl
    in:
      config: step17_gppmd_config
      input_gro_path: step15_mdrun_npt/output_gro_file
      input_top_zip_path: step7_genion/output_top_zip_file
      input_cpt_path:  step15_mdrun_npt/output_cpt_file
    out: [output_tpr_file]

  step18_mdrun_md:
    run: biobb_adapters/mdrun.cwl
    in:
      input_tpr_path: step17_grompp_md/output_tpr_file
    out: [output_trr_file, output_gro_file, output_edr_file, output_log_file, output_cpt_file]

  step19_rmsfirst:
    run: biobb_adapters/rms.cwl
    in:
      config: step19_rmsfirst_config
      output_xvg_path: step19_rmsfirst_name
      input_structure_path: step17_grompp_md/output_tpr_file
      input_traj_path: step18_mdrun_md/output_trr_file
    out: [output_xvg_file]

  step20_rmsexp:
    run: biobb_adapters/rms.cwl
    in:
      config: step20_rmsexp_config
      output_xvg_path: step20_rmsexp_name
      input_structure_path: step8_grompp_min/output_tpr_file
      input_traj_path: step18_mdrun_md/output_trr_file
    out: [output_xvg_file]

  step21_rgyr:
    run: biobb_adapters/rgyr.cwl
    in:
      config: step21_rgyr_config
      input_structure_path: step8_grompp_min/output_tpr_file
      input_traj_path: step18_mdrun_md/output_trr_file
    out: [output_xvg_file]

  step22_image:
    run: biobb_adapters/gmximage.cwl
    in:
      config: step22_image_config
      input_top_path: step17_grompp_md/output_tpr_file
      input_traj_path: step18_mdrun_md/output_trr_file
    out: [output_traj_file]

  step23_dry:
    run: biobb_adapters/gmxtrjconvstr.cwl
    in:
      config: step23_dry_config
      input_structure_path: step18_mdrun_md/output_gro_file
      input_top_path: step17_grompp_md/output_tpr_file
    out: [output_str_file]
