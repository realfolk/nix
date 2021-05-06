{
  pkgs
}:

let

projectsLib = import ../default.nix { inherit pkgs; };

# COMMANDS

projectTypeId = "static";

makeBuildDir = project: dirName: "${project.buildPath}/${projectTypeId}/${dirName}";

commands = rec {
  build = project: projectsLib.makeCommand {
    inherit project;
    name = "${projectTypeId}-build";
    script = ''
      echo "Removing old build directory: ${project.buildPath}"
      mkdir -p "${project.buildPath}"
      rm -rf "${project.buildPath}"
      cp -r "${project.srcPath}" "${project.buildPath}"
      echo "Successfully copied assets to new build directory: ${project.buildPath}"
    '';
  };

  build-optimized = project: projectsLib.makeCommand {
    inherit project;
    name = "${projectTypeId}-build-optimized";
    script = ''
      echo "--- Start optimized build ---"
      ${(build project).bin}
      cd ${project.buildPath}

      # helper to replace file name suffixes
      replace_suffix() {
        file="$1"
        old_suffix="$2"
        new_suffix="$3"
        echo "$(dirname "$file")/$(basename "$file" "$old_suffix")$new_suffix"
      }
      export -f replace_suffix

      echo "--- Minify JS files ---"
      # closure compiler does not permit specifying an output file that is the same as the input file.
      # so, we output to a tmp file, and then replace the input file with the minified version.
      find -iname '*.js' -exec bash -c 'echo "Minifying $1" && ${pkgs.closurecompiler}/bin/closure-compiler --js "$1" --js_output_file "$2" && mv "$2" "$1" && echo "Minified $1"' bash "{}" "{}.tmp" \;

      echo "--- Minify CSS files ---"
      find -iname '*.css' -exec bash -c 'echo "Minifying $1" && ${pkgs.yuicompressor}/bin/yuicompressor --type css -o "$1" "$1" && echo "Minified $1"' bash "{}" \;

      echo "--- Minify HTML files ---"
      find -iname '*.html' -exec bash -c 'echo "Minifying $1" && ${pkgs.python38Packages.htmlmin}/bin/htmlmin "$1" "$1" && echo "Minified $1"' bash "{}" \;

      echo "--- Optimize images ---"
      find . \( -iname '*.jpg' -o -iname '*.jpeg' \) -exec bash -c '${pkgs.jpegoptim}/bin/jpegoptim --strip-all "$1"' bash "{}" \;
      find . -iname '*.png' -exec bash -c '${pkgs.optipng}/bin/optipng "$1"' bash "{}" \;

      echo "--- Compress assets ---"
      zopfli_compress() {
        file="$1"
        echo "Compressing (zopfli): $file"
        ${pkgs.zopfli}/bin/zopfli "$1"
        echo "Compressed (zopfli): $file"
      }
      brotli_compress() {
        file="$1"
        echo "Compressing (brotli): $file"
        ${pkgs.brotli}/bin/brotli "$1"
        echo "Compressed (brotli): $file"
      }
      export -f zopfli_compress
      export -f brotli_compress
      find . \( -iname '*.js' -o -iname '*.css' -o -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.svg' -o -iname '*.html' -o -iname   '*.mdrn' -o -iname '*.json' \) -exec bash -c 'zopfli_compress "$1"; brotli_compress "$1"' bash "{}" \;

      echo "--- Successfully completed optimized build ---"
      echo "Build files written to ${project.buildPath}"
    '';
  };
};

# PROJECTS

projectConfig = {
  commands = [
    projectsLib.commonCommands.pwd-src
    projectsLib.commonCommands.pwd-build
    projectsLib.commonCommands.cd-src
    projectsLib.commonCommands.cd-build
    projectsLib.commonCommands.ls-src
    projectsLib.commonCommands.ls-build
    commands.build
    commands.build-optimized
  ];
};

defineProject = rootConfig: defineConfig:
  projectsLib.defineProject rootConfig defineConfig;

makeProject = project: projectsLib.makeProject project projectConfig;

makeProjects = projects: projectsLib.makeProjects projects projectConfig;

in

{
  inherit defineProject makeProject makeProjects;
}
