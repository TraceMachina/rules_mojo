{ pkgs, ... }:
{
  # Default hooks
  trailing-whitespace-fixer = {
    enable = true;
    name = "trailing-whitespace";
    description = "Remove trailing whitespace";
    entry = "${pkgs.python311Packages.pre-commit-hooks}/bin/trailing-whitespace-fixer";
    types = [ "text" ];
  };
  end-of-file-fixer = {
    enable = true;
    name = "end-of-file-fixer";
    description = "Remove trailing whitespace";
    entry = "${pkgs.python311Packages.pre-commit-hooks}/bin/end-of-file-fixer";
    types = [ "text" ];
  };
  fix-byte-order-marker = {
    enable = true;
    name = "fix-byte-order-marker";
    entry = "${pkgs.python311Packages.pre-commit-hooks}/bin/fix-byte-order-marker";
    types = [ "text" ];
  };
  mixed-line-ending = {
    enable = true;
    name = "mixed-line-ending";
    entry = "${pkgs.python311Packages.pre-commit-hooks}/bin/mixed-line-ending";
    types = [ "text" ];
  };
  check-case-conflict = {
    enable = true;
    name = "check-case-conflict";
    entry = "${pkgs.python311Packages.pre-commit-hooks}/bin/check-case-conflict";
    types = [ "text" ];
  };
  detect-private-key = {
    enable = true;
    name = "detect-private-key";
    entry = "${pkgs.python311Packages.pre-commit-hooks}/bin/detect-private-key";
    types = [ "text" ];
  };

  # Starlark
  bazel-buildifier-format = {
    enable = true;
    name = "buildifier format";
    description = "Format Starlark";
    entry = "${pkgs.bazel-buildtools}/bin/buildifier";
    types = [ "bazel" ];
  };
  bazel-buildifier-lint = {
    enable = true;
    name = "buildifier lint";
    description = "Lint Starlark";
    entry = "${pkgs.bazel-buildtools}/bin/buildifier -lint=warn";
    types = [ "bazel" ];
  };

  # YAML
  yamllint = {
    enable = true;
    excludes = [ "^(.github/styles/)" ];
  };

  # Bash/Shell
  shellcheck = {
    enable = true;
    excludes = [ "png" ];
    types_or = [ "shell" ];
  };

  # Markdown
  markdownlint = {
    enable = true;
    excludes = [
      "^(licenses/|.github/styles/|docs/src/content/docs/reference/|docs/src/content/docs/rules/)"
    ];
    types = [ "markdown" ];
  };

  # Nix
  nixpkgs-fmt.enable = true;
  statix.enable = true;
  deadnix.enable = true;

  # Vale
  vale = {
    enable = true;
    excludes = [ "^.github/styles/" ];
    types = [ "markdown" ];
  };
}
