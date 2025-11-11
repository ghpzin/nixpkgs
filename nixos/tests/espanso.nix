{ pkgs, ... }:
{
  name = "espanso";

  nodes.machine =
    { lib, ... }:
    {
      imports = [
        ./common/x11.nix
        ./common/user-account.nix
      ];
      environment.systemPackages = with pkgs; [ espanso ];
      test-support.displayManager.auto.user = "alice";
    };

  testScript =
    { ... }:
    ''
      with subtest("ensure x starts"):
          machine.wait_for_x()
          machine.wait_for_file("/home/alice/.Xauthority")
          machine.succeed("xauth merge ~alice/.Xauthority")
      machine.execute("xterm -e espanso service start --unmanaged")
      machine.sleep(10)
      machine.screenshot("started")
    '';
}
