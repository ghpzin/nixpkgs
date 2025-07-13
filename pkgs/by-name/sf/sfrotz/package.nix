{
  fetchFromGitLab,
  freetype,
  libao,
  libjpeg,
  libmodplug,
  libpng,
  libsamplerate,
  libsndfile,
  libvorbis,
  pkg-config,
  SDL2,
  SDL2_mixer,
  lib,
  stdenv,
  zlib,
  which,
  fetchpatch,
}:

stdenv.mkDerivation rec {
  pname = "sfrotz";
  version = "2.55";

  src = fetchFromGitLab {
    domain = "gitlab.com";
    owner = "DavidGriffith";
    repo = "frotz";
    rev = version;
    hash = "sha256-Gsi6i1cXTONA9iZ39dPy1QH5trIg7P++/D/VVzexmpg=";
  };

  buildInputs = [
    freetype
    libao
    libjpeg
    libmodplug
    libpng
    libsamplerate
    libsndfile
    libvorbis
    SDL2
    SDL2_mixer
    zlib
  ];
  nativeBuildInputs = [
    pkg-config
    which
  ];
  # patches = [
  #   (fetchpatch {
  #     url = "https://gitlab.com/DavidGriffith/frotz/-/commit/dcb3f56be73aac5d16c9c2ca11aaa512cdedbae7.patch";
  #     hash = "sha256-U+Xs5LvSjiOludJL0SmIG4ufWKUO/HYRkf5XQ2HpIqc=";
  #   })
  # ];
  postPatch = ''
    # sed -i '459i$(error "$(shell $(PKGCONF) $(SDL_SOUND_PKGS) --libs)")' Makefile
    # sed -i 's/ifneq ($(NO_PKGCONF), yes)/ifndef foobar/' Makefile
    # sed -i '460i\\t$(error "$(SDL_SOUND_LDFLAGS)")' Makefile
    # sed -i '424i$(eval SDL_LDFLAGS += $(shell $(PKGCONF) $(SDL_PKGS) --libs))' Makefile
    # sed -i '425i$(eval SDL_SOUND_LDFLAGS = $(shell $(PKGCONF) $(SDL_SOUND_PKGS) --libs))' Makefile
    # sed -i '426i$(error "$(SDL_SOUND_LDFLAGS)")' Makefile
    # sed -i '458d' Makefile
    # sed -i '468i\\t$(SFROTZ_BIN): $(SFROTZ_LIBS)' Makefile
    # sed -i '462i\\t@echo "SDL_SOUND_LDFLAGS=$(SDL_SOUND_LDFLAGS))"' Makefile
    # sed -i '459i\\t$(eval SDL_SOUND_LDFLAGS = $(shell $(PKGCONF) $(SDL_SOUND_PKGS) --libs))' Makefile
    # SDL_SOUND_LDFLAGS="$(SDL_SOUND_LDFLAGS))"' Makefile
    sed -n '420,430p' Makefile
  '';
  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  buildPhase = ''
    export PKG_CONFIG_PATH="${SDL2_mixer.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
    echo "PKG_CONFIG_PATH set to: $PKG_CONFIG_PATH"
    make dumb sdl_nosound sdl
  '';
  installTargets = [ "install_sfrotz" ];

  meta = {
    description = "Interpreter for Infocom and other Z-Machine games (SDL interface)";
    mainProgram = "sfrotz";
    longDescription = ''
      Frotz is a Z-Machine interpreter. The Z-machine is a virtual machine
      designed by Infocom to run all of their text adventures. It went through
      multiple revisions during the lifetime of the company, and two further
      revisions (V7 and V8) were created by Graham Nelson after the company's
      demise. The specification is now quite well documented; this version of
      Frotz supports version 1.0.

      This version of Frotz fully supports all these versions of the Z-Machine
      including the graphical version 6. Graphics and sound are created through
      the use of the SDL libraries. AIFF sound effects and music in MOD and OGG
      formats are supported when packaged in Blorb container files or optionally
      from individual files.
    '';
    homepage = "https://davidgriffith.gitlab.io/frotz/";
    # changelog = "https://gitlab.com/DavidGriffith/frotz/-/raw/${version}/NEWS";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ddelabru ];
    platforms = lib.platforms.linux;
  };
}
