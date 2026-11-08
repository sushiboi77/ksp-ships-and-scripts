//Author: sushiboi
//this is a boot file to run the Landing program LAND3.ks.
switch to 0.
PRINT "IDLE v1.1".
wait until altitude > 48500.// and throttle = 0.2.
PRINT "HANDOFF".
run LAND4.ks.