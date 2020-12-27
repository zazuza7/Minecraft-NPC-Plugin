Book_Script_Name:

  type: book

  # The 'custom name' can be anything you wish.
  # | All book scripts MUST have this key!
  title: MinionControl

  # The 'custom name' can be anything you wish.
  # | All book scripts MUST have this key!
  author: ScriptWriterzazuza

  # Defaults to true. Set to false to spawn a 'book and quill' instead of a 'written book'.
  # | Some book scripts might have this key!
  signed: true

  # Each -line in the text section represents an entire page.
  # To create a newline, use the tag <n>. To create a paragraph, use <p>.
  # | All book scripts MUST have this key!
  text:
    - Hey there! <n>Welcome to Minion plugin's guide! <n>You can check the contents of the guide in page 2.
    - 1 Introduction <n>2 <&4><&l>Contents <&r><&0><n>3 Spawning a minion <n>5 Setting up and controlling minions.
    - If you are the server owner, a lot of our plugin's features can be customized in /plugins/Denizen/minion_plugin_config.yml file.
    - To start spawning minions, you'll need to get your hands on a <&0><&l>Book and Quill <&r><&0>item. To craft it you'll need to use a <&l>Book<&r><&0>, <&l>Ink Sac <&r><&0>and a <&l>Feather<&r><&0>. After getting the item you'll need to open it, write any bit of text inside and sign the book, naming it <&l>MinionControl<&r><&0>.
    - Doing so will allow that book to spawn and interact with minions.
    - After going through steps mentioned in previous pages, you can spawn NPCs by left clicking with the <&0><&l>MinionControl<&r><&0> item.
    - A spawned minion will automatically get selected - all other actions performed by this item will only affect the currently selected minion. You can also select a minion by left clicking while aiming at it.
    - Right-clicking with the MinionControl item while aiming at a container block (a chest, barrel, etc.) will link it to the currently selected minion - it will deposit its items and take the resources from the linked block.
    - Right-clicking with the MinionControl item while aiming at a non-container block (dirt, gold ore, etc.) will command the currently selected minion to start mining there.
    - If the currently selected minion is already mining, Right-clicking with the MinionControl item will command the minion to stop mining and return to its linked chest.

