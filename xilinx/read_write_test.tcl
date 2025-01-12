set args $argv

set bitstream       [lindex $args 0]
set hw_wrapper      [lindex $args 1]
set ps7_init_script [lindex $args 2]

set cpu_core_0 "ARM Cortex-A9 MPCore #0"

connect

puts "=== Setting target CPU..."
targets -set -filter {name =~ $cpu_core_0}

puts "=== Resetting CPU..."
rst

puts "=== Loading bitstream..."
fpga $bitstream

puts "=== Loading HW wrapper..."
loadhw $hw_wrapper

puts "=== Reading ps7_init.tcl script..."
source $ps7_init_script

puts "=== Initting CPU..."
ps7_init
ps7_post_config

set mmio_values {
    {0x43c00000 0xff00ff00}
    {0x43c00004 0x00ff00ff}
    {0x43c00008 0xffff0000}
    {0x43c0000c 0x0000ffff}
}

puts ""
puts "Writing values to MMIO..."
puts ""

foreach item $mmio_values {
    set address [lindex $item 0]
    set value   [lindex $item 1]
    puts "Writing $value to address $address..."
    mwr $address $value
}

puts ""
puts "Reading back and verifying values..."
puts "Read values must have inverted bits to written ones."
puts ""

foreach item $mmio_values {
    set address [lindex $item 0]
    set value   [lindex $item 1]

    set expected_value [expr {~$value & 0xffffffff}]
    set read_value [lindex [mrd $address] 1]
    set hex_read_value [expr 0x$read_value]
    if {$hex_read_value == $expected_value} {
        puts "Address $address: Read value 0x[format %08x $hex_read_value] matches expected value 0x[format %08x $expected_value]"
    } else {
        puts "ERROR: Address $address: Read value 0x[format %08x $hex_read_value] does NOT match expected value 0x[format %08x $expected_value]"
    }
}

disconnect
