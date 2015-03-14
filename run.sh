#/bin/bash

xsc read_scn.c 
xvlog -sv test.v axi4l_mst.sv axi4l_slv.sv
xelab work.test -sv_lib dpi 
xsim work.test -R
