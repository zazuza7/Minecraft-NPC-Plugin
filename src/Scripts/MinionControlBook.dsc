MinionControlBook:

  type: book

  title: MinionControl
  author: ScriptWriterzazuza

  # Defaults to true. Set to false to spawn a 'book and quill' instead of a 'written book'.
  signed: true

  # Each -line in the text section represents an entire page.
  # To create a newline, use the tag <n>. To create a paragraph, use <p>.
  text:
    - Hey there! <n>Welcome to Minion plugin's guide! <n>You can check the contents of the guide in page 2.
    - 1 Introduction <n>2 <&4><&l>Contents <&r><&0><n>3 Customization<n>4 Setting up <n>7 Spawning and controlling minions <n>12 Mining routine <n>15 Monsters
    - If you are the server owner, a lot of our plugin's features can be customized in /plugins/Denizen/MinionConfig.yml file.
    - To start spawning minions, you'll need to get your hands on a <&0><&l>Book and Quill <&r><&0>item. To craft it you'll need to use a <&l>Book<&r><&0>, <&l>Ink Sac <&r><&0>and a <&l>Feather<&r><&0>. After getting the item you'll need to open it, write any bit of text inside and sign the book, naming it <&l>MinionControl<&r><&0>.
    - Doing so will allow that book to spawn and interact with minions.
    #Page 6
    - Right clicking while holding MinionControl book in the off-hand slot will open this guide.
    - You can spawn NPCs by left clicking with the <&0><&l>MinionControl<&r><&0> book.
    - A spawned minion will automatically get selected - all other actions performed by this item will only affect the currently selected minion. You can also select a minion by left clicking while aiming at it.
    - Right-clicking with the MinionControl item while aiming at a container block (a chest, barrel, etc.) will link it to the currently selected minion - it will deposit its items and take the resources from the linked block.
    - Right-clicking with the MinionControl item while aiming at a non-container block (dirt, gold ore, etc.) will command the currently selected minion to start mining there.
    #Page 11
    - If the currently selected minion is already mining, Right-clicking with the MinionControl item will command the minion to stop mining and return to its linked chest.
    - The minion will mine tunnels of specified height and width while trying to avoid mining into new caves, water or lava.
    - After encountering an obstacle the minion deposits all of the items it has that are specified in "Items" list (which can be found in MinionConfig.yml) to its linked chest.
    - If a minion encounters a block specified in "Blocks_To_Prioritize" list (which can be found in MinionConfig.yml) - it will try to mine it if it is 1 block distance away from the minion's direct path.
    - Monsters are hostile to minions and will attack them on sight. This can be changed in MinionConfig.yml file.
    #Page 16
    - Minions are oblivious to being attacked and will not react to attacking monsters.
    - Minions do <&0><&l>not<&r><&0> drop their items on death.

