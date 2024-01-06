const socket = new WebSocket("ws://localhost:8080/game")

let game = "";

socket.addEventListener("open", () => socket.send("init"))
socket.addEventListener("message", ({ data }) => { game = data; console.log(data) })

document.addEventListener("keydown", 
    e => {
        if (["h", "j", "k", "l", "x"].includes(e.key)) {
            socket.send(e.key + "." + game)
        }
    })
    
