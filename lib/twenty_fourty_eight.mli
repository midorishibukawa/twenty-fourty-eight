module type Game = sig
    type direction = Up | Down | Left | Right
    type cell = { value : int ; position : int } 
    type t = cell list
    val new_game : unit -> t
    val move : direction -> t -> t
end

module type GameParams = sig
    (** defines the size of the game board *)
    val size : int

    (** defines the seed for the `Random.init` call. 
        if `None`, will call `Random.self_init` instead. *)
    val seed : int option
end

module Game : GameParams -> Game
