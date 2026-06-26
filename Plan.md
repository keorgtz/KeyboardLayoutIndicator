# PLAN.md

## Keyboard Layout Indicator Plugin for DankMaterialShell (DMS)

**Proyecto:** Keyboard Layout Indicator
**Versión objetivo:** 2.0.0
**Compatibilidad:**

* Fedora 44
* Hyprland 0.55+
* DankMaterialShell 1.4.6
* Quickshell 0.3

---

# Objetivo

Desarrollar un plugin profesional para DankMaterialShell que permita visualizar y administrar el layout del teclado de Hyprland utilizando una interfaz Material Design 3 totalmente integrada con DMS.

El resultado debe sentirse como un plugin oficial de DMS.

No debe parecer un widget externo.

---

# Estado actual

## Ya implementado

### Estructura

Existe:

```
~/.config/DankMaterialShell/plugins/keyboardLayoutIndicator/
```

con:

```
plugin.json
KeyboardLayout.qml
KeyboardLayoutSettings.qml
KeyboardService.qml
```

NO eliminar estos archivos.

Se deben reutilizar.

---

## plugin.json

Ya existe.

Debe conservarse.

Actualizar únicamente si es necesario.

---

## KeyboardService.qml

Existe una primera implementación.

Actualmente:

* ejecuta `hyprctl devices`
* usa Process
* actualiza layout mediante Timer
* expone

```
layout
fullName
```

No eliminar.

Debe evolucionar.

---

## KeyboardLayout.qml

Existe un inicio.

Debe reemplazarse completamente utilizando la arquitectura oficial de DMS.

No reutilizar el código antiguo.

---

# Investigación realizada

Ya se inspeccionó la implementación oficial de DMS.

Archivos analizados:

```
/usr/share/quickshell/dms/Modules/Plugins/PluginComponent.qml
```

```
/usr/share/quickshell/dms/Modules/Plugins/DesktopPluginComponent.qml
```

y plugins oficiales como:

AlarmClock

DankDesktopWeather

No volver a investigar estos archivos.

Ya fueron revisados.

---

# Arquitectura objetivo

```
Keyboard Layout Indicator

│

├── plugin.json

├── KeyboardLayout.qml

├── KeyboardService.qml

├── KeyboardLayoutSettings.qml

├── KeyboardPopout.qml

├── KeyboardLayoutsModel.qml

├── icons/

│     us.svg

│     mx.svg

│     jp.svg

│     de.svg

│

└── README.md
```

---

# Principios

Usar exclusivamente componentes oficiales de DMS.

Ejemplos:

```
PluginComponent
StyledText
DankIcon
Theme
BasePill
PluginPopout
DankTooltip
DankRipple
```

No crear componentes equivalentes.

No duplicar funcionalidades que ya existen.

---

# Diseño

Material Design 3.

Utilizar Theme.

Nunca utilizar colores hardcodeados.

Ejemplo:

```
Theme.primary

Theme.surface

Theme.surfaceContainer

Theme.surfaceVariant

Theme.cornerRadius
```

---

# Objetivos funcionales

## Fase 1

Reescribir KeyboardLayout.qml.

Debe utilizar correctamente:

```
PluginComponent

horizontalBarPill
```

como los plugins oficiales.

No implementar lógica dentro del Widget.

Toda la lógica vive en KeyboardService.

---

## Fase 2

Crear KeyboardLayoutsModel.qml.

Responsabilidades:

* detectar layouts

* detectar layout activo

* soportar cualquier idioma

No limitarse a:

US

ES

Debe funcionar con:

DE

JP

FR

etc.

---

## Fase 3

Refactorizar KeyboardService.

Eliminar código repetido.

Mover toda la lógica al servicio.

El widget solamente debe consumir propiedades.

---

## Fase 4

Crear KeyboardPopout.qml

Debe mostrar:

Layout actual

Layouts disponibles

Indicador visual

Botón para cambiar

Información completa

---

## Fase 5

Crear Settings.

Permitir:

Mostrar bandera

Mostrar icono

Mostrar texto

Mostrar tooltip

Mostrar nombre largo

Mostrar nombre corto

Actualizar automáticamente

Intervalo de refresco

---

## Fase 6

Animaciones.

Usar únicamente:

Theme.shortDuration

Theme.standardEasing

No inventar animaciones.

---

## Fase 7

Hover.

Debe comportarse exactamente igual que los widgets oficiales.

---

## Fase 8

Tooltip.

Usar DankTooltip.

Mostrar por ejemplo:

```
Keyboard Layout

English (US)
```

---

## Fase 9

Click izquierdo

Cambiar layout.

No abrir popout.

---

## Fase 10

Click derecho

Abrir popout.

---

## Fase 11

Optimización.

Eliminar el Timer actual si Quickshell permite escuchar eventos.

Si no es posible:

Reducir polling.

Nunca ejecutar Process innecesariamente.

---

## Fase 12

Compatibilidad.

Debe funcionar con:

Hyprland

DMS

Quickshell

Fedora

sin dependencias externas.

No instalar:

waybar

xkb-switch

etc.

---

# Diseño visual

El widget debe parecer oficial.

Ejemplo:

```
⌨ US
```

o

```
🇺🇸 US
```

Hover:

```
English (US)
```

Animación:

Escala

Ripple

Cambio de color

---

# Rendimiento

Evitar Process repetitivos.

Evitar ejecutar bash constantemente.

Evitar recrear objetos.

---

# Calidad

Código limpio.

Separación estricta entre:

Vista

Modelo

Servicio

Configuración

---

# No hacer

No usar colores hardcodeados.

No usar Label cuando exista StyledText.

No crear Rectangles innecesarios.

No implementar botones manualmente si DMS ya los ofrece.

No romper compatibilidad con futuras versiones.

---

# Criterios de aceptación

El plugin debe sentirse como un plugin oficial de DMS.

No debe distinguirse visualmente de:

AlarmClock

Weather

CPU

Clipboard

Debe ser mantenible.

Debe permitir futuras extensiones.

Debe estar listo para publicarse en el Plugin Registry de DankMaterialShell.
