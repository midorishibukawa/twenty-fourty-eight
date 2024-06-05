open Batteries

module IntSet = Set.Make(Int)
module IntMap = Map.Make(Int)


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

module Game(Params : GameParams) : Game = struct
    type direction = Up | Down | Left | Right
    type cell = { value : int ; position : int } 
    type t = cell list

    (** initialises the Random module according to the
        passed Params *)
    let () = 
        Option.map Random.init Params.seed 
        |? Random.self_init ()

    let cell_qty = Params.size * Params.size

    (** empty game structure, with both 
        value and position lists empty *)
    let empty_game = []

    (** set of all possible positions a cell can have *)
    let all_pos_set = 0 --^ cell_qty |> IntSet.of_enum

    (** generates a new cell with a value
        between 0 and 1 on any random empty space *)
    let generate_cell game =
        let empty_pos =
            game
            |> List.map (fun { position ; _ } -> position)
            |> List.fold (flip IntSet.remove) all_pos_set
            |> IntSet.to_array in
        let position =
            empty_pos
            |> Array.length
            |> Random.int
            |> Array.get empty_pos in 
        let value = if Random.int 16 = 0 then 1 else 0 in
        { value ; position }::game

    (** creates a new game with a single random cell *)
    let new_game () = generate_cell empty_game

    (** TODO *)
    let move _dir game = game
end
