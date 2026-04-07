# Ninja Migration Plan (Nuevo Diseno)

## Objetivo
Migrar Ninja al nuevo diseno en pasos pequenos, validables, sin romper lo estable.

## Alcance actual
- Incluye: nivel 2 y nivel 3.
- Excluye por ahora: nivel 4+.

## Regla de ejecucion
- Hacemos 1 tarea por iteracion.
- Cada tarea termina con:
  1) cambios exactos por archivo,
  2) prueba minima,
  3) nota en GUIDE_HANDOFF.

---

## Fase A - Nivel 2 completo

### Tarea A1 - Runtime audit baseline (snapshot)
Estado: completada.
Resultado: detectamos gaps principales (Throwing Art faltante, stances no free, Shadow Jump desfasado, Throwing model viejo).

### Tarea A2 - Ninja Discipline: first stance change free per turn
Estado: implementada (pendiente validacion in-game).
Objetivo:
- Implementar cambio de stance gratis 1 vez por turno.
- Mantener cambios adicionales bloqueados/no gratuitos segun diseno.

Archivos esperados:
- `Spell_Shout.txt`
- `Status_RO_Ninja.txt`
- `Passive.txt` (si hace falta soporte tecnico)
- `ScriptExtender/Lua/*` (solo si Stats no alcanza)

Criterio de aceptacion:
- Primer cambio de stance en turno: no consume Bonus Action.
- Segundo cambio en el mismo turno: no permitido o no gratis (segun regla final).

Riesgo:
- En Stats puro puede ser limitado; podria requerir Script Extender.

### Tarea A3 - Ninja Discipline: bonuses nuevos por rama
Estado: implementada (pendiente validacion in-game).
Objetivo:
- Throwing Mastery: bonus vs objetivos condicionados (modelo nuevo).
- Shadow Arts: mantener movilidad y preparar base para sinergias de aislado/condicionado.
- Ninpou Training: mantener +Spell Attack/+DC y preparar escalado nuevo.

Archivos esperados:
- `Status_RO_Ninja.txt`
- `Passive.txt`
- `Localization/English/english.xml`

Criterio de aceptacion:
- Cada stance aplica su identidad base en runtime.
- No rompe stances ON/OFF existentes.

### Tarea A4 - Thrown Technique migracion al modelo de condiciones
Estado: implementada (pendiente validacion in-game).
Objetivo:
- Shuriken/Kunai/Huuma alineados al nuevo diseno nivel 2 (y tiers 5/9 coherentes).
- Reemplazar dependencia central de `Exposed Armor` por el ladder de condiciones nuevo.

Archivos esperados:
- `Spell_Projectile_RO_Ninja.txt`
- `Status_RO_Ninja.txt`
- `Passive.txt`
- `Localization/English/english.xml`
- `Class Design/ninja.json` (si hace falta ajuste menor de consistencia)

Criterio de aceptacion:
- Kunai aplica condicion del nuevo modelo (no solo AC-1).
- Shuriken/Huuma reflejan bonus a condicionados.

### Tarea A5 - Shadow Jump alineado al nuevo diseno
Estado: implementada (pendiente validacion in-game).
Objetivo:
- L2 debe dar +1 al siguiente ataque/tecnica.
- L5: +1 ataque +1d4.
- L9: +2 ataque +1d6.

Archivos esperados:
- `Spell_Target.txt`
- `Status_RO_Ninja.txt`
- `Passive.txt`
- `Progressions.lsx` (si hay que mover passive tecnico)
- `Localization/English/english.xml`

Criterio de aceptacion:
- Buff correcto por tier y con duracion correcta.

---

## Fase B - Nivel 3 completo

### Tarea B1 - Throwing Art (nuevo skill faltante)
Objetivo:
- Implementar `Throwing Art` con sus 3 variantes:
  - Razor Shuriken
  - Crippling Kunai
  - Disrupting Senbon
- MVP primero: dano + condicion core por variante.

Archivos esperados:
- `Spell_Projectile_RO_Ninja.txt`
- `Status_RO_Ninja.txt`
- `Passive.txt`
- `Progressions.lsx`
- `Localization/English/english.xml`

Criterio de aceptacion:
- Aparece en nivel 3.
- Cada variante funciona y consume recursos correctos.

### Tarea B2 - Mist Slash condicion de L9
Objetivo:
- Cambiar L9 para que el bonus dependa de target aislado o condicionado.

Archivos esperados:
- `Spell_Projectile_RO_Ninja.txt`
- `Passive.txt` / `Status_RO_Ninja.txt` (segun implementacion)
- `Localization/English/english.xml` (si cambia tooltip)

Criterio de aceptacion:
- El bonus no aplica siempre; solo bajo condicion de diseno.

### Tarea B3 - Ninpou Bolt sinergias con fields (si aplica a nivel 3 actual)
Objetivo:
- Mantener Ninpou Bolt estable.
- Agregar solo sinergias que no rompan y tengan soporte real en fields.

Archivos esperados:
- `Spell_Projectile_RO_Ninja.txt`
- `Status_RO_Ninja.txt` (si se usan estados puente)
- `Localization/English/english.xml`

Criterio de aceptacion:
- Base sigue funcionando y sinergias activan solo en condiciones correctas.

---

## Orden recomendado de ejecucion (1 a 1)
1. A2 - Discipline free switch per turn
2. A3 - Discipline bonuses nuevos
3. A4 - Thrown Technique nuevo modelo
4. A5 - Shadow Jump alineado
5. B1 - Throwing Art
6. B2 - Mist Slash L9 condicional
7. B3 - Ninpou Bolt sinergias

## Definition of Done (nivel 2 y 3)
- Todo lo pedido en diseno para L2/L3 existe en runtime.
- Skills aparecen, consumen recursos correctos y aplican efectos correctos.
- No hay regresiones en features ya estables.
- GUIDE_HANDOFF actualizado por cada iteracion.
