
/** NGameVoiceAccessibility::CManager::Update

can nop the call okay

Trackmania.exe+D7EFC4 - 89 B5 80000000        - mov [rbp+00000080],esi
Trackmania.exe+D7EFCA - 4D 8B E9              - mov r13,r9
Trackmania.exe+D7EFCD - 4D 8B F0              - mov r14,r8
Trackmania.exe+D7EFD0 - E8 6B9938FF           - call Trackmania.exe+108940 { NGameVoiceAccessibility::CManager::Update
 }
Trackmania.exe+D7EFD5 - 48 8B 85 28010000     - mov rax,[rbp+00000128]
Trackmania.exe+D7EFDC - 89 30                 - mov [rax],esi
Trackmania.exe+D7EFDE - 8B 85 20010000        - mov eax,[rbp+00000120]



89 B5 80 00 00 00 4D 8B E9 4D 8B F0 E8 6B 99 38 FF 48 8B 85 28 01 00 00 89 30 8B 85 20 01 00 00
89 B5 ?? 00 00 00 4D 8B ?? 4D 8B ?? E8 ?? ?? ?? ?? 48 8B 85 ?? ?? 00 00 89 30 8B 85 20 01 00 00
vv unique
89 B5 ?? 00 00 00 4D 8B ?? 4D 8B ?? E8 ?? ?? ?? ?? 48 8B 85 ?? ?? 00 00


 */

const string NGameVoiceAccessMgrUpdate_Pattern = "89 B5 ?? 00 00 00 4D 8B ?? 4D 8B ?? E8 ?? ?? ?? ?? 48 8B 85 ?? ?? 00 00";
const uint offset = 12;

string[] origBytes;
uint64[] callPtr;

void Main() {
    callPtr.InsertLast(Dev::FindPattern(NGameVoiceAccessMgrUpdate_Pattern));
    if (callPtr[0] == 0) {
        UI::ShowNotification(
            Meta::ExecutingPlugin().Name,
            "Failed to find pattern for NGameVoiceAccessibility::CManager::Update.",
            vec4(.8, .1, .1, .5), 10000
        );
        callPtr.RemoveLast();
        return;
    }
    callPtr[0] += offset;
    origBytes.InsertLast(Dev::Patch(callPtr[0], "90 90 90 90 90"));

    UI::ShowNotification(
        Meta::ExecutingPlugin().Name,
        "Patch: Skipping NGameVoiceAccessibility::CManager::Update calls.",
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
        "Unapplying Patch for NGameVoiceAccessibility::CManager::Update calls.",
        vec4(.2, .1, .5, .5), 10000
    );
}

void OnDestroyed() { Unload(); }
void OnDisabled() { Unload(); }
