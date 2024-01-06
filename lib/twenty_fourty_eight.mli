open Types

module Templates = Templates 

val new_game : int -> game

val move : direction -> game -> game 

val handle_message : string -> string

val string_of_game : game -> string

val game_of_string : string -> game
