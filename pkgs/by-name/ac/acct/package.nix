{
  fetchurl,
  lib,
  stdenv,
  fetchpatch2,
}:

stdenv.mkDerivation rec {
  pname = "acct";
  version = "6.6.4";

  src = fetchurl {
    url = "mirror://gnu/acct/acct-${version}.tar.gz";
    sha256 = "0gv6m8giazshvgpvwbng98chpas09myyfw1zr2y7hqxib0mvy5ac";
  };

  doCheck = true;

  patches = [
    (fetchpatch2 {
      url = "https://src.fedoraproject.org/rpms/psacct/raw/rawhide/f/psacct-6.6.4-sprintf-buffer-overflow.patch";
      hash = "sha256-l74tLIuhpXj+dIA7uAY9L0qMjQ2SbDdc+vjHMyVouFc=";
    })
    # Fix build with gcc15
    (fetchpatch2 {
      name = "acct-fix-incompatible-pointer-types.patch";
      url = "https://src.fedoraproject.org/rpms/psacct/raw/9f8c92eb28b0124652848b778438c23052f07679/f/f42-fix-ftbfs.patch";
      hash = "sha256-y4n9jOJWNjm+nCM6OO7RQSrPrBYe/gre4lAnLMMvju8=";
    })
  ];

  meta = {
    description = "GNU Accounting Utilities, login and process accounting utilities";

    longDescription = ''
      The GNU Accounting Utilities provide login and process accounting
      utilities for GNU/Linux and other systems.  It is a set of utilities
      which reports and summarizes data about user connect times and process
      execution statistics.
    '';

    license = lib.licenses.gpl3Plus;

    homepage = "https://www.gnu.org/software/acct/";

    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.linux;
  };
}
