module D = Dream
module S = Static
module T = Templates

let () =
    let handle_htmx ~req ~f ~no_htmx body =
        f @@
        match D.header req "HX-Request" with
        | None   -> no_htmx body
        | Some _ -> body in
    D.run ~port:8080 ~interface:"0.0.0.0"
    @@ D.logger 
    @@ D.router [
        D.get "/static/**" 
            @@ D.static 
            ~loader:(fun _root path _req -> 
                match Static.read path with
                | None -> Dream.empty `Not_Found 
                | Some asset -> D.respond asset)
            "";

        D.get "/" (fun req -> 
            handle_htmx 
                ~req
                ~f:D.html
                ~no_htmx:(fun x -> Dream_html.(to_string @@ T.page ~title:"midori's devlog" @@ HTML.main [] [txt ~raw:true "%s" x])) 
            @@ Dream_html.to_string @@ T.article "");

    ]
