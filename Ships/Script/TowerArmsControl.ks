// global commandRecieved is false.

// until commandRecieved {
//     if not ship:messages:empty {
//         print("Message Recieved at: " + missionTime).
//         // wait 1.
//         // clearScreen.
//         local dataPacket is ship:MESSAGES:POP.  //stores the whole data packet in a variable
//         local decodedMessage is dataPacket:CONTENT. //stores the message contents in decodedMessage
//         //print decodedMessage.
//         if decodedMessage = "CLOSE" {
//             toggle ag2.
//             set commandRecieved to true.
//         } else {
//             clearScreen.
//             print "invalid message".
//             wait 3.
//         }
//     } else {
//         print("waiting for messages: " + ship:messages).
//         print(missionTime).
//         wait 0.01.
//         clearScreen. 
//     }
// }

GLOBAL commandRecieved IS FALSE.

UNTIL commandRecieved {
    LIST TARGETS IN targetsList.

    FOR v IN targetsList {
        IF v <> SHIP {
            LOCAL boosterAGL IS v:ALTITUDE - v:GEOPOSITION:TERRAINHEIGHT.
            LOCAL dist IS (v:POSITION - SHIP:POSITION):MAG.

            IF boosterAGL < 105 and dist < 200 and v:VERTICALSPEED < -0.2 {
                CLEARSCREEN.
                PRINT "Booster detected.".
                PRINT "Booster AGL: " + ROUND(boosterAGL) + "m".
                PRINT "Distance: " + ROUND(dist) + "m".
                PRINT "Closing arms.".

                TOGGLE AG2.
                SET commandRecieved TO TRUE.
                BREAK.
            }
        }
    }

    PRINT "Waiting for booster..." AT (0, 0).
    PRINT "Mission time: " + MISSIONTIME AT (0, 1).
    WAIT 0.1.
    CLEARSCREEN.
}