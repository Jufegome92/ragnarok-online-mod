# BG3 Ragnarok Mod - Handoff Guide

## 1) Objetivo actual
Proyecto MVP para BG3 inspirado en Ragnarok Online.
- Clase base: `RO_Novice`
- Primera subclase implementada para pruebas: `RO_Archer`
- Enfoque: iteraciï¿½n mï¿½nima viable (una feature por vez, test en juego, continuar)

## 2) Estructura clave del repo
- Mod source: `RagnarokOnlineMod/`
- Diseï¿½o funcional: `Class Design/*.json`
- Referencias: `Reference/Packages/...`
- Herramientas: `Tools/`
- PAK de salida: `Package/`

Rutas crï¿½ticas:
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
- Descripciï¿½n/lore en inglï¿½s
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
Fï¿½rmula exacta pedida por diseï¿½o:
`(4 + (2 * character_level)) + (character_level * floor(spellcasting_modifier / 2))`

Notas:
- Sin fallback forzado (se quitï¿½ para validar cï¿½lculo real).
- Novice base mantiene 6 MP por progresiï¿½n base.
- Cuando existe pasivo marcador de fï¿½rmula (`RO_MP_Formula_*`), Lua aplica ajuste por pasivo tï¿½cnico `RO_MP_Adjust_*`.
- Para Archer se usa `RO_MP_Formula_WIS`.

Archivos tï¿½cnicos:
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
- DDS en rutas Tooltips/ControllerUI (segï¿½n uso)
- `Icon` en `Passive.txt` o `Spell_*.txt` debe coincidir con nombre esperado

### Conversiï¿½n PNG -> DDS
Script wrapper:
- `Tools/convert_icon_dds.ps1`

Ejemplo:
```powershell
powershell -ExecutionPolicy Bypass -File .\Tools\convert_icon_dds.ps1 -InputPath "RagnarokOnlineMod/Icons/archer_class.png" -BaseName "RO_Archer" -OutDir "RagnarokOnlineMod/Icons/dds" -Sizes 24x24,380x380
```

Tambiï¿½n acepta `-Input` como alias.

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

## 7) Checklist rï¿½pido para otro chat
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
- "Invalid file" al importar: normalmente por estructura/formato de archivos GUI o XML/LSX invï¿½lido.
- Icono no aparece: faltaba registro en `GUI/metadata.lsf` o path no coincidï¿½a.
- MP se queda en 6: Lua no cargado o marcador de fï¿½rmula no aplicado en el nivel correcto.

## 9) Prï¿½ximo paso recomendado
Despuï¿½s de validar Archer + MP en runtime:
- Implementar siguiente job (sugerido: `Acolyte` o `Swordman`) con el mismo patrï¿½n:
  - marcador de fï¿½rmula (`RO_MP_Formula_*`) segï¿½n spellcasting stat
  - progression mï¿½nima viable
  - 1 skill funcional
  - test in-game

---
Este documento busca que cualquier nuevo chat continue sin reconstruir contexto histï¿½rico.

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
- Cambio entre stances consume recurso correctamente y hace overwrite por `StackId` comï¿½n.

## 11) Lecciï¿½n clave: rango y desventaja
Problema detectado:
- En Stats puros no encontramos una condiciï¿½n robusta para "fuera del rango normal del arma equipada actual".
- Soluciï¿½n previa basada en `Advantage(...)` por distancia fija causaba ventaja falsa en rangos medios (ej. 11-12m).

Conclusiï¿½n:
- Para lï¿½gica de rango dependiente del arma equipada, usar Script Extender (SE).

## 12) Migraciï¿½n a SE para Vulture's Eye
### Quï¿½ quedï¿½ activo
- Nuevo mï¿½dulo SE: `ScriptExtender/Lua/RO_VulturesEye.lua`
- Cargado desde: `ScriptExtender/Lua/BootstrapServer.lua`

### Quï¿½ hace
- Detecta si el personaje tiene una status de Vulture's Eye activa.
- Detecta arma a distancia equipada.
- Aplica un pasivo tï¿½cnico anti-desventaja segï¿½n umbral por arma (09/15/18m).
- Limpia ese pasivo al salir de la stance o cambiar contexto.

### Pasivos tï¿½cnicos aï¿½adidos (actual)
Archivo: `Stats/Generated/Data/Passive.txt`
- `RO_Archer_VulturesEye_LongRangeNoDisadv_09_L2`
- `RO_Archer_VulturesEye_LongRangeNoDisadv_09_L5`
- `RO_Archer_VulturesEye_LongRangeNoDisadv_15_L2`
- `RO_Archer_VulturesEye_LongRangeNoDisadv_15_L5`
- `RO_Archer_VulturesEye_LongRangeNoDisadv_18_L2`
- `RO_Archer_VulturesEye_LongRangeNoDisadv_18_L5`

### Legacy archivado (no activo)
- `Reference/Notes/Archived/VulturesEye_Legacy_LongRangeNoDisadv.txt`
- Passive legacy renombrado a `RO_Archer_VulturesEye_LongRangeNoDisadv_Legacy` para evitar uso accidental.

## 13) Regla prï¿½ctica para prï¿½ximas skills
- Preferir `Stats/Progressions` cuando la lï¿½gica es estï¿½tica y declarativa.
- Usar `SE` solo cuando se necesite lï¿½gica dinï¿½mica/contextual (arma equipada, estado runtime, cï¿½lculos avanzados).
- Mantener historial en `Reference/Notes/Archived/` cuando se retire una soluciï¿½n para facilitar rollback y auditorï¿½a.



## 14) Estado validado en juego (checkpoint estable)
Todo lo siguiente fue validado en runtime:
- Cambio de stances funciona (`Owl's Eye` <-> `Vulture's Eye`) y consume `RO_MP`.
- `Owl's Eye` aplica bonus de attack roll correctamente.
- `Vulture's Eye`:
  - ignora desventaja melee con ballestas,
  - aumenta rango efectivo por tier,
  - aplica daï¿½o extra por distancia (`+1d4`/`+1d6`) y en L12 (`+1d12` global).
- `Double Strafe`:
  - ejecuta 2 hits reales,
  - hereda bonos de stance,
  - aplica correctamente bonus de Vulture en ambos impactos.
- Fuera del rango extendido vuelve a existir desventaja (no queda neutralizada infinito).

## 15) Template de implementaciï¿½n (para futuros chats)
### Paso A: Definir en Stats (base declarativa)
1. Crear/actualizar spell o stance en `Spell_*.txt`.
2. Crear/actualizar status en `Status_*.txt`.
3. Exponer/otorgar vï¿½a `Passive.txt` + `Progressions.lsx`.
4. Mantener naming consistente (`*_L2`, `*_L5`, `*_L9`, `*_L12`).

### Paso B: Detectar si hace falta SE
Usar Script Extender cuando haya lï¿½gica dinï¿½mica como:
- arma equipada cambia reglas,
- ventanas de distancia por tier,
- multi-hit encadenado,
- sincronizaciï¿½n runtime por status/eventos.

### Paso C: Patrï¿½n SE recomendado
1. Crear mï¿½dulo `ScriptExtender/Lua/<Feature>.lua`.
2. Registrar en `BootstrapServer.lua` con `Ext.Require(...)`.
3. Escuchar eventos mï¿½nimos necesarios (`StatusApplied/Removed`, equip change, etc.).
4. Aplicar pasivos tï¿½cnicos acotados y limpiarlos al salir del estado.
5. Evitar fallback silencioso durante debug (para detectar errores rï¿½pido).

### Paso D: Validaciï¿½n mï¿½nima en juego
1. Skill/stance visible y casteable.
2. Coste de recurso correcto.
3. Aplicaciï¿½n/remociï¿½n de status esperada.
4. Combat log confirma daï¿½o/rolls esperados por hit.
5. Prueba borde de distancia (dentro y fuera del rango extendido).
6. Prueba con al menos 2 armas de distinto rango (ej. hand crossbow y longbow).

### Paso E: Si algo falla
Orden de diagnï¿½stico:
1. Ver si falla visibilidad/desbloqueo (Progression/Passive).
2. Ver si falla ejecuciï¿½n (SpellSuccess/RequirementConditions).
3. Ver si falla herencia de bonos (context.Source vs target, OnDamage functors).
4. Ver si falla por timing (resolver con listener SE + delay corto).
5. Documentar hallazgo y dejar nota en este archivo.

## 16) Arrow Crafting + Double Strafe (estado final estable)
### Resumen
- Arrow Crafting quedï¿½ migrado a Script Extender para controlar proc por impacto real.
- Se eliminï¿½ la dependencia de passives OnDamage para aplicar daï¿½o elemental de Arrow Craft.
- Consumo de cargas y daï¿½o elemental ahora se resuelven en flujo ï¿½nico de SE.

### Problemas observados y causa raï¿½z
1. Doble proc con `Vulture's Eye` en segundo hit de `Double Strafe`.
- Causa: mï¿½ltiples eventos/functors sobre followup disparaban mï¿½s de una aplicaciï¿½n elemental.

2. Cargas consumidas sin daï¿½o elemental visible.
- Causa: el enfoque con `UseSpell` tï¿½cnico desde SE no estaba aplicando daï¿½o de forma confiable en este contexto.

### Soluciï¿½n final aplicada
- En `RO_ArrowCraft.lua`:
  - `UsingSpellOnTarget` registra intentos vï¿½lidos de ataque con `StoryActionID`.
  - `AttackedBy` confirma hit real (`damageAmount > 0`) y ejecuta proc UNA sola vez por acciï¿½n.
  - El proc aplica `Status` tï¿½cnico al objetivo (`RO_ARCHER_ARROWCRAFT_PROC_*`) con `OnApplyFunctors`.
  - Luego consume exactamente 1 carga (`3->2`, `2->1`, `1->0`) y limpia estado de crafting al agotar.

- En `Status_RO_Archer.txt`:
  - Se agregaron statuses tï¿½cnicos `RO_ARCHER_ARROWCRAFT_PROC_*` (16 variantes: 4 elementos x 4 tiers).
  - Cada status usa `OnApplyFunctors` con daï¿½o elemental inmediato.
  - Tiers con efecto secundario usan DC dinï¿½mica:
    - `CalculateSpellDC(Ability.Wisdom,context.Source)`
    - Equivale a `8 + Proficiency Bonus + Wisdom Modifier`.

### Archivos clave de esta feature
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/ScriptExtender/Lua/RO_ArrowCraft.lua`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/ScriptExtender/Lua/RO_DoubleStrafe.lua`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/ScriptExtender/Lua/BootstrapServer.lua`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Status_RO_Archer.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Shout.txt`

### Nota de mantenimiento
- Los spells tï¿½cnicos `Target_RO_ArrowCraft_Proc_*` en `Spell_Target.txt` quedaron como intento intermedio y no son necesarios para la versiï¿½n final estable basada en status on-hit.
- Mantener `RO_ArrowCraft.lua` como fuente de verdad para proc/consumo.

### Checklist de regresiï¿½n (rï¿½pido)
1. Ataque normal con Fire/Poison/Shock/Radiant Arrow:
- aplica daï¿½o elemental y consume 1 carga.
2. `Double Strafe`:
- aplica daï¿½o elemental en ambos hits (uno por hit) sin duplicar en followup.
3. Con `Vulture's Eye` activo:
- no duplica daï¿½o elemental adicional por hit.
4. Agotar cargas:
- remueve `RO_ARCHER_ARROW_CHARGE_*` y limpia estado de arrow crafting.

## 17) Archer Skill: Improve Concentration (L4/L6/L9/L12)
### Resumen
- Se implementï¿½ `Improve Concentration` como skill activa del Archer desde nivel 4.
- Es `Bonus Action`, cuesta `3 MP`, requiere `Concentration`.
- Escalado aplicado:
  - L4: +1 ranged attack rolls, +1 AC, 2 turnos.
  - L6: +2 ranged attack rolls, +2 AC, 2 turnos.
  - L9: +2 ranged attack rolls, +2 AC, 3 turnos.
  - L12: +2 ranged attack rolls, +2 AC, 3 turnos.

### Implementaciï¿½n tï¿½cnica
1. `Status_RO_Archer.txt`
- Nuevos statuses:
  - `RO_ARCHER_IMPROVE_CONCENTRATION_L4`
  - `RO_ARCHER_IMPROVE_CONCENTRATION_L6`
  - `RO_ARCHER_IMPROVE_CONCENTRATION_L9`
  - `RO_ARCHER_IMPROVE_CONCENTRATION_L12`
- Boosts: `RollBonus(RangedWeaponAttack,...)`, `RollBonus(RangedOffHandWeaponAttack,...)`, `AC(...)`.

2. `Spell_Shout.txt`
- Nuevos spells:
  - `Shout_RO_ImproveConcentration`
  - `Shout_RO_ImproveConcentration_6`
  - `Shout_RO_ImproveConcentration_9`
  - `Shout_RO_ImproveConcentration_12`
- Todos con `UseCosts "BonusActionPoint:1;RO_MP:3"` y `SpellFlags` con `IsConcentration`.

3. `Passive.txt`
- Nuevos passives por tier:
  - `RO_Archer_ImproveConcentration`
  - `RO_Archer_ImproveConcentration_L6`
  - `RO_Archer_ImproveConcentration_L9`
  - `RO_Archer_ImproveConcentration_L12`
- Desbloquean el shout correspondiente por tier.

4. `Progressions.lsx`
- Archer L4: agrega `RO_Archer_ImproveConcentration`.
- Archer L6: reemplaza por `RO_Archer_ImproveConcentration_L6`.
- Archer L9: reemplaza por `RO_Archer_ImproveConcentration_L9`.
- Archer L12: reemplaza por `RO_Archer_ImproveConcentration_L12`.

5. `english.xml`
- Se aï¿½adieron name/description entries para passives, shouts y statuses.

### Eficiencia L12 (MP)
- Se aplicï¿½ reducciï¿½n de coste en `Double Strafe` tier 12 de forma explï¿½cita:
  - `Projectile_RO_DoubleStrafe_12` ahora usa `ActionPoint:1;RO_MP:1`.
- Esto implementa el `-1 MP (minimum 1)` para la skill de ataque de batalla actual del Archer.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Status_RO_Archer.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Shout.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Projectile_RO_Archer.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

## 18) Archer completado (estado final)
### Alcance
Archer queda funcional end-to-end hasta nivel 12 con identidad Ragnarok:
- Stances: `Owl's Eye`, `Vulture's Eye`
- Nï¿½cleo ofensivo: `Double Strafe`
- Utilidad: `Arrow Crafting` (4 elementos, 2 cargas), `Improve Concentration`
- AoE/Control: `Arrow Shower`
- Anti-melee spacing tool: `Arrow Repel`

### Reglas finales confirmadas
1. `Arrow Crafting`
- Sistema final controlado por Script Extender.
- Consume cargas por hit confirmado.
- `Double Strafe` consume correctamente 1 carga por impacto.
- DC de secundarios en tiers altos: `CalculateSpellDC(Ability.Wisdom,context.Source)` = `8 + proficiency + WIS mod`.

2. `Arrow Shower`
- Skill de acciï¿½n con coste MP, sin cooldown de Short Rest.
- Debe depender de MP (como el resto del kit), no de recarga por descanso corto.

3. `Arrow Repel`
- Aplica daï¿½o de arma + bonus por tier.
- Empuja objetivo segï¿½n tier definido.
- Interactï¿½a con el kit Archer (stances/buffs); se aï¿½adiï¿½ compatibilidad para consumo de Arrow Craft cuando corresponde.

4. `Owl's Eye` vs `Vulture's Eye` en melee
- Regla de diseï¿½o: ataques a distancia en melee tienen desventaja salvo excepciones.
- `Vulture's Eye` ignora point-blank disadvantage desde su adquisiciï¿½n.
- `Owl's Eye` no ignora point-blank en tiers bajos; su bypass estï¿½ planteado para tier alto del diseï¿½o.
- `Arrow Repel` tiene ignore point-blank condicionado al propio spell (no es bypass global para todos los ataques).

5. Recursos/descansos (target final)
- `RO_MP` debe recargar en Long Rest.
- `Owl's Eye` y `Vulture's Eye` deben figurar con duraciï¿½n/recovery alineada a Short Rest (segï¿½n decisiï¿½n de diseï¿½o cerrada en iteraciï¿½n).

### Archivos clave del cierre Archer
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Status_RO_Archer.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Shout.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Projectile_RO_Archer.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/ScriptExtender/Lua/RO_ArrowCraft.lua`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/ScriptExtender/Lua/RO_DoubleStrafe.lua`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/ScriptExtender/Lua/BootstrapServer.lua`

### Regresiï¿½n mï¿½nima para revalidar en siguiente chat
1. Ataque normal, `Double Strafe`, `Arrow Shower`, `Arrow Repel` con y sin Arrow Craft activo.
2. Verificar consumo de cargas por hit y limpieza al agotar.
3. Verificar que `Vulture's Eye` ignora desventaja point-blank y que fuera de ese caso no hay bypass global accidental.
4. Verificar tooltips/name/description/icon para skills nuevas (sin `Not Found` ni `?`).
5. Verificar que el gating principal de skills sea MP (no short-rest cooldown involuntario).

### Estado de proyecto
- Archer: `COMPLETADO` para MVP.
- Siguiente fase recomendada: iniciar siguiente job (Acolyte/Swordman o la clase priorizada) reutilizando patrï¿½n `Stats + SE solo donde sea dinï¿½mico`.

## 19) Playbook para nuevos chats (contexto rï¿½pido y consistente)
Objetivo: que cualquier chat nuevo pueda continuar sin perder tiempo ni romper consistencia.

### A) Orden recomendado de trabajo por skill
1. Leer diseï¿½o fuente en `Class Design/<Class>.json`.
2. Confirmar nivel, coste MP, tipo de acciï¿½n, duraciï¿½n, escalado y sinergias.
3. Definir si se resuelve 100% en Stats o requiere SE:
- Stats: reglas declarativas estables (costes, boosts directos, unlocks, duration).
- SE: lï¿½gica contextual/dinï¿½mica (multi-hit, ventanas por arma/rango, consumo por hit confirmado, sincronizaciï¿½n de followups).
4. Implementar primero versiï¿½n mï¿½nima funcional.
5. Probar en juego.
6. Ajustar edge cases.
7. Documentar en este handoff lo que cambiï¿½ y por quï¿½.

### B) Dï¿½nde mirar referencias antes de implementar
1. Referencia interna del proyecto:
- `Reference/` (mods ejemplo y notas archivadas).
2. Implementaciones ya estables de este mod:
- `Double Strafe`, `Arrow Crafting`, `Improve Concentration`, `Arrow Shower`, `Arrow Repel`.
3. Buscar patrones con `rg` antes de copiar lï¿½gica.

Consultas ï¿½tiles:
```powershell
rg -n "RO_Archer|ArrowCraft|DoubleStrafe|ArrowShower|ArrowRepel" RagnarokOnlineMod/Public
rg -n "Ext.Osiris|Ext.Events|StatusApplied|AttackedBy|UsingSpellOnTarget" RagnarokOnlineMod/Mods/*/ScriptExtender/Lua
```

### C) Mï¿½todo estï¿½ndar para crear una skill nueva
1. `Spell_*.txt`
- Crear spell (o shout/zone/projectile segï¿½n tipo).
- Definir `UseCosts` con `RO_MP`.
- Definir `SpellProperties`/functors base.

2. `Status_*.txt` (si aplica)
- Crear status para buffs/debuffs/procs.
- Agregar `Boosts` o `OnApplyFunctors`.

3. `Passive.txt`
- Crear passive de unlock por tier (`_Lx`).
- Evitar duplicar nombres/UUIDs conceptuales.

4. `Progressions.lsx`
- Entregar passive/spell en el nivel correcto.
- Reemplazar tiers anteriores cuando corresponda.

5. `english.xml`
- Agregar nombre/descripcion para skills, passives y statuses.
- Evitar `Not Found` en tooltip.

6. Iconos
- Reusar iconos vanilla vï¿½lidos o registrar custom assets correctamente.
- Si aparece `?`, revisar key de icono + metadata/ruta.

7. SE (solo si hace falta)
- Crear mï¿½dulo en `ScriptExtender/Lua/`.
- Registrar en `BootstrapServer.lua`.
- Mantener una sola fuente de verdad para la lï¿½gica crï¿½tica.

### D) Criterio para decidir Stats vs SE
Usar Stats si:
- El efecto depende solo del caster/target sin estado complejo temporal.
- No depende de confirmar impacto real por evento.

Usar SE si:
- Hay multi-hit con followups.
- Se debe consumir recurso por hit confirmado.
- Hay condiciones por contexto runtime (arma equipada, rango real, acciï¿½n ligada por `StoryActionID`, etc.).

### E) Checklist de validaciï¿½n por skill (rï¿½pido)
1. Tooltip correcto: nombre, descripciï¿½n, coste, duraciï¿½n.
2. Gating correcto: acciï¿½n/bonus action + MP.
3. Sin cooldown oculto no deseado (si la skill no lo define).
4. Daï¿½o/efecto aparece en combat log.
5. Escalado por nivel correcto.
6. Interacciï¿½n con stances/buffs del Archer correcta.
7. No duplica procs ni consume de mï¿½s.
8. Al reempaquetar, la versiï¿½n cargada en juego refleja cambios.

### F) Si en juego no se refleja un cambio
1. Reempaquetar PAK.
2. Confirmar mod activo en BG3MM.
3. Verificar que el archivo editado estï¿½ dentro del PAK.
4. Revisar colisiones con mods de referencia/otros mods.
5. Confirmar que la localizaciï¿½n coincide con nuevas keys.

### G) Quï¿½ actualizar siempre en el handoff al cerrar una tarea
1. Quï¿½ problema habï¿½a (sï¿½ntoma).
2. Causa raï¿½z encontrada.
3. Soluciï¿½n final aplicada.
4. Archivos tocados.
5. Riesgos/edge-cases pendientes.
6. Checklist de regresiï¿½n mï¿½nima.

### H) Plantilla corta para iniciar un chat nuevo
Pegar esto al inicio del nuevo chat:
1. "Lee `GUIDE_HANDOFF.md` completo primero." 
2. "Trabajaremos en `<skill/feature>` de `<Class Design/*.json>` sin romper lo ya estable." 
3. "Antes de editar, lista archivos objetivo y estrategia (Stats vs SE)." 
4. "Despuï¿½s de cambios, actualiza `GUIDE_HANDOFF.md` con causa raï¿½z + soluciï¿½n + archivos tocados + tests." 

## 20) Magician Skill: Frost Diver (L3/L9/L12)
### Resumen
- Se implementï¿½ `Frost Diver` para Magician como skill de control single-target con save de Constituciï¿½n.
- Coste: `4 MP`, tipo `Action`, rango `18m`.
- Fï¿½rmula de DC en runtime: `SourceSpellDC()` (equivale a `8 + proficiency + spellcasting ability modifier`).

### Escalado aplicado
- L3: `2d6 + SpellCastingAbilityModifier` (Cold), y en save fallido aplica `FROZEN` por 1 turno.
- L9: `3d6 + SpellCastingAbilityModifier` (Cold), y en save fallido aplica `FROZEN` por 2 turnos.
- L12: `4d6 + SpellCastingAbilityModifier` (Cold), y en save fallido aplica `FROZEN` por 2 turnos.

### Implementaciï¿½n tï¿½cnica
1. `Spell_Target.txt`
- Nuevos spells:
  - `Target_RO_Magician_FrostDiver`
  - `Target_RO_Magician_FrostDiver_9`
  - `Target_RO_Magician_FrostDiver_12`
- `SpellRoll`: `not SavingThrow(Ability.Constitution, SourceSpellDC())`.
- `SpellSuccess`/`SpellFail` configurados para mantener daï¿½o en ambos casos y status solo en save fallido.

2. `Passive.txt`
- Nuevos passives de unlock por tier:
  - `RO_Magician_FrostDiver_L3`
  - `RO_Magician_FrostDiver_L9`
  - `RO_Magician_FrostDiver_L12`

3. `Progressions.lsx`
- Magician L3: agrega `RO_Magician_FrostDiver_L3`.
- Magician L9: agrega `RO_Magician_FrostDiver_L9` y remueve `RO_Magician_FrostDiver_L3`.
- Magician L12: agrega `RO_Magician_FrostDiver_L12` y remueve `RO_Magician_FrostDiver_L9`.

4. `english.xml`
- Se aï¿½adieron entries de localizaciï¿½n para:
  - nombre y descripciones de passive por tier,
  - nombre del spell y descripciones por tier.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Target.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

## 21) Magician Skill: Element AoE (L5/L9/L12) - MVP Stats
### Resumen
- Se implementï¿½ `Element AoE` para Magician con estructura modular `Base / Intensified / Overload` y variantes `Fire` + `Lightning`.
- Costes activos:
  - Base: `4 MP`
  - Intensified: `5 MP`
  - Overload: `6 MP`
- Gating por progresiï¿½n:
  - L5: desbloquea tier base de la skill.
  - L9: reemplaza por versiï¿½n mejorada de daï¿½o.
  - L12: reemplaza por versiï¿½n final con mayor radio y daï¿½o.

### Implementaciï¿½n tï¿½cnica
1. Nuevo archivo de spells:
- `Stats/Generated/Data/Spell_Zone_RO_Magician.txt`
- Contenedores por tier y milestone:
  - `Zone_RO_Magician_ElementAoE_Base_5/_9/_12`
  - `Zone_RO_Magician_ElementAoE_Intensified_5/_9/_12`
  - `Zone_RO_Magician_ElementAoE_Overload_5/_9/_12`
- Variantes por elemento:
  - Fire: `Zone_RO_Magician_ElementAoE_Fire_*`, `..._Intensified_*`, `..._Overload_*`
  - Lightning: `Zone_RO_Magician_ElementAoE_Lightning_*`, `..._Intensified_*`, `..._Overload_*`

2. Passives de unlock:
- `RO_Magician_ElementAoE_L5`
- `RO_Magician_ElementAoE_L9`
- `RO_Magician_ElementAoE_L12`

3. Progression conectada:
- L5 agrega `RO_Magician_ElementAoE_L5`.
- L9 agrega `RO_Magician_ElementAoE_L9` y remueve `RO_Magician_ElementAoE_L5`.
- L12 agrega `RO_Magician_ElementAoE_L12` y remueve `RO_Magician_ElementAoE_L9`.

### Escalado implementado
- Fire:
  - L5: `3d6 + SpellCastingAbilityModifier`
  - L9: `4d6 + SpellCastingAbilityModifier`
  - L12: `5d6 + SpellCastingAbilityModifier` + radio mayor (`Base 4`)
- Lightning:
  - L5: `2d6`
  - L9: `3d8`
  - L12: `4d10` + radio mayor (`Base 4`)

### Riders por overchannel (MVP)
- Fire Intensified: CON save o `BURNING` 1 turno.
- Fire Overload: aï¿½ade daï¿½o extra `1d4 Fire`.
- Lightning Intensified: CON save o `SHOCKED` 1 turno.
- Lightning Overload: daï¿½o extra `1d4 Lightning` si el objetivo estï¿½ `SHOCKED`.

### Nota de alcance (importante)
- Esta entrega es `MVP en Stats` (sin Script Extender).
- La parte de "storm zone" persistente por turnos de Lightning en diseï¿½o original quedï¿½ simplificada a explosiï¿½n AoE instantï¿½nea.
- Si se quiere comportamiento persistente robusto por turnos (strikes por turno, trigger al entrar/salir), conviene migrar esa parte a SE en iteraciï¿½n posterior.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Zone_RO_Magician.txt` (nuevo)
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`

## 22) Magician Element AoE - Hotfix UI/Shape
### Problema
- En juego aparecï¿½a `Not Found` para nombre/descripciï¿½n de variantes de Element AoE.
- El ï¿½rea se mostraba no circular.

### Causa raï¿½z
- `DisplayName`/`Description` se habï¿½an dejado como texto directo en stats (sin `contentuid` de localizaciï¿½n), lo que en esta ruta terminï¿½ resolviendo a `Not Found`.
- Las variantes base estaban con `Shape = Square`.

### Fix aplicado
- `Spell_Zone_RO_Magician.txt`:
  - Se cambiaron `DisplayName`/`Description` de contenedores y variantes L5 a contentuids nuevos.
  - Se cambiï¿½ `Shape` de las variantes base Fire/Lightning a `Circle`.
- `Passive.txt`:
  - `RO_Magician_ElementAoE_L5/L9/L12` ahora usan contentuids para `DisplayName`/`Description`.
- `Localization/English/english.xml`:
  - Se aï¿½adieron entradas para los contentuids nuevos de Element AoE.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Zone_RO_Magician.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

## 23) Magician cierre (Element AoE + Fire Wall + Stone Curse)
### Estado actual consolidado
- `Element AoE` quedo con targeting tipo Fireball (`SpellType = Projectile`, `TargetRadius = 18`, radio de impacto por variante), con zona circular movible antes de confirmar cast.
- `Element AoE Fire` y `Element AoE Lightning` estan en modelo de detonacion instantanea (sin zona persistente por turnos).
- `Fire Wall` quedo funcionando como control de zona persistente, separado de Element AoE.
- `Stone Curse` se mantiene en coste de diseno `3 MP`.

### Ajustes de balance/diseno confirmados
- `Fire Wall`:
  - L6: `5d8`
  - L9: `6d8`
  - L12: `7d8`, `wall_length 8m`, `duration 3 turns`
- `Element AoE`:
  - Costes por overchannel: `4 / 5 / 6 MP`
  - Fire: `3d6 -> 4d6 -> 5d6` (con spellcasting modifier)
  - Lightning: `2d6 -> 3d8 -> 4d10`

### Causa raiz de errores vistos durante esta iteracion
1. El cast se cancelaba al hacer click:
- Causa principal: configuracion de spell/targeting inconsistente para el flujo de area seleccionable.
- Solucion: unificar a patron projectile AoE (igual naturaleza que Fireball).

2. Area gigante tipo cono en lugar de circulo controlable:
- Causa principal: mezcla de configuracion de zone/cone heredada en variantes previas.
- Solucion: normalizar variantes a detonacion con radio (`AreaRadius/ExplodeRadius`) y contenedor projectile.

3. Riesgo de crash en level-up (nivel 7) durante edicion:
- Se detecto corrupcion en `Class Design/Magician.json` (entradas invalidas tipo `$13`) en una pasada intermedia.
- Se reparo y se dejo JSON valido y coherente con implementacion final.

### Archivos de referencia para continuar Magician
- Diseno: `Class Design/Magician.json`
- AoE: `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Zone_RO_Magician.txt`
- Fire Wall: `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Wall_RO_Magician.txt`
- Progresion: `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`
- Localizacion: `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

### Regresion minima recomendada (rapida)
1. Subir Magician de nivel `5 -> 8` y validar que no haya crash en `7`.
2. Probar `Element AoE` Fire/Lightning:
- aparece preview circular movible,
- respeta alcance `18m`,
- aplica dano correcto por milestone.
3. Probar `Fire Wall` en L6/L9/L12:
- dano por cruce/fin de turno segun tier,
- duracion y longitud correctas.

## 24) Ninja skeleton inicial (sin skills) - listo para carga
### Sintoma
- La subclase `Ninja` estaba definida en `Class Design/ninja.json`, pero no existia en runtime (`ClassDescriptions`, `Progressions`, `Localization`), por lo que no podia seleccionarse/cargar en juego.

### Causa raiz
- Faltaba el wiring minimo para registrar la subclase:
  - `ClassDescription` con UUID/tabla propia,
  - inclusion en selector de subclases de Novice nivel 2,
  - progresion base con proficiencias y marcador MP,
  - localizacion de nombre/descripcion.

### Solucion final
- Se agrego `RO_Ninja` como subclase hija de `RO_Novice` con perfil MVP sin skills:
  - HP base/per level: `8 / 6`
  - Primary ability: `Dexterity`
  - Spellcasting ability: `Wisdom`
  - Class equipment/sound profile: `Rogue`
- Se conecto al selector de subclase de Novice (nivel 2).
- Se creo tabla de progresion `RO_Ninja` (niveles 2-12):
  - Nivel 2: saving throws `DEX/WIS`, proficiencias de armadura/armas y skills (`Stealth`, `Arcana`), expertise selector (1), `RO_MP_Formula_WIS`.
  - Niveles 3-12: nodos vacios (skeleton estable sin skills).
- Se agrego localizacion de clase (`Ninja` + descripcion base).

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/ClassDescriptions/ClassDescriptions.lsx`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

### Riesgos
- No se agregaron skills ni iconos de Ninja en esta iteracion; la clase debe cargar, pero visualmente puede requerir icono especifico despues.
- `SelectSkillsExpertise(...)` usa el mismo patron de subclases existentes; validar en juego que la seleccion de expertise se presente como esperado para Ninja.

### Regresion minima
1. Crear personaje Novice y subir a nivel 2.
2. Verificar que `Ninja` aparezca como opcion de subclase y sea seleccionable.
3. Confirmar que no hay `Not Found` en nombre/descripcion de subclase.
4. Validar que se apliquen:
- saving throws `DEX/WIS`,
- proficiencias (`Light Armor`, `Daggers`, `Shortswords`, `Scimitars`, `Sickles`, `Handaxes`),
- skill proficiencies (`Stealth`, `Arcana`) + 1 expertise,
- formula MP por `RO_MP_Formula_WIS`.
## 25) Ninja no aparecia + Ninja Discipline (MVP INT, sin SE)
### Sintoma
- `Ninja` no aparecia en el selector de subclase al subir `Novice` a nivel 2.
- Al iniciar el trabajo de la primera skill (`Ninja Discipline`), faltaba wiring runtime completo (statuses + localizacion), y habia riesgo de `Not Found`.

### Causa raiz
1. `ClassDescriptions.lsx` quedo corrupto en el bloque de `RO_Ninja` (linea rota `\$14" />`), por lo que la definicion de subclase no podia cargarse correctamente.
2. La subclase estaba originalmente modelada con `Wisdom`, pero el objetivo de diseno para Ninpou en esta iteracion paso a `Intelligence`.
3. `Ninja Discipline` tenia passive + shouts, pero no existia archivo de statuses de Ninja (`Status_RO_Ninja.txt`) ni todas las entradas de localizacion.

### Solucion final
- Se reparo el bloque completo de `RO_Ninja` en `ClassDescriptions.lsx` y se dejo:
  - `Name = RO_Ninja`
  - `ParentGuid = RO_Novice`
  - `ProgressionTableUUID = fedc62af-817a-47b8-abf2-0a8de2694f70`
  - `SpellCastingAbility = 4 (Intelligence)`
- Se mantuvo progression de Ninja en nivel 2 con:
  - `RO_MP_Formula_INT`
  - `RO_Ninja_Discipline`
  - saving throws `DEX/INT`.
- Se implemento MVP funcional de `Ninja Discipline` (sin SE):
  - passive unlock ya presente (`RO_Ninja_Discipline`),
  - shouts ON/OFF por cada rama,
  - nuevo `Status_RO_Ninja.txt` con 3 disciplinas y `StackId` comun `RO_NINJA_DISCIPLINE` + `StackType Overwrite`.
- Se completo localizacion para:
  - passive Ninja Discipline,
  - shouts ON/OFF,
  - statuses activos,
  - descripcion base de subclase Ninja alineada a `Intelligence`.
- Se alineo `Class Design/ninja.json` a `Intelligence`:
  - spellcasting ability,
  - formula de DC,
  - nota de MP,
  - saving throws,
  - referencias de `wisdom_modifier` a `intelligence_modifier` en skills ninpou.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/ClassDescriptions/ClassDescriptions.lsx`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Shout.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Status_RO_Ninja.txt` (nuevo)
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`
- `Class Design/ninja.json`

### Riesgos
- `Ninja Discipline` queda en MVP declarativo (Stats): no implementa aun la regla exacta de "first stance change each turn is free"; para esa precision puede requerir SE.
- Las bonificaciones por rama estan en tier base (L2): escalados L5/L9 y efectos avanzados siguen pendientes.
- Si el PAK instalado esta bloqueado por proceso (BG3/BG3MM), los cambios no se reflejaran hasta cerrar el bloqueo y copiar el PAK nuevo.

### Regresion minima
1. Subir `Novice` a nivel 2 y confirmar que `Ninja` aparece y es seleccionable.
2. Confirmar que no hay `Not Found` en nombre/descripcion de Ninja ni en Ninja Discipline.
3. Activar cada disciplina (`Throwing/Shadow/Ninpou`) y validar que:
- solo una quede activa a la vez (overwrite por `StackId`),
- la version OFF retire la disciplina correcta.
4. Verificar en ficha que Ninja usa `INT` para caster context (DC/Spell Attack esperado de Ninpou en siguientes skills).

## 26) Ninja Skill: Thrown Technique (L2/L5/L9) - MVP Stats
### Sintoma
- Ninja ya cargaba y tenia `Ninja Discipline`, pero faltaba su ataque base de rama Throwing (`Thrown Technique`) para continuar el kit nivel 2.

### Causa raiz
- No existian spells/passives/runtime wiring para la skill en `Stats/Progressions/Localization`.

### Solucion final
- Se implemento `Thrown Technique` con contenedor y 3 variantes en `Spell_Projectile_RO_Ninja.txt`:
  - `Throw Shuriken` (18m, 1 MP)
  - `Throw Kunai` (18m, 1 MP, aplica `Exposed Armor`)
  - `Throw Huuma Shuriken` (2m impacto, 2 MP)
- Se agrego escalado por milestone:
  - L2: `1d6 / 1d8 / 2d6`
  - L5: `1d8 / 1d10 / 3d6`
  - L9: `2d8 / 2d10(+Bleeding) / 4d6`
- Se agrego passive de unlock por tiers:
  - `RO_Ninja_ThrownTechnique_L2`
  - `RO_Ninja_ThrownTechnique_L5`
  - `RO_Ninja_ThrownTechnique_L9`
- Se conecto en progression Ninja:
  - L2 agrega `RO_Ninja_ThrownTechnique_L2`
  - L5 reemplaza por `RO_Ninja_ThrownTechnique_L5`
  - L9 reemplaza por `RO_Ninja_ThrownTechnique_L9`
- Se agrego status tecnico `RO_NINJA_KUNAI_EXPOSED` (`AC(-1)`) y localizacion completa de skill/tiers/status.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Projectile_RO_Ninja.txt` (nuevo)
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Status_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

### Riesgos
- `Throw Kunai` se implementa en MVP como `-1 AC` general por 2 turnos, no estrictamente "solo contra tu siguiente ataque".
- `Throw Huuma Shuriken` en MVP usa AoE de impacto uniforme (no separa dano centro/secundario con precision total).
- Para comportamiento exacto de esas dos reglas, puede requerirse SE en iteracion posterior.

### Regresion minima
1. Nivel 2 Ninja: verificar que aparece `Thrown Technique` en hotbar.
2. Verificar contenedor con 3 variantes (`Shuriken/Kunai/Huuma`) y costes MP `1/1/2`.
3. Verificar escalado en nivel 5 y 9 (passive swap y tooltip/dano).
4. Verificar que Kunai aplique `Exposed Armor` y en L9 ademas `Bleeding`.
5. Verificar que Huuma golpee en area pequena (2m) sin `Not Found` en nombre/descripcion/icono.

## 27) Hotfix Thrown Technique no visible en hotbar
### Sintoma
- `Thrown Technique` aparecia como passive en ficha, pero el contenedor/skills (`Shuriken/Kunai/Huuma`) no aparecian en hotbar.

### Causa raiz
- Los proyectiles de Thrown Technique estaban configurados con `AttackType.RangedWeaponAttack`.
- En runtime, sin contexto de arma/rango compatible, el juego puede ocultar esas skills en barra.

### Solucion final
- En `Spell_Projectile_RO_Ninja.txt` se cambio `SpellRoll` de Thrown Technique a `AttackType.RangedSpellAttack` (L2 base, heredado por L5/L9).
- Se ajusto tooltip de ataque a `RangedSpellAttack`.
- Se reempaqueto el mod.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Projectile_RO_Ninja.txt`
- `Package/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903.pak`

### Riesgos
- `Throwing Mastery` actualmente bonifica `RangedWeaponAttack`; al usar `RangedSpellAttack`, ese +1 de stance no aplica todavia a Thrown Technique. Se puede resolver en siguiente iteracion con bonus condicionado por `SpellId` o ajuste de boosts.

### Regresion minima
1. Ninja L2: verificar que `Thrown Technique` aparece en hotbar/spellbook.
2. Abrir contenedor y confirmar `Throw Shuriken`, `Throw Kunai`, `Throw Huuma Shuriken`.
3. Verificar costes MP `1/1/2` y cast sobre enemigo visible a 18m.

## 28) Hotfix Throwing Mastery no aplicaba a Thrown Technique
### Sintoma
- Tras el hotfix de visibilidad, `Thrown Technique` aparecia en hotbar, pero el +1 de `Throwing Mastery` no se aplicaba en las tiradas.

### Causa raiz
- `Throwing Mastery` seguia usando `RollBonus(RangedWeaponAttack,...)`.
- `Thrown Technique` se movio a `RangedSpellAttack` para evitar ocultamiento en barra.

### Solucion final
- Se cambio el boost de `RO_NINJA_DISCIPLINE_THROWING` a condicion por `SpellId` de todas las variantes de `Thrown Technique` (L2/L5/L9) y se aplica `RollBonus(Attack,1)` solo en esas skills.

### Archivo tocado
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Status_RO_Ninja.txt`

### Regresion minima
1. Activar `Throwing Mastery`.
2. Usar `Throw Shuriken`, `Throw Kunai`, `Throw Huuma` en L2 y confirmar +1 al ataque.
3. Subir a L5/L9 y confirmar que el +1 sigue aplicando en las variantes tier altas.
4. Confirmar que ataques no relacionados no reciben ese +1.

## 29) Hotfix critico: Throwing Mastery + Thrown Technique no cargaban bien
### Sintoma
- `Throwing Mastery` casteaba pero no aplicaba estado visible/bonificador y no habilitaba salida.
- `Thrown Technique` no aparecia en hotbar pese a tener passive otorgado.

### Causa raiz
- El boost condicional con `IF(SpellId(...))` en status resulto inestable para este caso y rompia aplicacion efectiva del status.
- `Spell_Projectile_RO_Ninja.txt` usaba `DexterityModifier` en formulas de dano; ese token no se usa en otros spells del repo y podia cortar parse/carga del archivo completo.

### Solucion final
- `RO_NINJA_DISCIPLINE_THROWING`: boost simplificado a `SpellAttackRollBonus(1)` (estable).
- `Thrown Technique`: se removio `+DexterityModifier` de formulas para asegurar carga del archivo y visibilidad de skills.
- Se actualizo localizacion para reflejar dano actual sin modificador.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Status_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Projectile_RO_Ninja.txt`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

### Riesgo pendiente
- Este fix prioriza estabilidad/visibilidad. El scaling con DEX queda pendiente para reintroducir con expresion validada (o via SE) en siguiente iteracion.

### Regresion minima
1. Activar `Throwing Mastery` y validar que aparece estado + opcion OFF.
2. Confirmar que aparece `Thrown Technique` en hotbar.
3. Abrir contenedor y validar `Shuriken/Kunai/Huuma` visibles y casteables.
4. Verificar costes MP `1/1/2` y efectos de Kunai (`Exposed Armor`, y Bleeding en L9).

## 30) Hotfix fallback estable: Thrown Technique directo + Throwing Mastery estable
### Sintoma
- Persistian dos fallos: `Throwing Mastery` no aplicaba correctamente y `Thrown Technique` no aparecia en barra.

### Causa raiz (hipotesis validada por comportamiento)
- Configuracion con contenedor + formulas previas estaba provocando que las skills no quedaran visibles/cargadas de forma consistente en runtime.
- `Throwing Mastery` con condicion avanzada no era estable en este estado.

### Solucion final aplicada (prioridad: funcionalidad inmediata)
- `Thrown Technique` se dejo como 3 skills directas por tier (sin dependencia de contenedor):
  - `Throw Shuriken`
  - `Throw Kunai`
  - `Throw Huuma Shuriken`
- Passive unlock por tier ahora desbloquea directamente las 3 skills correspondientes.
- `Throwing Mastery` se simplifico a boost estable:
  - `RollBonus(RangedWeaponAttack,1);SpellAttackRollBonus(1)`
- Se preservo `Shadow Arts` y `Ninpou` sin cambios funcionales.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Projectile_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Status_RO_Ninja.txt`
- `Package/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903.pak`

### Riesgos
- Este fix prioriza disponibilidad y test in-game rapido sobre pureza de diseno del contenedor.
- Si se quiere volver al UX de contenedor unico, debe reintroducirse despues de validar sintaxis/carga de forma incremental.

### Regresion minima
1. En Ninja L2 deben aparecer en hotbar/spellbook: `Throw Shuriken`, `Throw Kunai`, `Throw Huuma Shuriken`.
2. Activar `Throwing Mastery` y confirmar estado activo + opcion OFF.
3. Verificar que `Shadow Arts` y `Ninpou` siguen funcionando como antes.
4. Probar cast real de las 3 tecnicas y consumo MP esperado (1/1/2).

## 31) Ninja Throwing Mastery + Thrown Technique (hotfix estable MVP)
### Sï¿½ntoma reportado
- `Throwing Mastery` se casteaba pero no dejaba condiciï¿½n/bono activo y no habilitaba salida OFF.
- `Thrown Technique` mostraba comportamiento inestable: faltaba `Throw Shuriken` y las acciones de throw no eran consistentes al usarse.
- `Throw Kunai` mostraba tooltip confuso por duraciï¿½n (`2 turns`) y en pruebas no quedaba claro el coste MP.

### Causa raï¿½z
1. La boost de `RO_NINJA_DISCIPLINE_THROWING` incluï¿½a una expresiï¿½n no estable para este contexto, provocando que el estado no se consolidara correctamente.
2. La implementaciï¿½n de throws dependï¿½a de una estructura con herencias parciales que introdujo comportamiento inconsistente en desbloqueo/ejecuciï¿½n.
3. Parte del feedback visual (tooltip de estado) mezclaba informaciï¿½n ï¿½til con ruido para la UX de test.

### Soluciï¿½n final aplicada
- Se dejï¿½ `Throwing Mastery` con status simple y vï¿½lido (`SpellAttackRollBonus(1)`) y se moviï¿½ el `+1 Attack Roll` de throws a un passive oculto condicional por estado activo + `SpellId` de throws ninja:
  - nuevo passive: `RO_Ninja_ThrowingMastery_Bonus`.
- Se reescribiï¿½ `Thrown Technique` como 3 skills directas y explï¿½citas (sin contenedor):
  - `Projectile_RO_Ninja_ThrowShuriken_*`
  - `Projectile_RO_Ninja_ThrowKunai_*`
  - `Projectile_RO_Ninja_ThrowHuuma_*`
- Se normalizaron costes/rangos:
  - Shuriken: 18m, 1 MP.
  - Kunai: 10m, 1 MP.
  - Huuma: 10m, 2 MP, radio 2m.
- Se agregï¿½ `DexterityModifier` al daï¿½o base/escalados para alinear con diseï¿½o.
- Se reforzï¿½ `Shout_RO_NinjaDiscipline_Throwing` con `TargetConditions "Self()"` y tooltip de estado aplicado.

### Archivos tocados
- `Class Design/ninja.json`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Projectile_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Shout.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Status_RO_Ninja.txt`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

### Riesgos abiertos
- `Huuma` aï¿½n no aplica explï¿½citamente daï¿½o secundario diferenciado por objetivo en el mismo impacto (MVP actual: daï¿½o principal + configuraciï¿½n AoE de radio).
- El uso de `DexterityModifier` en `DealDamage(...)` depende del parser/runtime del juego; si BG3 ignora esa parte, puede requerir ajuste con fï¿½rmula alternativa.

### Regresiï¿½n mï¿½nima a validar
1. Subir a Novice 2 -> Ninja y confirmar que aparecen 3 acciones: Shuriken/Kunai/Huuma.
2. Verificar costes: 1/1/2 MP respectivamente.
3. Activar Throwing Mastery y confirmar:
   - aparece estado activo,
   - aparece opciï¿½n OFF,
   - los throws ganan +1 al ataque (combat log).
4. Cambiar a Shadow/Ninpou y confirmar que Throwing bonus deja de aplicar.

## 32) Ninja Throws: desventaja por "outside normal range" (hotfix)
### Sï¿½ntoma
- `Throw Shuriken`, `Throw Kunai` y `Throw Huuma Shuriken` mostraban `Disadvantage` con motivo `Target outside normal range` incluso en situaciones donde la intenciï¿½n era un rango fijo de skill.

### Causa raï¿½z
- Los throws estaban configurados con `HasHighGroundRangeExtension`, lo que habilita disparo fuera del rango normal con desventaja.
- Ademï¿½s, al usar `RangedWeaponAttack`, el cï¿½lculo puede depender del contexto de arma equipada y generar comportamiento confuso para tï¿½cnicas custom.

### Soluciï¿½n final
- En `Spell_Projectile_RO_Ninja.txt`:
  - `SpellRoll` de throws ninja migrado a `Attack(AttackType.RangedSpellAttack)`.
  - `TooltipAttackSave` actualizado a `RangedSpellAttack`.
  - `SpellFlags` simplificado a `HasSomaticComponent;IsSpell;IsHarmful` (sin `HasHighGroundRangeExtension`).
- Resultado esperado: los throws respetan su rango base (18/10/10) sin extenderse con desventaja por fuera de rango normal.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Projectile_RO_Ninja.txt`

### Riesgos
- `RangedSpellAttack` usa pipeline de spell attack; validar que la sensaciï¿½n de precisiï¿½n se mantenga segï¿½n el balance esperado de Ninja.

### Regresiï¿½n mï¿½nima
1. Con Ninja L2, verificar que Shuriken/Kunai/Huuma ya no muestren `Target outside normal range` + desventaja al apuntar dentro de su rango.
2. Verificar que fuera de rango simplemente no permita seleccionar/castear el objetivo.
3. Confirmar que consumo MP (1/1/2) y daï¿½o siguen correctos.

## 33) Balance pass solicitado (Shuriken/Kunai/Huuma)
### Sï¿½ntoma
- `Shuriken` quedaba opacado por `Kunai` (mismo coste, menos daï¿½o y sin utilidad extra).
- `Kunai` aplicaba `-1 AC` por demasiado tiempo para su coste.
- `Huuma` se sentï¿½a correcto en coste, pero con radio bajo para rol AoE.

### Causa raï¿½z
- Balance inicial demasiado lineal: `Kunai` era estrictamente mejor que `Shuriken` en casi todo.

### Soluciï¿½n final aplicada
- `Shuriken`: se aï¿½adiï¿½ identidad de precisiï¿½n con `+2 Attack Roll` (pasivo oculto condicional por `SpellId` de shuriken).
- `Kunai`: `RO_NINJA_KUNAI_EXPOSED` ahora dura `1` turno (antes `2`).
- `Huuma`:
  - L2: radio aumentado a `3m`.
  - L5 y L9: radio aumentado a `4m`.
  - Coste se mantiene en `2 MP`.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Projectile_RO_Ninja.txt`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`
- `Class Design/ninja.json`

### Riesgos
- El `+2 Attack Roll` de Shuriken puede dejarlo muy consistente en objetivos de AC media; validar en combate real.

### Regresiï¿½n mï¿½nima
1. Confirmar Shuriken con mejor tasa de impacto respecto a Kunai en mismo objetivo.
2. Confirmar Kunai aplica `Exposed Armor` y expira en 1 turno.
3. Confirmar Huuma L2 impacta en 3m y L5+ en 4m.
4. Confirmar costes MP: Shuriken 1, Kunai 1, Huuma 2.

## 34) Ninja Shadow Jump (L2/L5/L9) - MVP funcional
### Sï¿½ntoma / objetivo
- Se solicitï¿½ implementar `Shadow Jump` como siguiente skill de Ninja:
  - L2: teleport 9m, Bonus Action, 2 MP.
  - L5: teleport 12m + bono al siguiente ataque/tï¿½cnica.
  - L9: teleport 15m + bono al siguiente ataque/tï¿½cnica + daï¿½o extra.

### Causa raï¿½z previa
- La subclase Ninja aï¿½n no tenï¿½a `Shadow Jump` conectado en runtime (spell + passive + progression + loc).

### Soluciï¿½n final aplicada
- Se implementaron 3 spells target basados en `Target_MistyStep`:
  - `Target_RO_Ninja_ShadowJump_2` (9m)
  - `Target_RO_Ninja_ShadowJump_5` (12m + status L5)
  - `Target_RO_Ninja_ShadowJump_9` (15m + status L9)
- Se aï¿½adieron statuses:
  - `RO_NINJA_SHADOW_JUMP_BUFF_L5` -> `+1 Attack Roll`
  - `RO_NINJA_SHADOW_JUMP_BUFF_L9` -> `+1 Attack Roll`
- Se aï¿½adiï¿½ passive tï¿½cnico L9 de daï¿½o:
  - `RO_Ninja_ShadowJump_L9_DamageBonus` (OnDamage, +1d6 Force mientras status L9 estï¿½ activo).
- Se aï¿½adieron passives de unlock por milestone:
  - `RO_Ninja_ShadowJump_L2`
  - `RO_Ninja_ShadowJump_L5`
  - `RO_Ninja_ShadowJump_L9`
- Se conectï¿½ en `Progressions.lsx`:
  - L2 agrega `RO_Ninja_ShadowJump_L2`.
  - L5 agrega `RO_Ninja_ShadowJump_L5` y remueve `L2`.
  - L9 agrega `RO_Ninja_ShadowJump_L9` + `RO_Ninja_ShadowJump_L9_DamageBonus` y remueve `L5`.
- Se agregaron textos de localizaciï¿½n para skill, upgrades y momentum buff.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Target.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Status_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

### Riesgos
- En L9, el +1d6 se implementï¿½ como passive `OnDamage` mientras el buff estï¿½ activo; si se hacen mï¿½ltiples hits en ese turno, puede aplicarse mï¿½s de una vez.

### Regresiï¿½n mï¿½nima
1. Ninja L2: aparece `Shadow Jump` (9m), consume Bonus Action + 2 MP.
2. Ninja L5: salta 12m y muestra buff de +1 Attack Roll.
3. Ninja L9: salta 15m, mantiene +1 Attack Roll y aï¿½ade +1d6 Force en ataque/tï¿½cnica durante el buff.

## 35) Shadow Jump icon fix (question mark)
### Sï¿½ntoma
- `Shadow Jump` aparecï¿½a con icono de `?` en UI.

### Causa raï¿½z
- Se usï¿½ clave de icono no vï¿½lida: `Spell_Illusion_MistyStep`.

### Soluciï¿½n final
- Se reemplazï¿½ por clave vï¿½lida y conocida del juego: `Spell_Conjuration_MistyStep`.
- Se aplicï¿½ en spell, statuses de buff y passives de unlock para consistencia visual.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Target.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Status_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`

### Riesgos
- Si un entorno especï¿½fico no expone esa clave, el fallback serï¿½a `Spell_Conjuration_DimensionDoor`.

### Regresiï¿½n mï¿½nima
1. Verificar icono de `Shadow Jump` en barra y hoja de personaje.
2. Verificar icono del buff tras usar `Shadow Jump` L5/L9.

## 36) Containerizaciï¿½n UI (Ninja Training + Thrown Technique)
### Sï¿½ntoma / objetivo
- Habï¿½a demasiadas skills sueltas en barra para Ninja.
- Se pidiï¿½ agrupar:
  - `Throwing Mastery`, `Shadow Arts`, `Ninpou Training` en un solo skill contenedor.
  - `Throw Shuriken`, `Throw Kunai`, `Throw Huuma` dentro de `Thrown Technique`.

### Causa raï¿½z
- Desbloqueo actual otorgaba cada sub-skill individualmente, saturando la barra.

### Soluciï¿½n final aplicada
- `Ninja Discipline` migrado a patrï¿½n contenedor y renombrado visualmente a `Ninja Training`:
  - contenedor ON: `Shout_RO_NinjaTraining_On`
  - contenedor OFF: `Shout_RO_NinjaTraining_Off`
  - subskills ON/OFF ahora usan `SpellContainerID`.
- Iconografï¿½a unificada por pedido:
  - activaciones: icono ï¿½nico `Action_MobileShooting`
  - desactivaciones: icono ï¿½nico `Action_SlashingFlourish_Ranged`
- `Thrown Technique` migrado a contenedor por tier:
  - `Projectile_RO_Ninja_ThrownTechnique_2`
  - `Projectile_RO_Ninja_ThrownTechnique_5`
  - `Projectile_RO_Ninja_ThrownTechnique_9`
  - subskills de shuriken/kunai/huuma enlazadas con `SpellContainerID`.
- Passives actualizados para desbloquear contenedores (no variantes sueltas).
- Localizaciï¿½n ajustada para mostrar `Ninja Training` y acciï¿½n de apagado (`Cancel Training`).

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Shout.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Projectile_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

### Riesgos
- Como en cualquier contenedor de BG3, si una variante no cumple `RequirementConditions`, puede no mostrarse en ese momento; esto es esperado.

### Regresiï¿½n mï¿½nima
1. Verificar que aparece solo `Ninja Training` (ON/OFF) en lugar de 6 botones sueltos.
2. Verificar que `Thrown Technique` abre las 3 variantes segï¿½n tier.
3. Verificar que cada variante sigue consumiendo su MP correcto y aplica su efecto.

## 37) Nivel 3 - Mist Slash (MVP funcional)
### Sï¿½ntoma / objetivo
- Se solicitï¿½ implementar `Mist Slash` para nivel 3 (Bonus Action, 2 MP), con escalado en 5/9 y reposicionamiento seguro tras impactar.

### Causa raï¿½z previa
- La subclase Ninja no tenï¿½a skill ofensiva de nivel 3 conectada en runtime.

### Soluciï¿½n final aplicada
- Se aï¿½adieron spells de `Mist Slash`:
  - `Projectile_RO_Ninja_MistSlash_3`
  - `Projectile_RO_Ninja_MistSlash_5`
  - `Projectile_RO_Ninja_MistSlash_9`
- Perfil de ejecuciï¿½n:
  - ataque melee basado en arma principal (`Projectile_MainHandAttack` + `ExecuteWeaponFunctors(MainHand)`),
  - coste `BonusActionPoint:1;RO_MP:2`,
  - alcance corto (`TargetRadius` 6).
- Escalado:
  - L3: daï¿½o de arma.
  - L5: daï¿½o de arma + `1d6`.
  - L9: daï¿½o de arma + `2d6` y `+1 Attack Roll` para la tï¿½cnica de L9.
- Reposicionamiento seguro tras hit:
  - statuses `RO_NINJA_MIST_SLASH_REPOSITION_L3/L5/L9` aplicados en `SpellSuccess`, con:
    - `ActionResource(Movement,3,0)`
    - `IgnoreLeaveAttackRange()`
- Se aï¿½adieron passives y progresiï¿½n:
  - `RO_Ninja_MistSlash_L3` en nivel 3.
  - upgrade a `RO_Ninja_MistSlash_L5` en nivel 5 (remove L3).
  - upgrade a `RO_Ninja_MistSlash_L9` en nivel 9 (remove L5).
- Se agregï¿½ localizaciï¿½n completa de skill, upgrades y buff de reposition.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Projectile_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Status_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

### Riesgos
- La condiciï¿½n "target aislado" de diseï¿½o se aproximï¿½ en MVP con `+1 Attack Roll` en variante L9 (sin detector de aislamiento aï¿½n).
- El comportamiento de "sin opportunity attacks" depende de `IgnoreLeaveAttackRange()` en status; validar visualmente en combate.

### Regresiï¿½n mï¿½nima
1. A nivel 3 aparece `Mist Slash` y consume Bonus Action + 2 MP.
2. Al impactar, el personaje gana 3m de movimiento y puede reposicionarse sin OA.
3. En nivel 5 y 9 sube daï¿½o segï¿½n diseï¿½o (`+1d6`, luego `+2d6`).
4. En nivel 9 `Mist Slash` gana +1 al ataque.

## 38) Nivel 3 - Ninpou Bolt (MVP separado por elemento)
### Sintoma / objetivo
- Se solicito implementar `Ninpou Bolt` para Ninja nivel 3 mientras se prueba nivel 2, priorizando MVP estable.
- Requisito de implementacion: 3 skills separadas (sin contenedor por ahora):
  - `Crimson Fire Blossom`
  - `Lightning Spear of Ice`
  - `Wind Blade`

### Causa raiz previa
- `Ninpou Bolt` solo existia en `Class Design/ninja.json`; no habia runtime wiring en Stats/Progression/Localization.

### Solucion final aplicada
- Se agregaron 9 spells de proyectil en `Spell_Projectile_RO_Ninja.txt`:
  - Tier nivel 3:
    - `Projectile_RO_Ninja_NinpouBolt_Fire_3`
    - `Projectile_RO_Ninja_NinpouBolt_Cold_3`
    - `Projectile_RO_Ninja_NinpouBolt_Wind_3`
  - Tier nivel 5:
    - `Projectile_RO_Ninja_NinpouBolt_Fire_5`
    - `Projectile_RO_Ninja_NinpouBolt_Cold_5`
    - `Projectile_RO_Ninja_NinpouBolt_Wind_5`
  - Tier nivel 9:
    - `Projectile_RO_Ninja_NinpouBolt_Fire_9`
    - `Projectile_RO_Ninja_NinpouBolt_Cold_9`
    - `Projectile_RO_Ninja_NinpouBolt_Wind_9`
- Configuracion comun MVP:
  - `ActionPoint:1;RO_MP:2`
  - `TargetRadius:18`
  - `SpellRoll: Attack(AttackType.RangedSpellAttack)`
  - Escalado de dano por tier:
    - L3: `2d6 + IntelligenceModifier`
    - L5: `3d6 + IntelligenceModifier`
    - L9: `4d6 + IntelligenceModifier`
- Se agregaron passives de unlock/escalado:
  - `RO_Ninja_NinpouBolt_L3` (visible)
  - `RO_Ninja_NinpouBolt_L5` (hidden)
  - `RO_Ninja_NinpouBolt_L9` (hidden)
- Se conecto progresion Ninja:
  - Nivel 3 agrega `RO_Ninja_NinpouBolt_L3`.
  - Nivel 5 agrega `RO_Ninja_NinpouBolt_L5` y remueve `RO_Ninja_NinpouBolt_L3`.
  - Nivel 9 agrega `RO_Ninja_NinpouBolt_L9` y remueve `RO_Ninja_NinpouBolt_L5`.
- Se agrego localizacion EN para nombres/descripciones de las 3 variantes y descripciones de milestone del passive.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Projectile_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

### Riesgos
- Las sinergias avanzadas con `Ninpou Field` (bonus damage/slow/reaction lock) no se cablearon todavia para evitar acoplarse a statuses/campos que aun no estan cerrados.
- `Wind Blade` usa dano `Thunder` con icono lightning por disponibilidad de iconografia estable.

### Regresion minima
1. Ninja nivel 3: aparecen las 3 skills separadas de Ninpou Bolt y cada una consume 2 MP.
2. Verificar ataque a distancia magico (Ranged Spell Attack) y dano elemental correcto por variante.
3. Ninja nivel 5: las 3 variantes pasan a 3d6 + INT.
4. Ninja nivel 9: las 3 variantes pasan a 4d6 + INT.
5. Confirmar que `Mist Slash` y kit de nivel 2 siguen visibles y funcionales.

## 39) Migracion A2 - Primer cambio de disciplina gratis por turno (Ninja)
### Sintoma / objetivo
- El nuevo diseno de Ninja exige que el primer cambio de disciplina por turno sea gratis.
- Estado previo: todas las activaciones/desactivaciones de disciplina consumian `BonusActionPoint` siempre.

### Causa raiz
- En `Spell_Shout.txt` las skills de disciplina usan `UseCosts` fijos (`BonusActionPoint:1`) y no habia logica runtime para reembolso de la primera activacion por turno.

### Solucion final aplicada
- Se implemento soporte en Script Extender para reembolsar 1 Bonus Action en el primer cambio de disciplina de cada turno de combate:
  - Nuevo modulo: `RO_NinjaDisciplineFreeSwitch.lua`.
  - Se registra en `BootstrapServer.lua`.
- Logica runtime:
  - Escucha `TurnStarted` y resetea bandera por personaje.
  - Escucha `EnteredCombat` y deja la bandera en estado limpio.
  - Escucha `LeftCombat` y limpia tracking.
  - Escucha `UsingSpell` y, si el spell es una de las 6 variantes de disciplina (ON/OFF) y es el primer uso del turno, ejecuta:
    - `PartyIncreaseActionResourceValue(caster, "BonusActionPoint", 1.0)`
  - Resultado practico: el primer switch queda gratis; siguientes en el mismo turno no se reembolsan.

### Archivos tocados
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/ScriptExtender/Lua/RO_NinjaDisciplineFreeSwitch.lua` (nuevo)
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/ScriptExtender/Lua/BootstrapServer.lua`

### Riesgos
- El reembolso usa `PartyIncreaseActionResourceValue`; si el motor no descuenta BA en un caso puntual, podria generar +1 BA neto.
- Regla aplicada solo en combate (coherente con economia por turno). Fuera de combate no se fuerza reembolso.

### Regresion minima
1. Iniciar combate con Ninja y verificar BA inicial.
2. Usar una disciplina (`Throwing/Shadow/Ninpou` ON u OFF): BA debe terminar igual (reembolso).
3. Usar un segundo cambio de disciplina en el mismo turno: BA debe gastarse normalmente.
4. Terminar turno y repetir en el siguiente: el primer cambio vuelve a ser gratis.

## 40) Migracion A3 - Bonuses de disciplina por rama (Ninja)
### Sintoma / objetivo
- El nuevo diseno exige que `Throwing Mastery` premie objetivos condicionados y que `Ninpou Training` escale por hitos.
- Estado previo:
  - Throwing tenia bono plano desacoplado de condiciones.
  - Ninpou se quedaba en +1 Spell Attack/+1 DC fijo en todos los niveles.

### Causa raiz
- Las disciplinas estaban modeladas como boosts base estaticos y faltaban pasivos de escalado por nivel para Ninja.

### Solucion final aplicada
- Throwing Mastery (runtime):
  - Se movio el bono de precision al passive tecnico condicional:
    - `RO_Ninja_ThrowingMastery_Bonus` ahora da `+1 Attack` solo si:
      - disciplina Throwing activa,
      - se usa tecnica de Throwing,
      - y el objetivo esta condicionado (`BLEEDING`, `OFF_BALANCED`, `DAZED`, `RO_NINJA_KUNAI_EXPOSED`).
  - El status `RO_NINJA_DISCIPLINE_THROWING` queda con boost neutro (`SpellAttackRollBonus(0)`) para no introducir parse risk con campo vacio.

- Ninpou Training (escalado por hitos):
  - Se agregaron passives ocultos:
    - `RO_Ninja_NinpouTraining_L5`: mientras `RO_NINJA_DISCIPLINE_NINPOU` esta activo, agrega `+1 Spell Attack` y `+1 Spell Save DC`.
    - `RO_Ninja_NinpouTraining_L9`: mientras `RO_NINJA_DISCIPLINE_NINPOU` esta activo, agrega `+2 Spell Attack` y `+2 Spell Save DC`.
  - Se cableo en progresion:
    - Nivel 5 agrega `RO_Ninja_NinpouTraining_L5`.
    - Nivel 9 agrega `RO_Ninja_NinpouTraining_L9` y remueve `RO_Ninja_NinpouTraining_L5`.
  - Efecto total esperado con disciplina activa:
    - L2: +1/+1 (status base)
    - L5: +2/+2 (status base + passive L5)
    - L9: +3/+3 (status base + passive L9)

- Se actualizaron textos de disciplina para reflejar el comportamiento nuevo:
  - Throwing: bono contra objetivos condicionados.
  - Ninpou: indica que mejora en niveles altos.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Status_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

### Riesgos
- El set de "conditioned targets" en esta iteracion usa estados confirmados en runtime (`BLEEDING`, `OFF_BALANCED`, `DAZED` y `RO_NINJA_KUNAI_EXPOSED`).
- Estados del nuevo diseno como `REELING/HAMSTRUNG/MAIMED` se integraran al migrar A4/B1.

### Regresion minima
1. Activar Throwing Mastery y atacar un objetivo sin condicion: no debe recibir el +1 condicional.
2. Aplicar una condicion valida al objetivo y repetir tecnica de Throwing: debe aparecer el +1 condicional.
3. Activar Ninpou Training en L2/L5/L9 y verificar bonus efectivos de Spell Attack/DC (+1/+2/+3 respectivamente).
4. Confirmar que Shadow Arts conserva +3m movement sin cambios.

## 41) Migracion A4 - Thrown Technique al modelo de condiciones (Ninja)
### Sintoma / objetivo
- El nuevo diseno pide que `Thrown Technique` deje de depender solo de `Exposed Armor` y use un modelo de condiciones para setup y payoff.
- Estado previo:
  - Shuriken/Huuma no tenian payoff contra objetivos condicionados.
  - Kunai estaba centrado en `Exposed Armor` sin escalar al nuevo ladder.

### Causa raiz
- `Spell_Projectile_RO_Ninja.txt` tenia formulas base de dano sin condicionales de estado para Shuriken/Huuma.
- Kunai aplicaba principalmente `RO_NINJA_KUNAI_EXPOSED` y no encadenaba al modelo de condiciones nuevo.

### Solucion final aplicada
- `Thrown Technique` actualizado por tier (2/5/9):
  - Shuriken:
    - mantiene dano base por tier,
    - agrega dano extra contra objetivos condicionados:
      - L2: `+1d4`
      - L5: `+1d6`
      - L9: `+1d8`
  - Kunai:
    - mantiene `Exposed Armor (-1 AC, 1 turno)` por compatibilidad,
    - agrega Bleeding por salvacion de CON fallida:
      - L2: Bleeding 2 turnos
      - L5: Bleeding 3 turnos
    - L9: mantiene Bleeding y puede aplicar `Dazed` a objetivos que ya estaban Bleeding (CON fallida).
  - Huuma:
    - mantiene dano/rango/coste y radios (3m en L2, 4m en L5/L9),
    - agrega dano extra contra objetivos condicionados:
      - L2: `+1d4`
      - L5: `+1d6`
      - L9: `+1d8`
    - L9: puede aplicar `Off Balance` en objetivo condicionado con salvacion de STR fallida.
- `Throwing Mastery` se alineo mejor al ladder agregando `SLOWED` al set de condiciones validas para el +1 condicional.
- Localizacion EN actualizada para reflejar el comportamiento real de cada variante y sus upgrades.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Projectile_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

### Riesgos
- Se usa `SourceSpellDC()` para tiradas de CON/STR en Kunai/Huuma; validar que la dificultad se sienta correcta para Ninja en runtime.
- `Exposed Armor` se mantiene por compatibilidad de balance, aunque ya no es el centro del branch.

### Regresion minima
1. L2: Shuriken y Huuma deben mostrar/aplicar dano extra solo en targets condicionados.
2. L2/L5: Kunai debe seguir aplicando `Exposed Armor` y ademas Bleeding en fallo de CON.
3. L9: Kunai sobre objetivo ya Bleeding puede aplicar Dazed en fallo de CON.
4. L9: Huuma sobre objetivo condicionado puede aplicar Off Balance en fallo de STR.
5. Confirmar que coste MP/rango/radios siguen: Shuriken 1 MP (18m), Kunai 1 MP (10m), Huuma 2 MP (10m; 3m->4m).

## 42) Migracion A5 - Shadow Jump alineado al nuevo diseno (Ninja)
### Sintoma / objetivo
- Alinear `Shadow Jump` al diseno nuevo:
  - L2: +1 Attack Roll al siguiente ataque/tecnica.
  - L5: +1 Attack Roll +1d4 al siguiente ataque/tecnica.
  - L9: +2 Attack Roll +1d6 al siguiente ataque/tecnica.
- Estado previo:
  - L2 solo teletransportaba (sin buff de seguimiento).
  - L5 tenia +1 Attack Roll, pero sin dano adicional.
  - L9 tenia +1 Attack Roll (no +2) y dano separado, no consumido de forma limpia como "siguiente ataque".

### Causa raiz
- El wiring de `Shadow Jump` estaba partido entre status y passive legacy (`RO_Ninja_ShadowJump_L9_DamageBonus`), con comportamiento incompleto para L2/L5 y escalado parcial en L9.

### Solucion final aplicada
- Spells `Target_RO_Ninja_ShadowJump_*`:
  - L2 ahora aplica `RO_NINJA_SHADOW_JUMP_BUFF_L2` al lanzar.
  - L5 mantiene teleport 12m y aplica `RO_NINJA_SHADOW_JUMP_BUFF_L5`.
  - L9 mantiene teleport 15m y aplica `RO_NINJA_SHADOW_JUMP_BUFF_L9`.
- Status de Shadow Jump:
  - `RO_NINJA_SHADOW_JUMP_BUFF_L2`: `RollBonus(Attack,1)`.
  - `RO_NINJA_SHADOW_JUMP_BUFF_L5`: `RollBonus(Attack,1)`.
  - `RO_NINJA_SHADOW_JUMP_BUFF_L9`: `RollBonus(Attack,2)`.
- Consumo "siguiente ataque/tecnica":
  - Se reemplazo el passive legacy por `RO_Ninja_ShadowJump_Followup` (hidden, `OnDamage`):
    - si hay buff L5, agrega `1d4 Force`;
    - si hay buff L9, agrega `1d6 Force`;
    - luego remueve el status L2/L5/L9 correspondiente para que se consuma en el primer hit.
- Progresion:
  - Nivel 2 de Ninja ahora agrega tambien `RO_Ninja_ShadowJump_Followup`.
  - Nivel 9 ya no agrega `RO_Ninja_ShadowJump_L9_DamageBonus`.
- Localizacion EN actualizada para reflejar nuevos valores de L2/L5/L9 y nuevos textos de momentum.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Target.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Status_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

### Riesgos
- El trigger de consumo usa `OnDamage` + `HasDamageEffectFlag(DamageFlags.Hit)`; en skills multi-hit solo el primer hit deberia consumir el buff, pero conviene validar visualmente en combate real.
- El dano extra de seguimiento esta modelado como `Force` para estabilidad tecnica (consistente con implementaciones previas del mod).

### Regresion minima
1. L2: usar Shadow Jump y comprobar que el siguiente ataque/tecnica gana +1 Attack Roll y luego se consume.
2. L5: usar Shadow Jump y comprobar +1 Attack Roll +1d4 en el siguiente hit; despues se consume.
3. L9: usar Shadow Jump y comprobar +2 Attack Roll +1d6 en el siguiente hit; despues se consume.
4. Verificar que no hay doble aplicacion de dano legacy en L9.
5. Confirmar que teleport/rango/coste siguen: 9m/12m/15m y 2 MP Bonus Action.

## 43) Ajuste de balance - Kunai Exposed Armor y Throwing Mastery (Ninja)
### Sintoma / objetivo
- Ajustar balance segun prueba runtime:
  - `Exposed Armor (-1 AC)` de Kunai debe durar 2 turnos para que el Ninja pueda capitalizar su propio setup.
  - `Throwing Mastery` debe dar `+1` base al attack roll con tecnicas de throw y `+2 total` contra objetivos condicionados.

### Causa raiz
- `RO_NINJA_KUNAI_EXPOSED` se aplicaba por 1 turno en los tres tiers de Kunai, quedando demasiado corto para secuencia de turnos.
- `RO_Ninja_ThrowingMastery_Bonus` solo otorgaba bono cuando el objetivo ya estaba condicionado.

### Solucion final aplicada
- Kunai (`ThrowKunai_2/5/9`):
  - `ApplyStatus(RO_NINJA_KUNAI_EXPOSED,100,1)` -> `ApplyStatus(RO_NINJA_KUNAI_EXPOSED,100,2)`.
- Throwing Mastery:
  - Se cambio a dos capas en el passive:
    - +1 base para cualquier tecnica de throw con disciplina activa.
    - +1 adicional si el objetivo esta condicionado.
  - Resultado: +1 base, +2 total en condicionados.
- Tooltips EN actualizados para reflejar duracion de 2 turnos y regla de bonificador de Throwing Mastery.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Projectile_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

### Riesgos
- El +1 base y +1 condicional se aplican via dos condiciones en el mismo passive; validar en combate que no exista stacking inesperado fuera de tecnicas de throw.

### Regresion minima
1. Usar Kunai y verificar `Exposed Armor` por 2 turnos.
2. Con Throwing Mastery activa, usar tecnica de throw en objetivo sin condicion: debe verse +1.
3. Repetir en objetivo condicionado: debe verse +2 total.
4. Confirmar que coste/rango/efectos restantes de Shuriken/Kunai/Huuma no cambian.

## 44) Hotfix - Shadow Jump no se movia (regresion de A5)
### Sintoma / objetivo
- Al usar `Shadow Jump`, se veia animacion pero el personaje quedaba en el mismo lugar.

### Causa raiz
- En A5 se uso `SpellProperties` para aplicar buffs de Shadow Jump en spells que heredan de `Target_MistyStep`.
- Ese override podia pisar la propiedad heredada de teletransporte.

### Solucion final aplicada
- En `Target_RO_Ninja_ShadowJump_2/5/9` se movio la aplicacion de buff de:
  - `SpellProperties` -> `SpellSuccess`
- Se mantuvo `TooltipStatusApply` igual.
- Con esto, el teletransporte heredado de `MistyStep` queda intacto y el buff sigue aplicandose al completar el salto.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Target.txt`

### Riesgos
- Si algun entorno evalua `SpellSuccess` de forma distinta para teleports, podria requerir mover el apply a passive runtime; por ahora este es el fix mas pequeno y seguro.

### Regresion minima
1. Usar Shadow Jump y confirmar que el personaje si se mueve al punto objetivo.
2. Confirmar que el buff de follow-up sigue apareciendo tras el salto.
3. Confirmar que el buff se consume en el siguiente hit como antes.

## 45) Hotfix - Shadow Jump rango efectivo por tier (9/12/15)
### Sintoma / objetivo
- Shadow Jump seguia mostrando/permitiendo alcance cercano a 18m, heredado de `Misty Step`, en vez de 9/12/15 por tier.

### Causa raiz
- El spell hereda de `Target_MistyStep`; `SpellRange` solo no estaba forzando completamente el rango efectivo en UI/targeting.

### Solucion final aplicada
- Se forzo rango por tier en `ShadowJump_2/5/9` agregando `TargetRadius` explicito:
  - L2: `SpellRange 9` + `TargetRadius 9`
  - L5: `SpellRange 12` + `TargetRadius 12`
  - L9: `SpellRange 15` + `TargetRadius 15`
- Se mantuvo intacto el escalado funcional ya implementado:
  - L2: +1 Attack Roll siguiente ataque/tecnica
  - L5: +1 Attack Roll +1d4
  - L9: +2 Attack Roll +1d6

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Target.txt`

### Riesgos
- Si algun comportamiento UI interno prioriza otro campo heredado del root spell en una build concreta, podria requerir override adicional; este fix cubre el caso estandar de targeting/rango.

### Regresion minima
1. L2: Shadow Jump solo debe permitir destino hasta 9m.
2. L5: Shadow Jump solo debe permitir destino hasta 12m.
3. L9: Shadow Jump solo debe permitir destino hasta 15m.
4. Confirmar que buffs y consumo de follow-up siguen funcionando tras el cambio.

## 46) Migracion B1 - Throwing Art (Ninja nivel 3)
### Sintoma / objetivo
- Faltaba `Throwing Art` en el kit real de Ninja nivel 3, aunque estaba definido en el diseno.
- Se necesitaba un MVP funcional primero: skill cargable, 3 variantes, costes correctos y escalado base por hitos.

### Causa raiz
- No existian entradas runtime para `Throwing Art` en:
  - `Spell_Projectile_RO_Ninja.txt` (spells/variantes),
  - `Passive.txt` (unlock por tier),
  - `Progressions.lsx` (entrega por nivel 3/5/9),
  - `english.xml` (textos).
- Tampoco existia un status de soporte para `Reeling`.

### Solucion final aplicada
- Se agrego contenedor `Throwing Art` y sus variantes por tier:
  - L3: `Razor Shuriken`, `Crippling Kunai`, `Disrupting Senbon`.
  - L5/L9: upgrades de dano y riders.
- Reglas MVP implementadas:
  - Costo base: `Action + 2 MP` para las 3 variantes.
  - Rango: `18m`.
  - Attack type: `RangedSpellAttack`.
  - Razor: aplica `Bleeding` por salvacion CON fallida.
  - Crippling: aplica `Slowed` por salvacion CON fallida; en tiers altos agrega payoff contra slowed/off-balance.
  - Senbon: aplica nuevo estado `RO_NINJA_REELING` (Attack -1) por salvacion CON fallida; en tiers altos agrega rider de `Dazed`.
- Se creo `RO_NINJA_REELING` como status de Ninja.
- Se cableo unlock por progresion:
  - Nivel 3 agrega `RO_Ninja_ThrowingArt_L3`.
  - Nivel 5 reemplaza con `RO_Ninja_ThrowingArt_L5`.
  - Nivel 9 reemplaza con `RO_Ninja_ThrowingArt_L9`.
- Se extendio `RO_Ninja_ThrowingMastery_Bonus` para incluir spells de `Throwing Art` dentro de la rama Throwing.
- Se agregaron localizaciones EN para nombre, descripciones, tiers y status Reeling.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Projectile_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Status_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

### Riesgos
- `Crippling Kunai` usa `Slowed/Off Balance` como MVP funcional en lugar de estados dedicados `Hamstrung/Maimed` del diseno completo.
- `Disrupting Senbon` aplica `Dazed` como rider alto; puede requerir tuning fino en balance tras pruebas.
- Falta la parte premium de anti-concentracion de Razor L9 del diseno final (queda para iteracion posterior).

### Regresion minima
1. Subir Ninja a nivel 3 y validar que aparece `Throwing Art` en barra/categoria.
2. Abrir contenedor y confirmar 3 variantes visibles: Razor, Crippling, Senbon.
3. Confirmar coste de cada variante: `Action + 2 MP`.
4. Validar efectos base L3:
   - Razor aplica Bleeding en fallo CON.
   - Crippling aplica Slowed en fallo CON.
   - Senbon aplica Reeling en fallo CON.
5. Validar upgrade a nivel 5 y 9 (reemplazo de passive y nuevos valores/tooltips).

## 47) B1 pendiente - Hamstrung/Maimed + rider de concentracion (Ninja)
### Sintoma / objetivo
- Tras B1 MVP, quedaban pendientes del diseno:
  - `Crippling Kunai` debia usar `Hamstrung/Maimed` (no `Slowed/Off Balance`).
  - `Razor Shuriken` L9 debia presionar concentracion.

### Causa raiz
- La primera version de B1 priorizo estabilidad MVP y uso estados existentes para acelerar pruebas (`Slowed/Off Balance`) sin cerrar todavia los estados dedicados del ladder Throwing.

### Solucion final aplicada
- Nuevos status de Ninja:
  - `RO_NINJA_HAMSTRUNG`: `ActionResource(Movement,-3,0)`.
  - `RO_NINJA_MAIMED`: `ActionResource(Movement,-4.5,0);Disadvantage(AttackRoll)`.
  - `RO_NINJA_RAZOR_CONCENTRATION_BREAK`: `Disadvantage(Concentration)`.
- `Crippling Kunai` actualizado por tier:
  - L3: aplica `RO_NINJA_HAMSTRUNG` en fallo CON.
  - L5: si ya esta `HAMSTRUNG` y falla CON, aplica `RO_NINJA_MAIMED`.
  - L9: mantiene upgrade a `MAIMED` y bono +1d8 contra `HAMSTRUNG/MAIMED`.
- `Razor Shuriken` L9:
  - mantiene dano y bleeding,
  - agrega `RO_NINJA_RAZOR_CONCENTRATION_BREAK` (1 turno) cuando pega a objetivo bleeding.
- `Throwing Mastery` condicional ampliado para reconocer:
  - `RO_NINJA_REELING`, `RO_NINJA_HAMSTRUNG`, `RO_NINJA_MAIMED`.
- Localizacion EN actualizada para reflejar Hamstrung/Maimed y el rider de concentracion.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Status_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Projectile_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

### Riesgos
- El rider de concentracion se modela como status `Disadvantage(Concentration)` por 1 turno (aproximacion tecnica estable) y no como chequeo explicito "si esta concentrando" en tiempo real.
- `Maimed` combina slow fuerte y penalizador ofensivo; puede requerir tuning de duracion/valor tras playtest.

### Regresion minima
1. L3 Crippling Kunai: en fallo CON debe aplicar `Hamstrung` (movimiento -3m).
2. L5/L9 Crippling Kunai: sobre objetivo ya Hamstrung y fallo CON debe aplicar `Maimed`.
3. L9 Crippling Kunai: verificar +1d8 solo contra `Hamstrung` o `Maimed`.
4. L9 Razor Shuriken: sobre objetivo bleeding debe aplicar debuff de concentracion por 1 turno.
5. Throwing Mastery: confirmar bono condicional tambien con `Reeling/Hamstrung/Maimed`.

## 48) Migracion B2 - Mist Slash L9 condicional (Ninja)
### Sintoma / objetivo
- `Mist Slash` nivel 9 aplicaba `+1 Attack Roll` siempre, pero el diseno pide que ese bono sea condicional (aislado o condicionado).

### Causa raiz
- El passive `RO_Ninja_MistSlash_L9` tenia un `RollBonus(Attack,1)` sin ninguna condicion de target.

### Solucion final aplicada
- Se actualizo `RO_Ninja_MistSlash_L9` para que el `+1 Attack Roll` solo aplique cuando el objetivo este condicionado.
- Set de condiciones aplicado (alineado al modelo Throwing actual del mod):
  - `BLEEDING`, `OFF_BALANCED`, `DAZED`, `SLOWED`,
  - `RO_NINJA_REELING`, `RO_NINJA_HAMSTRUNG`, `RO_NINJA_MAIMED`, `RO_NINJA_KUNAI_EXPOSED`.
- Se actualizo tooltip EN de `Mist Slash` L9 para reflejar que el +1 es condicional.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

### Riesgos
- El componente "target aislado" no se implemento en esta iteracion por falta de una condicion runtime clara ya usada en el repo; se priorizo la mitad segura del diseno (target condicionado) sin romper estabilidad.

### Regresion minima
1. L9 Mist Slash sobre target sin condicion: no debe recibir +1 Attack Roll.
2. L9 Mist Slash sobre target con cualquier condicion del set: debe recibir +1 Attack Roll.
3. Confirmar que dano base (+2d6) y reposicion de 3m permanecen iguales.

## 49) Hotfix startup crash - Ninja (pre-menu CTD)
### Sintoma
- El juego se cerraba automaticamente antes de llegar al menu principal.

### Causa raiz
- Se introdujo `UTF-8 BOM` al inicio de archivos criticos de carga temprana:
  - `Status_RO_Ninja.txt`
  - `Spell_Projectile_RO_Ninja.txt`
  - `ScriptExtender/Lua/BootstrapServer.lua`
- En esta base, ese BOM al inicio de stats/lua puede romper parse/carga durante startup.

### Solucion final
- Se reescribieron los archivos afectados en `UTF-8 sin BOM`.
- Se mantuvo `RO_NinjaDisciplineFreeSwitch.lua` deshabilitado en bootstrap para aislar riesgo de startup:
  - `-- Ext.Require("RO_NinjaDisciplineFreeSwitch.lua")`
- Se reconstruyo el `.pak` y se redeployo en:
  - `C:\Users\jufeg\AppData\Local\Larian Studios\Baldur's Gate 3\Mods\RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903.pak`

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Status_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Projectile_RO_Ninja.txt`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/ScriptExtender/Lua/BootstrapServer.lua`
- `Package/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903.pak`

### Riesgos
- `RO_NinjaDisciplineFreeSwitch.lua` queda temporalmente fuera de carga; la funcionalidad de switch gratis no se evalua en runtime hasta reactivarlo.
- Si hay cache vieja en BG3MM/perfil, podria seguir cargando estado previo hasta refrescar load order.

### Regresion minima
1. Lanzar juego y confirmar que llega al menu principal sin CTD.
2. Cargar partida y confirmar que el mod aparece activo.
3. Probar Ninja L2/L3 rapido:
- Discipline on/off
- Thrown Technique
- Throwing Art
4. Confirmar que no reaparecen cierres al abrir menu de level up o al entrar en combate.

## 50) Reactivacion A2 - Ninja Discipline free switch por turno
### Sintoma / objetivo
- Se retoma la tarea `A2` del plan de migracion para que el primer cambio de disciplina por turno sea gratis en runtime.
- Estado previo: el modulo de free switch estaba documentado pero fuera de carga en `BootstrapServer.lua`.

### Causa raiz
- `RO_NinjaDisciplineFreeSwitch.lua` no existia en la carpeta Lua actual, por lo que no habia reembolso de Bonus Action en el primer switch del turno.

### Solucion final aplicada
- Se agrego `ScriptExtender/Lua/RO_NinjaDisciplineFreeSwitch.lua`.
- Se habilito su carga en `ScriptExtender/Lua/BootstrapServer.lua`.
- Logica aplicada:
  - Track por personaje de `EnteredCombat`, `TurnStarted`, `LeftCombat`.
  - En `UsingSpell`, si el spell es uno de los 6 de disciplina (`Throwing/Shadow/Ninpou` ON/OFF) y es el primer cambio de ese turno, se reembolsa 1 `BonusActionPoint` con `PartyIncreaseActionResourceValue`.
  - Cambios adicionales en el mismo turno no se reembolsan.

### Archivos tocados
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/ScriptExtender/Lua/RO_NinjaDisciplineFreeSwitch.lua` (nuevo)
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/ScriptExtender/Lua/BootstrapServer.lua`

### Riesgos
- Como el modelo es por reembolso (y no por coste 0 nativo), si alguna ejecucion puntual no descuenta BA antes del evento, podria verse +1 BA neto.
- El flujo se aplica en combate, alineado con economia de turnos.

### Regresion minima
1. Iniciar combate con Ninja y observar BA inicial.
2. Usar un cambio de disciplina (ON u OFF): BA final debe quedar igual.
3. Usar un segundo cambio de disciplina en el mismo turno: BA debe gastarse normalmente.
4. Iniciar turno nuevo y repetir: el primer cambio vuelve a ser gratis.
## 51) Ninja Discipline - L5 action economy + short rest alignment
### Sintoma / objetivo
- Ajustar Ninja Discipline segun decision de diseno actual de iteracion:
  - Nivel 2: cada cambio de disciplina cuesta `Bonus Action + 1 MP`.
  - Nivel 5: cada cambio de disciplina cuesta `1 MP` (sin Bonus Action).
  - La disciplina activa debe mantenerse hasta Short Rest (no 2 turnos de tooltip heredado).

### Solucion aplicada
- `Spell_Shout.txt`
  - `Shout_RO_NinjaDiscipline_Throwing/_Off`, `Shadow/_Off`, `Ninpou/_Off` (L2):
    - `UseCosts` actualizado a `BonusActionPoint:1;RO_MP:1`.
  - Se agregaron variantes L5:
    - `Shout_RO_NinjaTraining_On_5`, `Shout_RO_NinjaTraining_Off_5`.
    - `Shout_RO_NinjaDiscipline_Throwing_5/_Off_5`, `Shadow_5/_Off_5`, `Ninpou_5/_Off_5`.
    - `UseCosts` en variantes L5: `RO_MP:1`.
  - Se intento neutralizar tooltip heredado de duracion con `TooltipStatusApply ""` en variantes ON de disciplina.

- `Passive.txt`
  - Nuevo passive oculto `RO_Ninja_Discipline_L5` que desbloquea los contenedores L5.

- `Progressions.lsx`
  - Ninja nivel 5:
    - `PassivesAdded` ahora incluye `RO_Ninja_Discipline_L5`.
    - `PassivesRemoved` ahora incluye `RO_Ninja_Discipline`.

- `RO_StanceRest.lua`
  - Se agregaron los tres status de disciplina a limpieza en `ShortRested`:
    - `RO_NINJA_DISCIPLINE_THROWING`
    - `RO_NINJA_DISCIPLINE_SHADOW`
    - `RO_NINJA_DISCIPLINE_NINPOU`

- `Localization/English/english.xml`
  - Textos de Ninja Discipline actualizados para indicar "until your next Short Rest".

### Estado actual / verificacion
- Economia de accion de L2/L5 queda implementada en stats.
- Remocion por short rest queda cableada por Script Extender.
- La presentacion de duracion en tooltip puede seguir mostrando texto heredado segun cache/UI de juego; la fuente funcional (status + limpieza por short rest) ya queda alineada.

### Regresion minima recomendada
1. L2: cambiar de disciplina consume `Bonus Action + 1 MP`.
2. L5: cambiar de disciplina consume solo `1 MP`.
3. Hacer Short Rest: disciplina activa se remueve.
4. Confirmar que ON/OFF siguen alternando una sola disciplina activa por `StackId` compartido.

## 52) Migracion A3 - Ninja Discipline bonuses por rama (ajuste runtime)
### Sintoma / objetivo
- Alinear `Ninja Discipline` con A3:
  - Throwing: bonus base en tecnicas de throw + bonus adicional contra objetivos condicionados.
  - Shadow: mantener identidad de movilidad.
  - Ninpou: mantener +Spell Attack / +Spell Save DC.

### Causa raiz
- `RO_NINJA_DISCIPLINE_THROWING` tenia `SpellAttackRollBonus(1)` global (afectaba todo spell attack).
- `RO_Ninja_ThrowingMastery_Bonus` solo daba +1 base y no tenia capa condicional por estado del objetivo.

### Solucion final aplicada
- `Status_RO_Ninja.txt`
  - `RO_NINJA_DISCIPLINE_THROWING` deja de aplicar bonus global de spell attack.
- `Passive.txt`
  - `RO_Ninja_ThrowingMastery_Bonus` ahora tiene dos capas:
    - +1 a tecnicas de throw (Shuriken/Kunai/Huuma por tiers).
    - +1 adicional si el objetivo esta condicionado (`BLEEDING`, `OFF_BALANCED`, `DAZED`, `SLOWED`, `RO_NINJA_REELING`, `RO_NINJA_HAMSTRUNG`, `RO_NINJA_MAIMED`, `RO_NINJA_KUNAI_EXPOSED`).
- `english.xml`
  - Tooltip de Throwing Mastery actualizado para reflejar `+1 base` y `+1 adicional vs condicionados`.

### Regresion minima
1. Con Throwing activa y objetivo sin condicion: +1 al ataque en tecnicas de throw.
2. Con Throwing activa y objetivo condicionado: +2 total al ataque en tecnicas de throw.
3. Confirmar que Shadow sigue dando +3m movimiento.
4. Confirmar que Ninpou sigue dando +1 Spell Attack y +1 Spell Save DC.

## 53) Migracion A4 - Thrown Technique al modelo condicional (MVP estable)
### Sintoma / objetivo
- `Thrown Technique` seguia en modelo legacy (Kunai centrado en `Exposed Armor` y sin payoffs condicionales claros en Shuriken/Huuma).
- Objetivo A4: migrar a un modelo condicional estable sin romper economy ni tiers existentes.

### Solucion final aplicada
- `Spell_Projectile_RO_Ninja.txt`
  - `Throw Shuriken` (L2/L5/L9):
    - mantiene dano base por tier,
    - agrega dano extra vs objetivos condicionados: `+1d4 / +1d6 / +1d8`.
  - `Throw Kunai` (L2/L5/L9):
    - elimina dependencia de `Exposed Armor (-AC)`,
    - en fallo de CON aplica estado de presion (misma key tecnica `RO_NINJA_KUNAI_EXPOSED`) por `2 / 3 / 3` turnos.
  - `Throw Huuma` (L2/L5/L9):
    - mantiene dano base por tier,
    - agrega dano extra vs condicionados: `+1d4 / +1d6 / +1d8`.
    - L9 agrega rider: si objetivo condicionado falla STR, aplica `OFF_BALANCED`.

- `Status_RO_Ninja.txt`
  - `RO_NINJA_KUNAI_EXPOSED` migrado a efecto de precision-pressure:
    - de `AC(-1)` -> `RollBonus(Attack,-1)`.

- `Localization/English/english.xml`
  - Tooltips de Shuriken/Kunai/Huuma y textos de mejora por tier actualizados al modelo condicional.
  - Status `h2ninjathrowng0021/0022` renombrado de `Exposed Armor` a `Reeling` con descripcion de `-1 Attack Rolls`.

### Notas de compatibilidad
- Para minimizar riesgo de regresion, se reutiliza la key de status `RO_NINJA_KUNAI_EXPOSED` (sin introducir ID nueva).
- El passive de Throwing Mastery ya reconoce este estado dentro del set de "conditioned targets".

### Regresion minima
1. Shuriken L2/L5/L9: confirmar dano extra solo cuando el objetivo esta condicionado.
2. Kunai L2/L5/L9: confirmar que en fallo CON aplica estado de `Reeling` (penalizador de ataque) y ya no baja AC.
3. Huuma L2/L5/L9: confirmar dano extra en condicionados.
4. Huuma L9: sobre objetivo condicionado, confirmar aplicacion de `Off Balance` en fallo STR.
5. Confirmar que costes/rangos siguen iguales: Shuriken `1 MP / 18m`, Kunai `1 MP / 10m`, Huuma `2 MP / 10m`.

## 54) Hotfix A5 - Shadow Jump (buff por tier + rango 9/12/15 forzado)
### Sintoma / objetivo
- Regresion detectada en Ninja:
  - `Shadow Jump` seguia heredando comportamiento de `Misty Step` y podia mostrarse/permitirse como ~18m.
  - Escalado de follow-up no alineado al diseno A5:
    - faltaba buff en L2,
    - L9 seguia con +1 Attack en status,
    - persistia passive legacy `RO_Ninja_ShadowJump_L9_DamageBonus`.

### Solucion final aplicada
- `Spell_Target.txt`
  - `Target_RO_Ninja_ShadowJump_2`:
    - agrega `SpellSuccess ApplyStatus(RO_NINJA_SHADOW_JUMP_BUFF_L2,100,1)`,
    - agrega `TooltipStatusApply` de L2,
    - agrega `TargetRadius 9`.
  - `Target_RO_Ninja_ShadowJump_5`:
    - mueve apply de `SpellProperties` a `SpellSuccess`,
    - agrega `TargetRadius 12`.
  - `Target_RO_Ninja_ShadowJump_9`:
    - mueve apply de `SpellProperties` a `SpellSuccess`,
    - agrega `TargetRadius 15`.

- `Status_RO_Ninja.txt`
  - nuevo status `RO_NINJA_SHADOW_JUMP_BUFF_L2` (`RollBonus(Attack,1)`).
  - `RO_NINJA_SHADOW_JUMP_BUFF_L9` sube a `RollBonus(Attack,2)`.

- `Passive.txt`
  - reemplazo de passive legacy:
    - `RO_Ninja_ShadowJump_L9_DamageBonus` -> `RO_Ninja_ShadowJump_Followup`.
  - `RO_Ninja_ShadowJump_Followup`:
    - consume buff de L2/L5/L9 en el primer hit valido,
    - aplica dano adicional por tier:
      - L5: `+1d4 Force`
      - L9: `+1d6 Force`

- `Progressions.lsx`
  - Nivel 2 agrega `RO_Ninja_ShadowJump_Followup`.
  - Nivel 9 deja de agregar `RO_Ninja_ShadowJump_L9_DamageBonus` y lo remueve por compatibilidad.

- `english.xml`
  - tooltips de Shadow Jump actualizados para reflejar:
    - L2: +1 Attack en siguiente hit,
    - L9: +2 Attack +1d6.

### Regresion minima
1. L2: Shadow Jump solo targetea hasta 9m y da +1 Attack en siguiente hit.
2. L5: Shadow Jump solo targetea hasta 12m y da +1 Attack +1d4 en siguiente hit.
3. L9: Shadow Jump solo targetea hasta 15m y da +2 Attack +1d6 en siguiente hit.
4. Confirmar que el buff se consume en el primer hit valido (no persiste).
