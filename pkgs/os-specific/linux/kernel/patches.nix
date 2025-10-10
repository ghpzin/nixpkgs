{
  lib,
  fetchpatch,
  fetchurl,
}:

{
  ath_regd_optional = rec {
    name = "ath_regd_optional";
    patch = fetchpatch {
      name = name + ".patch";
      url = "https://github.com/openwrt/openwrt/raw/ed2015c38617ed6624471e77f27fbb0c58c8c660/package/kernel/mac80211/patches/ath/402-ath_regd_optional.patch";
      sha256 = "1ssDXSweHhF+pMZyd6kSrzeW60eb6MO6tlf0il17RC0=";
      postFetch = ''
        sed -i 's/CPTCFG_/CONFIG_/g' $out
        sed -i '/--- a\/local-symbols/,$d' $out
      '';
    };
  };

  bridge_stp_helper = {
    name = "bridge-stp-helper";
    patch = ./bridge-stp-helper.patch;
  };

  request_key_helper = {
    name = "request-key-helper";
    patch = ./request-key-helper.patch;
  };

  hardened =
    let
      mkPatch =
        kernelVersion:
        {
          version,
          sha256,
          patch,
        }:
        let
          src = patch;
        in
        {
          name = lib.removeSuffix ".patch" src.name;
          patch = fetchurl (lib.removeAttrs src [ "extra" ]);
          extra = src.extra;
          inherit version sha256;
        };
      patches = lib.importJSON ./hardened/patches.json;
    in
    lib.mapAttrs mkPatch patches;

  # Adapted for Linux 5.10 from:
  # https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=b3bee1e7c3f2b1b77182302c7b2131c804175870
  compile_boot_code_with_std_gnu11_5_10 = {
    name = "compile-boot-code-with-std-gnu11-5_10";
    patch = ./compile-boot-code-with-std-gnu11-5_10.patch;
  };

  # Adapted for Linux 5.15 from:
  # https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=b3bee1e7c3f2b1b77182302c7b2131c804175870
  compile_boot_code_with_std_gnu11_5_15 = {
    name = "compile-boot-code-with-std-gnu11-5_15";
    patch = ./compile-boot-code-with-std-gnu11-5_15.patch;
  };

  export-rt-sched-migrate = {
    name = "export-rt-sched-migrate";
    patch = ./export-rt-sched-migrate.patch;
  };
}
