# BG3 Ragnarok Mod - Handoff Guide

## 1) Objetivo actual
Proyecto MVP para BG3 inspirado en Ragnarok Online.
- Clase base: `RO_Novice`
- Primera subclase implementada para pruebas: `RO_Archer`
- Enfoque: iteraci�n m�nima viable (una feature por vez, test en juego, continuar)

## 2) Estructura clave del repo
- Mod source: `RagnarokOnlineMod/`
- Dise�o funcional: `Class Design/*.json`
- Referencias: `Reference/Packages/...`
- Herramientas: `Tools/`
- PAK de salida: `Package/`

Rutas cr�ticas:
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
- Descripci�n/lore en ingl�s
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
F�rmula exacta pedida por dise�o:
`(4 + (2 * character_level)) + (character_level * floor(spellcasting_modifier / 2))`

Notas:
- Sin fallback forzado (se quit� para validar c�lculo real).
- Novice base mantiene 6 MP por progresi�n base.
- Cuando existe pasivo marcador de f�rmula (`RO_MP_Formula_*`), Lua aplica ajuste por pasivo t�cnico `RO_MP_Adjust_*`.
- Para Archer se usa `RO_MP_Formula_WIS`.

Archivos t�cnicos:
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
- DDS en rutas Tooltips/ControllerUI (seg�n uso)
- `Icon` en `Passive.txt` o `Spell_*.txt` debe coincidir con nombre esperado

### Conversi�n PNG -> DDS
Script wrapper:
- `Tools/convert_icon_dds.ps1`

Ejemplo:
```powershell
powershell -ExecutionPolicy Bypass -File .\Tools\convert_icon_dds.ps1 -InputPath "RagnarokOnlineMod/Icons/archer_class.png" -BaseName "RO_Archer" -OutDir "RagnarokOnlineMod/Icons/dds" -Sizes 24x24,380x380
```

Tambi�n acepta `-Input` como alias.

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

## 7) Checklist r�pido para otro chat
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
- "Invalid file" al importar: normalmente por estructura/formato de archivos GUI o XML/LSX inv�lido.
- Icono no aparece: faltaba registro en `GUI/metadata.lsf` o path no coincid�a.
- MP se queda en 6: Lua no cargado o marcador de f�rmula no aplicado en el nivel correcto.

## 9) Pr�ximo paso recomendado
Despu�s de validar Archer + MP en runtime:
- Implementar siguiente job (sugerido: `Acolyte` o `Swordman`) con el mismo patr�n:
  - marcador de f�rmula (`RO_MP_Formula_*`) seg�n spellcasting stat
  - progression m�nima viable
  - 1 skill funcional
  - test in-game

---
Este documento busca que cualquier nuevo chat continue sin reconstruir contexto hist�rico.

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
- Cambio entre stances consume recurso correctamente y hace overwrite por `StackId` com�n.

## 11) Lecci�n clave: rango y desventaja
Problema detectado:
- En Stats puros no encontramos una condici�n robusta para "fuera del rango normal del arma equipada actual".
- Soluci�n previa basada en `Advantage(...)` por distancia fija causaba ventaja falsa en rangos medios (ej. 11-12m).

Conclusi�n:
- Para l�gica de rango dependiente del arma equipada, usar Script Extender (SE).

## 12) Migraci�n a SE para Vulture's Eye
### Qu� qued� activo
- Nuevo m�dulo SE: `ScriptExtender/Lua/RO_VulturesEye.lua`
- Cargado desde: `ScriptExtender/Lua/BootstrapServer.lua`

### Qu� hace
- Detecta si el personaje tiene una status de Vulture's Eye activa.
- Detecta arma a distancia equipada.
- Aplica un pasivo t�cnico anti-desventaja seg�n umbral por arma (09/15/18m).
- Limpia ese pasivo al salir de la stance o cambiar contexto.

### Pasivos t�cnicos a�adidos (actual)
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

## 13) Regla pr�ctica para pr�ximas skills
- Preferir `Stats/Progressions` cuando la l�gica es est�tica y declarativa.
- Usar `SE` solo cuando se necesite l�gica din�mica/contextual (arma equipada, estado runtime, c�lculos avanzados).
- Mantener historial en `Reference/Notes/Archived/` cuando se retire una soluci�n para facilitar rollback y auditor�a.



## 14) Estado validado en juego (checkpoint estable)
Todo lo siguiente fue validado en runtime:
- Cambio de stances funciona (`Owl's Eye` <-> `Vulture's Eye`) y consume `RO_MP`.
- `Owl's Eye` aplica bonus de attack roll correctamente.
- `Vulture's Eye`:
  - ignora desventaja melee con ballestas,
  - aumenta rango efectivo por tier,
  - aplica da�o extra por distancia (`+1d4`/`+1d6`) y en L12 (`+1d12` global).
- `Double Strafe`:
  - ejecuta 2 hits reales,
  - hereda bonos de stance,
  - aplica correctamente bonus de Vulture en ambos impactos.
- Fuera del rango extendido vuelve a existir desventaja (no queda neutralizada infinito).

## 15) Template de implementaci�n (para futuros chats)
### Paso A: Definir en Stats (base declarativa)
1. Crear/actualizar spell o stance en `Spell_*.txt`.
2. Crear/actualizar status en `Status_*.txt`.
3. Exponer/otorgar v�a `Passive.txt` + `Progressions.lsx`.
4. Mantener naming consistente (`*_L2`, `*_L5`, `*_L9`, `*_L12`).

### Paso B: Detectar si hace falta SE
Usar Script Extender cuando haya l�gica din�mica como:
- arma equipada cambia reglas,
- ventanas de distancia por tier,
- multi-hit encadenado,
- sincronizaci�n runtime por status/eventos.

### Paso C: Patr�n SE recomendado
1. Crear m�dulo `ScriptExtender/Lua/<Feature>.lua`.
2. Registrar en `BootstrapServer.lua` con `Ext.Require(...)`.
3. Escuchar eventos m�nimos necesarios (`StatusApplied/Removed`, equip change, etc.).
4. Aplicar pasivos t�cnicos acotados y limpiarlos al salir del estado.
5. Evitar fallback silencioso durante debug (para detectar errores r�pido).

### Paso D: Validaci�n m�nima en juego
1. Skill/stance visible y casteable.
2. Coste de recurso correcto.
3. Aplicaci�n/remoci�n de status esperada.
4. Combat log confirma da�o/rolls esperados por hit.
5. Prueba borde de distancia (dentro y fuera del rango extendido).
6. Prueba con al menos 2 armas de distinto rango (ej. hand crossbow y longbow).

### Paso E: Si algo falla
Orden de diagn�stico:
1. Ver si falla visibilidad/desbloqueo (Progression/Passive).
2. Ver si falla ejecuci�n (SpellSuccess/RequirementConditions).
3. Ver si falla herencia de bonos (context.Source vs target, OnDamage functors).
4. Ver si falla por timing (resolver con listener SE + delay corto).
5. Documentar hallazgo y dejar nota en este archivo.

## 16) Arrow Crafting + Double Strafe (estado final estable)
### Resumen
- Arrow Crafting qued� migrado a Script Extender para controlar proc por impacto real.
- Se elimin� la dependencia de passives OnDamage para aplicar da�o elemental de Arrow Craft.
- Consumo de cargas y da�o elemental ahora se resuelven en flujo �nico de SE.

### Problemas observados y causa ra�z
1. Doble proc con `Vulture's Eye` en segundo hit de `Double Strafe`.
- Causa: m�ltiples eventos/functors sobre followup disparaban m�s de una aplicaci�n elemental.

2. Cargas consumidas sin da�o elemental visible.
- Causa: el enfoque con `UseSpell` t�cnico desde SE no estaba aplicando da�o de forma confiable en este contexto.

### Soluci�n final aplicada
- En `RO_ArrowCraft.lua`:
  - `UsingSpellOnTarget` registra intentos v�lidos de ataque con `StoryActionID`.
  - `AttackedBy` confirma hit real (`damageAmount > 0`) y ejecuta proc UNA sola vez por acci�n.
  - El proc aplica `Status` t�cnico al objetivo (`RO_ARCHER_ARROWCRAFT_PROC_*`) con `OnApplyFunctors`.
  - Luego consume exactamente 1 carga (`3->2`, `2->1`, `1->0`) y limpia estado de crafting al agotar.

- En `Status_RO_Archer.txt`:
  - Se agregaron statuses t�cnicos `RO_ARCHER_ARROWCRAFT_PROC_*` (16 variantes: 4 elementos x 4 tiers).
  - Cada status usa `OnApplyFunctors` con da�o elemental inmediato.
  - Tiers con efecto secundario usan DC din�mica:
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
- Los spells t�cnicos `Target_RO_ArrowCraft_Proc_*` en `Spell_Target.txt` quedaron como intento intermedio y no son necesarios para la versi�n final estable basada en status on-hit.
- Mantener `RO_ArrowCraft.lua` como fuente de verdad para proc/consumo.

### Checklist de regresi�n (r�pido)
1. Ataque normal con Fire/Poison/Shock/Radiant Arrow:
- aplica da�o elemental y consume 1 carga.
2. `Double Strafe`:
- aplica da�o elemental en ambos hits (uno por hit) sin duplicar en followup.
3. Con `Vulture's Eye` activo:
- no duplica da�o elemental adicional por hit.
4. Agotar cargas:
- remueve `RO_ARCHER_ARROW_CHARGE_*` y limpia estado de arrow crafting.

## 17) Archer Skill: Improve Concentration (L4/L6/L9/L12)
### Resumen
- Se implement� `Improve Concentration` como skill activa del Archer desde nivel 4.
- Es `Bonus Action`, cuesta `3 MP`, requiere `Concentration`.
- Escalado aplicado:
  - L4: +1 ranged attack rolls, +1 AC, 2 turnos.
  - L6: +2 ranged attack rolls, +2 AC, 2 turnos.
  - L9: +2 ranged attack rolls, +2 AC, 3 turnos.
  - L12: +2 ranged attack rolls, +2 AC, 3 turnos.

### Implementaci�n t�cnica
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
- Se a�adieron name/description entries para passives, shouts y statuses.

### Eficiencia L12 (MP)
- Se aplic� reducci�n de coste en `Double Strafe` tier 12 de forma expl�cita:
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
- N�cleo ofensivo: `Double Strafe`
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
- Skill de acci�n con coste MP, sin cooldown de Short Rest.
- Debe depender de MP (como el resto del kit), no de recarga por descanso corto.

3. `Arrow Repel`
- Aplica da�o de arma + bonus por tier.
- Empuja objetivo seg�n tier definido.
- Interact�a con el kit Archer (stances/buffs); se a�adi� compatibilidad para consumo de Arrow Craft cuando corresponde.

4. `Owl's Eye` vs `Vulture's Eye` en melee
- Regla de dise�o: ataques a distancia en melee tienen desventaja salvo excepciones.
- `Vulture's Eye` ignora point-blank disadvantage desde su adquisici�n.
- `Owl's Eye` no ignora point-blank en tiers bajos; su bypass est� planteado para tier alto del dise�o.
- `Arrow Repel` tiene ignore point-blank condicionado al propio spell (no es bypass global para todos los ataques).

5. Recursos/descansos (target final)
- `RO_MP` debe recargar en Long Rest.
- `Owl's Eye` y `Vulture's Eye` deben figurar con duraci�n/recovery alineada a Short Rest (seg�n decisi�n de dise�o cerrada en iteraci�n).

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

### Regresi�n m�nima para revalidar en siguiente chat
1. Ataque normal, `Double Strafe`, `Arrow Shower`, `Arrow Repel` con y sin Arrow Craft activo.
2. Verificar consumo de cargas por hit y limpieza al agotar.
3. Verificar que `Vulture's Eye` ignora desventaja point-blank y que fuera de ese caso no hay bypass global accidental.
4. Verificar tooltips/name/description/icon para skills nuevas (sin `Not Found` ni `?`).
5. Verificar que el gating principal de skills sea MP (no short-rest cooldown involuntario).

### Estado de proyecto
- Archer: `COMPLETADO` para MVP.
- Siguiente fase recomendada: iniciar siguiente job (Acolyte/Swordman o la clase priorizada) reutilizando patr�n `Stats + SE solo donde sea din�mico`.

## 19) Playbook para nuevos chats (contexto r�pido y consistente)
Objetivo: que cualquier chat nuevo pueda continuar sin perder tiempo ni romper consistencia.

### A) Orden recomendado de trabajo por skill
1. Leer dise�o fuente en `Class Design/<Class>.json`.
2. Confirmar nivel, coste MP, tipo de acci�n, duraci�n, escalado y sinergias.
3. Definir si se resuelve 100% en Stats o requiere SE:
- Stats: reglas declarativas estables (costes, boosts directos, unlocks, duration).
- SE: l�gica contextual/din�mica (multi-hit, ventanas por arma/rango, consumo por hit confirmado, sincronizaci�n de followups).
4. Implementar primero versi�n m�nima funcional.
5. Probar en juego.
6. Ajustar edge cases.
7. Documentar en este handoff lo que cambi� y por qu�.

### B) D�nde mirar referencias antes de implementar
1. Referencia interna del proyecto:
- `Reference/` (mods ejemplo y notas archivadas).
2. Implementaciones ya estables de este mod:
- `Double Strafe`, `Arrow Crafting`, `Improve Concentration`, `Arrow Shower`, `Arrow Repel`.
3. Buscar patrones con `rg` antes de copiar l�gica.

Consultas �tiles:
```powershell
rg -n "RO_Archer|ArrowCraft|DoubleStrafe|ArrowShower|ArrowRepel" RagnarokOnlineMod/Public
rg -n "Ext.Osiris|Ext.Events|StatusApplied|AttackedBy|UsingSpellOnTarget" RagnarokOnlineMod/Mods/*/ScriptExtender/Lua
```

### C) M�todo est�ndar para crear una skill nueva
1. `Spell_*.txt`
- Crear spell (o shout/zone/projectile seg�n tipo).
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
- Reusar iconos vanilla v�lidos o registrar custom assets correctamente.
- Si aparece `?`, revisar key de icono + metadata/ruta.

7. SE (solo si hace falta)
- Crear m�dulo en `ScriptExtender/Lua/`.
- Registrar en `BootstrapServer.lua`.
- Mantener una sola fuente de verdad para la l�gica cr�tica.

### D) Criterio para decidir Stats vs SE
Usar Stats si:
- El efecto depende solo del caster/target sin estado complejo temporal.
- No depende de confirmar impacto real por evento.

Usar SE si:
- Hay multi-hit con followups.
- Se debe consumir recurso por hit confirmado.
- Hay condiciones por contexto runtime (arma equipada, rango real, acci�n ligada por `StoryActionID`, etc.).

### E) Checklist de validaci�n por skill (r�pido)
1. Tooltip correcto: nombre, descripci�n, coste, duraci�n.
2. Gating correcto: acci�n/bonus action + MP.
3. Sin cooldown oculto no deseado (si la skill no lo define).
4. Da�o/efecto aparece en combat log.
5. Escalado por nivel correcto.
6. Interacci�n con stances/buffs del Archer correcta.
7. No duplica procs ni consume de m�s.
8. Al reempaquetar, la versi�n cargada en juego refleja cambios.

### F) Si en juego no se refleja un cambio
1. Reempaquetar PAK.
2. Confirmar mod activo en BG3MM.
3. Verificar que el archivo editado est� dentro del PAK.
4. Revisar colisiones con mods de referencia/otros mods.
5. Confirmar que la localizaci�n coincide con nuevas keys.

### G) Qu� actualizar siempre en el handoff al cerrar una tarea
1. Qu� problema hab�a (s�ntoma).
2. Causa ra�z encontrada.
3. Soluci�n final aplicada.
4. Archivos tocados.
5. Riesgos/edge-cases pendientes.
6. Checklist de regresi�n m�nima.

### H) Plantilla corta para iniciar un chat nuevo
Pegar esto al inicio del nuevo chat:
1. "Lee `GUIDE_HANDOFF.md` completo primero." 
2. "Trabajaremos en `<skill/feature>` de `<Class Design/*.json>` sin romper lo ya estable." 
3. "Antes de editar, lista archivos objetivo y estrategia (Stats vs SE)." 
4. "Despu�s de cambios, actualiza `GUIDE_HANDOFF.md` con causa ra�z + soluci�n + archivos tocados + tests." 

## 20) Magician Skill: Frost Diver (L3/L9/L12)
### Resumen
- Se implement� `Frost Diver` para Magician como skill de control single-target con save de Constituci�n.
- Coste: `4 MP`, tipo `Action`, rango `18m`.
- F�rmula de DC en runtime: `SourceSpellDC()` (equivale a `8 + proficiency + spellcasting ability modifier`).

### Escalado aplicado
- L3: `2d6 + SpellCastingAbilityModifier` (Cold), y en save fallido aplica `FROZEN` por 1 turno.
- L9: `3d6 + SpellCastingAbilityModifier` (Cold), y en save fallido aplica `FROZEN` por 2 turnos.
- L12: `4d6 + SpellCastingAbilityModifier` (Cold), y en save fallido aplica `FROZEN` por 2 turnos.

### Implementaci�n t�cnica
1. `Spell_Target.txt`
- Nuevos spells:
  - `Target_RO_Magician_FrostDiver`
  - `Target_RO_Magician_FrostDiver_9`
  - `Target_RO_Magician_FrostDiver_12`
- `SpellRoll`: `not SavingThrow(Ability.Constitution, SourceSpellDC())`.
- `SpellSuccess`/`SpellFail` configurados para mantener da�o en ambos casos y status solo en save fallido.

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
- Se a�adieron entries de localizaci�n para:
  - nombre y descripciones de passive por tier,
  - nombre del spell y descripciones por tier.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Target.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

## 21) Magician Skill: Element AoE (L5/L9/L12) - MVP Stats
### Resumen
- Se implement� `Element AoE` para Magician con estructura modular `Base / Intensified / Overload` y variantes `Fire` + `Lightning`.
- Costes activos:
  - Base: `4 MP`
  - Intensified: `5 MP`
  - Overload: `6 MP`
- Gating por progresi�n:
  - L5: desbloquea tier base de la skill.
  - L9: reemplaza por versi�n mejorada de da�o.
  - L12: reemplaza por versi�n final con mayor radio y da�o.

### Implementaci�n t�cnica
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
- Fire Overload: a�ade da�o extra `1d4 Fire`.
- Lightning Intensified: CON save o `SHOCKED` 1 turno.
- Lightning Overload: da�o extra `1d4 Lightning` si el objetivo est� `SHOCKED`.

### Nota de alcance (importante)
- Esta entrega es `MVP en Stats` (sin Script Extender).
- La parte de "storm zone" persistente por turnos de Lightning en dise�o original qued� simplificada a explosi�n AoE instant�nea.
- Si se quiere comportamiento persistente robusto por turnos (strikes por turno, trigger al entrar/salir), conviene migrar esa parte a SE en iteraci�n posterior.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Zone_RO_Magician.txt` (nuevo)
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`

## 22) Magician Element AoE - Hotfix UI/Shape
### Problema
- En juego aparec�a `Not Found` para nombre/descripci�n de variantes de Element AoE.
- El �rea se mostraba no circular.

### Causa ra�z
- `DisplayName`/`Description` se hab�an dejado como texto directo en stats (sin `contentuid` de localizaci�n), lo que en esta ruta termin� resolviendo a `Not Found`.
- Las variantes base estaban con `Shape = Square`.

### Fix aplicado
- `Spell_Zone_RO_Magician.txt`:
  - Se cambiaron `DisplayName`/`Description` de contenedores y variantes L5 a contentuids nuevos.
  - Se cambi� `Shape` de las variantes base Fire/Lightning a `Circle`.
- `Passive.txt`:
  - `RO_Magician_ElementAoE_L5/L9/L12` ahora usan contentuids para `DisplayName`/`Description`.
- `Localization/English/english.xml`:
  - Se a�adieron entradas para los contentuids nuevos de Element AoE.

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
### S�ntoma reportado
- `Throwing Mastery` se casteaba pero no dejaba condici�n/bono activo y no habilitaba salida OFF.
- `Thrown Technique` mostraba comportamiento inestable: faltaba `Throw Shuriken` y las acciones de throw no eran consistentes al usarse.
- `Throw Kunai` mostraba tooltip confuso por duraci�n (`2 turns`) y en pruebas no quedaba claro el coste MP.

### Causa ra�z
1. La boost de `RO_NINJA_DISCIPLINE_THROWING` inclu�a una expresi�n no estable para este contexto, provocando que el estado no se consolidara correctamente.
2. La implementaci�n de throws depend�a de una estructura con herencias parciales que introdujo comportamiento inconsistente en desbloqueo/ejecuci�n.
3. Parte del feedback visual (tooltip de estado) mezclaba informaci�n �til con ruido para la UX de test.

### Soluci�n final aplicada
- Se dej� `Throwing Mastery` con status simple y v�lido (`SpellAttackRollBonus(1)`) y se movi� el `+1 Attack Roll` de throws a un passive oculto condicional por estado activo + `SpellId` de throws ninja:
  - nuevo passive: `RO_Ninja_ThrowingMastery_Bonus`.
- Se reescribi� `Thrown Technique` como 3 skills directas y expl�citas (sin contenedor):
  - `Projectile_RO_Ninja_ThrowShuriken_*`
  - `Projectile_RO_Ninja_ThrowKunai_*`
  - `Projectile_RO_Ninja_ThrowHuuma_*`
- Se normalizaron costes/rangos:
  - Shuriken: 18m, 1 MP.
  - Kunai: 10m, 1 MP.
  - Huuma: 10m, 2 MP, radio 2m.
- Se agreg� `DexterityModifier` al da�o base/escalados para alinear con dise�o.
- Se reforz� `Shout_RO_NinjaDiscipline_Throwing` con `TargetConditions "Self()"` y tooltip de estado aplicado.

### Archivos tocados
- `Class Design/ninja.json`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Projectile_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Shout.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Status_RO_Ninja.txt`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

### Riesgos abiertos
- `Huuma` a�n no aplica expl�citamente da�o secundario diferenciado por objetivo en el mismo impacto (MVP actual: da�o principal + configuraci�n AoE de radio).
- El uso de `DexterityModifier` en `DealDamage(...)` depende del parser/runtime del juego; si BG3 ignora esa parte, puede requerir ajuste con f�rmula alternativa.

### Regresi�n m�nima a validar
1. Subir a Novice 2 -> Ninja y confirmar que aparecen 3 acciones: Shuriken/Kunai/Huuma.
2. Verificar costes: 1/1/2 MP respectivamente.
3. Activar Throwing Mastery y confirmar:
   - aparece estado activo,
   - aparece opci�n OFF,
   - los throws ganan +1 al ataque (combat log).
4. Cambiar a Shadow/Ninpou y confirmar que Throwing bonus deja de aplicar.

## 32) Ninja Throws: desventaja por "outside normal range" (hotfix)
### S�ntoma
- `Throw Shuriken`, `Throw Kunai` y `Throw Huuma Shuriken` mostraban `Disadvantage` con motivo `Target outside normal range` incluso en situaciones donde la intenci�n era un rango fijo de skill.

### Causa ra�z
- Los throws estaban configurados con `HasHighGroundRangeExtension`, lo que habilita disparo fuera del rango normal con desventaja.
- Adem�s, al usar `RangedWeaponAttack`, el c�lculo puede depender del contexto de arma equipada y generar comportamiento confuso para t�cnicas custom.

### Soluci�n final
- En `Spell_Projectile_RO_Ninja.txt`:
  - `SpellRoll` de throws ninja migrado a `Attack(AttackType.RangedSpellAttack)`.
  - `TooltipAttackSave` actualizado a `RangedSpellAttack`.
  - `SpellFlags` simplificado a `HasSomaticComponent;IsSpell;IsHarmful` (sin `HasHighGroundRangeExtension`).
- Resultado esperado: los throws respetan su rango base (18/10/10) sin extenderse con desventaja por fuera de rango normal.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Projectile_RO_Ninja.txt`

### Riesgos
- `RangedSpellAttack` usa pipeline de spell attack; validar que la sensaci�n de precisi�n se mantenga seg�n el balance esperado de Ninja.

### Regresi�n m�nima
1. Con Ninja L2, verificar que Shuriken/Kunai/Huuma ya no muestren `Target outside normal range` + desventaja al apuntar dentro de su rango.
2. Verificar que fuera de rango simplemente no permita seleccionar/castear el objetivo.
3. Confirmar que consumo MP (1/1/2) y da�o siguen correctos.

## 33) Balance pass solicitado (Shuriken/Kunai/Huuma)
### S�ntoma
- `Shuriken` quedaba opacado por `Kunai` (mismo coste, menos da�o y sin utilidad extra).
- `Kunai` aplicaba `-1 AC` por demasiado tiempo para su coste.
- `Huuma` se sent�a correcto en coste, pero con radio bajo para rol AoE.

### Causa ra�z
- Balance inicial demasiado lineal: `Kunai` era estrictamente mejor que `Shuriken` en casi todo.

### Soluci�n final aplicada
- `Shuriken`: se a�adi� identidad de precisi�n con `+2 Attack Roll` (pasivo oculto condicional por `SpellId` de shuriken).
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

### Regresi�n m�nima
1. Confirmar Shuriken con mejor tasa de impacto respecto a Kunai en mismo objetivo.
2. Confirmar Kunai aplica `Exposed Armor` y expira en 1 turno.
3. Confirmar Huuma L2 impacta en 3m y L5+ en 4m.
4. Confirmar costes MP: Shuriken 1, Kunai 1, Huuma 2.

## 34) Ninja Shadow Jump (L2/L5/L9) - MVP funcional
### S�ntoma / objetivo
- Se solicit� implementar `Shadow Jump` como siguiente skill de Ninja:
  - L2: teleport 9m, Bonus Action, 2 MP.
  - L5: teleport 12m + bono al siguiente ataque/t�cnica.
  - L9: teleport 15m + bono al siguiente ataque/t�cnica + da�o extra.

### Causa ra�z previa
- La subclase Ninja a�n no ten�a `Shadow Jump` conectado en runtime (spell + passive + progression + loc).

### Soluci�n final aplicada
- Se implementaron 3 spells target basados en `Target_MistyStep`:
  - `Target_RO_Ninja_ShadowJump_2` (9m)
  - `Target_RO_Ninja_ShadowJump_5` (12m + status L5)
  - `Target_RO_Ninja_ShadowJump_9` (15m + status L9)
- Se a�adieron statuses:
  - `RO_NINJA_SHADOW_JUMP_BUFF_L5` -> `+1 Attack Roll`
  - `RO_NINJA_SHADOW_JUMP_BUFF_L9` -> `+1 Attack Roll`
- Se a�adi� passive t�cnico L9 de da�o:
  - `RO_Ninja_ShadowJump_L9_DamageBonus` (OnDamage, +1d6 Force mientras status L9 est� activo).
- Se a�adieron passives de unlock por milestone:
  - `RO_Ninja_ShadowJump_L2`
  - `RO_Ninja_ShadowJump_L5`
  - `RO_Ninja_ShadowJump_L9`
- Se conect� en `Progressions.lsx`:
  - L2 agrega `RO_Ninja_ShadowJump_L2`.
  - L5 agrega `RO_Ninja_ShadowJump_L5` y remueve `L2`.
  - L9 agrega `RO_Ninja_ShadowJump_L9` + `RO_Ninja_ShadowJump_L9_DamageBonus` y remueve `L5`.
- Se agregaron textos de localizaci�n para skill, upgrades y momentum buff.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Target.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Status_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

### Riesgos
- En L9, el +1d6 se implement� como passive `OnDamage` mientras el buff est� activo; si se hacen m�ltiples hits en ese turno, puede aplicarse m�s de una vez.

### Regresi�n m�nima
1. Ninja L2: aparece `Shadow Jump` (9m), consume Bonus Action + 2 MP.
2. Ninja L5: salta 12m y muestra buff de +1 Attack Roll.
3. Ninja L9: salta 15m, mantiene +1 Attack Roll y a�ade +1d6 Force en ataque/t�cnica durante el buff.

## 35) Shadow Jump icon fix (question mark)
### S�ntoma
- `Shadow Jump` aparec�a con icono de `?` en UI.

### Causa ra�z
- Se us� clave de icono no v�lida: `Spell_Illusion_MistyStep`.

### Soluci�n final
- Se reemplaz� por clave v�lida y conocida del juego: `Spell_Conjuration_MistyStep`.
- Se aplic� en spell, statuses de buff y passives de unlock para consistencia visual.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Target.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Status_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`

### Riesgos
- Si un entorno espec�fico no expone esa clave, el fallback ser�a `Spell_Conjuration_DimensionDoor`.

### Regresi�n m�nima
1. Verificar icono de `Shadow Jump` en barra y hoja de personaje.
2. Verificar icono del buff tras usar `Shadow Jump` L5/L9.

## 36) Containerizaci�n UI (Ninja Training + Thrown Technique)
### S�ntoma / objetivo
- Hab�a demasiadas skills sueltas en barra para Ninja.
- Se pidi� agrupar:
  - `Throwing Mastery`, `Shadow Arts`, `Ninpou Training` en un solo skill contenedor.
  - `Throw Shuriken`, `Throw Kunai`, `Throw Huuma` dentro de `Thrown Technique`.

### Causa ra�z
- Desbloqueo actual otorgaba cada sub-skill individualmente, saturando la barra.

### Soluci�n final aplicada
- `Ninja Discipline` migrado a patr�n contenedor y renombrado visualmente a `Ninja Training`:
  - contenedor ON: `Shout_RO_NinjaTraining_On`
  - contenedor OFF: `Shout_RO_NinjaTraining_Off`
  - subskills ON/OFF ahora usan `SpellContainerID`.
- Iconograf�a unificada por pedido:
  - activaciones: icono �nico `Action_MobileShooting`
  - desactivaciones: icono �nico `Action_SlashingFlourish_Ranged`
- `Thrown Technique` migrado a contenedor por tier:
  - `Projectile_RO_Ninja_ThrownTechnique_2`
  - `Projectile_RO_Ninja_ThrownTechnique_5`
  - `Projectile_RO_Ninja_ThrownTechnique_9`
  - subskills de shuriken/kunai/huuma enlazadas con `SpellContainerID`.
- Passives actualizados para desbloquear contenedores (no variantes sueltas).
- Localizaci�n ajustada para mostrar `Ninja Training` y acci�n de apagado (`Cancel Training`).

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Shout.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Projectile_RO_Ninja.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`

### Riesgos
- Como en cualquier contenedor de BG3, si una variante no cumple `RequirementConditions`, puede no mostrarse en ese momento; esto es esperado.

### Regresi�n m�nima
1. Verificar que aparece solo `Ninja Training` (ON/OFF) en lugar de 6 botones sueltos.
2. Verificar que `Thrown Technique` abre las 3 variantes seg�n tier.
3. Verificar que cada variante sigue consumiendo su MP correcto y aplica su efecto.
