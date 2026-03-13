{ inputs, ... }:
builtins
// inputs.nixpkgs.lib.extend (
  _: prev: {
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
              entries = lib.readDir appsDir;

              desktopFiles = lib.pipe entries [
                lib.attrNames
                (lib.filter (name: lib.hasSuffix ".desktop" name))
              ];
            in
            if desktopFiles == [ ] then null else "${lib.last desktopFiles}"
          else
            null;

        ifNull = new: old: if old == null then new else old;

        genAttrsSame = names: value: lib.genAttrs names (_: value);

        associations = import ./associations.nix;
      };
  }

)
