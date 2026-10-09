{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  inkscape,
  just,
  xcursorgen,
  catppuccin-whiskers,
  python3,
  python3Packages,
  zip,
  onlyBuildPersonal ? false,
}:
let
  dimensions = {
    palette = [
      "frappe"
      "latte"
      "macchiato"
      "mocha"
    ];
    color = [
      "Blue"
      "Dark"
      "Flamingo"
      "Green"
      "Lavender"
      "Light"
      "Maroon"
      "Mauve"
      "Peach"
      "Pink"
      "Red"
      "Rosewater"
      "Sapphire"
      "Sky"
      "Teal"
      "Yellow"
    ];
  };
  variantName = { palette, color }: palette + color;
  variants = lib.mapCartesianProduct variantName dimensions;
  version = "2.0.0";
in
stdenvNoCC.mkDerivation {
  pname = "catppuccin-cursors";
  inherit version;

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "cursors";
    rev = "v${version}";
    hash = "sha256-qis6p+/m7+DdRDYzLq9yB2eZGpfZe5z5xRsa/1HoIG4=";
  };

  nativeBuildInputs = [
    just
    inkscape
    xcursorgen
    catppuccin-whiskers
    python3
    python3Packages.pyside6
    zip
  ];

  outputs = variants ++ [ "out" ]; # dummy "out" output to prevent breakage

  outputsToInstall = [ ];

  postPatch = ''
    rm justfile
    cp ${./src/justfile} justfile

    rm src/templates/svgs.tera
    cp ${./src/svgs.tera} src/templates/svgs.tera
    cp ${./src/svgs_animated.tera} src/templates/svgs_animated.tera

    rm -rf src/svgs
    cp -r ${./src/modified} src/svgs
  '';

  buildPhase = ''
    runHook preBuild

    patchShebangs .

    ${if onlyBuildPersonal then "just personal" else "just all"}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    for output in $(getAllOutputNames); do
      if [ "$output" != "out" ]; then
        local outputDir="''${!output}"
        local iconsDir="$outputDir"/share/icons

        mkdir -p "$iconsDir"

        # Convert to kebab case with the first letter of each word capitalized
        local variant=$(sed 's/\([A-Z]\)/-\1/g' <<< "$output")
        local variant=''${variant,,}

        # Added this check since not all outputs will have results (to speed up build process)
        if [ -d "dist/catppuccin-$variant-cursors" ]; then
          mv "dist/catppuccin-$variant-cursors" "$iconsDir"
        fi
      fi
    done

    # Needed to prevent breakage
    mkdir -p "$out"

    runHook postInstall
  '';

  meta = {
    description = "Catppuccin cursor theme based on Volantes";
    homepage = "https://github.com/Destructor-Ben/cursor-theme";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
}
