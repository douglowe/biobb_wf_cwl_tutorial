#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: gmx_energy
hints:
  DockerRequirement:
    dockerPull: mmbirb/biobb_analysis:latest
inputs:
  input_energy_path:
    type: File
    inputBinding:
      position: 1
      prefix: --input_energy_path

  output_xvg_path:
    type: string
    inputBinding:
      position: 2
      prefix: --output_xvg_path
    default: "energy.xvg"

  config:
    type: string?
    inputBinding:
      position: 3
      prefix: --config

outputs:
  output_xvg_file:
    type: File
    format: edam:format_XVG
    outputBinding:
      glob: $(inputs.output_xvg_path)

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.22.owl
