RULES:

THE DEAL
The deck is divided evenly, with each player receiving 26 cards, dealt one at a time, face down. Anyone may deal first. Each player places his stack of cards face down, in front of him.

THE PLAY
Each player turns up a card at the same time and the player with the higher card takes both cards and puts them, face down, on the bottom of his stack.

If the cards are the same rank, it is War. Each player turns up one card face down and one card face up. The player with the higher cards takes both piles (six cards). If the turned-up cards are again the same rank, each player places another card face down and turns another card face up. The player with the higher card takes all 10 cards, and so on.

HOW TO KEEP SCORE
The game ends when one player has won all the cards.

Objects: Responsibilities, Questions, Commands, Information
card
  R: displaying rank & suit, hiding rank & suit (face up, face down)
  Q: what is your rank & suit?
  C: give rank & suit, display face_up, display face_down
  I: rank, suit, face_up or face_down ?
deck
  R: managing a collection of cards that do not belong to the player
  Q: what cards are available? how many cards? what order?
  C: shuffle, deal, add card(s), remove cards(s)
  I: cards it has, the order of the cards, top card, number of cards, if empty
player
  R: manages a collection of cards it owns
  Q: what cards do you have? what is the top card? are you out of cards?
  C: play round, play war round, add_winnings
  I: cards it has, the order of the cards--no wait, a player doesn't know that in a real game!--, top card, if empty
game
  R: manages the movement between two players
  Q: who won the round? who won the game?
  C: start game, declare winner of round, declare winner of game
  I: who is playing, who won, when the game is over and who the winner is
