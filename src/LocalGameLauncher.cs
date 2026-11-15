// Opens the .hta with the same name as this exe (e.g. LocalGameLauncher.exe -> LocalGameLauncher.hta) using Windows' mshta.
using System.Diagnostics; using System.IO;
class P { static void Main() {
  string exe = System.Reflection.Assembly.GetExecutingAssembly().Location;
  string hta = Path.ChangeExtension(exe, ".hta");
  Process.Start(new ProcessStartInfo(Path.Combine(System.Environment.SystemDirectory, "mshta.exe"), "\"" + hta + "\"") { WorkingDirectory = Path.GetDirectoryName(exe), UseShellExecute = false });
} }
