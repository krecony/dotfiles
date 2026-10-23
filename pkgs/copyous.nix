{
  lib,
  stdenv,
  fetchurl,
  fetchzip,
  glib,
  libgda5,
  gsound,
}:
let
  highlightJs = fetchurl {
    url = "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/es/highlight.min.js";
    hash = "sha256-eGWDmUnwdk2eCiHjEaTixCYz7q7oyl7BJ7hkOFZXMf4=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-shell-extension-copyous";
  version = "2.0.1";

  src = fetchzip {
    url = "https://github.com/boerdereinar/copyous/releases/download/v${finalAttrs.version}/copyous@boerdereinar.dev.zip";
    hash = "sha256-jTVRjVqJu1g4opZ7G57h9iKg3JZ2qbWp27ZF/VoX0Kw=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    glib
    libgda5
    gsound
  ];

  buildPhase = ''
    runHook preBuild
    glib-compile-schemas --strict schemas
    runHook postBuild
  '';

  preInstall = ''
    sed -i "1i import GIRepository from 'gi://GIRepository';\nGIRepository.Repository.dup_default().prepend_search_path('${libgda5}/lib/girepository-1.0');\nGIRepository.Repository.dup_default().prepend_search_path('${gsound}/lib/girepository-1.0');\n" lib/preferences/dependencies/dependencies.js

    sed -i "1i import GIRepository from 'gi://GIRepository';\nGIRepository.Repository.dup_default().prepend_search_path('${libgda5}/lib/girepository-1.0');\n" lib/database/entryTracker.js
    sed -i "1i import GIRepository from 'gi://GIRepository';\nGIRepository.Repository.dup_default().prepend_search_path('${gsound}/lib/girepository-1.0');\n" lib/common/sound.js

    sed -i "1i import GIRepository from 'gi://GIRepository';\nGIRepository.Repository.dup_default().prepend_search_path('${gsound}/lib/girepository-1.0');\n" lib/preferences/general/feedbackSettings.js
  '';

  installPhase = ''
    runHook preInstall

    extensionDir="$out/share/gnome-shell/extensions/copyous@boerdereinar.dev"

    mkdir -p "$extensionDir"
    cp -r -T . "$extensionDir"

    install -Dm444 ${highlightJs} "$extensionDir/highlight.min.js"

    runHook postInstall
  '';

  passthru = {
    extensionPortalSlug = "copyous";
    extensionUuid = "copyous@boerdereinar.dev";
  };

  meta = with lib; {
    description = "Modern Clipboard Manager for GNOME";
    homepage = "https://github.com/boerdereinar/copyous";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ jmir ];
    platforms = platforms.linux;
  };
})
