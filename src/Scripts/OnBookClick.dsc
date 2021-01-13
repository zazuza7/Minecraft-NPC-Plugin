OnBookClick:
    type: world
    events:
        on player clicks block with:written_book:
            - if <context.item.book_title> == MinionControl:
                - if <player.item_in_offhand.material.name> != anythin:
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
                                    #NPC has to be able to jump on top of chest
                                    - ~run LongWalk def:<[NPC]>|<[NPC].flag[ChestLocation].as_location.above>
                                    - if <[NPC].location.distance[<[NPC].flag[ChestLocation].as_location>]> > 3.5:
                                        - narrate "Can't reach my linked chest :( My current location is - <[NPC].location.round.simple>"
                                        - stop
                                    - ~run Collect&Deposit&Clear def:<[NPC]>
                                #IF NPC has an iron or diamond pickaxe in its first inventory slot
                                - else if <[NPC].inventory.slot[1].material.name> == iron_pickaxe || <[NPC].inventory.slot[1].material.name> == diamond_pickaxe:
                                    #Starts mining target block if not already mining
                                    - if <[NPC].has_flag[StopMining]>:
                                        - narrate "Starting mining"
                                        - run TopFunction def:<player.flag[Selected].as_npc>|<player.cursor_on>|<player.eye_location.precise_impact_normal.rotate_around_y[-1.5708].rotate_around_y[-1.5708].round_to_precision[1]>
                                    #Stops mining if already mining
                                    - else:
                                        - flag <[NPC]> StopMining:1
                                        - narrate "Stopping mining"
                                - else:
                                    - narrate "I lack tools. Please put an iron or diamond pickaxe into my first slot."
                        - else:
                            - narrate "No selected NPCs found"
                    #On left click
                    - else if <context.click_type>  == LEFT_CLICK_AIR || <context.click_type>  == LEFT_CLICK_BLOCK:
                        #Selects a NPC if aimed at one
                        - if <player.target.has_flag[Role]>:
                            - if <player.target> == <player.flag[Selected].as_entity>:
                                - narrate "This NPC was already selected"
                            - else:
                                - narrate "NPC selected successfully"
                            - flag <player> Selected:<player.target>
                        #Else Spawns a NPC and sets its parameters
                        - else:
                            - create player Minion <player.location>
                            - flag <player.target> Role:Undefined
                            - flag <player.target> Owner:<player>
                            - flag <player.target> StopMining:1
                            - flag <player> Selected:<player.target>
                            - adjust <player.target> Owner:<player>
                            #if set to true, the NPC will teleport to the location its moving towards if it cannot reach it.
                            - adjust <player.target> Teleport_on_Stuck:false
                            - vulnerable npc:<player.target>
                            - health <player.target> state:true
                            #NPC health is configurable in denizen/MinionConfig.yml
                            - adjust <player.target> max_health:20
                            - adjust <player.target> health:20
                            - adjust <player.target> skin:Slave
                            - narrate "NPC succesfully spawned"
