# =========================================================================
# Quick Solver: Test Individual Problems
# =========================================================================
# Quickly test a specific problem instance with selected algorithms
# =========================================================================

# Clear environment
rm(list = ls())
cat("\014")

# Set working directory
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}

# Load algorithms and utilities
source("../algorithms/blind/expand-node.R")
source("../algorithms/blind/breadth-first-search.R")
source("../algorithms/blind/depth-first-search.R")
source("../algorithms/blind/depth-limited-search.R")
source("../algorithms/informed/uniform-cost-search.R")
source("../algorithms/informed/greedy-best-first-search.R")
source("../algorithms/informed/a-star-search.R")
source("../algorithms/results-analysis/analyze-results.R")
source("../problems/rag-maze.R")
source("./visualization-utils.R")

# =========================================================================
# CONFIGURATION: Modify these values to test different problems
# =========================================================================

# Which problem to solve
PROBLEM_FILE <- "../data/01-loop-trap.txt"

# Maximum iterations
MAX_ITERATIONS <- 5000

# Algorithms to run (select which ones)
ALGORITHMS <- c(
  "bfs_ts", "bfs_gs",    # Breadth-First Search
  "dfs_ts", "dfs_gs",    # Depth-First Search
  "ucs_ts", "ucs_gs",    # Uniform Cost Search
  "gbfs_ts", "gbfs_gs",  # Greedy Best-First Search
  "astar_ts", "astar_gs" # A*
)

# =========================================================================
# EXECUTION
# =========================================================================

problem <- initialize.problem(file = PROBLEM_FILE)

# Print problem info
print.rag.problem(problem)

cat("Running algorithms...\n\n")

results <- list()

# Run selected algorithms
if ("bfs_ts" %in% ALGORITHMS) {
  cat("BFS (Tree Search)...\n")
  results$bfs_ts <- breadth.first.search(problem, max_iterations = MAX_ITERATIONS)
}

if ("bfs_gs" %in% ALGORITHMS) {
  cat("BFS (Graph Search)...\n")
  results$bfs_gs <- breadth.first.search(problem, max_iterations = MAX_ITERATIONS, graph_search = TRUE)
}

if ("dfs_ts" %in% ALGORITHMS) {
  cat("DFS (Tree Search)...\n")
  results$dfs_ts <- depth.first.search(problem, max_iterations = MAX_ITERATIONS)
}

if ("dfs_gs" %in% ALGORITHMS) {
  cat("DFS (Graph Search)...\n")
  results$dfs_gs <- depth.first.search(problem, max_iterations = MAX_ITERATIONS, graph_search = TRUE)
}

if ("ucs_ts" %in% ALGORITHMS) {
  cat("UCS (Tree Search)...\n")
  results$ucs_ts <- uniform.cost.search(problem, max_iterations = MAX_ITERATIONS)
}

if ("ucs_gs" %in% ALGORITHMS) {
  cat("UCS (Graph Search)...\n")
  results$ucs_gs <- uniform.cost.search(problem, max_iterations = MAX_ITERATIONS, graph_search = TRUE)
}

if ("gbfs_ts" %in% ALGORITHMS) {
  cat("Greedy BFS (Tree Search)...\n")
  results$gbfs_ts <- greedy.best.first.search(problem, max_iterations = MAX_ITERATIONS)
}

if ("gbfs_gs" %in% ALGORITHMS) {
  cat("Greedy BFS (Graph Search)...\n")
  results$gbfs_gs <- greedy.best.first.search(problem, max_iterations = MAX_ITERATIONS, graph_search = TRUE)
}

if ("astar_ts" %in% ALGORITHMS) {
  cat("A* (Tree Search)...\n")
  results$astar_ts <- a.star.search(problem, max_iterations = MAX_ITERATIONS)
}

if ("astar_gs" %in% ALGORITHMS) {
  cat("A* (Graph Search)...\n")
  results$astar_gs <- a.star.search(problem, max_iterations = MAX_ITERATIONS, graph_search = TRUE)
}

# Print comparison table
print.comparison.table(results)

# Print best solution
best_algo <- names(results)[which.min(sapply(results, function(x) x$nodes_expanded))]
best_result <- results[[best_algo]]

cat(paste0("BEST ALGORITHM: ", best_algo, "\n"))
print.solution(best_result, problem)
visualize.solution.path(best_result, problem)

cat("\n=== TEST COMPLETE ===\n\n")
