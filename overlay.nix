final: prev: {
  catppuccin-cursors = prev.catppuccin-cursors.overrideAttrs (oldAttrs: {
    # TODO instead of overriding the justfile, patch it to configure which cursor themes get built
    postPatch = ''
      rm justfile
      cp ${./src/justfile} justfile

      rm src/templates/svgs.tera
      cp ${./src/svgs.tera} src/templates/svgs.tera

      rm -rf src/svgs
      cp -r ${./src/modified} src/svgs
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
  });
}
