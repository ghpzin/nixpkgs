{ pkgs, ... }:
{
  name = "freecad";

  nodes.machine =
    { config, pkgs, ... }:
    {
      imports = [
        ./common/x11.nix
      ];
      environment.systemPackages = [ pkgs.freecad ];
    };

  testScript = ''
    machine.wait_for_x()
    with subtest("open ArchDetail.FCStd without segfault"):
      (status, output) = machine.execute("freecad ${pkgs.freecad.out}/share/examples/ArchDetail.FCStd 2>&1", timeout=10)
      print(f"Status: {status}")
      print("Output:")
      print(output)
      assert "SIGSEGV" not in output, "Segmentation fault during test"
  '';
}
