#!/bin/bash

project_name="axi4lite_hw_test"
project_dir="./axi4lite_hw_test"
ic_part="xc7z010clg400-1"

ps7_init_script="ps7_init.tcl"
hw_design_wrapper="design_1_wrapper.hdf"
bitstream="design_1_wrapper.bit"

create_project_script="create_project.tcl"
read_write_test_script="read_write_test.tcl"

echo
echo "Create and build Vivado project"
echo

vivado -mode batch -source ${create_project_script} -tclargs ${project_name} ${project_dir} ${ic_part}

if [[ $? -eq 0 ]]; then
  echo "$create_project_script script executed successfully."
else
  echo "Error: $create_project_script script execution failed!"
  exit 1
fi

ps7_init_path=`find ${project_dir}/${project_name}.srcs -name ${ps7_init_script}`
hw_design_wrapper_path=`find ${project_dir}/${project_name}.sdk -name ${hw_design_wrapper}`
bitstream_path=`find ${project_dir}/${project_name}.runs -name ${bitstream}`

echo
echo "Build output:"
echo "-------------------------------------------------------------------------"
echo ${ps7_init_path}
echo ${hw_design_wrapper_path}
echo ${bitstream_path}
echo "-------------------------------------------------------------------------"
echo
echo "Run read/write test"
echo

xsct -eval "set argv {$bitstream_path $hw_design_wrapper_path $ps7_init_path}; source $read_write_test_script;"

if [[ $? -eq 0 ]]; then
  echo "$read_write_test_script script executed successfully."
else
  echo "Error: $read_write_test_script script execution failed!"
  exit 1
fi

