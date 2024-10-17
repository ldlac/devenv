{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, devenv, systems, ... }@inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      devShells = forEachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [
              {
                # https://devenv.sh/reference/options/
                dotenv.disableHint = true;

                packages = [ 
                  pkgs.nodejs_18
                  pkgs.stdenv
                ];

                enterShell = ''
                  export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib";
                '';

                languages = {
                  python = {
                    enable = true;
                    package = pkgs.python311;
                    poetry = {
                      enable = true;
                    };
                  };
                };
              }
            ];
          };
        });
    };
}
