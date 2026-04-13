# Arkanoid (Swift / SpriteKit)

## Descripción
Clon del clásico juego Arkanoid desarrollado de forma nativa para iOS utilizando el framework SpriteKit. El proyecto incluye un motor de físicas 2D fluido, mecánicas de rebote inteligente según la zona de impacto en la barra, destrucción de ladrillos con efectos visuales de partículas nativas (`SKEmitterNode`), control direccional táctil del jugador y un sistema de progresión que incrementa la velocidad de la bola progresivamente.

## Ejemplo de uso rápido
1. Abre el proyecto utilizando Xcode haciendo doble clic en `arkanoidIA.xcodeproj`.
2. Selecciona un dispositivo físico o simulador en la barra superior (ej. iPhone 15 Pro).
3. Presiona `Cmd + R` (Product > Run) para compilar y lanzar la aplicación de manera inmediata.

## Estructura del proyecto
```text
arkanoidIA/
├── arkanoidIA/
│   ├── AppDelegate.swift          # Gestión del ciclo base de inicialización de la app.
│   ├── SceneDelegate.swift        # Gestión del ciclo de vida de la escena de interfaz en iOS.
│   ├── GameViewController.swift   # Controlador principal responsable de instanciar y cargar SpriteKit y el archivo .sks.
│   ├── GameScene.swift            # Lógica central del motor: reglas, score, inputs táctiles, y colisiones de físicas.
│   ├── GameScene.sks              # Definición espacial y serialización de nodos estáticos base en la escena.
│   └── Actions.sks                # Archivo base para serialización de animaciones complejas (si se emplean).
└── arkanoidIA.xcodeproj/          # Configuración del workspace, perfiles de firma y configuración de compilación generada por Xcode.
```

## Variables de entorno
Este proyecto es un juego puramente cliente y nativo. No hace consumo de API externa en su estado actual.

| Nombre | Descripción | Ejemplo | Obligatoria |
|--------|-------------|---------|-------------|
| Ninguna | No se requieren variables de entorno externas ni secretos para la compilación de este proyecto. | `N/A` | No |