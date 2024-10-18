
/** enum devices section
 *
 * idea is to turn the `je` into a `jmp`

Trackmania.exe+263ED9 - 74 4F                 - je Trackmania.exe+263F2A
Trackmania.exe+263EDB - 39 AF CC180000        - cmp [rdi+000018CC],ebp
Trackmania.exe+263EE1 - 74 47                 - je Trackmania.exe+263F2A
Trackmania.exe+263EE3 - 48 8D 15 E61E8701     - lea rdx,[Trackmania.exe+1AD5DD0] { ("EnumDevices") }
Trackmania.exe+263EEA - 89 6C 24 40           - mov [rsp+40],ebp {  }
Trackmania.exe+263EEE - 48 8D 4C 24 30        - lea rcx,[rsp+30]
Trackmania.exe+263EF3 - E8 5822EAFF           - call Trackmania.exe+106150
Trackmania.exe+263EF8 - 48 8B 8F A8180000     - mov rcx,[rdi+000018A8]
Trackmania.exe+263EFF - 4C 8D 05 BAFBFFFF     - lea r8,[Trackmania.exe+263AC0] { (1220709192) }
Trackmania.exe+263F06 - 4C 8B CF              - mov r9,rdi
Trackmania.exe+263F09 - C7 44 24 20 01000000  - mov [rsp+20],00000001 { 1 }
Trackmania.exe+263F11 - BA 04000000           - mov edx,00000004 { 4 }
Trackmania.exe+263F16 - 48 8B 01              - mov rax,[rcx]
Trackmania.exe+263F19 - FF 50 20              - call qword ptr [rax+20]
Trackmania.exe+263F1C - 8B 54 24 40           - mov edx,[rsp+40]
Trackmania.exe+263F20 - 48 8D 4C 24 30        - lea rcx,[rsp+30]
Trackmania.exe+263F25 - E8 3622EAFF           - call Trackmania.exe+106160

 *
 */

// cc180000 -> 1C190000

// const string EnumDevices_Pattern = "74 4F 39 AF CC 18 00 00 74 47 48 8D 15 ?? ?? ?? ?? 89 6C 24 40 48 8D 4C 24 30"; // E8 58 22 EA FF 48 8B 8F A8 18 00 00 4C 8D 05 BA FB FF FF 4C 8B CF C7 44 24 20 01 00 00 00 BA 04 00 00 00 48 8B 01 FF 50 20 8B 54 24 40 48 8D 4C 24 30 E8 36 22 EA FF";
   const string EnumDevices_Pattern = "74 4F 39 AF ?? ?? 00 00 74 47 48 8D 15 ?? ?? ?? ?? 89 6C 24 40 48 8D 4C 24 30"; // E8 58 22 EA FF 48 8B 8F A8 18 00 00 4C 8D 05 BA FB FF FF 4C 8B CF C7 44 24 20 01 00 00 00 BA 04 00 00 00 48 8B 01 FF 50 20 8B 54 24 40 48 8D 4C 24 30 E8 36 22 EA FF";

string[] origBytes;
uint64[] callPtr;

void Main() {
    // 74(je) to EB(jmp)
    callPtr.InsertLast(Dev::FindPattern(EnumDevices_Pattern));
    if (callPtr[0] == 0) {
        UI::ShowNotification(
            Meta::ExecutingPlugin().Name,
            "Failed to find pattern for EnumDevices.",
            vec4(.8, .1, .1, .5), 10000
        );
        callPtr.RemoveLast();
        return;
    }
    origBytes.InsertLast(Dev::Patch(callPtr[0], "EB"));

    UI::ShowNotification(
        Meta::ExecutingPlugin().Name,
        "Patch: Skipping InputPortDx8::HotPlugUpdate::EnumDevices calls.",
        vec4(.2, .5, .1, .5), 10000
    );
}

/** Called when the plugin is enabled from the settings, the menu or programatically via the [`Meta` API](https://openplanet.dev/docs/api/Meta).
*/
void OnEnabled() {
    Main();
}

void Unload() {
    for (uint i = 0; i < callPtr.Length; i++) {
        if (callPtr[i] == 0) continue;
        Dev::Patch(callPtr[i], origBytes[i]);
    }
    callPtr.RemoveRange(0, callPtr.Length);
    origBytes.RemoveRange(0, origBytes.Length);

    UI::ShowNotification(
        Meta::ExecutingPlugin().Name,
        "Unapplying Patch for InputPortDx8::HotPlugUpdate::EnumDevices calls.",
        vec4(.2, .1, .5, .5), 10000
    );
}

void OnDestroyed() { Unload(); }
void OnDisabled() { Unload(); }
