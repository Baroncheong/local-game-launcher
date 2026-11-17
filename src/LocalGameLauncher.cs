// Opens the .hta with the same name as this exe (e.g. LocalGameLauncher.exe -> LocalGameLauncher.hta) using Windows' mshta,
// then gives the window logo.ico and this app's taskbar ID, so it shows the logo and stacks on a pinned shortcut.
// "LocalGameLauncher.exe /pin <shortcut.lnk> ..." stamps the same taskbar ID onto shortcuts (run once after pinning).
using System; using System.Diagnostics; using System.IO; using System.Text; using System.Threading;
using System.Runtime.InteropServices; using System.Text.RegularExpressions;

class P {
  [STAThread]
  static void Main(string[] args) {
    string exe = System.Reflection.Assembly.GetExecutingAssembly().Location;
    string dir = Path.GetDirectoryName(exe), hta = Path.ChangeExtension(exe, ".hta"), ico = Path.Combine(dir, "logo.ico");
    string appId = "LocalGameLauncher." + Path.GetFileNameWithoutExtension(exe);
    if (args.Length > 1 && args[0] == "/pin") { for (int i = 1; i < args.Length; i++) Shell.StampShortcut(args[i], appId, exe, ico); return; }

    try { // older document modes still read this attribute; keep it absolute so it also works there
      string text = File.ReadAllText(hta, Encoding.UTF8);
      string fixedText = new Regex("(<hta:application[^>]*?)icon=\"[^\"]*\"").Replace(text, m => m.Groups[1].Value + "icon=\"" + ico + "\"", 1);
      if (fixedText != text) File.WriteAllText(hta, fixedText, new UTF8Encoding(false));
    } catch { }

    Process p = Process.Start(new ProcessStartInfo(Path.Combine(Environment.SystemDirectory, "mshta.exe"), "\"" + hta + "\"") { WorkingDirectory = dir, UseShellExecute = false });
    // mshta ignores the hta icon in modern document modes: set icon + taskbar ID on its window ourselves
    for (int t = 0; t < 150 && p != null && !p.HasExited; t++) {
      IntPtr w = Shell.FindVisibleWindow(p.Id); // mshta's MainWindowHandle can be a hidden helper window
      if (w != IntPtr.Zero) { Thread.Sleep(300); Shell.Decorate(w, appId, exe, ico); return; }
      Thread.Sleep(100);
    }
  }
}

static class Shell {
  const int WM_SETICON = 0x80;
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern IntPtr LoadImage(IntPtr h, string name, uint type, int cx, int cy, uint flags);
  [DllImport("user32.dll")] static extern IntPtr SendMessage(IntPtr h, int msg, IntPtr w, IntPtr l);
  [DllImport("user32.dll")] static extern int GetSystemMetrics(int i);
  delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc f, IntPtr l);
  [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetClassName(IntPtr h, StringBuilder s, int n);

  public static IntPtr FindVisibleWindow(int pid) {
    IntPtr found = IntPtr.Zero;
    EnumWindows((h, l) => {
      uint wp; GetWindowThreadProcessId(h, out wp);
      if (wp != pid || !IsWindowVisible(h)) return true;
      var cls = new StringBuilder(256); GetClassName(h, cls, 256);
      if (cls.ToString() == "HTML Application Host Window Class") { found = h; return false; }
      return true;
    }, IntPtr.Zero);
    return found;
  }
  [DllImport("shell32.dll")] static extern int SHGetPropertyStoreForWindow(IntPtr hwnd, ref Guid iid, [MarshalAs(UnmanagedType.Interface)] out IPropertyStore store);

  public static void Decorate(IntPtr hwnd, string appId, string exe, string ico) {
    // taskbar ID + what a pinned copy of this window relaunches, then the icons
    Guid iid = typeof(IPropertyStore).GUID; IPropertyStore ps;
    if (SHGetPropertyStoreForWindow(hwnd, ref iid, out ps) == 0) {
      Set(ps, 5, appId);                  // System.AppUserModel.ID
      Set(ps, 2, "\"" + exe + "\"");      // RelaunchCommand
      Set(ps, 4, Path.GetFileNameWithoutExtension(exe)); // RelaunchDisplayNameResource
      Set(ps, 3, ico);                    // RelaunchIconResource
      Marshal.ReleaseComObject(ps);
    }
    IntPtr big = LoadImage(IntPtr.Zero, ico, 1, GetSystemMetrics(11), GetSystemMetrics(12), 0x10);
    IntPtr small = LoadImage(IntPtr.Zero, ico, 1, GetSystemMetrics(49), GetSystemMetrics(50), 0x10);
    if (big != IntPtr.Zero) SendMessage(hwnd, WM_SETICON, (IntPtr)1, big);
    if (small != IntPtr.Zero) SendMessage(hwnd, WM_SETICON, (IntPtr)0, small);
  }

  public static void StampShortcut(string lnk, string appId, string exe, string ico) {
    var link = (IShellLinkW)new ShellLink();
    ((IPersistFile)link).Load(lnk, 2);
    link.SetPath(exe); link.SetArguments(""); link.SetWorkingDirectory(Path.GetDirectoryName(exe)); link.SetIconLocation(ico, 0);
    var ps = (IPropertyStore)link; Set(ps, 5, appId); ps.Commit();
    ((IPersistFile)link).Save(lnk, true);
  }

  static void Set(IPropertyStore ps, int pid, string value) {
    var key = new PROPERTYKEY { fmtid = new Guid("9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3"), pid = pid };
    var v = new PROPVARIANT { vt = 31, p = Marshal.StringToCoTaskMemUni(value) }; // VT_LPWSTR
    try { ps.SetValue(ref key, ref v); } finally { Marshal.FreeCoTaskMem(v.p); }
  }

  [StructLayout(LayoutKind.Sequential, Pack = 4)] struct PROPERTYKEY { public Guid fmtid; public int pid; }
  [StructLayout(LayoutKind.Sequential)] struct PROPVARIANT { public ushort vt; ushort r1, r2, r3; public IntPtr p; IntPtr p2; }

  [ComImport, Guid("886D8EEB-8CF2-4446-8D02-CDBA1DBDCF99"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
  interface IPropertyStore {
    void GetCount(out uint c); void GetAt(uint i, out PROPERTYKEY k);
    void GetValue(ref PROPERTYKEY k, out PROPVARIANT v); void SetValue(ref PROPERTYKEY k, ref PROPVARIANT v); void Commit();
  }
  [ComImport, Guid("00021401-0000-0000-C000-000000000046")] class ShellLink { }
  [ComImport, Guid("000214F9-0000-0000-C000-000000000046"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
  interface IShellLinkW {
    void GetPath([MarshalAs(UnmanagedType.LPWStr)] StringBuilder f, int n, IntPtr fd, int fl); void GetIDList(out IntPtr p); void SetIDList(IntPtr p);
    void GetDescription([MarshalAs(UnmanagedType.LPWStr)] StringBuilder s, int n); void SetDescription([MarshalAs(UnmanagedType.LPWStr)] string s);
    void GetWorkingDirectory([MarshalAs(UnmanagedType.LPWStr)] StringBuilder s, int n); void SetWorkingDirectory([MarshalAs(UnmanagedType.LPWStr)] string s);
    void GetArguments([MarshalAs(UnmanagedType.LPWStr)] StringBuilder s, int n); void SetArguments([MarshalAs(UnmanagedType.LPWStr)] string s);
    void GetHotkey(out short k); void SetHotkey(short k); void GetShowCmd(out int c); void SetShowCmd(int c);
    void GetIconLocation([MarshalAs(UnmanagedType.LPWStr)] StringBuilder s, int n, out int i); void SetIconLocation([MarshalAs(UnmanagedType.LPWStr)] string s, int i);
    void SetRelativePath([MarshalAs(UnmanagedType.LPWStr)] string s, int r); void Resolve(IntPtr h, int f); void SetPath([MarshalAs(UnmanagedType.LPWStr)] string s);
  }
  [ComImport, Guid("0000010b-0000-0000-C000-000000000046"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
  interface IPersistFile {
    void GetClassID(out Guid g); [PreserveSig] int IsDirty();
    void Load([MarshalAs(UnmanagedType.LPWStr)] string f, int m); void Save([MarshalAs(UnmanagedType.LPWStr)] string f, bool r);
    void SaveCompleted([MarshalAs(UnmanagedType.LPWStr)] string f); void GetCurFile([MarshalAs(UnmanagedType.LPWStr)] out string f);
  }
}
