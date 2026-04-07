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

    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-mineral = {
      url = "github:cynicsketch/nix-mineral";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim = {
      url = "github:krecony/nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:KreconyMakaron/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    polymc = {
      url = "github:PolyMC/PolyMC";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # doesn't use nixpkgs
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    #https://github.com/hyprwm/Hyprland/issues/5891
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xdg-portal-hyprland = {
      url = "github:hyprwm/xdg-desktop-portal-hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprcontrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
