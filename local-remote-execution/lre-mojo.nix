{ buildImage
, lre-cc
, mojoEnv
, ...
}:

let
  Env = mojoEnv;
in
buildImage {
  name = "lre-mojo";
  maxLayers = 20;
  fromImage = lre-cc;
  config = { inherit Env; };
  # Attached for passthrough to rbe-configs-gen.
  meta = { inherit Env; };

  # Don't set a tag here so that the image is tagged by its derivation hash.
  # tag = null;
}
