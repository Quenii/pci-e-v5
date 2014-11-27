call rem_files.bat

::Following coregen commands to be uncommented  when the parameter DEBUG_EN is changed from 0 to 1 in ddr2_sdram_mig33.v/.vhd file.
::coregen -b icon4_cg.xco
::coregen -b vio_async_in96_cg.xco
::coregen -b vio_async_in192_cg.xco
::coregen -b vio_sync_out32_cg.xco
::coregen -b vio_async_in100_cg.xco

::del *.ncf
xtclsh set_ise_prop.tcl
