# Cómo se seleccionaron las herramientas

Este repositorio reúne **patrones reutilizables**, no copias masivas de proyectos. El inventario inicial encontró muchos scripts repetidos en ramas, artefactos de prueba y carpetas de dependencias. La selección actual cubre 21 tareas distintas en ocho temas.

Para adaptar un script se quitaron rutas absolutas, nombres de proyectos, servidores, usuarios, credenciales, consultas de negocio y resultados generados. Los valores que un visitante debe decidir se convirtieron en parámetros. Los ejemplos usan archivos ficticios o públicos. Los scripts que inspeccionan un equipo o una base de datos producen salida local; esa salida no se incluye en el repositorio.

Antes de cada publicación se ejecutan `./tests/Smoke.ps1` y `./scripts/security/Test-GitStagedContent.ps1 -FailOnFindings`, además de una revisión manual. La detección automática es heurística y puede pasar por alto datos sensibles; por eso las contribuciones deben revisarse antes de publicarse.

## Requisitos opcionales

La mayoría de los scripts usa PowerShell 7. Algunos requieren Windows, Edge o Chrome, draw.io Desktop, un controlador ODBC o el runtime de SAP Crystal Reports. `Convert-TextToSpeech.ps1` usa Windows PowerShell 5.1 y System.Speech. Cada archivo declara sus propios requisitos y tiene un ejemplo de uso.
