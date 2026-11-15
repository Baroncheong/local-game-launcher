// Opens the .hta with the same name as this exe (e.g. LocalGameLauncher.exe -> LocalGameLauncher.hta) using Windows' mshta.
using System.Diagnostics; using System.IO; using System.Text; using System.Text.RegularExpressions;
class P { static void Main() {
  string exe = System.Reflection.Assembly.GetExecutingAssembly().Location;
  string dir = Path.GetDirectoryName(exe), hta = Path.ChangeExtension(exe, ".hta");
  // mshta only shows a window/taskbar icon when the hta's icon attribute is an absolute path,
  // so point it at logo.ico next to this exe (rewritten only when the folder has moved).
  try {
    string text = File.ReadAllText(hta, Encoding.UTF8);
    string want = "icon=\"" + Path.Combine(dir, "logo.ico") + "\"";
    string fixedText = new Regex("(<hta:application[^>]*?)icon=\"[^\"]*\"").Replace(text, m => m.Groups[1].Value + want, 1);
    if (fixedText != text) File.WriteAllText(hta, fixedText, new UTF8Encoding(false));
  } catch { }
  Process.Start(new ProcessStartInfo(Path.Combine(System.Environment.SystemDirectory, "mshta.exe"), "\"" + hta + "\"") { WorkingDirectory = dir, UseShellExecute = false });
} }
