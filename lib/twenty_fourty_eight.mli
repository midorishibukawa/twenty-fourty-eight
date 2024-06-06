(** 2048 in OCaml *)

module type Game = sig
    (** Defines all possible movement directions. *)
    type direction = Up | Down | Left | Right

    (** Defines all possible game states.
        The player can keep playing after winning,
        and the state will be kept as `Won`. *)
    type state = Won | Over | Playing

    (** Represents a game cell with a value and an index position. *)
    type cell = { value : int ; position : int } 

    (** Represents the actual game state, which is a list of all cells. *)
    type t = cell list

    (** Creates a new game with a single random cell. *)
    val new_game : unit -> t
    
    (** Moves all cells into the given direction,generates a new cell,
        and returns a tuple of the new cells and the game state. *)
    val move : direction -> t -> t * state
end

module type GameParams = sig
    (** Defines the size of the game board. *)
    val size : int

    (** Defines the seed for the `Random.init` call. 
        If `None`, will call `Random.self_init` instead. *)
    val seed : int option
end

module Game : GameParams -> Game
