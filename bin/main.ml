open Batteries
open Twenty_fourty_eight

module Params = struct
    let size = 4
    let seed = None
end

module Game = Game(Params);;
module IntMap = Map.Make(Int);;

let get_char () =
    let termio = Unix.tcgetattr Unix.stdin in
    let () =
        Unix.tcsetattr Unix.stdin Unix.TCSADRAIN
            { termio with Unix.c_icanon = false } in
    let res = input_char stdin in
    Unix.tcsetattr Unix.stdin Unix.TCSADRAIN termio;
    res;;

let rec main ?(game = Game.new_game ()) () =
    let game_str =
        let enum = 0 -- (Params.size * Params.size - 1) in
        let map = List.fold_left2 (fun acc v p -> IntMap.add p v acc) IntMap.empty game.values game.positions in
        let to_str str i =
            let s = IntMap.find_opt i map |> Option.map string_of_int |? " " in
            let br = if (i + 1) mod Params.size = 0 then "\n\t|\t" else "" in 
            Printf.sprintf "%s%s\t|\t%s" str s br in
        Enum.fold to_str "\n\n\n\n\n\n\t|\t" enum
        in
    IO.write_string stdout (game_str ^ "\n");
    IO.flush_all ();
    let open Game in
    match get_char () with
    | 'w' -> main ~game:(move Up game) () 
    | 'a' -> main ~game:(move Left game) ()
    | 's' -> main ~game:(move Down game) ()
    | 'd' -> main ~game:(move Right game) ()
    | ';' -> ()
    | _ -> main ~game ();;

main ()
