function setflaps {
    parameter fwddeploy.
    parameter aftdeploy.

    for pt in ship:parts {

        // FRONT FLAPS
        if pt:name:contains("SEP.24.SHIP.PROTO.FWD.LEFT")
        or pt:name:contains("SEP.24.SHIP.PROTO.FWD.RIGHT") {

            if pt:hasmodule("ModuleSEPControlSurface") {
                pt:getmodule("ModuleSEPControlSurface"):setfield("Deploy", fwddeploy).
            }
        }

        // AFT FLAPS
        if pt:name:contains("SEP.24.SHIP.PROTO.AFT.LEFT")
        or pt:name:contains("SEP.24.SHIP.PROTO.AFT.RIGHT") {

            if pt:hasmodule("ModuleSEPControlSurface") {
                pt:getmodule("ModuleSEPControlSurface"):setfield("Deploy", aftdeploy).
            }
        }
    }
}


// first argument = front flaps
// second argument = aft flaps
// deploy = bend
// retract = straight

setflaps(1, 1). // deploy all 4
wait 2.

setflaps(0, 1). // retract front, keep aft deployed
wait 2.

setflaps(1, 0). // deploy front, retract aft
wait 2.

setflaps(0, 0). // retract all 4