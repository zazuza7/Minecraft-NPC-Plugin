
MiningTask:
    type: task
    script:
        - define NPC <[1]>
#Stops the script if the direction is vertical
        - if <player.eye_location.precise_impact_normal.x> == 0 && <player.eye_location.precise_impact_normal.z> == 0:
            - stop
        - flag <[NPC]> CurrentBlockMined:!
        - wait 0.5s

        - flag <[NPC]> Direction:<player.eye_location.precise_impact_normal>
        - flag <[NPC]> CurrentBlockMined:<player.cursor_on>
        - flag <[NPC]> Status:Mine
        - flag <[NPC]> StripStartingPosition:!

#{ FLAGINT PRADINY BLOKA        - flag <[NPC]>
        - repeat 1:

            - run SetFlag def:<[NPC]>
            - flag <[NPC]> CurrentBlockMined:<[NPC].flag[StripStartingPosition].as_location>

            - repeat 1000:
                - ~run CheckingSubScript def:<[NPC]>|Top
                - if <[NPC].has_flag[CurrentBlockMined]>:
                    - ~run MiningSubScript def:<[NPC]>
                - if <[NPC].has_flag[CurrentBlockMined]>:
                    - flag <[NPC]> CurrentBlockMined:<[NPC].flag[CurrentBlockMined].as_location.below>
                    - ~run CheckingSubScript def:<[NPC]>|Bottom

                - if <[NPC].has_flag[CurrentBlockMined]>:
                    - ~run MiningSubScript def:<[NPC]>
                - if <[NPC].has_flag[CurrentBlockMined]>:
                    - flag <[NPC]> CurrentBlockMined:<[NPC].flag[CurrentBlockMined].as_location.sub[<[NPC].flag[Direction].as_location>].above>
                - if !<[NPC].has_flag[CurrentBlockMined]>:
                    - repeat stop
            - ~run LongWalk def:<[NPC]>|<[NPC].flag[ChestLocation]>
            - if <[NPC].location.distance[<[NPC].flag[ChestLocation].as_location>]> > 3.5:
                - narrate "I'm stuck, can't reach linked chest :( My current location is - <[NPC].location.round.simple>"
                - flag <[NPC]> status:Stop
                - stop
            - ~run deposit def:<[NPC]>
        - flag <[NPC]> StripStartingPosition:!



#Flags position from which the NPC will start mining a new strip
SetFlag:
    type: task
    script:
        - define NPC <[1]>
        - if <[NPC].has_flag[StripStartingPosition]>:
            - repeat <yaml[MinionConfig].read[StripMineDistance]>:
                - flag <[NPC]> StripStartingPosition:<[NPC].flag[StripStartingPosition].as_location.sub[<[NPC].flag[Direction].as_location.rotate_around_y[-1.5708].round_to_precision[1]>]>
#{            - modifyblock <[NPC].flag[StripStartingPosition]> dirt
            - narrate "Setting not 1st pos"
        - else:
            - flag <[NPC]> StripStartingPosition:<player.cursor_on>
            - narrate "Setting 1st pos"


#NPC moves towards a single target block and simulates mining it, while receiving drops to its inventory
MiningSubScript:
    type: task
    script:
        - define NPC <[1]>
        - define CurrentBlockMined <[NPC].flag[CurrentBlockMined]>

        - if <[NPC].location.distance[<[CurrentBlockMined]>]> > 3.5:
            - walk <[CurrentBlockMined].as_location.add[<[NPC].flag[Direction].as_location>]> <[NPC]> auto_range
        - run DistanceCheck def:<[NPC]>|<[NPC].flag[CurrentBlockMined].as_location>
        - waituntil <[NPC].location.distance[<[CurrentBlockMined]>]> < 3.5 || !<[NPC].has_flag[CurrentBlockMined]>
        - if <[NPC].has_flag[CurrentBlockMined]>:
#{            - wait 0.3
            - animate <[NPC]> ARM_SWING
            - blockcrack <[CurrentBlockMined]> progress:<util.random.int[4].to[7]>
#{            - wait 0.5s
            - animate <[NPC]> ARM_SWING
            - give <[CurrentBlockMined].as_location.drops.get[1]> to:<[NPC].inventory>
            - modifyblock <[CurrentBlockMined]> air
            - blockcrack <[CurrentBlockMined]> progress:0
        - else:
            - narrate "Can't reach a block I'm trying to mine :( My current location is - <[NPC].location.round.simple>"

#Checks whether there is danger while mining and changes status of NPC if necessary
CheckingSubScript:
    type: task
    script:
        - define NPC <[1]>
        - define Target <[NPC].flag[CurrentBlockMined].as_location>
        - define Direction <[NPC].flag[Direction].as_location>

        - if !<[NPC].has_flag[CurrentBlockMined]>:
            - stop
        - if <[Target].sub[<[Direction]>].material.is_transparent>:
            - narrate "Air in front detected, stopping mining <[2]>"
            - flag <[NPC]> CurrentBlockMined:!
        - else if <[Target].sub[<[Direction]>].is_liquid>:
            - narrate "Lava/Water in front detected, stopping mining"
            - flag <[NPC]> CurrentBlockMined:!
        - else if <[Target].above.material.is_transparent> && <[2]> == Top:
            - narrate "Air above detected, stopping mining"
            - flag <[NPC]> CurrentBlockMined:!
        - else if <[Target].above.is_liquid> && <[2]> == Top:
            - narrate "Lava/Water above detected, stopping mining"
            - flag <[NPC]> CurrentBlockMined:!
        - else if <[Target].below.material.is_transparent> && <[2]> == Bottom:
            - narrate "Air below detected, stopping mining"
            - flag <[NPC]> CurrentBlockMined:!
        - else if <[Target].below.is_liquid> && <[2]> == Bottom:
            - narrate "Lava/Water below detected, stopping mining"
            - flag <[NPC]> CurrentBlockMined:!
        - else if <[Target].add[<[Direction].rotate_around_y[1.5708].round_to_precision[1]>].material.is_transparent>:
            - narrate "Right-side Air detected, stopping mining"
            - flag <[NPC]> CurrentBlockMined:!
        - else if <[Target].add[<[Direction].rotate_around_y[1.5708].round_to_precision[1]>].is_liquid>:
            - narrate "Right-side Lava/Water detected, stopping mining"
            - flag <[NPC]> CurrentBlockMined:!
        - else if <[Target].add[<[Direction].rotate_around_y[-1.5708].round_to_precision[1]>].material.is_transparent>:
            - narrate "Left-side Air detected, stopping mining"
            - flag <[NPC]> CurrentBlockMined:!
        - else if <[Target].add[<[Direction].rotate_around_y[-1.5708].round_to_precision[1]>].is_liquid>:
            - narrate "Left-side Lava/Water detected, stopping mining"
            - flag <[NPC]> CurrentBlockMined:!





#If NPC is too far to reach the target block after 20s it stops trying to reach it
DistanceCheck:
    type: task
    script:
        - define NPC <[1]>
        - define CurrentBlockMined <[2]>
        - chunkload <[CurrentBlockMined].chunk> duration:11s
        - wait 10s
        - if <[NPC].location.distance[<[CurrentBlockMined]>]> > 3.5 && <[CurrentBlockMined].material.name> != air:
            - narrate "Rekt after 20s"
            - flag <[NPC]> CurrentBlockMined:!

