with import <nixpkgs> {};
bundlerEnv rec {
  inherit ruby;
  gemdir = ./.;

  name = "pry";
  version = "0.10.4";
}
