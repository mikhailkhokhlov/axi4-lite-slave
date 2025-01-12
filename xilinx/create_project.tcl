#set project_name "axi4lite_hw_test"
#set project_dir "./axi4lite_hw_test"
set args $argv

set project_name [lindex $args 0]
set project_dir  [lindex $args 1]
set ic_part      [lindex $args 2]

#create_project $project_name $project_dir -part xc7z010clg400-1
create_project $project_name $project_dir -part $ic_part

set_property board_part digilentinc.com:zybo-z7-10:part0:1.0 [current_project]

set src_fileset "sources_1"

add_files -fileset $src_fileset ../dff-async-rst-n.v
add_files -fileset $src_fileset ../s-axi4l-rd-channel.v
add_files -fileset $src_fileset ../s-axi4l-wr-channel.v
add_files -fileset $src_fileset ../skid-buffer.v
add_files -fileset $src_fileset hdl/axi4l-reg-file.v
add_files -fileset $src_fileset hdl/reg-file-wrapper.v
add_files -fileset $src_fileset hdl/reg-file-4x32.v
add_files -fileset $src_fileset bd/design_1.bd

update_compile_order -fileset $src_fileset
import_files -fileset $src_fileset -force -norecurse

set constr_fileset "constrs_1"

add_files -fileset $constr_fileset ./constr/Zybo-Z7-Master.xdc
import_files -fileset constrs_1 -force -norecurse

set design_wrapper "${project_dir}/${project_name}.srcs/${src_fileset}/bd/bd/hdl/design_1_wrapper.v"

make_wrapper -files [get_files design_1.bd] -top
add_files -fileset $src_fileset $design_wrapper
set_property top top [current_fileset]

update_compile_order -fileset $src_fileset

launch_runs synth_1
wait_on_run synth_1
launch_runs impl_1
wait_on_run impl_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

set sdk_dir "${project_dir}/${project_name}.sdk"
set hdf_wrapper "${sdk_dir}/design_1_wrapper.hdf"

file mkdir $sdk_dir
write_hwdef -force -file $hdf_wrapper

exit
