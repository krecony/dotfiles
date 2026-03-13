{
  outputs =
    inputs@{
      git-hooks,
      nixpkgs,
      self,
      ...
    }:
    let
      lib = import ./lib { inherit inputs; };
    in
    {
      formatter = lib.custom.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      checks = lib.custom.forAllSystems (
        system:
        import ./checks.nix {
          inherit
            system
            self
            git-hooks
            lib
            ;
        }
      );

      devShells = lib.custom.forAllSystems (
        system:
        import ./devshell.nix {
          inherit system nixpkgs self;
        }
      );

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
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    #https://github.com/hyprwm/Hyprland/issues/5891
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    xdg-portal-hyprland.url = "github:hyprwm/xdg-desktop-portal-hyprland";
    hyprcontrib.url = "github:hyprwm/contrib";
    hyprlock.url = "github:hyprwm/hyprlock";
  };
}
