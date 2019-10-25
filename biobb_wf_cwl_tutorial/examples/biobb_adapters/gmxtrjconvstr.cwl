#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: gmx_trjconv_str
hints:
  DockerRequirement:
    dockerPull: mmbirb/biobb_analysis:latest
inputs:
  input_structure_path:
    type: File
    inputBinding:
      position: 1
      prefix: --input_structure_path

  input_top_path:
    type: File
    inputBinding:
      position: 2
      prefix: --input_top_path

  input_index_path:
    type: File?
    inputBinding:
      position: 3
      prefix: --input_index_path

  output_str_path:
    type: string
    inputBinding:
      position: 4
      prefix: --output_str_path
    default: "structure.gro"

  config:
    type: string?
    inputBinding:
      position: 5
      prefix: --config

outputs:
  output_str_file:
    type: File
    outputBinding:
      glob: $(inputs.output_str_path)

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.22.owl
