# =========================================================================
# GUÍA DE INICIO RÁPIDO - RAG Maze Solver
# =========================================================================
# Sigue estos pasos para comenzar a usar el sistema
# =========================================================================

# PASO 1: Ejecutar el solver principal
# =========================================================================
# Este comando procesa TODOS los problemas en data/ automáticamente
# 
# Simplemente abre RStudio, navega a mains/ y ejecuta:

setwd("mains")  # Si no estás en ese directorio
source("main.R")

# Esto generará:
# - Tablas comparativas en consola
# - Archivos CSV en results/ con resultados detallados
# - Análisis de cuál algoritmo fue mejor para cada problema

# =========================================================================
# PASO 2: Explorar Resultados (DESPUÉS de ejecutar main.R)
# =========================================================================

# Lee el resumen en consola y observa:
# - Final de cada problema demuestra una "trampa"
# - Algunos algoritmos fallan, otros tienen éxito
# - La tabla muestra: algoritmo, nodos expandidos, profundidad, tiempo

# =========================================================================
# PASO 3: Probar un Problema Específico (Ejecución Rápida)
# =========================================================================

# Si solo quieres probar UN problema rápidamente:

setwd("mains")
source("quick-solver.R")

# Esto:
# 1. Visualiza el mapa
# 2. Muestra los enlaces RAG disponibles
# 3. Ejecuta solo los algoritmos deseados
# 4. Muestra la mejor solución
# 5. Dibuja la ruta en el mapa

# =========================================================================
# PASO 4: Entender los Problemas (casos de estudio)
# =========================================================================

# Abre: README.md
# Sección: "Casos de Uso" explica cada problema

# Resumen:
# 01-loop-trap.txt     → BFS: OK   | DFS: entra en bucle
# 02-rag-dilema.txt    → UCS: OK   | Greedy: no óptimo  
# 03-deep-corridor.txt → BFS: OK   | DFS: profundidad excesiva
# 04-cost-trap.txt     → UCS: OK   | BFS: no óptimo (costos variados)
# 05-greedy-trap.txt   → A*: OK    | Greedy: trampa de heurística
# 06-shallow-illusion.txt → similar

# =========================================================================
# PASO 5: Crear tu Propio Problema (Opcional)
# =========================================================================

setwd("mains")
source("problem-generator.R")

# Generar plantilla:
create.problem.template(
  filename = "../data/07-tu-problema.txt",
  rows = 12,
  cols = 12
)

# Edita el archivo generado con tu mapa y RAG links
# Luego ejecuta main.R nuevamente - automáticamente procesa tu nuevo archivo

# =========================================================================
# PASO 6: Análisis Avanzado (Programación)
# =========================================================================

# Para análisis personalizado o integración:

source("../algorithms/blind/breadth-first-search.R")
source("../algorithms/informed/a-star-search.R")
source("../problems/rag-maze.R")

# Cargar un problema específico
problem <- initialize.problem(file = "../data/01-loop-trap.txt")

# Ejecutar un algoritmo
bfs_result <- breadth.first.search(
  problem, 
  graph_search = TRUE,
  max_iterations = 5000
)

# Ver resultados
cat("Solución encontrada:", bfs_result$found, "\n")
cat("Costo:", bfs_result$cost, "\n")
cat("Profundidad:", bfs_result$depth, "\n")
cat("Nodos expandidos:", bfs_result$nodes_expanded, "\n")
cat("Tiempo:", bfs_result$time, "segundos\n")
cat("Ruta:", paste(bfs_result$path, collapse=" → "), "\n")

# =========================================================================
# PASO 7: Visualizar Resultados (Utilidades)
# =========================================================================

source("visualization-utils.R")

# Mostrar problema
print.rag.problem(problem)

# Mostrar solución
print.solution(bfs_result, problem)

# Tabla comparativa (si tienes múltiples resultados)
results <- list(
  bfs_ts = breadth.first.search(problem, max_iterations=5000),
  astar_gs = a.star.search(problem, graph_search=TRUE, max_iterations=5000)
)
print.comparison.table(results)

# Visualizar ruta en el mapa
visualize.solution.path(bfs_result, problem)

# =========================================================================
# ESTRUCTURA DE DIRECTORIOS ESPERADA
# =========================================================================

# search-template-2026/
# ├── algorithms/
# │   ├── blind/
# │   │   ├── breadth-first-search.R
# │   │   ├── depth-first-search.R
# │   │   ├── depth-limited-search.R
# │   │   ├── iterative-deepening-search.R
# │   │   └── expand-node.R
# │   ├── informed/
# │   │   ├── uniform-cost-search.R
# │   │   ├── greedy-best-first-search.R
# │   │   └── a-star-search.R
# │   └── results-analysis/
# │       └── analyze-results.R
# ├── data/
# │   ├── 01-loop-trap.txt
# │   ├── 02-rag-dilema.txt
# │   ├── 03-deep-corridor.txt
# │   ├── 04-cost-trap.txt
# │   ├── 05-greedy-trap.txt
# │   └── 06-shallow-illusion.txt
# ├── problems/
# │   ├── rag-maze.R              ← NUEVO
# │   └── 0-problem-template.R
# ├── mains/
# │   ├── main.R                  ← MODIFICADO
# │   ├── quick-solver.R          ← NUEVO
# │   ├── visualization-utils.R   ← NUEVO
# │   ├── problem-generator.R     ← NUEVO
# │   └── 0-main-template.R
# ├── results/                     (se crea automáticamente)
# ├── README.md                    ← NUEVO (documentación)
# └── CODIGO_GENERADO.md           ← NUEVO (este resumen)

# =========================================================================
# COMANDOS RÁPIDOS
# =========================================================================

# Procesar TODO:
source("mains/main.R")

# Probar un problema:
source("mains/quick-solver.R")

# Crear nuevo problema:
source("mains/problem-generator.R")
create.problem.template("../data/07-nuevo.txt", rows=15, cols=15)

# Validar archivo:
source("mains/problem-generator.R")
validate.problem.file("../data/01-loop-trap.txt")

# =========================================================================
# TROUBLESHOOTING
# =========================================================================

# Error: "File not found"
# → Verifica que ejecutas desde directorio mains/
# → Asegúrate que data/ tiene los archivos .txt

# Error: "Object not found" en algorithms
# → Las rutas en source() son relativas a mains/
# → Usa: ../algorithms/ ../problems/

# Algo tarda mucho
# → Es normal (BFS puede tardar en laberintos grandes)
# → Reduce MAX_ITERATIONS en quick-solver.R

# No encuentra solución
# → Verifica que existe camino de S a G en el mapa
# → Aumenta MAX_ITERATIONS

# =========================================================================
# SIGUIENTE PASO: Abre README.md para documentación completa
# =========================================================================
