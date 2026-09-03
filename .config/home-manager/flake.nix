{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # ユーザー名を受け取って homeManagerConfiguration を返すヘルパー。
      mkHome = user: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home.nix
          {
            home.username = user;
            home.homeDirectory = "/home/${user}";
          }
        ];
      };

      # アカウントを追加したいときは、このリストに名前を足す
      users = [ "violet" "gray" "blue" "kijimad" ]; # kijimad は仕事用
    in {
      homeConfigurations = nixpkgs.lib.genAttrs users mkHome;
    };
}
