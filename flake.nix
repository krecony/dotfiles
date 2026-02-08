{
  outputs =
    inputs@{
      nixpkgs,
      self,
      ...
    }:
    let
      lib = import ./lib { inherit inputs; };
    in
    {
      formatter = lib.custom.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      nixosConfigurations = import ./hosts { inherit lib self; };
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
    sops-nix.url = "github:Mic92/sops-nix";

    #https://github.com/hyprwm/Hyprland/issues/5891
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    xdg-portal-hyprland.url = "github:hyprwm/xdg-desktop-portal-hyprland";
    hyprcontrib.url = "github:hyprwm/contrib";
    hyprlock.url = "github:hyprwm/hyprlock";
  };
}
