# Example of a short CWL workflow with BioExcel building blocks 

# !/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
inputs:
  step1_pdb_config: string
  step1_pdb_name: string

outputs:
  pdb:
    type: File
    outputSource: step2_fixsidechain/output_pdb_file

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
