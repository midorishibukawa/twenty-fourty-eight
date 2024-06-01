open Batteries

module IntSet = Set.Make(Int);;
module IntMap = Map.Make(Int);;

module type GameParams = sig
    val size : int
    val seed : int option
end

module type Game = sig
    type direction = Up | Down | Left | Right
    type axis = Horizontal | Vertical
    type t = { values : int list ; positions : int list };;

    val new_game : unit -> t
    val move : direction -> t -> t
end

module Game(Params : GameParams) : Game = struct
    type direction = Up | Down | Left | Right
    type axis = Horizontal | Vertical
    type t = { values : int list ; positions : int list };;

    let () = Params.seed |> Option.map Random.init |? Random.self_init ();;
    let cell_qty = Params.size * Params.size;;

    (** empty game structure, with both value and position lists empty *)
    let empty_game = { values = [] ; positions = [] };;

    (** set of all possible positions a cell can have *)
    let all_pos_set = Enum.init cell_qty Fun.id |> IntSet.of_enum;;

    (** map where all possible positions a cell can have are the keys,
        while their cartesian coordinates are the values *)
    let all_pos_map =
        let rec get_div_mod ?(y=0) x =
            if x < Params.size
            then x, y
            else get_div_mod ~y:(y + 1) (x - Params.size) in
        let i_to_xy acc i = IntMap.add i (get_div_mod i) acc in
        List.fold i_to_xy IntMap.empty (IntSet.elements all_pos_set);;


    (** converts directions into axis *)
    let dir_to_axis dir =
        match dir with
        | Left | Right -> Horizontal
        | Up   | Down  -> Vertical;;

    (** converts a tuple of list into a list of tuples *)
    let tup2_to_list (la, lb) = List.map2 (fun a b -> a, b) la lb;;

    (** convverts a tuple of values and positions into a game structur *)
    let tup_to_game { values ; positions } (value, position) =
        { values = value::values
        ; positions = position::positions
        };;
    

    (** generates a new cell with a value between 0 and 1 on any random empty space *)
    let generate_cell game =
        let { values ; positions } = game in
        let empty_pos = 
            List.fold (flip IntSet.remove) all_pos_set positions 
            |> IntSet.to_array in
        if Array.length empty_pos = 0
        then game
        else
        let new_pos =
            empty_pos
            |> Array.length
            |> Random.int
            |> Array.get empty_pos in 
        let new_val = if Random.int 16 = 1 then 1 else 0 in
        (new_val::values, new_pos::positions)
        |> tup2_to_list
        |> List.sort (fun (_, pos_a) (_, pos_b) -> pos_a - pos_b)
        |> List.fold tup_to_game empty_game;;

    (** creates a new game with a single random cell *)
    let new_game () = generate_cell empty_game;;

    (** move all cells into the given direction and generates a new cell,
        return the new game state
     *)
    let move dir game =
        let { values ; positions } = game in
        let axis = dir_to_axis dir in
        let map_pos value pos = 
            let select_i (x, y) = if axis = Vertical then x else y in
            value, IntMap.find pos all_pos_map |> select_i in
        let line_arr = Array.init Params.size (fun _ -> []) in
        let update_arr arr (value, i) = 
            arr.(i) <- value::arr.(i);
            arr in
        let dir_to_j' j =
            match dir with
            | Down | Right -> Params.size - j - 1
            | Up   | Left  -> j in
        let is_rev = dir = Down || dir = Right in
        let rec arr_to_tuples ?(acc=[]) ?(j=0) i values =
            let j' = dir_to_j' j in
            let x, y = if axis = Vertical then i, j' else j', i in
            let pos = y * Params.size + x in
            match values with
            | [] -> (if is_rev then Fun.id else List.rev) acc 
            | value_a::value_b::values' ->
                    let accd, values'' =
                        if value_a = value_b
                        then 1, values'
                        else 0, value_b::values' in
                    let acc = (value_a + accd, pos)::acc in
                    arr_to_tuples ~acc ~j:(j + 1) i values''
            | value_a::values'' -> 
                    arr_to_tuples ~acc:((value_a, pos)::acc) ~j:(j + 1) i values''
            in
        List.map2 map_pos values positions
        |> List.fold update_arr line_arr
        |> Array.map (if is_rev then List.rev else Fun.id)
        |> Array.mapi arr_to_tuples
        |> Array.to_list
        |> List.flatten
        |> List.fold tup_to_game empty_game
        |> generate_cell;;
end
