{
  lib,
  stdenv,
  fetchpatch,
  fetchurl,
  meson,
  ninja,
  pkg-config,
  SDL2,
  alsa-lib,
  bullet,
  check,
  curl,
  dbus,
  doxygen,
  expat,
  fontconfig,
  freetype,
  fribidi,
  ghostscript,
  giflib,
  glib,
  gst_all_1,
  gtk3,
  harfbuzz,
  hicolor-icon-theme,
  ibus,
  jbig2dec,
  libGL,
  libdrm,
  libgbm,
  libinput,
  libjpeg,
  libpng,
  libpulseaudio,
  libraw,
  librsvg,
  libsndfile,
  libspectre,
  libtiff,
  libwebp,
  libxkbcommon,
  lua,
  lz4,
  mesa-gl-headers,
  mint-x-icons,
  openjpeg,
  openssl,
  poppler,
  systemd,
  udev,
  util-linux,
  wayland,
  wayland-protocols,
  wayland-scanner,
  writeText,
  xorg,
  zlib,
  directoryListingUpdater,
}:

stdenv.mkDerivation rec {
  pname = "efl";
  version = "1.28.1";

  src = fetchurl {
    url = "http://download.enlightenment.org/rel/libs/${pname}/${pname}-${version}.tar.xz";
    sha256 = "sha256-hM9hRfnMgr//aQAFviQ5LI88UvjgD/BNjuo3FCnAlCQ=";
  };

  nativeBuildInputs = [
    meson
    ninja
    gtk3
    pkg-config
    check
    wayland-scanner
  ];

  buildInputs = [
    fontconfig
    freetype
    giflib
    glib
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gstreamer
    ibus
    libGL
    libpng
    libpulseaudio
    libsndfile
    libtiff
    lz4
    mesa-gl-headers
    openssl
    systemd
    udev
    wayland-protocols
    xorg.libX11
    xorg.libXcursor
    xorg.xorgproto
    zlib
    # still missing parent icon themes: RAVE-X, Faenza
  ];

  propagatedBuildInputs = [
    SDL2
    alsa-lib
    bullet
    curl
    dbus
    dbus
    doxygen
    expat
    fribidi
    ghostscript
    harfbuzz
    hicolor-icon-theme # for the icon theme
    jbig2dec
    libdrm
    libgbm
    libinput
    libjpeg
    libraw
    librsvg
    libspectre
    libwebp
    libxkbcommon
    lua
    mint-x-icons # Mint-X is a parent icon theme of Enlightenment-X
    openjpeg
    poppler
    util-linux
    wayland
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libxcb
  ];

  dontDropIconThemeCache = true;

  mesonFlags = [
    "--buildtype=release"
    "-D build-tests=false" # disable build tests, which are not working
    "-D ecore-imf-loaders-disabler=ibus,scim" # ibus is disabled by default, scim is not available in nixpkgs
    "-D embedded-lz4=false"
    "-D fb=true"
    "-D network-backend=connman"
    "-D sdl=true"
    "-D elua=true"
    "-D bindings=lua,cxx"
    # for wayland client support
    "-D wl=true"
    "-D drm=true"
  ];

  patches = [
    ./efl-elua.patch
    (fetchpatch {
      name = "efl-evas-gcc15.patch";
      url = "https://git.enlightenment.org/enlightenment/efl/commit/0fcaf460c4a33eb54a51b9d8cb38321603019529.patch";
      hash = "sha256-MZc9biAdl4OlBIbWxKDN9lyj60ux2/+TKRGOGsICs3c=";
    })
    (fetchpatch {
      name = "efl-eldbus-gcc15.patch";
      url = "https://git.enlightenment.org/enlightenment/efl/commit/9948f15ebdfae6b39f88ab58623e28c2b9320e0b.patch";
      hash = "sha256-3ZNB7n+jR6obUHRkN/KMi7dt5bDa8Ny2UDkgRpiSUH0=";
    })
    (fetchpatch {
      name = "efl-ecore-file-gcc15.patch";
      url = "https://git.enlightenment.org/enlightenment/efl/commit/6e63309b26c25cc1c09228b9d06fd47bd6b13884.patch";
      hash = "sha256-E5zLMMjoFIjkVq0eTw13j0RchZYEb9TEYOEV/4CAS9k=";
    })
    (fetchpatch {
      name = "efl-eeze-gcc15.patch";
      url = "https://git.enlightenment.org/enlightenment/efl/commit/60217eff9672e55c67454df13a16236d106fc92f.patch";
      hash = "sha256-Ix8mpEqaaqNcD/VCC8NFzmJYH1IWyj7e0R1nyVt8Zow=";
    })
    (fetchpatch {
      name = "efl-edje-gcc15.patch";
      url = "https://git.enlightenment.org/enlightenment/efl/commit/628c40cce2de0a18818b40615d3351b0c9e9b889.patch";
      hash = "sha256-2An0zuJpmADRtqE3ljjrFI4raiIeoDUW9B0yKLWldsU=";
    })
    (fetchpatch {
      name = "efl-embryo-gcc15.patch";
      url = "https://git.enlightenment.org/enlightenment/efl/commit/fc4c5ec8afc3d1d145eff9807e5235ae6bfeea83.patch";
      hash = "sha256-6l4vKG2gbVqZWVdBccG9CBCxZPEnznnqQJ4VpKIyiXk=";
    })
  ];

  postPatch = ''
    patchShebangs src/lib/elementary/config_embed

    # fix destination of systemd unit and dbus service
    substituteInPlace systemd-services/meson.build --replace "sys_dep.get_pkgconfig_variable('systemduserunitdir')" "'$out/systemd/user'"
    substituteInPlace dbus-services/meson.build --replace "dep.get_pkgconfig_variable('session_bus_services_dir')" "'$out/share/dbus-1/services'"
  '';

  # bin/edje_cc creates $HOME/.run, which would break build of reverse dependencies.
  setupHook = writeText "setupHook.sh" ''
    export HOME="$TEMPDIR"
  '';

  preConfigure = ''
    # allow ecore_con to find libcurl.so, which is a runtime dependency (it is dlopened)
    export LD_LIBRARY_PATH="${curl.out}/lib''${LD_LIBRARY_PATH:+:}$LD_LIBRARY_PATH"

    source "$setupHook"
  '';

  postInstall = ''
    # fix use of $out variable
    substituteInPlace "$out/share/elua/core/util.lua" --replace '$out' "$out"
    rm "$out/share/elua/core/util.lua.orig"

    # add all module include dirs to the Cflags field in efl.pc
    modules=$(for i in "$out/include/"*/; do printf ' -I''${includedir}/'`basename $i`; done)
    substituteInPlace "$out/lib/pkgconfig/efl.pc" \
      --replace 'Cflags: -I''${includedir}/efl-1' \
                'Cflags: -I''${includedir}/eina-1/eina'"$modules"

    # build icon cache
    gtk-update-icon-cache "$out"/share/icons/Enlightenment-X
  '';

  postFixup = ''
    # Some libraries are linked at runtime by hand in code (they are dlopened)
    patchelf --add-needed ${curl.out}/lib/libcurl.so $out/lib/libecore_con.so
    patchelf --add-needed ${libpulseaudio}/lib/libpulse.so $out/lib/libecore_audio.so
    patchelf --add-needed ${libsndfile.out}/lib/libsndfile.so $out/lib/libecore_audio.so
  '';

  passthru.updateScript = directoryListingUpdater { };

  meta = {
    description = "Enlightenment foundation libraries";
    homepage = "https://enlightenment.org/";
    license = with lib.licenses; [
      bsd2
      lgpl2Only
      lib.licenses.zlib
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [
      matejc
      ftrvxmtrx
    ];
    teams = [ lib.teams.enlightenment ];
  };
}
