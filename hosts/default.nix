{
  self,
  lib,
  ...
}:
let
  inherit (self) inputs;

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

        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko

        hmModule
        hmAliasModule

        ../modules
      ];

      specialArgs = {
        inherit inputs system lib;
      };
    };
in
{
  # huawei laptop
  zephyr = mkHost "zephyr" "x86_64-linux";
  # raspberry pi 3b+
  hermes = mkHost "hermes" "aarch64-linux";
}
