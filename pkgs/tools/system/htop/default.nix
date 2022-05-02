{ lib, fetchFromGitHub, stdenv, autoreconfHook
, ncurses
, IOKit
, sensorsSupport ? stdenv.isLinux, lm_sensors
, systemdSupport ? stdenv.isLinux, systemd
}:

assert systemdSupport -> stdenv.isLinux;

stdenv.mkDerivation rec {
  pname = "htop";
  version = "3.1.2";

  src = fetchFromGitHub {
    owner = "htop-dev";
    repo = pname;
    rev = version;
    sha256 = "sha256-RKYS8UYZTVKMR/3DG31eqkG4knPRl8WXsZU/XGmGmAg=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [ ncurses ]
    ++ lib.optional stdenv.isDarwin IOKit
    ++ lib.optional sensorsSupport lm_sensors
    ++ lib.optional systemdSupport systemd
  ;

  configureFlags = [ "--enable-unicode" "--sysconfdir=/etc" ]
    ++ lib.optional sensorsSupport "--with-sensors"
  ;

  postFixup =
    let
      optionalPatch = pred: so: lib.optionalString pred "patchelf --add-needed ${so} $out/bin/htop";
    in
    ''
      ${optionalPatch sensorsSupport "${lm_sensors}/lib/libsensors.so"}
      ${optionalPatch systemdSupport "${systemd}/lib/libsystemd.so"}
    '';

  meta = with lib; {
    description = "An interactive process viewer for Linux";
    homepage = "https://htop.dev";
    license = licenses.gpl2Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ rob relrod ];
    changelog = "https://github.com/htop-dev/htop/blob/${version}/ChangeLog";
  };
}
