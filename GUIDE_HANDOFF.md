# BG3 Ragnarok Mod - Handoff Guide

## 1) Objetivo actual
Proyecto MVP para BG3 inspirado en Ragnarok Online.
- Clase base: `RO_Novice`
- Primera subclase implementada para pruebas: `RO_Archer`
- Enfoque: iteración mínima viable (una feature por vez, test en juego, continuar)

## 2) Estructura clave del repo
- Mod source: `RagnarokOnlineMod/`
- Diseño funcional: `Class Design/*.json`
- Referencias: `Reference/Packages/...`
- Herramientas: `Tools/`
- PAK de salida: `Package/`

Rutas críticas:
- Meta mod: `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/meta.lsx`
- Class descriptions: `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/ClassDescriptions/ClassDescriptions.lsx`
- Progressions: `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`
- Passives: `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- Spells/Shouts: `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_*.txt`
- Localization: `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`
- GUI metadata (class icons): `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/GUI/metadata.lsf`
- Script Extender config: `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/ScriptExtender/Config.json`
- Script Extender Lua: `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/ScriptExtender/Lua/RO_MPSystem.lua`

## 3) Estado funcional implementado
### Novice (base)
- Clase visible y seleccionable en character creation
- Descripción/lore en inglés
- HP ajustado a 6 base (+CON)
- Recurso custom `RO_MP` base 6
- Passive `Basic Skill` con proficiencias de Novice
- Skills implementadas:
  - `Play Dead` (self, 4 turnos, action, coste MP, uso por short rest)
  - `First Aid` (touch, heal scaling 1d4/1d6/1d8 por nivel)
- Passive `Valkyrie's Blessing` (reroll tipo halfling luck adaptado)

### Subclase test
- `RO_Archer` creada para validar flujo de level-up/subclass
- Progression de subclase cargada
- Icono de subclase en assets y registrado en GUI metadata

## 4) Sistema MP con Script Extender
Fórmula exacta pedida por diseño:
`(4 + (2 * character_level)) + (character_level * floor(spellcasting_modifier / 2))`

Notas:
- Sin fallback forzado (se quitó para validar cálculo real).
- Novice base mantiene 6 MP por progresión base.
- Cuando existe pasivo marcador de fórmula (`RO_MP_Formula_*`), Lua aplica ajuste por pasivo técnico `RO_MP_Adjust_*`.
- Para Archer se usa `RO_MP_Formula_WIS`.

Archivos técnicos:
- `ScriptExtender/Lua/RO_MPSystem.lua`
- `Stats/Generated/Data/Passive_RO_MPSystem.txt`

## 5) Iconos: pipeline correcto
### Clase/Subclase (Class UI)
1. Imagen fuente en `RagnarokOnlineMod/Icons/`
2. Copia (PNG) a:
   - `.../GUI/Assets/ClassIcons/<ClassName>.png`
   - `.../GUI/Assets/ClassIcons/hotbar/<ClassName>.png`
3. Registrar rutas en `GUI/metadata.lsf` (obligatorio)

### Passive/Skill icons
- DDS en rutas Tooltips/ControllerUI (según uso)
- `Icon` en `Passive.txt` o `Spell_*.txt` debe coincidir con nombre esperado

### Conversión PNG -> DDS
Script wrapper:
- `Tools/convert_icon_dds.ps1`

Ejemplo:
```powershell
powershell -ExecutionPolicy Bypass -File .\Tools\convert_icon_dds.ps1 -InputPath "RagnarokOnlineMod/Icons/archer_class.png" -BaseName "RO_Archer" -OutDir "RagnarokOnlineMod/Icons/dds" -Sizes 24x24,380x380
```

También acepta `-Input` como alias.

## 6) Empaquetado
Comando principal:
```powershell
$src=(Resolve-Path '.\RagnarokOnlineMod').Path
$dst=(Resolve-Path '.\Package').Path + '\RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903.pak'
& '.\Tools\ExportTool\Packed\Tools\Divine.exe' -g bg3 -a create-package -s $src -d $dst
```

Ver contenido del pak:
```powershell
$pak=(Resolve-Path '.\Package\RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903.pak').Path
& '.\Tools\ExportTool\Packed\Tools\Divine.exe' -g bg3 -a list-package -s $pak
```

## 7) Checklist rápido para otro chat
1. Confirmar que `metadata.lsf` tiene entradas para cada icono de clase/subclase.
2. Confirmar que `Progressions.lsx` tiene clase base + subclase en niveles correctos.
3. Confirmar que `ScriptExtender/Config.json` incluye `"FeatureFlags": ["Lua"]` y `ModTable` correcto.
4. Reempaquetar PAK.
5. Activar mod en BG3MM.
6. Probar en juego:
   - Clase visible
   - Subclase seleccionable
   - Iconos correctos
   - MP esperado

## 8) Problemas vistos antes (y causa probable)
- "Invalid file" al importar: normalmente por estructura/formato de archivos GUI o XML/LSX inválido.
- Icono no aparece: faltaba registro en `GUI/metadata.lsf` o path no coincidía.
- MP se queda en 6: Lua no cargado o marcador de fórmula no aplicado en el nivel correcto.

## 9) Próximo paso recomendado
Después de validar Archer + MP en runtime:
- Implementar siguiente job (sugerido: `Acolyte` o `Swordman`) con el mismo patrón:
  - marcador de fórmula (`RO_MP_Formula_*`) según spellcasting stat
  - progression mínima viable
  - 1 skill funcional
  - test in-game

---
Este documento busca que cualquier nuevo chat continue sin reconstruir contexto histórico.

## 10) Hallazgos recientes (Stances Archer)
### Owl's Eye (estado actual)
- Skill activa tipo stance (ON/OFF), no passive pura.
- Se aplica correctamente en combate, consume `RO_MP`, y se remueve con skill OFF.
- Bonus de attack roll visible en UI; critical threshold aplicado pero no siempre visible directamente en tooltip.

### Vulture's Eye (estado actual)
- Implementado como stance con escalado por hitos:
  - Lv2: +25% rango efectivo, ignora desventaja point-blank con ballestas, +1d4 a distancia >10m.
  - Lv5: +50% rango efectivo.
  - Lv9: bonus de distancia sube a +1d6 (>10m).
  - Lv12: reemplaza bonus de distancia por +1d12 SIEMPRE en ataques a distancia.
- Cambio entre stances consume recurso correctamente y hace overwrite por `StackId` común.

## 11) Lección clave: rango y desventaja
Problema detectado:
- En Stats puros no encontramos una condición robusta para "fuera del rango normal del arma equipada actual".
- Solución previa basada en `Advantage(...)` por distancia fija causaba ventaja falsa en rangos medios (ej. 11-12m).

Conclusión:
- Para lógica de rango dependiente del arma equipada, usar Script Extender (SE).

## 12) Migración a SE para Vulture's Eye
### Qué quedó activo
- Nuevo módulo SE: `ScriptExtender/Lua/RO_VulturesEye.lua`
- Cargado desde: `ScriptExtender/Lua/BootstrapServer.lua`

### Qué hace
- Detecta si el personaje tiene una status de Vulture's Eye activa.
- Detecta arma a distancia equipada.
- Aplica un pasivo técnico anti-desventaja según umbral por arma (09/15/18m).
- Limpia ese pasivo al salir de la stance o cambiar contexto.

### Pasivos técnicos añadidos
Archivo: `Stats/Generated/Data/Passive.txt`
- `RO_Archer_VulturesEye_LongRangeNoDisadv_09`
- `RO_Archer_VulturesEye_LongRangeNoDisadv_15`
- `RO_Archer_VulturesEye_LongRangeNoDisadv_18`

### Legacy archivado (no activo)
- `Reference/Notes/Archived/VulturesEye_Legacy_LongRangeNoDisadv.txt`
- Passive legacy renombrado a `RO_Archer_VulturesEye_LongRangeNoDisadv_Legacy` para evitar uso accidental.

## 13) Regla práctica para próximas skills
- Preferir `Stats/Progressions` cuando la lógica es estática y declarativa.
- Usar `SE` solo cuando se necesite lógica dinámica/contextual (arma equipada, estado runtime, cálculos avanzados).
- Mantener historial en `Reference/Notes/Archived/` cuando se retire una solución para facilitar rollback y auditoría.
