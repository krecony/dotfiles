{
  outputs =
    inputs@{ nixpkgs, ... }:
    let
      custom = import ./lib { inherit (nixpkgs) lib; };
    in
    {
      formatter = custom.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      homeManagerModules = {
        inherit (inputs.ags.homeManagerModules) ags;
      };

      nixosModules = {
        inherit (inputs.disko.nixosModules) disko;
        inherit (inputs.stylix.nixosModules) stylix;
        inherit (inputs.musnix.nixosModules) musnix;
        inherit (inputs.nix-mineral.nixosModules) nix-mineral;
        inherit (inputs.home-manager.nixosModules) home-manager;
      };

      nixosConfigurations = import ./hosts inputs;

      overlays = [
        (final: prev: {
          lib = prev.lib.extend (self: super: { inherit custom; });
        })
      ];
    };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    lmms-nixpkgs.url = "github:wizardlink/nixpkgs/lmms";
    musnix.url = "github:musnix/musnix";
    nix-mineral.url = "github:cynicsketch/nix-mineral";
    home-manager.url = "github:nix-community/home-manager";
    nixvim.url = "github:mikaelfangel/nixvim-config";
    stylix.url = "github:danth/stylix";
    ags.url = "github:KreconyMakaron/ags";
    polymc.url = "github:PolyMC/PolyMC";
    disko.url = "github:nix-community/disko";

    #https://github.com/hyprwm/Hyprland/issues/5891
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    xdg-portal-hyprland.url = "github:hyprwm/xdg-desktop-portal-hyprland";
    hyprcontrib.url = "github:hyprwm/contrib";
    hyprlock.url = "github:hyprwm/hyprlock";
  };
}
