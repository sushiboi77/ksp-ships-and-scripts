print "launch".
lock throttle to 1.
set upv to ship:facing:topvector.
lock steering to lookDirUp(ship:up:forevector, upv).
//rcs on.

wait until alt:radar > 90.

set target_ap to 80000.
set launch_heading to 180.
set end_pitch to 43.5 - sin(launch_heading)*3.5. //FOR G2
lock launch_pitch to end_pitch + arcsin(1-ship:orbit:apoapsis/target_ap)*((90-end_pitch)/90).

lock steering to HEADING(launch_heading, launch_pitch, 270).

until ship:orbit:apoapsis > target_ap {
    print "Launch progress is: " + round((ship:orbit:apoapsis/target_ap)*100).
}

lock throttle to 0.
stage.
wait 4.
lock throttle to 1.
wait until ship:orbit:apoapsis > 90000.
unlock all.
sas on.