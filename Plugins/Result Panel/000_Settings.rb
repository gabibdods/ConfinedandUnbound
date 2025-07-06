module Settings

  # 1 - Show trainer's name.
  # 2 - Show trainer's icon.
  # 3 - Show both.
  PANELSTYLE = 3

  #File path (UI for Essentials v21+ or Pictures for Essentials v20.1-)
  FILEPATH = "Graphics/UI/Result Panel/"

  #Max rows of trainers' template
  TEMPLATEROWS = 6

  #The trainers' file name
  TEMPLATENAME = "Trainers_Vanilla"

  # RESULTPANEL8 or RESULTPANEL16 = {
  #   :Panel name (the same name you call on pbResultPanel) => {
  #     :Trainers => ["Trainer1", "Trainer2", "Trainer3" ...] the names of the trainers. Use "Player" to inform the player position. You can also use an integer value to use a name stored in a corresponding variable.
  #     :Icons => [Icon1, Icon2, Icon3 ...] the icon position of each trainer (you don't need to infom this if your panel style = 1).
  #   If your panel's size = 8, you must inform 8 trainers/icons on RESULTPANEL8 or 16 if the size is 16 on RESULTPANEL16.
  #     :RoundX => [...] On these you must inform the position on the panel for each trainer who passes to the next round.
  #   For example: Round2 => [1,4,6,7] means that the trainers on positions 1, 4, 6, and 7 on the panel are classified to the second round.
  #   Note that the number of classified participants in each round is half the previous round. Sized 16 panels have one more round than sized 8 ones.
  # You can see some examples below.

  RESULTPANEL8_SINGLE = {
    :Test => {
      :Trainers => ["Leaf", "Bianca", 12, "Brendan", "Roberto", "May", "Player", "Regis"],
      :Icons => [2, 18, 5, 3, 15, 4, 1, 19],
      :Round2 => [1,4,6,7],
      :Round3 => [1,7],
      :Round4 => [1]
    },

    #:YourPanelName => {
    #  :Trainers => ["Trainer1", "Trainer2", "Player", "Trainer4", "Trainer5", "Trainer6", "Trainer7", "Trainer8"],
    #  :Icons => [Icon1, Icon2, Icon3, Icon4, Icon5, Icon6, Icon7, Icon8],
    #  :Round2 => [2,3,5,8],
    #  :Round3 => [3,8],
    #  :Round4 => [3]
    #},

  }

  RESULTPANEL16_SINGLE = {
    :Test => {
      :Trainers => ["Paula", "Player", "Brendan", "Bianca", "Icaro", "Regis", "Gean", 12,
       "Rhenan", "May", "Everton", "Robson", "Leaf", "Roberto", "Kelvin", "Adam"],
      :Icons => [9, 1, 3, 18, 32, 19, 37, 5, 12, 4, 13, 33, 2, 15, 14, 29,],
      :Round2 => [2,3,6,7,9,12,13,15],
      :Round3 => [2,7,9,13],
      :Round4 => [2,13],
      :Round5 => [2]
    },

    #:YourPanelName => {
    #  :Trainers => ["Trainer1", "Trainer2", "Player", "Trainer4", "Trainer5", "Trainer6", "Trainer7", "Trainer8", ... , "Trainer16"],
    #  :Icons => [Icon1, Icon2, Icon3, Icon4, Icon5, Icon6, Icon7, Icon8, ... , Icon16],
    #  :Round2 => [2,3,5,8,10,11,13,16],
    #  :Round3 => [3,8,10,13],
    #  :Round4 => [3,10],
    #  :Round5 => [3]
    #},
  
  }
  
end