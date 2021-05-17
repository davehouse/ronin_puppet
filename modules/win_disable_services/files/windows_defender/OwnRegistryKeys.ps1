$script:baseKey = @{
    "HKEY_CLASSES_ROOT" = @{
        "name" = "HKEY_CLASSES_ROOT";
        "shortName" = "HKCR";
        "key" = [Microsoft.Win32.Registry]::ClassesRoot
    };
    "HKEY_CURRENT_CONFIG" = @{
        "name" = "HKEY_CURRENT_CONFIG";
        "shortName" = "HKCC";
        "key" = [Microsoft.Win32.Registry]::CurrentConfig
    };
    "HKEY_CURRENT_USER" = @{
        "name" = "HKEY_CURRENT_USER";
        "shortName" = "HKCU";
        "key" = [Microsoft.Win32.Registry]::CurrentUser
    };
    "HKEY_DYN_DATA" = @{
        "name" = "HKEY_DYN_DATA";
        "shortName" = "HKDD";
        "key" = [Microsoft.Win32.Registry]::DynData
    };
    "HKEY_LOCAL_MACHINE" = @{
        "name" = "HKEY_LOCAL_MACHINE";
        "shortName" = "HKLM";
        "key" = [Microsoft.Win32.Registry]::LocalMachine
    };
    "HKEY_PERFORMANCE_DATA" = @{
        "name" = "HKEY_PERFORMANCE_DATA";
        "shortName" = "HKPD";
        "key" = [Microsoft.Win32.Registry]::PerformanceData
    };
    "HKEY_USERS" = @{
        "name" = "HKEY_USERS";
        "shortName" = "HKU";
        "key" = [Microsoft.Win32.Registry]::Users
    }
}

function enablePrivilege {
    param(
        # The privilege to adjust. This set is taken from:
        # http://msdn.microsoft.com/en-us/library/bb530716(VS.85).aspx
        [validateSet(
            "SeAssignPrimaryTokenPrivilege",
            "SeAuditPrivilege",
            "SeBackupPrivilege",
            "SeChangeNotifyPrivilege",
            "SeCreateGlobalPrivilege",
            "SeCreatePagefilePrivilege",
            "SeCreatePermanentPrivilege",
            "SeCreateSymbolicLinkPrivilege",
            "SeCreateTokenPrivilege",
            "SeDebugPrivilege",
            "SeEnableDelegationPrivilege",
            "SeImpersonatePrivilege",
            "SeIncreaseBasePriorityPrivilege",
            "SeIncreaseQuotaPrivilege",
            "SeIncreaseWorkingSetPrivilege",
            "SeLoadDriverPrivilege",
            "SeLockMemoryPrivilege",
            "SeMachineAccountPrivilege",
            "SeManageVolumePrivilege",
            "SeProfileSingleProcessPrivilege",
            "SeRelabelPrivilege",
            "SeRemoteShutdownPrivilege",
            "SeRestorePrivilege",
            "SeSecurityPrivilege",
            "SeShutdownPrivilege",
            "SeSyncAgentPrivilege",
            "SeSystemEnvironmentPrivilege",
            "SeSystemProfilePrivilege",
            "SeSystemtimePrivilege",
            "SeTakeOwnershipPrivilege",
            "SeTcbPrivilege",
            "SeTimeZonePrivilege",
            "SeTrustedCredManAccessPrivilege",
            "SeUndockPrivilege",
            "SeUnsolicitedInputPrivilege"
        )]
        $privilege,

        # The process on which to adjust the privilege. Defaults to the current process.
        $processId = $pid,

        # Switch to disable the privilege, rather than enable it.
        [switch] $disable
    )

    # Taken from P/Invoke.NET with minor adjustments.
    $definition = @'
using System;
using System.Runtime.InteropServices;

public class AdjustPrivilege {
    [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
    internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall, ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr relen);

    [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
    internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);

    [DllImport("advapi32.dll", SetLastError = true)]
    internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);

    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    internal struct TokPriv1Luid {
        public int Count;
        public long Luid;
        public int Attr;
    }

    internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
    internal const int SE_PRIVILEGE_DISABLED = 0x00000000;
    internal const int TOKEN_QUERY = 0x00000008;
    internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;

    public static bool EnablePrivilege(long processHandle, string privilege, bool disable) {
        bool result;
        TokPriv1Luid tp;
        IntPtr hproc = new IntPtr(processHandle);
        IntPtr htok = IntPtr.Zero;
        result = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
        tp.Count = 1;
        tp.Luid = 0;
        if (disable) {
            tp.Attr = SE_PRIVILEGE_DISABLED;
        } else {
            tp.Attr = SE_PRIVILEGE_ENABLED;
        }
        result = LookupPrivilegeValue(null, privilege, ref tp.Luid);
        result = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
        return result;
    }
}
'@

    $processHandle = (get-process -id $processId).handle
    $type = add-type $definition -passThru
    $type[0]::EnablePrivilege($processHandle, $privilege, $disable)
}

function getKeyNames {
    param(
        [parameter(mandatory = $true)]
        [string[]] $filePaths = $null
    )

    return (get-content $filePaths | select-string -pattern "\[\-?(.*)\]" -allMatches | forEach-object {$_.matches.groups[1].value} | get-unique)
}

function splitKeyName {
    param(
        [parameter(mandatory = $true)]
        [string] $keyName = $null
    )

    $names = $keyName.split("\\/", 2)

    $rootKeyName = $names[0]
    $subKeyName = $names[1]

    $keyPart = @{
        root = $baseKey[$rootKeyName];
        subKey = @{
            name = $subKeyName
        }
    }

    return $keyPart
}

function ownRegistryKey {
    param(
        [parameter(mandatory = $true)]
        [string] $keyName = $null
    )

    write-host """$keyName"""

    # Check if the key exists.
    if ($(try { test-path -path "Registry::$keyName".trim() } catch { $false })) {
        write-host "    Opening..."

        $keyPart = splitKeyName -keyName $keyName
        $ownableKey = $keyPart.root.key.openSubKey($keyPart.subKey.name, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree, [System.Security.AccessControl.RegistryRights]::TakeOwnership)
        if ($ownableKey -ne $null) {
            # Set the owner.
            write-host "    Setting owner..."
            $acl = $ownableKey.getAccessControl([System.Security.AccessControl.AccessControlSections]::None)
            $owner = [System.Security.Principal.NTAccount] "Administrators"
            $acl.setOwner($owner)
            $ownableKey.setAccessControl($acl)

            # Set the permissions.
            write-host "    Setting permissions..."
            $acl = $ownableKey.getAccessControl()
            $person = [System.Security.Principal.NTAccount] "Administrators"
            $access = [System.Security.AccessControl.RegistryRights] "FullControl"
            $inheritance = [System.Security.AccessControl.InheritanceFlags] "ContainerInherit"
            $propagation = [System.Security.AccessControl.PropagationFlags] "None"
            $type = [System.Security.AccessControl.AccessControlType] "Allow"

            $rule = new-object System.Security.AccessControl.RegistryAccessRule($person, $access, $inheritance, $propagation, $type)
            $acl.setAccessRule($rule)
            $ownableKey.setAccessControl($acl)

            $ownableKey.close()

            write-host "    Done."

            # Own children subkeys.
            $readableKey = $keyPart.root.key.openSubKey($keyPart.subKey.name, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadSubTree, [System.Security.AccessControl.RegistryRights]::ReadKey)
            if ($readableKey -ne $null) {
                $subKeyNames = ($readableKey.getSubKeyNames() | forEach-object { "$keyName\$_" })
                $readableKey.close()
                if ($subKeyNames -ne $null) {
                    ownRegistryKeys -keyNames $subKeyNames
                }
            } else {
                write-host "    Unable to open children subkeys."
            }
        } else {
            write-host "    Unable to open subkey."
        }
    } else {
        write-host "    Key does not exist."
    }

    write-host
}

function ownRegistryKeys {
    param(
        [parameter(mandatory = $true)]
        [string[]] $keyNames = $null
    )

    $keyName = $null
    foreach ($keyName in $keyNames) {
        # Own parent key and children subkeys.
        ownRegistryKey -keyName $keyName
    }
}

function requestPrivileges {
    $numberOfRetries = 10

    $privilegeResult = $false
    for ($r = 0; !$privilegeResult -band $r -lt $numberOfRetries; $r += 1) {
        $privilegeResult = enablePrivilege -privilege "SeTakeOwnershipPrivilege"
    }

    if (!$privilegeResult) {
        write-host "Unable to receive privilege."
        exit 1
    }
}

function main {
    param(
        [parameter(mandatory = $true)]
        [string[]] $filePaths = $null
    )

    requestPrivileges

    $keyNames = getKeyNames -filePaths $filePaths
    ownRegistryKeys -keyNames $keyNames
}

main $args
