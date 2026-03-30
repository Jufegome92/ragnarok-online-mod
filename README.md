# ragnarok-online-mod

## PNG to DDS helper

Added script: `Tools/png_to_dds.py`

Requires Python + Pillow:
- `pip install pillow`

### Convert with predefined spec

```bash
python Tools/png_to_dds.py convert \
  --input RagnarokOnlineMod/ragnarok-online-logo-png_seeklogo-491164.png \
  --out-dir RagnarokOnlineMod \
  --spec Tools/png_to_dds_spec.example.json \
  --pixel-format DXT5
```

### Convert with custom sizes

```bash
python Tools/png_to_dds.py convert \
  --input RagnarokOnlineMod/Icons/basic_skill.png \
  --out-dir RagnarokOnlineMod/Icons/dds \
  --sizes 24x24 64x64 \
  --basename basic_skill \
  --pixel-format DXT5
```

### Inspect DDS headers

```bash
python Tools/png_to_dds.py inspect RagnarokOnlineMod/*.dds
```
## Script Extender MP System (RO_MP)

Added a server-side SE system that supports formula-based MP for future Novice subclasses while keeping base Novice fixed MP.

Formula used by SE when a subclass marker passive is present:

`(4 + (2 * character_level)) + (character_level * floor(spellcasting_modifier / 2))`

Current behavior:
- If no marker passive is found, character remains on Novice fixed flow (base 6 MP from progression).
- If marker passive exists, SE computes total MP from the formula and applies a technical adjustment passive.

SE files:
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/ScriptExtender/Config.json`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/ScriptExtender/Lua/BootstrapServer.lua`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/ScriptExtender/Lua/RO_MPSystem.lua`

Technical passives file:
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive_RO_MPSystem.txt`

Subclass marker passives (grant one at subclass level 1):
- `RO_MP_Formula_WIS`
- `RO_MP_Formula_INT`
- `RO_MP_Formula_DEX`
- `RO_MP_Formula_CHA`
- `RO_MP_Formula_STR`
- `RO_MP_Formula_CON`