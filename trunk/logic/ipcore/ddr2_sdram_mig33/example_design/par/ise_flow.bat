call rem_files.bat

::Following coregen commands to be uncommented  when the parameter DEBUG_EN is changed from 0 to 1 in ddr2_sdram_mig33.v/.vhd file.
::coregen -b icon4_cg.xco
::coregen -b vio_async_in96_cg.xco
::coregen -b vio_async_in192_cg.xco
::coregen -b vio_sync_out32_cg.xco
::coregen -b vio_async_in100_cg.xco

::del *.ncf
echo Synthesis Tool: XST

mkdir "../synth/__projnav" > ise_flow_results.txt
mkdir "../synth/xst" >> ise_flow_results.txt
mkdir "../synth/xst/work" >> ise_flow_results.txt

xst -ifn xst_run.txt -ofn mem_interface_top.syr -intstyle ise >> ise_flow_results.txt
ngdbuild -intstyle ise -dd ../synth/_ngo -nt timestamp -uc ddr2_sdram_mig33.ucf -p xc5vlx50tff1136-1 ddr2_sdram_mig33.ngc ddr2_sdram_mig33.ngd >> ise_flow_results.txt

map -intstyle ise -detail -w -logic_opt off -ol high -xe n -t 1 -cm area -o ddr2_sdram_mig33_map.ncd ddr2_sdram_mig33.ngd ddr2_sdram_mig33.pcf >> ise_flow_results.txt
par -w -intstyle ise -ol high -xe n ddr2_sdram_mig33_map.ncd ddr2_sdram_mig33.ncd ddr2_sdram_mig33.pcf >> ise_flow_results.txt
trce -e 3 -xml ddr2_sdram_mig33 ddr2_sdram_mig33.ncd -o ddr2_sdram_mig33.twr ddr2_sdram_mig33.pcf >> ise_flow_results.txt
bitgen -intstyle ise -f mem_interface_top.ut ddr2_sdram_mig33.ncd >> ise_flow_results.txt

echo done!
