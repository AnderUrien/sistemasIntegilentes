# RAG Maze Solver - Guía de Uso

## Descripción General

Este proyecto implementa un solucionador de problemas de búsqueda en laberintos con enlaces RAG (Retrieval Augmented Graph). El sistema permite:

- **Lectura automática de problemas** desde archivos de configuración en `data/`
- **Ejecución de múltiples algoritmos de búsqueda**:
  - Búsqueda ciega: BFS, DFS, DLS, IDS
  - Búsqueda informada: UCS, Greedy Best-First, A*
  - Modalidades: Tree Search vs Graph Search
- **Análisis comparativo** de resultados
- **Exportación de datos** a CSV

## Estructura de Archivos

```
mains/
├── main.R                    # Script principal (procesa todos los problemas)
├── quick-solver.R            # Resuelve rápidamente un problema específico
├── visualization-utils.R     # Utilidades para visualización
└── 0-main-template.R        # Plantilla de referencia

problems/
├── rag-maze.R               # Definición del problema RAG Maze
└── 0-problem-template.R     # Plantilla de problema

data/
├── 01-loop-trap.txt         # Ejemplo: trampa de bucle
├── 02-rag-dilema.txt        # Ejemplo: dilema RAG
├── 03-deep-corridor.txt     # Ejemplo: corredor profundo
├── 04-cost-trap.txt         # Ejemplo: trampa de costo
├── 05-greedy-trap.txt       # Ejemplo: trampa greedy
└── 06-shallow-illusion.txt  # Ejemplo: ilusión superficial

algorithms/
├── blind/                   # Algoritmos de búsqueda ciega
├── informed/                # Algoritmos de búsqueda informada
└── results-analysis/        # Análisis de resultados
```

## Formato de Archivo de Problemas

Cada problema se define en un archivo `.txt` con la siguiente estructura:

```
[PARAMS]
GEN_LAT=120
SWITCH_LAT=60
EUR_PER_SEC=0.01
PROVIDER=VectorDB_PRO;LAT=30;COST=1.40
PROVIDER=VectorDB_ECO;LAT=55;COST=0.70

[MAP]
ROWS=9
COLS=9
S . . . . . . . .
. . . . . . . . .
...
. . . . . . . . G

[RAG_LINKS]
VectorDB_ECO;4,4;4,5
VectorDB_PRO;5,5;4,4
```

### Explicación de Secciones

- **[PARAMS]**: Parámetros globales del problema
  - `GEN_LAT`: Latencia de generación
  - `SWITCH_LAT`: Latencia de cambio
  - `EUR_PER_SEC`: Costo en euros por segundo
  - `PROVIDER`: Define proveedores RAG con latencia (LAT) y costo (COST)

- **[MAP]**: Mapa del laberinto
  - `ROWS`: Número de filas
  - `COLS`: Número de columnas
  - `S`: Posición inicial (Start)
  - `G`: Posición objetivo (Goal)
  - `.`: Celda vacía transitable
  - `#`: Celda bloqueada (muro)

- **[RAG_LINKS]**: Enlaces especiales de teletransporte
  - Formato: `PROVIDER;start_col,start_row;end_col,end_row`
  - Permiten saltar entre locaciones con costo específico
  - Útiles para simular distintas estrategias de búsqueda

## Cómo Usar

### Opción 1: Procesar Todos los Problemas

Ejecuta el script principal que procesa automáticamente todos los archivos en `data/`:

```r
# En RStudio, abre y ejecuta mains/main.R
source("mains/main.R")
```

**Qué hace:**
- Lee todos los archivos `.txt` en `data/`
- Crea problemas automáticamente
- Ejecuta todos los algoritmos
- Genera tabla comparativa
- Exporta resultados a `results/` en formato CSV

### Opción 2: Probar un Problema Específico (Rápido)

Para pruebas rápidas de un problema individual:

```r
# Abre y ejecuta mains/quick-solver.R
# Modifica estas líneas al inicio:
PROBLEM_FILE <- "../data/01-loop-trap.txt"
MAX_ITERATIONS <- 5000
ALGORITHMS <- c("bfs_ts", "bfs_gs", "astar_gs")  # Selecciona algoritmos

source("mains/quick-solver.R")
```

**Qué hace:**
- Carga un problema específico
- Muestra visualización del mapa
- Ejecuta algoritmos seleccionados
- Muestra tabla comparativa
- Visualiza la ruta solución

### Opción 3: Uso Programático

Para integrar en análisis personalizados:

```r
# Cargar fuentes
source("../algorithms/blind/breadth-first-search.R")
source("../problems/rag-maze.R")

# Crear problema
problem <- initialize.problem(file = "../data/01-loop-trap.txt")

# Resolver
result <- breadth.first.search(problem, graph_search = TRUE, max_iterations = 5000)

# Acceder resultados
result$found          # ¿Se encontró solución?
result$cost           # Costo total
result$depth          # Profundidad
result$nodes_expanded # Nodos expandidos
result$path           # Ruta solución
result$actions        # Acciones realizadas
```

## Métricas Reportadas

| Métrica | Descripción |
|---------|-------------|
| **Found** | ¿Se encontró solución? |
| **Cost** | Costo total del camino (suma de costos) |
| **Depth** | Profundidad de la solución |
| **Nodes Expanded** | Cantidad de nodos expandidos |
| **Time** | Tiempo de ejecución en segundos |

## Algoritmos Disponibles

### Búsqueda Ciega (Uninformed)
- **BFS** (Breadth-First Search): Completo, óptimo si costos uniformes
- **DFS** (Depth-First Search): Incompleto, pero eficiente en memoria
- **DLS** (Depth-Limited Search): DFS con límite de profundidad
- **IDS** (Iterative Deepening Search): Completo y óptimo

### Búsqueda Informada (Informed)
- **UCS** (Uniform Cost Search): Óptimo, pero lento
- **Greedy BFS**: Rápido pero no óptimo
- **A \***: Óptimo y generalmente más rápido

### Modalidades
- **Tree Search**: Permite revisitar nodos
- **Graph Search**: Evita revisitar nodos (más eficiente)

## Interpretación de Resultados

### Ejemplo de Salida

```
============================================================
Problem Name:      RAG Maze - [01-loop-trap.txt]
Grid Size:         9 x 9
Start:             (4, 4)
Goal:              (8, 8)
RAG Links:         4
============================================================

ALGORITHM COMPARISON

Algorithm       Found  Cost  Depth  Nodes_Expanded  Time_sec  Status
bfs_gs          TRUE   8     8      32              0.0234    SUCCESS
astar_gs        TRUE   8     8      28              0.0189    SUCCESS
ucs_gs          TRUE   8     8      35              0.0267    SUCCESS
dfs_gs          TRUE   8     100    45              0.0345    SUCCESS
```

### Interpretación

- **bfs_gs**: Expandió 32 nodos, encontró solución con costo 8, profundidad 8
- **astar_gs**: Más eficiente (28 nodos), resolver heurística bien
- **dfs_gs**: Más nodos (45) porque es más desordenado

## Casos de Uso

### 1. Comparar Algoritmos
Ver cuál es más eficiente para cada tipo de problema:

```r
# Todos los algoritmos en main.R
ALGORITHMS <- c("bfs_ts", "bfs_gs", "dfs_ts", "dfs_gs", 
                "ucs_ts", "ucs_gs", "gbfs_ts", "gbfs_gs",
                "astar_ts", "astar_gs")
```

### 2. Investigar Trampas de Búsqueda
Cada problema demuestra un concepto diferente:

- **01-loop-trap**: BFS encuentra solución, DFS entra en bucle
- **02-rag-dilema**: UCS vs A* (costo vs heurística)
- **03-deep-corridor**: DFS puede fracasar por profundidad
- **04-cost-trap**: BFS no es óptimo con costos variados
- **05-greedy-trap**: Greedy no es óptimo
- **06-shallow-illusion**: Heurística inadecuada

### 3. Crear Nuevos Problemas
Agrega un archivo en `data/` con el formato especificado y ejecuta main.R

## Notas Técnicas

### Representación de Estado
- Estado = (col, row) en indexación 1-based de R
- Conversión automática desde 0-based en archivos

### Costo de Acciones
- Movimientos normales: costo = 1
- Enlaces RAG: costo = latencia_proveedor + costo_proveedor

### Heurística
- Manhattan distance: `|col_actual - col_goal| + |row_actual - row_goal|`
- Admisible (nunca sobreestima) porque ignora muros

## Troubleshooting

### "File not found"
- Verifica que estés ejecutando desde el directorio `mains/`
- Usa rutas relativas `../data/` y `../algorithms/`

### "No solution found"
- Aumenta `MAX_ITERATIONS`
- Verifica que el problema sea resoluble (hay camino de S a G)

### Algoritmo muy lento
- Usa Graph Search en lugar de Tree Search
- Usa A* o Greedy BFS si hay buena heurística
- Reduce `MAX_ITERATIONS` para tests rápidos

## Referencias

- Russell & Norvig: "Artificial Intelligence: A Modern Approach"
- Problemas educativos diseñados para demostrar diferentes trampas de búsqueda
- Implementación genérica de algoritmos reutilizable

---

**Última actualización:** Marzo 2026
**Uso educativo:** Universidad de Deusto
