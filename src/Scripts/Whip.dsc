OnBookClick:
    type: world
    events:
        on player clicks block with:written_book:
            - if <context.item.book_title> == MinionControl:
                - determine passively cancelled
                - ratelimit <player> 1s
#On Right Click
                - if <context.click_type>  == RIGHT_CLICK_AIR || <context.click_type>  == RIGHT_CLICK_BLOCK:
#If aimed at NPC, opens its inventory
                    - if <player.target.has_flag[role]||null> != null:
                        - inventory open d:<player.target.inventory>
#If there is a NPC selected
                    - else if <player.flag[Selected].as_npc||null> != null:
                        - define NPC <player.flag[Selected].as_npc>
                        - if <player.location.distance[<[NPC].location>]> <= 1000:
#If aimed at chest, links it with currently selected NPC
                            - if <player.cursor_on.has_inventory> || <player.cursor_on.material.name> == ender_chest:
                                - flag <[NPC]> ChestLocation:<player.cursor_on>
                                - narrate "Chest Linked succesfully"
# NPC has to be able to jump on top of chest
#I could try changing it to .below?
                                - ~run LongWalk def:<[NPC]>|<[NPC].flag[ChestLocation].as_location.above>
                                - if <[NPC].location.distance[<[NPC].flag[ChestLocation].as_location>]> > 3.5:
                                    - narrate "Can't reach my linked chest :( My current location is - <[NPC].location.round.simple>"
                                    - stop
                                - ~run Collect&Deposit&Clear def:<[NPC]>
# If NPC is miner type and player is aiming at a normal block - starts mining
                            - else if <[NPC].inventory.slot[1].material.name> == iron_pickaxe || <[NPC].inventory.slot[1].material.name> == diamond_pickaxe:
#{                                - run MiningTask def:<[NPC]>
                                - run TopFunction def:<player.flag[Selected].as_npc>|<player.cursor_on>|<player.eye_location.precise_impact_normal.rotate_around_y[-1.5708].rotate_around_y[-1.5708].round_to_precision[1]>
                            - else:
                                - narrate "I lack purpose. Please put a tool in my first slot."
                    - else:
                        - narrate "No selected NPCs found nearby"
#On left click
                - else if <context.click_type>  == LEFT_CLICK_AIR || <context.click_type>  == LEFT_CLICK_BLOCK:
#Sselects a NPC if aimed at one
                    - if <player.target.has_flag[Role]>:
                        - flag <player> Selected:<player.target>
#Or Spawns a NPC and sets its parameters
                    - else:
                        - create player Minion <player.location>
                        - flag <player.target> Role:Undefined
                        - flag <player.target> Owner:<player>
                        - flag <player> Selected:<player.target>
                        - adjust <player.target> Owner:<player>
                        - adjust <player.target> Teleport_on_Stuck:false
                        - vulnerable npc:<player.target>
                        - health <player.target> state:true
                        - adjust <player.target> max_health:4
                        - adjust <player.target> skin:Slave
                        - narrate "NPC succesfully spawned ^'^"
