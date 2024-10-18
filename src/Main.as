
/** NGameVoiceAccessibility::CManager::Update

Trackmania.exe+D7F00B - 48 89 BC 24 C8010000  - mov [rsp+000001C8],rdi
Trackmania.exe+D7F013 - 48 8B CB              - mov rcx,rbx
Trackmania.exe+D7F016 - 4C 89 A4 24 C0010000  - mov [rsp+000001C0],r12
Trackmania.exe+D7F01E - 4C 89 BC 24 B8010000  - mov [rsp+000001B8],r15
Trackmania.exe+D7F026 - E8 45F0FFFF           - call Trackmania.exe+D7E070
Trackmania.exe+D7F02B - 48 8B CB              - mov rcx,rbx
Trackmania.exe+D7F02E - E8 1DE5FFFF           - call Trackmania.exe+D7D550
Trackmania.exe+D7F033 - 85 C0                 - test eax,eax
Trackmania.exe+D7F035 - 0F84 10080000         - je Trackmania.exe+D7F84B { je -> jmp to skip }


change last to:
Trackmania.exe+D7F035 - E9 11080000           - jmp Trackmania.exe+D7F84B { je -> jmp to skip }
Trackmania.exe+D7F03A - 90                    - nop



E8 45 F0 FF FF 48 8B CB E8 1D E5 FF FF 85 C0 0F 84 10 08 00 00 65 48 8B 04 25 58 00 00 00
E8 ?? ?? ?? ?? 48 8B CB E8 ?? ?? ?? ?? 85 C0 0F 84 10 08 00 00 65 48 8B 04 25 58 00 00 00

unique:
E8 ?? ?? ?? ?? 48 8B CB E8 ?? ?? ?? ?? 85 C0 0F 84 10 08 00 00
E8 ?? ?? ?? ?? 48 8B CB E8 ?? ?? ?? ?? 85 C0 E9 11 08 00 00 90


45 / 3 = 15



 */

const string NGameVoiceAccessMgrUpdate_Pattern = "E8 ?? ?? ?? ?? 48 8B CB E8 ?? ?? ?? ?? 85 C0 0F 84 10 08 00 00";
const uint offset = 15;

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
    origBytes.InsertLast(Dev::Patch(callPtr[0], "E9 11 08 00 00 90"));

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
