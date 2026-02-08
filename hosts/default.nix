{
  self,
  lib,
  ...
}:
let
  inherit (self) inputs;

  nixosImports = [
    inputs.disko.nixosModules.disko
    inputs.stylix.nixosModules.stylix
    inputs.musnix.nixosModules.musnix
    inputs.nix-mineral.nixosModules.nix-mineral
    inputs.home-manager.nixosModules.home-manager
  ];

  hmImports = [ inputs.ags.homeManagerModules.ags ];

  hmModule =
    { config, ... }:
    {
      home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;
        extraSpecialArgs = {
          inherit inputs self;
          nixosConfig = config;
        };
        users = {
          ${config.core.user} = {
            home = {
              username = config.core.user;
              homeDirectory = "/home/${config.core.user}";
              stateVersion = "22.11";
            };
            imports = hmImports;
          };
        };
      };
    };

  hmAliasModule =
    { lib, config, ... }:
    {
      imports = [
        (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" config.core.user ])
      ];
    };

  mkHost =
    name: system:
    lib.nixosSystem rec {
      inherit system;

      modules = [
        {
          networking.hostName = name;
          nixpkgs.hostPlatform = system;
        }

        ./${name}

        hmModule
        hmAliasModule

        ../modules
      ]
      ++ nixosImports;

      specialArgs = {
        inherit inputs system lib;
      };
    };
in
{
  # huawei Laptop
  zephyr = mkHost "zephyr" "x86_64-linux";
}
