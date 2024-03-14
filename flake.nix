{
  inputs = {
    twpm.url = "github:Dasharo/TwPM_toplevel";
  };

  outputs = { self, twpm }: {
    inherit (twpm) apps devShells packages;
  };
}
