open Dream_html 
open HTML 
let page ~title:title_txt html_body =
    html [ lang "en" ] 
        [ head []
            [ title [] title_txt
            ; meta  [ charset "UTF-8" ] 
            ; meta  [ http_equiv `x_ua_compatible ; content "ID=edge" ]
            ; meta  [ name "viewport" ; content "width=device-width, initial-scale=1.0" ]
            ; link  [ rel "stylesheet" ; href "static/style.css" ]
            ; script    [ src "https://unpkg.com/htmx.org@1.9.2" 
                        ; integrity "sha384-L6OqL9pRWyyFU3+/bjdSri+iIphTN/bvYyM37tICVyOJkWZLpP2vGn6VUEXgzg6h"
                        ; crossorigin `anonymous ] ""]
        ; body [] 
            [ nav [] []
            ; html_body ] ] ;;

let article ctt =
    article []
        [ txt ~raw:true "%s" ctt ]

let p ctt = p [] [ txt "%s" ctt ]
