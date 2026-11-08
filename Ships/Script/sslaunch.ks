print "launch".
lock throttle to 1.
set upv to ship:facing:topvector.
lock steering to lookDirUp(ship:up:forevector, upv).
set camera to vessel("Tracking Camera"):connection.
//rcs on.

wait until alt:radar > 100.

set target_ap to 80000.
set launch_heading to 90. // 90 is east
set end_pitch to 30 - sin(launch_heading)*3.5. //FOR G2
lock launch_pitch to end_pitch + arcsin(1-ship:orbit:apoapsis/target_ap)*((90-end_pitch)/90).

lock steering to HEADING(launch_heading, launch_pitch, 270).

when ship:velocity:surface:mag > 700 then {
    lock throttle to 0.65.
}

until ship:orbit:apoapsis > target_ap {
    print "Launch progress is: " + round((ship:orbit:apoapsis/target_ap)*100).
    camera:sendmessage("ping").
}

toggle AG1.
toggle AG1.
lock throttle to 0.5.
rcs on.
wait 0.25.
stage.
wait 0.1.
lock throttle to 1.
wait until ship:orbit:apoapsis > 90000.
unlock all.
sas on.