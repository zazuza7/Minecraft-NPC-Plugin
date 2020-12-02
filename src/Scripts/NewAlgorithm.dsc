TopFunction:
    type: task
    script:
    - define Width <yaml[MinionConfig].read[Strip_Width]>
    - define Height <yaml[MinionConfig].read[Strip_Height]>
    - define StripMineDistance <yaml[MinionConfig].read[StripMineDistance]>
    - define Depth 3
    - define NPC <[1]>
    - define InitialLocation <[2]>
    - define Direction <[3]>

    - define NextInitialLocationVector <[Direction].rotate_around_y[-1.5708].round_to_precision[1].mul[<[StripMineDistance].add[<[Width].sub[1]>]>]>

    - while true:
        - ~run MoreEfficientLocationLoop def:<[NPC]>|<[InitialLocation]>|<[Direction]>|<[Depth]>
        - define InitialLocation:<[InitialLocation].add[<[NextInitialLocationVector]>]>

#Change direction and mine till other strip
        - ~run MoreEfficientLocationLoop def:<[NPC]>|<[InitialLocation].sub[<[Direction]>].add[<[Direction].rotate_around_y[1.5708].round_to_precision[1].mul[<[StripMineDistance]>]>]>|<[Direction].rotate_around_y[-1.5708].round_to_precision[1]>|<[StripMineDistance].add[<[Width]>]>

        - if <[loop_index]> == 3:
            - stop

#{        - if <[NPC].has_flag[ChestLocation]>:
#{            - ~run LongWalk def:<[NPC]>|<[NPC].flag[ChestLocation]>
#{            - ~run Collect&Deposit&Clear def:<[NPC]>


#{        - else:
#{            - narrate "I don't have a linked chest."

MoreEfficientLocationLoop:
    type: task
    script:
    - define Width <yaml[MinionConfig].read[Strip_Width]>
    - define Height <yaml[MinionConfig].read[Strip_Height]>
    - define NPC <[1]>
    - define InitialLocation <[2]>
    - define Direction <[3]>
    - define Depth <[4]>
    - define CurrentLocation <[InitialLocation]>
    - define InvalidBlockCounter:0
    - define SavedLoopIndex 0

    - define LocationsNotToMine:->:1
    - define LocationsNotToMine:<-:1
#Vectors of length 1 with directions relative to mining direction
    - define Left <[Direction].rotate_around_y[1.5708].round_to_precision[1]>
    - define Right <[Direction].rotate_around_y[-1.5708].round_to_precision[1]>
    - define Front <[Direction]>
    - define Back <[Direction].rotate_around_y[-1.5708].rotate_around_y[-1.5708].round_to_precision[1]>
    - define Top <location[0,1,0]>
    - define Bottom <location[0,-1,0]>

    - define H*W <[Width].mul[<[Height]>]>

    - define NewDepthVector <[Front].add[<[Top].mul[<[Height].sub[1]>]>]>
    - define NewDepthVector <[NewDepthVector].add[<[Left].mul[<[Width].sub[1]>]>]>

    - define NewVerticalLineVector <[Right].add[<[Top].mul[<[Height].sub[1]>]>]>
#This line is Greedy, mining could fail earlier than that. Should be changed if I'll have time
    - while <[InvalidBlockCounter]> < <[H*W].sub[1]> && <[SavedLoopIndex]> < <[H*W].mul[<[Depth]>]>:
        - define SavedLoopIndex <[loop_index]>
        - flag <[NPC]> StopMining:!
#Check front block for hazards
        - run CheckNewBlock def:<[NPC]>|<[CurrentLocation].add[<[Front]>]>|<[InitialLocation].add[<[Back]>]>
        - if <[NPC].has_flag[StopMining]>:
            - define LocationsNotToMine:->:<[CurrentLocation]>
            - define LocationsNotToMine:->:<[CurrentLocation].add[<[Front]>]>
            - define LocationsNotToMine:->:<[CurrentLocation].add[<[Front]>].add[<[Front]>]>
#Current block is not on the left side of the strip
            - if <[SavedLoopIndex].sub[1].mod[<[H*W]>]> >= <[Height]>:
                - define LocationsNotToMine:->:<[CurrentLocation].add[<[Left]>]>
#Current block is not on the right side of the strip
            - if <[SavedLoopIndex].sub[1].mod[<[H*W]>]> < <[H*W].sub[<[Height]>]>:
                - define LocationsNotToMine:->:<[CurrentLocation].add[<[Right]>]>
#Current block is not on the top side of the strip
            - if <[SavedLoopIndex].mod[<[Height]>]> != 1 && <[Height]> != 1:
                - define LocationsNotToMine:->:<[CurrentLocation].above>
#Current block is not on the bottom side of the strip
            - if <[SavedLoopIndex].mod[<[Height]>]> != 0:
                - define LocationsNotToMine:->:<[CurrentLocation].below>


#If there is a new block revealed on left side - check it
        - if <[SavedLoopIndex].sub[1].mod[<[H*W]>]> < <[Height]>:
            - run CheckNewBlock def:<[NPC]>|<[CurrentLocation].add[<[Left]>]>|<[InitialLocation].add[<[Back]>]>
#If there is a new block revealed on right side - check it
        - if <[SavedLoopIndex].sub[1].mod[<[H*W]>]> >= <[H*W].sub[<[Height]>]>:
            - run CheckNewBlock def:<[NPC]>|<[CurrentLocation].add[<[Right]>]>|<[InitialLocation].add[<[Back]>]>
#If there is a new block revealed on top side - check it
        - if <[SavedLoopIndex].mod[<[Height]>]> == 1 || <[Height]> == 1:
            - run CheckNewBlock def:<[NPC]>|<[CurrentLocation].above>|<[InitialLocation].add[<[Back]>]>
#If there is a new block revealed on Bottom side - check it
        - if <[SavedLoopIndex].mod[<[Height]>]> == 0:
            - run CheckNewBlock def:<[NPC]>|<[CurrentLocation].below>|<[InitialLocation].add[<[Back]>]>

#Checks if current location is not supposed to be mined CIA BLT KEICIA LOOP INDEXA
        - foreach <[LocationsNotToMine]> as:Location:
            - if <[Location]> == <[CurrentLocation]>:
                - define InvalidBlockCounter:++
                - define LocationsNotToMine <[LocationsNotToMine]>:<-:<[Location]>
                - flag <[NPC]> StopMining:1
                - foreach stop
#Mine current block
        - if !<[NPC].has_flag[StopMining]>:
            - ~run MiningSubscriptEdit def:<[NPC]>|<[CurrentLocation]>|<[Direction]>
            - if !<[NPC].has_flag[StopMining]>:
                - define InvalidBlockCounter:0
            - else:
                - define InvalidBlockCounter:++

#Find next block to mine
        - if <[SavedLoopIndex].mod[<[H*W]>]> == 0:
            - define CurrentLocation <[CurrentLocation].add[<[NewDepthVector]>]>
        - else if <[SavedLoopIndex].mod[<[Height]>]> == 0:
            - define CurrentLocation <[CurrentLocation].add[<[NewVerticalLineVector]>]>
        - else:
            - define CurrentLocation <[CurrentLocation].below>

CheckNewBlock:
    type: task
    script:
    - define NPC <[1]>
    - define Location <[2]>
    - define InitialLocation <[3]>
    - if <[Location].material.name> == air || <[Location].material.name> == cave_air:
        - ~run BlockConnectionCheck def:<[NPC]>|<[Location]>|<list_single[<[NPC].location>|<[InitialLocation]>]>
    - else if <[Location].is_liquid>:
        - flag <[NPC]> StopMining:1
        - narrate StopMiningLiquid



#NPC moves towards a single target block and simulates mining it, while receiving drops to its inventory
MiningSubScriptEdit:
    type: task
    script:
        - define NPC <[1]>
        - define CurrentBlockMined <[2]>
        - define Direction <[3]>
        - define DistanceOfMining 3.5

        - if <[NPC].location.distance[<[CurrentBlockMined]>]> > <[DistanceOfMining]>:
#Should change this to a long-walk
            - ~walk <[CurrentBlockMined].sub[<[Direction]>]> <[NPC]> auto_range
        - if <[NPC].location.distance[<[CurrentBlockMined]>]> <= <[DistanceOfMining]>:
            - if !<[CurrentBlockMined].material.is_transparent>:
#{                - wait 0.02
                - animate <[NPC]> ARM_SWING
                - blockcrack <[CurrentBlockMined]> progress:<util.random.int[4].to[7]>
#{                - wait 0.25s
                - animate <[NPC]> ARM_SWING
                - give <[CurrentBlockMined].drops.get[1]> to:<[NPC].inventory>
                - modifyblock <[CurrentBlockMined]> air
                - blockcrack <[CurrentBlockMined]> progress:0
            - else:
                - narrate "Block I'm trying to mine is transparent :( My current location is - <[NPC].location.round.simple>"
        - else:
                - narrate "Can't reach target block"
                - flag <[NPC]> StopMining:1