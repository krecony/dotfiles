{ inputs, ... }:
builtins // inputs.nixpkgs.lib.extend (
  final: prev: {
    custom =
      let
        lib = prev;
      in
      {
        mkBoolOption =
          desc: bool:
          lib.mkOption {
            default = bool;
            example = !bool;
            description = desc;
            type = lib.types.bool;
          };

        forAllSystems = lib.genAttrs [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-darwin"
          "x86_64-linux"
        ];

        getDesktopFile =
          pkg:
          let
            appsDir = "${pkg}/share/applications";
          in
          if lib.pathExists appsDir then
            let
              entries = builtins.readDir appsDir;

              desktopFiles = lib.pipe entries [
                builtins.attrNames
                (lib.filter (name: lib.hasSuffix ".desktop" name))
              ];
            in
            if desktopFiles == [ ] then null else "${lib.last desktopFiles}"
          else
            null;

        ifNull = new: old: if old == null then new else old;

        genAttrsSame = names: value: lib.genAttrs names (name: value);

        associations = import ./associations.nix;
      };
  }

)
