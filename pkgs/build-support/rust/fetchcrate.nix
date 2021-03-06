{ lib, fetchurl, unzip }:

{ crateName ? args.pname
, pname ? null
, version
, sha256
, ... } @ args:

assert pname == null || pname == crateName;

lib.overrideDerivation (fetchurl ({

  name = "${crateName}-${version}.tar.gz";
  url = "https://crates.io/api/v1/crates/${crateName}/${version}/download";
  recursiveHash = true;

  downloadToTemp = true;

  postFetch =
    ''
      export PATH=${unzip}/bin:$PATH

      unpackDir="$TMPDIR/unpack"
      mkdir "$unpackDir"
      cd "$unpackDir"

      renamed="$TMPDIR/${crateName}-${version}.tar.gz"
      mv "$downloadedFile" "$renamed"
      unpackFile "$renamed"
      fn=$(cd "$unpackDir" && echo *)
      if [ -f "$unpackDir/$fn" ]; then
        mkdir $out
      fi
      mv "$unpackDir/$fn" "$out"
    '';
} // removeAttrs args [ "crateName" "pname" "version" ]))
# Hackety-hack: we actually need unzip hooks, too
(x: {nativeBuildInputs = x.nativeBuildInputs++ [unzip];})
