@echo off
IF EXIST "../synth/__projnav" rmdir /S /Q "../synth/__projnav" 
IF EXIST "../synth/xst" rmdir /S /Q "../synth/xst" 
IF EXIST "../synth/_ngo" rmdir /S /Q "../synth/_ngo" 

IF EXIST tmp rmdir /S /Q tmp
IF EXIST _xmsgs rmdir /S /Q _xmsgs
IF EXIST vio_sync_out32_xdb rmdir /S /Q vio_sync_out32_xdb
IF EXIST vio_async_in100_xdb rmdir /S /Q vio_async_in100_xdb
IF EXIST vio_async_in192_xdb rmdir /S /Q vio_async_in192_xdb
IF EXIST vio_async_in96_xdb rmdir /S /Q vio_async_in96_xdb
IF EXIST icon4_xdb rmdir /S /Q icon4_xdb

IF EXIST xst rmdir /S /Q xst
IF EXIST xlnx_auto_0_xdb rmdir /S /Q xlnx_auto_0_xdb

IF EXIST coregen.log del /F /Q coregen.log
IF EXIST stdout.log del /F /Q stdout.log
IF EXIST vio_sync_out32.asy del /F /Q vio_sync_out32.asy
IF EXIST vio_sync_out32.cdc del /F /Q vio_sync_out32.cdc
IF EXIST vio_sync_out32.gise del /F /Q vio_sync_out32.gise
IF EXIST vio_sync_out32.ise del /F /Q vio_sync_out32.ise
IF EXIST vio_sync_out32.ncf del /F /Q vio_sync_out32.ncf
IF EXIST vio_sync_out32.ngc del /F /Q vio_sync_out32.ngc
IF EXIST vio_sync_out32.xco del /F /Q vio_sync_out32.xco
IF EXIST vio_sync_out32.xise del /F /Q vio_sync_out32.xise
IF EXIST vio_sync_out32_flist.txt del /F /Q vio_sync_out32_flist.txt
IF EXIST vio_sync_out32_readme.txt del /F /Q vio_sync_out32_readme.txt
IF EXIST vio_sync_out32_xmdf.tcl del /F /Q vio_sync_out32_xmdf.tcl

IF EXIST vio_async_in96.asy del /F /Q vio_async_in96.asy
IF EXIST vio_async_in96.cdc del /F /Q vio_async_in96.cdc
IF EXIST vio_async_in96.gise del /F /Q vio_async_in96.gise
IF EXIST vio_async_in96.ise del /F /Q vio_async_in96.ise
IF EXIST vio_async_in96.ncf del /F /Q vio_async_in96.ncf
IF EXIST vio_async_in96.ngc del /F /Q vio_async_in96.ngc
IF EXIST vio_async_in96.xco del /F /Q vio_async_in96.xco
IF EXIST vio_async_in96.xise del /F /Q vio_async_in96.xise
IF EXIST vio_async_in96_flist.txt del /F /Q vio_async_in96_flist.txt
IF EXIST vio_async_in96_readme.txt del /F /Q vio_async_in96_readme.txt
IF EXIST vio_async_in96_xmdf.tcl del /F /Q vio_async_in96_xmdf.tcl


IF EXIST vio_async_in100.asy del /F /Q vio_async_in100.asy
IF EXIST vio_async_in100.cdc del /F /Q vio_async_in100.cdc
IF EXIST vio_async_in100.gise del /F /Q vio_async_in100.gise
IF EXIST vio_async_in100.ise del /F /Q vio_async_in100.ise
IF EXIST vio_async_in100.ncf del /F /Q vio_async_in100.ncf
IF EXIST vio_async_in100.ngc del /F /Q vio_async_in100.ngc
IF EXIST vio_async_in100.xco del /F /Q vio_async_in100.xco
IF EXIST vio_async_in100.xise del /F /Q vio_async_in100.xise
IF EXIST vio_async_in100_flist.txt del /F /Q vio_async_in100_flist.txt
IF EXIST vio_async_in100_readme.txt del /F /Q vio_async_in100_readme.txt
IF EXIST vio_async_in100_xmdf.tcl del /F /Q vio_async_in100_xmdf.tcl

IF EXIST vio_async_in192.asy del /F /Q vio_async_in192.asy
IF EXIST vio_async_in192.cdc del /F /Q vio_async_in192.cdc
IF EXIST vio_async_in192.gise del /F /Q vio_async_in192.gise
IF EXIST vio_async_in192.ise del /F /Q vio_async_in192.ise
IF EXIST vio_async_in192.ncf del /F /Q vio_async_in192.ncf
IF EXIST vio_async_in192.ngc del /F /Q vio_async_in192.ngc
IF EXIST vio_async_in192.xco del /F /Q vio_async_in192.xco
IF EXIST vio_async_in192.xise del /F /Q vio_async_in192.xise
IF EXIST vio_async_in192_flist.txt del /F /Q vio_async_in192_flist.txt
IF EXIST vio_async_in192_readme.txt del /F /Q vio_async_in192_readme.txt
IF EXIST vio_async_in192_xmdf.tcl del /F /Q vio_async_in192_xmdf.tcl

IF EXIST icon4.gise del /F /Q icon4.gise
IF EXIST icon4.ise del /F /Q icon4.ise
IF EXIST icon4.ncf del /F /Q icon4.ncf
IF EXIST icon4.ngc del /F /Q icon4.ngc
IF EXIST icon4.xco del /F /Q icon4.xco
IF EXIST icon4.xise del /F /Q icon4.xise
IF EXIST icon4_flist.txt del /F /Q icon4_flist.txt
IF EXIST icon4_readme.txt del /F /Q icon4_readme.txt
IF EXIST icon4_xmdf.tcl del /F /Q icon4_xmdf.tcl

IF EXIST ise_flow_results.txt del /F /Q ise_flow_results.txt
IF EXIST ddr2_sdram_mig33_vhdl.prj del /F /Q ddr2_sdram_mig33_vhdl.prj
IF EXIST mem_interface_top.syr del /F /Q mem_interface_top.syr
IF EXIST ddr2_sdram_mig33.ngc del /F /Q ddr2_sdram_mig33.ngc
IF EXIST ddr2_sdram_mig33.ngo del /F /Q ddr2_sdram_mig33.ngo
IF EXIST netlist.lst del /F /Q netlist.lst
IF EXIST ddr2_sdram_mig33.ngr del /F /Q ddr2_sdram_mig33.ngr
IF EXIST ddr2_sdram_mig33_xst.xrpt del /F /Q ddr2_sdram_mig33_xst.xrpt
IF EXIST ddr2_sdram_mig33.bld del /F /Q ddr2_sdram_mig33.bld
IF EXIST ddr2_sdram_mig33.ngd del /F /Q ddr2_sdram_mig33.ngd
IF EXIST ddr2_sdram_mig33_ngdbuild.xrpt del /F /Q  ddr2_sdram_mig33_ngdbuild.xrpt
IF EXIST ddr2_sdram_mig33_map.map del /F /Q  ddr2_sdram_mig33_map.map
IF EXIST ddr2_sdram_mig33_map.mrp del /F /Q  ddr2_sdram_mig33_map.mrp
IF EXIST ddr2_sdram_mig33_map.ngm del /F /Q  ddr2_sdram_mig33_map.ngm
IF EXIST ddr2_sdram_mig33.pcf del /F /Q  ddr2_sdram_mig33.pcf
IF EXIST ddr2_sdram_mig33_map.ncd del /F /Q  ddr2_sdram_mig33_map.ncd
IF EXIST ddr2_sdram_mig33_map.xrpt del /F /Q  ddr2_sdram_mig33_map.xrpt
IF EXIST ddr2_sdram_mig33_summary.xml del /F /Q  ddr2_sdram_mig33_summary.xml
IF EXIST ddr2_sdram_mig33_usage.xml del /F /Q  ddr2_sdram_mig33_usage.xml
IF EXIST ddr2_sdram_mig33.ncd del /F /Q  ddr2_sdram_mig33.ncd
IF EXIST ddr2_sdram_mig33.par del /F /Q  ddr2_sdram_mig33.par
IF EXIST ddr2_sdram_mig33.xpi del /F /Q  ddr2_sdram_mig33.xpi
IF EXIST smartpreview.twr del /F /Q  smartpreview.twr
IF EXIST ddr2_sdram_mig33.ptwx del /F /Q  ddr2_sdram_mig33.ptwx
IF EXIST ddr2_sdram_mig33.pad del /F /Q  ddr2_sdram_mig33.pad
IF EXIST ddr2_sdram_mig33.unroutes del /F /Q  ddr2_sdram_mig33.unroutes
IF EXIST ddr2_sdram_mig33_pad.csv del /F /Q  ddr2_sdram_mig33_pad.csv
IF EXIST ddr2_sdram_mig33_pad.txt del /F /Q  ddr2_sdram_mig33_pad.txt
IF EXIST ddr2_sdram_mig33_par.xrpt del /F /Q  ddr2_sdram_mig33_par.xrpt
IF EXIST ddr2_sdram_mig33.twx del /F /Q  ddr2_sdram_mig33.twx
IF EXIST ddr2_sdram_mig33.bgn del /F /Q  ddr2_sdram_mig33.bgn
IF EXIST ddr2_sdram_mig33.twr del /F /Q  ddr2_sdram_mig33.twr
IF EXIST ddr2_sdram_mig33.drc del /F /Q  ddr2_sdram_mig33.drc
IF EXIST ddr2_sdram_mig33.bit del ddr2_sdram_mig33.bit

:: Files and folders generated by create ise
IF EXIST test_xdb rmdir /S /Q test_xdb 
IF EXIST _xmsgs rmdir /S /Q _xmsgs 
IF EXIST test.gise del /F /Q test.gise
IF EXIST test.xise del /F /Q test.xise
IF EXIST test.ise del /F /Q test.ise

:: Files generated by ISE through GUI mode
IF EXIST _ngo rmdir /S /Q _ngo 
IF EXIST xst rmdir /S /Q xst 
IF EXIST ddr2_sdram_mig33.lso del /F /Q ddr2_sdram_mig33.lso
IF EXIST ddr2_sdram_mig33.prj del /F /Q ddr2_sdram_mig33.prj
IF EXIST ddr2_sdram_mig33.xst del /F /Q ddr2_sdram_mig33.xst
IF EXIST ddr2_sdram_mig33.stx del /F /Q ddr2_sdram_mig33.stx
IF EXIST ddr2_sdram_mig33.syr del /F /Q ddr2_sdram_mig33.syr
IF EXIST ddr2_sdram_mig33_prev_built.ngd del /F /Q ddr2_sdram_mig33_prev_built.ngd
IF EXIST test.ntrc_log del /F /Q test.ntrc_log
IF EXIST ddr2_sdram_mig33_guide.ncd del /F /Q ddr2_sdram_mig33_guide.ncd
IF EXIST ddr2_sdram_mig33.ut del /F /Q ddr2_sdram_mig33.ut
IF EXIST ddr2_sdram_mig33.cmd_log del /F /Q ddr2_sdram_mig33.cmd_log
IF EXIST device_usage_statistics.html del /F /Q device_usage_statistics.html
IF EXIST ddr2_sdram_mig33_summary.html del /F /Q ddr2_sdram_mig33_summary.html

@echo on
