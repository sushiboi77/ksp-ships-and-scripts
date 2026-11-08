print "launch".
lock throttle to 1.
set upv to ship:facing:topvector.
lock steering to lookDirUp(ship:up:forevector, upv).
//rcs on.

wait until alt:radar > 100.

set target_ap to 1600000.
set launch_heading to 90. // 90 is east
set end_pitch to 55 - sin(launch_heading)*3.5. //FOR G2
lock launch_pitch to end_pitch + arcsin(1-ship:orbit:apoapsis/target_ap)*((90-end_pitch)/90).

lock steering to HEADING(launch_heading, launch_pitch, 270).

//when ship:velocity:surface:mag > 700 then {
//    lock throttle to 0.65.
//}

until ship:orbit:apoapsis > target_ap {
    print "Launch progress is: " + round((ship:orbit:apoapsis/target_ap)*100).
}

lock throttle to 0.
rcs on.

