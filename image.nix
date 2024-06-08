{ pkgs ? import <nixpkgs> { } }:

pkgs.dockerTools.buildLayeredImage {
    name = "ml-dev";
    contents = [ ./result/bin ];
    config.Cmd = [ "/twenty_fourty_eight" ];
}
