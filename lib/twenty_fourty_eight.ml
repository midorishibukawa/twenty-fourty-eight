open Batteries

module IntSet = Set.Make(Int);;
module IntMap = Map.Make(Int);;


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
    type axis = Horizontal | Vertical
    type cell = { value : int ; position : int } 
    type t = cell list

    let () = Params.seed |> Option.map Random.init |? Random.self_init ();;
    let cell_qty = Params.size * Params.size;;

    (** empty game structure, with both value and position lists empty *)
    let empty_game = [];;

    (** set of all possible positions a cell can have *)
    let all_pos_set = 0 --^ cell_qty |> IntSet.of_enum;;

    (** map where all possible positions a cell can have are the keys,
        while their cartesian coordinates are the values *)
    let all_pos_map =
        let rec get_div_mod ?(y=0) x =
            if x < Params.size
            then x, y
            else get_div_mod ~y:(y + 1) (x - Params.size) in
        let i_to_xy acc i = IntMap.add i (get_div_mod i) acc in
        all_pos_set
        |> IntSet.elements
        |> List.fold i_to_xy IntMap.empty;;

    (** generates a new cell with a value between 0 and 1 
        on any random empty space *)
    let generate_cell game =
        let empty_pos =
            game
            |> List.map (fun { position ; _ } -> position)
            |> List.fold (flip IntSet.remove) all_pos_set
            |> IntSet.to_array in
        if Array.length empty_pos = 0
        then game
        else
        let position =
            empty_pos
            |> Array.length
            |> Random.int
            |> Array.get empty_pos in 
        let value = if Random.int 16 = 0 then 1 else 0 in
        { value ; position }::game
        |> List.sort (fun a b -> b.position - a.position);;

    (** creates a new game with a single random cell *)
    let new_game () = generate_cell empty_game;;

    (** move all cells into the given direction and generates a new cell,
        return the new game state
     *)
    let move dir game =
        let axis =
            match dir with
            | Left | Right -> Horizontal
            | Up   | Down  -> Vertical in
        let line_arr = Array.init Params.size (fun _ -> []) in
        let update_arr arr { value ; position } = 
            let select_i (x, y) = if axis = Vertical then x else y in
            let i = IntMap.find position all_pos_map |> select_i in
            arr.(i) <- value::arr.(i);
            arr in
        let dir_to_j' j =
            match dir with
            | Down | Right -> Params.size - j - 1
            | Up   | Left  -> j in
        let is_rev = dir = Down || dir = Right in
        let rec arr_to_cells ?(acc=[]) ?(j=0) i values =
            let j' = dir_to_j' j in
            let x, y = if axis = Vertical then i, j' else j', i in
            let position = y * Params.size + x in
            match values with
            | [] -> (if is_rev then Fun.id else List.rev) acc 
            | value_a::value_b::values' ->
                    let accd, values'' =
                        if value_a = value_b
                        then 1, values'
                        else 0, value_b::values' in
                    let acc = { value = value_a + accd ; position }::acc in
                    let j = j + 1 in
                    arr_to_cells ~acc ~j i values''
            | value::values'' -> 
                    let acc = { value ; position }::acc in
                    let j = j + 1 in
                    arr_to_cells ~acc ~j i values''
            in
        game
        |> List.fold update_arr line_arr
        |> Array.map (if is_rev then List.rev else Fun.id)
        |> Array.mapi arr_to_cells
        |> Array.to_list
        |> List.flatten
        |> generate_cell;;
end
