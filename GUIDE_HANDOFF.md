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

### Pasivos técnicos añadidos (actual)
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

## 13) Regla práctica para próximas skills
- Preferir `Stats/Progressions` cuando la lógica es estática y declarativa.
- Usar `SE` solo cuando se necesite lógica dinámica/contextual (arma equipada, estado runtime, cálculos avanzados).
- Mantener historial en `Reference/Notes/Archived/` cuando se retire una solución para facilitar rollback y auditoría.



## 14) Estado validado en juego (checkpoint estable)
Todo lo siguiente fue validado en runtime:
- Cambio de stances funciona (`Owl's Eye` <-> `Vulture's Eye`) y consume `RO_MP`.
- `Owl's Eye` aplica bonus de attack roll correctamente.
- `Vulture's Eye`:
  - ignora desventaja melee con ballestas,
  - aumenta rango efectivo por tier,
  - aplica daño extra por distancia (`+1d4`/`+1d6`) y en L12 (`+1d12` global).
- `Double Strafe`:
  - ejecuta 2 hits reales,
  - hereda bonos de stance,
  - aplica correctamente bonus de Vulture en ambos impactos.
- Fuera del rango extendido vuelve a existir desventaja (no queda neutralizada infinito).

## 15) Template de implementación (para futuros chats)
### Paso A: Definir en Stats (base declarativa)
1. Crear/actualizar spell o stance en `Spell_*.txt`.
2. Crear/actualizar status en `Status_*.txt`.
3. Exponer/otorgar vía `Passive.txt` + `Progressions.lsx`.
4. Mantener naming consistente (`*_L2`, `*_L5`, `*_L9`, `*_L12`).

### Paso B: Detectar si hace falta SE
Usar Script Extender cuando haya lógica dinámica como:
- arma equipada cambia reglas,
- ventanas de distancia por tier,
- multi-hit encadenado,
- sincronización runtime por status/eventos.

### Paso C: Patrón SE recomendado
1. Crear módulo `ScriptExtender/Lua/<Feature>.lua`.
2. Registrar en `BootstrapServer.lua` con `Ext.Require(...)`.
3. Escuchar eventos mínimos necesarios (`StatusApplied/Removed`, equip change, etc.).
4. Aplicar pasivos técnicos acotados y limpiarlos al salir del estado.
5. Evitar fallback silencioso durante debug (para detectar errores rápido).

### Paso D: Validación mínima en juego
1. Skill/stance visible y casteable.
2. Coste de recurso correcto.
3. Aplicación/remoción de status esperada.
4. Combat log confirma daño/rolls esperados por hit.
5. Prueba borde de distancia (dentro y fuera del rango extendido).
6. Prueba con al menos 2 armas de distinto rango (ej. hand crossbow y longbow).

### Paso E: Si algo falla
Orden de diagnóstico:
1. Ver si falla visibilidad/desbloqueo (Progression/Passive).
2. Ver si falla ejecución (SpellSuccess/RequirementConditions).
3. Ver si falla herencia de bonos (context.Source vs target, OnDamage functors).
4. Ver si falla por timing (resolver con listener SE + delay corto).
5. Documentar hallazgo y dejar nota en este archivo.

## 16) Arrow Crafting + Double Strafe (estado final estable)
### Resumen
- Arrow Crafting quedó migrado a Script Extender para controlar proc por impacto real.
- Se eliminó la dependencia de passives OnDamage para aplicar daño elemental de Arrow Craft.
- Consumo de cargas y daño elemental ahora se resuelven en flujo único de SE.

### Problemas observados y causa raíz
1. Doble proc con `Vulture's Eye` en segundo hit de `Double Strafe`.
- Causa: múltiples eventos/functors sobre followup disparaban más de una aplicación elemental.

2. Cargas consumidas sin daño elemental visible.
- Causa: el enfoque con `UseSpell` técnico desde SE no estaba aplicando daño de forma confiable en este contexto.

### Solución final aplicada
- En `RO_ArrowCraft.lua`:
  - `UsingSpellOnTarget` registra intentos válidos de ataque con `StoryActionID`.
  - `AttackedBy` confirma hit real (`damageAmount > 0`) y ejecuta proc UNA sola vez por acción.
  - El proc aplica `Status` técnico al objetivo (`RO_ARCHER_ARROWCRAFT_PROC_*`) con `OnApplyFunctors`.
  - Luego consume exactamente 1 carga (`3->2`, `2->1`, `1->0`) y limpia estado de crafting al agotar.

- En `Status_RO_Archer.txt`:
  - Se agregaron statuses técnicos `RO_ARCHER_ARROWCRAFT_PROC_*` (16 variantes: 4 elementos x 4 tiers).
  - Cada status usa `OnApplyFunctors` con daño elemental inmediato.
  - Tiers con efecto secundario usan DC dinámica:
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
- Los spells técnicos `Target_RO_ArrowCraft_Proc_*` en `Spell_Target.txt` quedaron como intento intermedio y no son necesarios para la versión final estable basada en status on-hit.
- Mantener `RO_ArrowCraft.lua` como fuente de verdad para proc/consumo.

### Checklist de regresión (rápido)
1. Ataque normal con Fire/Poison/Shock/Radiant Arrow:
- aplica daño elemental y consume 1 carga.
2. `Double Strafe`:
- aplica daño elemental en ambos hits (uno por hit) sin duplicar en followup.
3. Con `Vulture's Eye` activo:
- no duplica daño elemental adicional por hit.
4. Agotar cargas:
- remueve `RO_ARCHER_ARROW_CHARGE_*` y limpia estado de arrow crafting.

## 17) Archer Skill: Improve Concentration (L4/L6/L9/L12)
### Resumen
- Se implementó `Improve Concentration` como skill activa del Archer desde nivel 4.
- Es `Bonus Action`, cuesta `3 MP`, requiere `Concentration`.
- Escalado aplicado:
  - L4: +1 ranged attack rolls, +1 AC, 2 turnos.
  - L6: +2 ranged attack rolls, +2 AC, 2 turnos.
  - L9: +2 ranged attack rolls, +2 AC, 3 turnos.
  - L12: +2 ranged attack rolls, +2 AC, 3 turnos.

### Implementación técnica
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
- Se añadieron name/description entries para passives, shouts y statuses.

### Eficiencia L12 (MP)
- Se aplicó reducción de coste en `Double Strafe` tier 12 de forma explícita:
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
- Núcleo ofensivo: `Double Strafe`
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
- Skill de acción con coste MP, sin cooldown de Short Rest.
- Debe depender de MP (como el resto del kit), no de recarga por descanso corto.

3. `Arrow Repel`
- Aplica daño de arma + bonus por tier.
- Empuja objetivo según tier definido.
- Interactúa con el kit Archer (stances/buffs); se añadió compatibilidad para consumo de Arrow Craft cuando corresponde.

4. `Owl's Eye` vs `Vulture's Eye` en melee
- Regla de diseño: ataques a distancia en melee tienen desventaja salvo excepciones.
- `Vulture's Eye` ignora point-blank disadvantage desde su adquisición.
- `Owl's Eye` no ignora point-blank en tiers bajos; su bypass está planteado para tier alto del diseño.
- `Arrow Repel` tiene ignore point-blank condicionado al propio spell (no es bypass global para todos los ataques).

5. Recursos/descansos (target final)
- `RO_MP` debe recargar en Long Rest.
- `Owl's Eye` y `Vulture's Eye` deben figurar con duración/recovery alineada a Short Rest (según decisión de diseño cerrada en iteración).

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

### Regresión mínima para revalidar en siguiente chat
1. Ataque normal, `Double Strafe`, `Arrow Shower`, `Arrow Repel` con y sin Arrow Craft activo.
2. Verificar consumo de cargas por hit y limpieza al agotar.
3. Verificar que `Vulture's Eye` ignora desventaja point-blank y que fuera de ese caso no hay bypass global accidental.
4. Verificar tooltips/name/description/icon para skills nuevas (sin `Not Found` ni `?`).
5. Verificar que el gating principal de skills sea MP (no short-rest cooldown involuntario).

### Estado de proyecto
- Archer: `COMPLETADO` para MVP.
- Siguiente fase recomendada: iniciar siguiente job (Acolyte/Swordman o la clase priorizada) reutilizando patrón `Stats + SE solo donde sea dinámico`.

## 19) Playbook para nuevos chats (contexto rápido y consistente)
Objetivo: que cualquier chat nuevo pueda continuar sin perder tiempo ni romper consistencia.

### A) Orden recomendado de trabajo por skill
1. Leer diseño fuente en `Class Design/<Class>.json`.
2. Confirmar nivel, coste MP, tipo de acción, duración, escalado y sinergias.
3. Definir si se resuelve 100% en Stats o requiere SE:
- Stats: reglas declarativas estables (costes, boosts directos, unlocks, duration).
- SE: lógica contextual/dinámica (multi-hit, ventanas por arma/rango, consumo por hit confirmado, sincronización de followups).
4. Implementar primero versión mínima funcional.
5. Probar en juego.
6. Ajustar edge cases.
7. Documentar en este handoff lo que cambió y por qué.

### B) Dónde mirar referencias antes de implementar
1. Referencia interna del proyecto:
- `Reference/` (mods ejemplo y notas archivadas).
2. Implementaciones ya estables de este mod:
- `Double Strafe`, `Arrow Crafting`, `Improve Concentration`, `Arrow Shower`, `Arrow Repel`.
3. Buscar patrones con `rg` antes de copiar lógica.

Consultas útiles:
```powershell
rg -n "RO_Archer|ArrowCraft|DoubleStrafe|ArrowShower|ArrowRepel" RagnarokOnlineMod/Public
rg -n "Ext.Osiris|Ext.Events|StatusApplied|AttackedBy|UsingSpellOnTarget" RagnarokOnlineMod/Mods/*/ScriptExtender/Lua
```

### C) Método estándar para crear una skill nueva
1. `Spell_*.txt`
- Crear spell (o shout/zone/projectile según tipo).
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
- Reusar iconos vanilla válidos o registrar custom assets correctamente.
- Si aparece `?`, revisar key de icono + metadata/ruta.

7. SE (solo si hace falta)
- Crear módulo en `ScriptExtender/Lua/`.
- Registrar en `BootstrapServer.lua`.
- Mantener una sola fuente de verdad para la lógica crítica.

### D) Criterio para decidir Stats vs SE
Usar Stats si:
- El efecto depende solo del caster/target sin estado complejo temporal.
- No depende de confirmar impacto real por evento.

Usar SE si:
- Hay multi-hit con followups.
- Se debe consumir recurso por hit confirmado.
- Hay condiciones por contexto runtime (arma equipada, rango real, acción ligada por `StoryActionID`, etc.).

### E) Checklist de validación por skill (rápido)
1. Tooltip correcto: nombre, descripción, coste, duración.
2. Gating correcto: acción/bonus action + MP.
3. Sin cooldown oculto no deseado (si la skill no lo define).
4. Daño/efecto aparece en combat log.
5. Escalado por nivel correcto.
6. Interacción con stances/buffs del Archer correcta.
7. No duplica procs ni consume de más.
8. Al reempaquetar, la versión cargada en juego refleja cambios.

### F) Si en juego no se refleja un cambio
1. Reempaquetar PAK.
2. Confirmar mod activo en BG3MM.
3. Verificar que el archivo editado está dentro del PAK.
4. Revisar colisiones con mods de referencia/otros mods.
5. Confirmar que la localización coincide con nuevas keys.

### G) Qué actualizar siempre en el handoff al cerrar una tarea
1. Qué problema había (síntoma).
2. Causa raíz encontrada.
3. Solución final aplicada.
4. Archivos tocados.
5. Riesgos/edge-cases pendientes.
6. Checklist de regresión mínima.

### H) Plantilla corta para iniciar un chat nuevo
Pegar esto al inicio del nuevo chat:
1. "Lee `GUIDE_HANDOFF.md` completo primero." 
2. "Trabajaremos en `<skill/feature>` de `<Class Design/*.json>` sin romper lo ya estable." 
3. "Antes de editar, lista archivos objetivo y estrategia (Stats vs SE)." 
4. "Después de cambios, actualiza `GUIDE_HANDOFF.md` con causa raíz + solución + archivos tocados + tests." 

## 20) Magician Skill: Frost Diver (L3/L9/L12)
### Resumen
- Se implementó `Frost Diver` para Magician como skill de control single-target con save de Constitución.
- Coste: `4 MP`, tipo `Action`, rango `18m`.
- Fórmula de DC en runtime: `SourceSpellDC()` (equivale a `8 + proficiency + spellcasting ability modifier`).

### Escalado aplicado
- L3: `2d6 + SpellCastingAbilityModifier` (Cold), y en save fallido aplica `FROZEN` por 1 turno.
- L9: `3d6 + SpellCastingAbilityModifier` (Cold), y en save fallido aplica `FROZEN` por 2 turnos.
- L12: `4d6 + SpellCastingAbilityModifier` (Cold), y en save fallido aplica `FROZEN` por 2 turnos.

### Implementación técnica
1. `Spell_Target.txt`
- Nuevos spells:
  - `Target_RO_Magician_FrostDiver`
  - `Target_RO_Magician_FrostDiver_9`
  - `Target_RO_Magician_FrostDiver_12`
- `SpellRoll`: `not SavingThrow(Ability.Constitution, SourceSpellDC())`.
- `SpellSuccess`/`SpellFail` configurados para mantener daño en ambos casos y status solo en save fallido.

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
- Se añadieron entries de localización para:
  - nombre y descripciones de passive por tier,
  - nombre del spell y descripciones por tier.

### Archivos tocados
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Spell_Target.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Stats/Generated/Data/Passive.txt`
- `RagnarokOnlineMod/Public/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Progressions/Progressions.lsx`
- `RagnarokOnlineMod/Mods/RO_Novice_08e09292-a7e0-4a5d-bbce-9d4ad4219903/Localization/English/english.xml`
