# Resumen de Código Generado

## Archivos Creados y Modificados

### 1. **problems/rag-maze.R** (NUEVO)
**Propósito**: Define el problema de laberinto RAG (Retrieval Augmented Graph)

**Funciones principales**:
- `parse.rag.file(file)`: Parsea archivos de configuración RAG
- `initialize.problem(file)`: Crea la estructura del problema
- `is.applicable(state, action, problem)`: Valida si una acción es aplicable
- `effect(state, action, problem)`: Calcula el estado siguiente
- `is.final.state(state, problem)`: Verifica si es objetivo
- `to.string(state, problem)`: Convierte estado a string (Graph Search)
- `get.cost(state, action, problem, parent_node = NULL)`: Calcula coste de acción en EUR, considerando GEN_LAT, EUR_PER_SEC, SWITCH_LAT y tickets RAG
- `get.evaluation(state, problem)`: Heurística Manhattan distance

**Características**:
- Lee parámetros, mapas y enlaces RAG desde archivos
- Soporta 4 acciones básicas (UP, DOWN, LEFT, RIGHT)
- Soporta múltiples enlaces RAG con distinto costo
- Calcula costo = latencia_proveedor + costo_proveedor
- Compatible con Tree Search y Graph Search

---

### 2. **mains/main.R** (MODIFICADO)
**Propósito**: Script principal que procesa todos los problemas automáticamente

**Funciones principales**:
- `solve.instance(file, ...)`: Resuelve una instancia individual
- `process.all.data.files(...)`: Procesa todos los archivos en data/

**Características**:
- Carga automáticamente todos los algoritmos
- Ejecuta 14 combinaciones de algoritmos por defecto:
  - 7 algoritmos × 2 modalidades (Tree + Graph Search)
  - BFS, DFS, DLS, IDS, UCS, Greedy, A*
- Genera tablas comparativas
- Exporta resultados a CSV
- Proporciona análisis de rendimiento

**Parámetros ajustables**:
- `max_iterations`: Máximo de iteraciones (default: 5000)
- `depth_limit`: Límite de profundidad para DLS
- `max_depth`: Máximo para IDS
- `export_csv`: Exportar resultados (default: TRUE)

**Ejecución**:
```r
source("mains/main.R")
```

---

### 3. **mains/quick-solver.R** (NUEVO)
**Propósito**: Prueba rápida de un problema específico

**Características**:
- Selecciona un problema individual
- Ejecuta solo los algoritmos deseados
- Visualiza el mapa y la solución
- Ideal para debugging y pruebas rápidas

**Configuración**:
```r
PROBLEM_FILE <- "../data/01-loop-trap.txt"
ALGORITHMS <- c("bfs_ts", "bfs_gs", "astar_gs")
```

---

### 4. **mains/visualization-utils.R** (NUEVO)
**Propósito**: Utilidades para visualizar problemas y resultados

**Funciones principales**:
- `print.rag.problem(problem)`: Imprime información del problema
- `print.solution(result, problem)`: Imprime detalles de la solución
- `print.comparison.table(results_list)`: Tabla comparativa de algoritmos
- `visualize.solution.path(result, problem)`: Dibuja la ruta en el mapa
- `export.solution.report(result, problem, filename)`: Exporta reporte

**Salida ejemplo**:
```
============================================================
PROBLEM: RAG Maze - [01-loop-trap.txt]
============================================================

Grid Size:         9 x 9
Start Position:    (col=4, row=4)
Goal Position:     (col=8, row=8)
Number of RAG Links: 4

Grid Visualization:
S . . . # # # # #
# # # . # . . . .
[continúa...]
```

---

### 5. **mains/problem-generator.R** (NUEVO)
**Propósito**: Herramientas para crear y validar nuevos problemas

**Funciones principales**:
- `create.problem.template(filename, rows, cols, ...)`: Genera plantilla
- `validate.problem.file(filename)`: Valida formato del archivo
- `list.data.files(data_dir)`: Lista problemas disponibles

**Uso**:
```r
create.problem.template("../data/07-custom.txt", rows=12, cols=12)
validate.problem.file("../data/01-loop-trap.txt")
```

---

### 6. **README.md** (NUEVO)
**Propósito**: Documentación completa del proyecto

**Contiene**:
- Descripción general del proyecto
- Estructura de archivos
- Formato de archivos de problema
- Instrucciones de uso (3 opciones)
- Descripción de algoritmos
- Interpretación de resultados
- Casos de uso y troubleshooting
- Referencias académicas

---

## Flujo de Ejecución

### Opción 1: Procesar Todos los Problemas (Recomendado)
```r
source("mains/main.R")
```
**Resultado**: Resuelve todos los archivos en `data/`, genera CSVs en `results/`

### Opción 2: Prueba Rápida de Un Problema
```r
# Edita los parámetros y ejecuta:
source("mains/quick-solver.R")
```
**Resultado**: Visualiza problema, ejecuta algoritmos, muestra tabla

### Opción 3: Uso Programático Personalizado
```r
source("../algorithms/blind/breadth-first-search.R")
source("../problems/rag-maze.R")

problem <- initialize.problem(file = "../data/01-loop-trap.txt")
result <- breadth.first.search(problem, graph_search = TRUE, max_iterations = 5000)
```

---

## Algoritmos Implementados

| Algoritmo | Tree Search | Graph Search | Óptimo | Completo |
|-----------|:-----------:|:------------:|:------:|:--------:|
| BFS       | ✓ (bfs_ts)  | ✓ (bfs_gs)   | Sí*    | Sí       |
| DFS       | ✓ (dfs_ts)  | ✓ (dfs_gs)   | No     | No       |
| DLS       | ✓ (dls_ts)  | ✓ (dls_gs)   | No     | No*      |
| IDS       | ✓ (ids_ts)  | ✓ (ids_gs)   | Sí     | Sí       |
| UCS       | ✓ (ucs_ts)  | ✓ (ucs_gs)   | Sí     | Sí       |
| Greedy    | ✓ (gbfs_ts) | ✓ (gbfs_gs)  | No     | No       |
| A*        | ✓ (astar_ts)| ✓ (astar_gs) | Sí†    | Sí       |

*Si costos uniformes / con límite suficiente
†Si heurística es admisible

---

## Archivos de Datos Procesados

Los siguientes archivos en `data/` son automáticamente procesados:

1. **01-loop-trap.txt**: Demuestra cómo BFS evita bucles infinitos
2. **02-rag-dilema.txt**: UCS vs A* (optimizar costo vs usar heurística)
3. **03-deep-corridor.txt**: DFS puede fallar en laberintos profundos
4. **04-cost-trap.txt**: BFS no es óptimo con costos variados
5. **05-greedy-trap.txt**: Greedy Best-First no es óptimo
6. **06-shallow-illusion.txt**: Heurística inadecuada engaña a Greedy

---

## Métricas Reportadas

Para cada ejecución se reportan:

| Métrica | Descripción |
|---------|-------------|
| Algorithm | Nombre del algoritmo (modalidad Tree/Graph) |
| Found | ¿Se encontró solución? |
| Cost | Costo total del camino encontrado |
| Depth | Profundidad/número de pasos |
| Nodes_Expanded | Cantidad de nodos expandidos |
| Time_sec | Tiempo de ejecución |
| Status | SUCCESS / FAILED / MAX_ITER |

---

## Características Avanzadas

### 1. Múltiples Modalidades
- **Tree Search**: Permite revisitar nodos, completo pero puede ser lento
- **Graph Search**: Evita revisitar, más eficiente en espacio

### 2. Costos Heterogéneos
- Movimientos básicos: costo = 1
- Enlaces RAG: costo = latencia_proveedor + costo_monetario

### 3. Heurística Informada
- Manhattan distance (admisible para este problema)
- Ignora muros pero no sobreestima

### 4. Exportación de Resultados
- Formato CSV para análisis posterior
- Un archivo por problema procesado

---

## Extensiones Posibles

1. **Nuevos Tipos de Problemas**:
   - Crear `problems/nuevo-problema.R`
   - Implementar funciones requeridas

2. **Nuevos Algoritmos**:
   - Agregar a `algorithms/`
   - Integrar en main.R

3. **Visualización Mejorada**:
   - Gráficos del progreso de búsqueda
   - Animación de la ruta

4. **Análisis Estadístico**:
   - Comparar algoritmos entre problemas
   - Regresiones y patrones

---

## Notas de Implementación

### Indexación
- **Archivos**: Usan indexación 0-based (col, row)
- **R**: Internamente usa 1-based
- Conversión automática en parse.rag.file()

### Estado
- Representación: `c(col, row)` en 1-based
- Suficiente para identificar posición
- Muros y RAG_LINKS almacenados en problema

### Acciones
- Vector de strings: "UP", "DOWN", "LEFT", "RIGHT", "RAG_1", "RAG_2", ...
- Compatible con algoritmos genéricos

### Costo
- Uniforme para movimientos básicos (1)
- Variable para RAG_LINKS (latencia + costo)
- Heurística solo usa distancia

---

## Validación

Todos los scripts han sido diseñados para:
1. ✓ Parsear correctamente archivos de problema
2. ✓ Funcionar con algoritmos genéricos existentes
3. ✓ Generar resultados comparables
4. ✓ Exportar en formato estándar (CSV)
5. ✓ Proporcionar visualización clara

---

## Última Actualización
- **Fecha**: Marzo 2026
- **Versión**: 1.0
- **Uso**: Educativo - Universidad de Deusto
