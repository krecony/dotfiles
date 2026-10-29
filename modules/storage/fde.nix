{ config, lib, ... }:
let
  cfg = config.storage;
  grubModules = [
    "part_gpt"
    "part_msdos"
    "fat"
    "btrfs"
    "cryptodisk"
    "luks"
    "pbkdf2"
    "gcry_sha256"
    "gcry_sha512"
    "normal"
    "configfile"
    "linux"
    "efi_gop"
    "efi_uga"
    "gfxterm"
    "gfxterm_background"
    "gettext"
  ];
in
{
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf cfg.fde.tpm2.enable {
        boot.initrd.systemd.tpm2.enable = true;
      })
      (lib.mkIf cfg.fde.encryptBoot {
        boot.loader = {
          grub = {
            enable = lib.mkForce true;
            device = lib.mkForce "nodev";
            efiSupport = lib.mkForce true;
            enableCryptodisk = lib.mkForce true;
            extraGrubInstallArgs = lib.mkForce [ "--modules=${lib.concatStringsSep " " grubModules}" ];
          };
          systemd-boot.enable = lib.mkForce false;
        };
      })
    ]
  );
}
