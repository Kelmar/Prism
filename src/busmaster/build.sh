set +x

./atf15xx_yosys/run_yosys.sh busmaster > busmaster.log
./atf15xx_yosys/run_fitter.sh -d ATF1502AS -p PLCC44 -s 7 busmaster -tdi_pullup on -tms_pullup on -output_fast off -xor_synthesis on
