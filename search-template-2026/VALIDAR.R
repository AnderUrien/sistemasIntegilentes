# =========================================================================
# Checklist de Validación - RAG Maze Solver
# =========================================================================
# Verifica que todo está correctamente implementado
# =========================================================================

# =========================================================================
# 1. ARCHIVOS CREADOS
# =========================================================================

# Verifica que existen los siguientes archivos:

files_to_check <- c(
  "problems/rag-maze.R",
  "mains/main.R",
  "mains/quick-solver.R",
  "mains/visualization-utils.R",
  "mains/problem-generator.R",
  "README.md",
  "CODIGO_GENERADO.md",
  "COMIENZA_AQUI.R"
)

cat("Verificando archivos...\n")
for (file in files_to_check) {
  if (file.exists(file)) {
    cat("✓", file, "\n")
  } else {
    cat("✗", file, "NO ENCONTRADO\n")
  }
}

# =========================================================================
# 2. ARCHIVOS DE DATOS
# =========================================================================

cat("\n\nVerificando archivos de datos...\n")
data_files <- list.files("data", pattern = "\\.txt$")
for (file in data_files) {
  cat("✓", file, "\n")
}

if (length(data_files) == 0) {
  cat("✗ No hay archivos de datos en data/\n")
}

# =========================================================================
# 3. CARGAR Y VALIDAR FUNCIONES
# =========================================================================

cat("\n\nValidando funciones cargables...\n")

# Test 1: Puede cargar el problema
tryCatch({
  source("problems/rag-maze.R")
  cat("✓ problems/rag-maze.R cargable\n")
}, error = function(e) {
  cat("✗ Error cargando rag-maze.R:", e$message, "\n")
})

# Test 2: Puede parsear un archivo
tryCatch({
  data <- parse.rag.file("data/01-loop-trap.txt")
  cat("✓ parse.rag.file() funciona\n")
}, error = function(e) {
  cat("✗ Error:", e$message, "\n")
})

# Test 3: Puede inicializar un problema
tryCatch({
  problem <- initialize.problem(file = "data/01-loop-trap.txt")
  cat("✓ initialize.problem() funciona\n")
  cat("  - Grid:", problem$rows, "x", problem$cols, "\n")
  cat("  - Start:", paste(problem$state_initial, collapse=","), "\n")
  cat("  - Goal:", paste(problem$state_final, collapse=","), "\n")
  cat("  - RAG Links:", length(problem$rag_links), "\n")
}, error = function(e) {
  cat("✗ Error:", e$message, "\n")
})

# Test 4: Funciones del problema
if (exists("problem")) {
  cat("\n✓ Funciones del problema:\n")
  
  state <- problem$state_initial
  
  # Test is.applicable
  applicable <- is.applicable(state, "RIGHT", problem)
  cat("  - is.applicable():", applicable, "\n")
  
  # Test effect
  next_state <- effect(state, "RIGHT", problem)
  cat("  - effect():", paste(next_state, collapse=","), "\n")
  
  # Test is.final.state
  is_goal <- is.final.state(state, problem)
  cat("  - is.final.state():", is_goal, "\n")
  
  # Test to.string
  state_str <- to.string(state, problem)
  cat("  - to.string():", state_str, "\n")
  
  # Test get.cost
  cost <- get.cost(state, "RIGHT", problem)
  cat("  - get.cost():", cost, "\n")
  
  # Test get.evaluation
  h_value <- get.evaluation(state, problem)
  cat("  - get.evaluation():", h_value, "\n")
}

# =========================================================================
# 4. CARGAR UTILIDADES
# =========================================================================

cat("\n\nValidando utilidades de visualización...\n")

tryCatch({
  source("mains/visualization-utils.R")
  cat("✓ visualization-utils.R cargable\n")
}, error = function(e) {
  cat("✗ Error:", e$message, "\n")
})

# =========================================================================
# 5. SUMMARY
# =========================================================================

cat("\n\n")
cat("=".repeats(70), "\n")
cat("VALIDACIÓN COMPLETADA\n")
cat("=".repeats(70), "\n\n")

cat("Próximos pasos:\n")
cat("1. Lee COMIENZA_AQUI.R para instrucciones de uso\n")
cat("2. Read README.md para documentación completa\n")
cat("3. Ejecuta: source('mains/main.R') para procesar todos los problemas\n")
cat("4. O ejecuta: source('mains/quick-solver.R') para una prueba rápida\n")

# =========================================================================
# Helper function (define if not exists)
# =========================================================================

repeats <- function(char, n) {
  paste(rep(char, n), collapse = "")
}
