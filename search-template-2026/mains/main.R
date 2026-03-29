# =========================================================================
# Main Script: RAG MAZE SOLVER
# =========================================================================
# Solves RAG Maze instances loaded from data files.
# Features:
#   - Processes all .txt files in the data directory
#   - Runs multiple search algorithms (blind and informed)
#   - Generates comparative results analysis
#   - Exports results to CSV
# -------------------------------------------------------------------------
#
# Authors / Maintainers:
#   - Roberto Carballedo
#   - Fernando Boto
#   - Enrique Onieva
#
# Last updated: March 2026
# Educational use only — University of Deusto
# =========================================================================

# =========================================================================
# 1. Clear environment
# =========================================================================
rm(list = ls())
cat("\014")

# =========================================================================
# 2. Set working directory
# =========================================================================
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}

# =========================================================================
# 3. Load Algorithms & Utilities
# =========================================================================
source("../algorithms/blind/expand-node.R")
source("../algorithms/blind/breadth-first-search.R")
source("../algorithms/blind/depth-first-search.R")
source("../algorithms/blind/depth-limited-search.R")
source("../algorithms/blind/iterative-deepening-search.R")
source("../algorithms/informed/uniform-cost-search.R")
source("../algorithms/informed/greedy-best-first-search.R")
source("../algorithms/informed/a-star-search.R")
source("../algorithms/results-analysis/analyze-results.R")

# =========================================================================
# 4. Load Problem Definition
# =========================================================================
source("../problems/rag-maze.R")

# =========================================================================
# 5. Solver Function
# =========================================================================
solve.instance <- function(file = NULL,
                           max_iterations = 5000,
                           depth_limit = 30,
                           max_depth = 30,
                           export_csv = TRUE,
                           csv_dir = "../results",
                           verbose = TRUE,
                           algorithms = c("bfs_ts", "bfs_gs", "dfs_ts", "dfs_gs", 
                                         "dls_ts", "dls_gs", "ids_ts", "ids_gs",
                                         "ucs_ts", "ucs_gs", "gbfs_ts", "gbfs_gs",
                                         "astar_ts", "astar_gs"),
                           ...) {
  
  # Create results folder if needed
  if (export_csv && !dir.exists(csv_dir)) {
    dir.create(csv_dir, recursive = TRUE)
  }
  
  problem <- initialize.problem(file = file)
  
  cat("\n============================================================\n")
  cat(paste0("Problem Name:     ", problem$name, "\n"))
  cat(paste0("Grid Size:        ", problem$rows, " x ", problem$cols, "\n"))
  cat(paste0("Start:            (", problem$state_initial[1], ", ", problem$state_initial[2], ")\n"))
  cat(paste0("Goal:             (", problem$state_final[1], ", ", problem$state_final[2], ")\n"))
  cat(paste0("RAG Links:        ", length(problem$rag_links), "\n"))
  cat("============================================================\n\n")
  
  results <- list()
  
  # --- TREE SEARCH ALGORITHMS ---
  if ("bfs_ts" %in% algorithms) {
    if (verbose) cat("Running BFS (Tree Search)...\n")
    results$bfs_ts <- breadth.first.search(problem, max_iterations = max_iterations, count_print = 1000)
  }
  
  if ("dfs_ts" %in% algorithms) {
    if (verbose) cat("Running DFS (Tree Search)...\n")
    results$dfs_ts <- depth.first.search(problem, max_iterations = max_iterations, count_print = 1000)
  }
  
  if ("dls_ts" %in% algorithms) {
    if (verbose) cat("Running DLS (Tree Search)...\n")
    results$dls_ts <- depth.limited.search(problem, max_iterations = max_iterations,
                                          depth_limit = depth_limit, count_print = 1000)
  }
  
  if ("ids_ts" %in% algorithms) {
    if (verbose) cat("Running IDS (Tree Search)...\n")
    results$ids_ts <- iterative.deepening.search(problem, max_iterations = max_iterations,
                                                max_depth = max_depth, count_print = 1000)
  }
  
  if ("ucs_ts" %in% algorithms) {
    if (verbose) cat("Running UCS (Tree Search)...\n")
    results$ucs_ts <- uniform.cost.search(problem, max_iterations = max_iterations, count_print = 1000)
  }
  
  if ("gbfs_ts" %in% algorithms) {
    if (verbose) cat("Running Greedy BFS (Tree Search)...\n")
    results$gbfs_ts <- greedy.best.first.search(problem, max_iterations = max_iterations, count_print = 1000)
  }
  
  if ("astar_ts" %in% algorithms) {
    if (verbose) cat("Running A* (Tree Search)...\n")
    results$astar_ts <- a.star.search(problem, max_iterations = max_iterations, count_print = 1000)
  }
  
  # --- GRAPH SEARCH ALGORITHMS ---
  if ("bfs_gs" %in% algorithms) {
    if (verbose) cat("Running BFS (Graph Search)...\n")
    results$bfs_gs <- breadth.first.search(problem, max_iterations = max_iterations, count_print = 1000, graph_search = TRUE)
  }
  
  if ("dfs_gs" %in% algorithms) {
    if (verbose) cat("Running DFS (Graph Search)...\n")
    results$dfs_gs <- depth.first.search(problem, max_iterations = max_iterations, count_print = 1000, graph_search = TRUE)
  }
  
  if ("dls_gs" %in% algorithms) {
    if (verbose) cat("Running DLS (Graph Search)...\n")
    results$dls_gs <- depth.limited.search(problem, max_iterations = max_iterations,
                                          depth_limit = depth_limit, count_print = 1000, graph_search = TRUE)
  }
  
  if ("ids_gs" %in% algorithms) {
    if (verbose) cat("Running IDS (Graph Search)...\n")
    results$ids_gs <- iterative.deepening.search(problem, max_iterations = max_iterations,
                                                max_depth = max_depth, count_print = 1000, graph_search = TRUE)
  }
  
  if ("ucs_gs" %in% algorithms) {
    if (verbose) cat("Running UCS (Graph Search)...\n")
    results$ucs_gs <- uniform.cost.search(problem, max_iterations = max_iterations, count_print = 1000, graph_search = TRUE)
  }
  
  if ("gbfs_gs" %in% algorithms) {
    if (verbose) cat("Running Greedy BFS (Graph Search)...\n")
    results$gbfs_gs <- greedy.best.first.search(problem, max_iterations = max_iterations, count_print = 1000, graph_search = TRUE)
  }
  
  if ("astar_gs" %in% algorithms) {
    if (verbose) cat("Running A* (Graph Search)...\n")
    results$astar_gs <- a.star.search(problem, max_iterations = max_iterations, count_print = 1000, graph_search = TRUE)
  }
  
  # --- ANALYSIS ---
  if (verbose) cat("\nGenerating analysis...\n")
  analysis <- analyze.results(results, problem)
  
  # Create table string for display
  table_str <- capture.output(print(analysis, row.names = FALSE))
  table_str <- paste(table_str, collapse = "\n")
  cat(paste0("\n", table_str))
  
  # --- EXPORT CSV ---
  if (export_csv) {
    csv_filename <- paste0(csv_dir, "/", basename(file))
    csv_filename <- gsub(".txt", ".csv", csv_filename)
    
    write.csv(analysis, file = csv_filename, row.names = FALSE)
    if (verbose) cat(paste0("\nResults exported to: ", csv_filename, "\n"))
  }
  
  return(list(problem = problem, results = results, analysis = analysis))
}

# =========================================================================
# 6. Process All Data Files
# =========================================================================
process.all.data.files <- function(data_dir = "../data",
                                   max_iterations = 5000,
                                   export_csv = TRUE,
                                   results_dir = "../results",
                                   verbose = TRUE) {
  
  # Get all .txt files
  data_files <- list.files(data_dir, pattern = "\\.txt$", full.names = TRUE)
  
  if (length(data_files) == 0) {
    cat("No .txt files found in", data_dir, "\n")
    return(NULL)
  }
  
  cat(paste0("\nFound ", length(data_files), " data file(s) to process.\n"))
  
  all_results <- list()
  
  for (file in data_files) {
    file_name <- basename(file)
    cat(paste0("\n\n=== Processing: ", file_name, " ===\n"))
    
    result <- solve.instance(
      file = file,
      max_iterations = max_iterations,
      export_csv = export_csv,
      csv_dir = results_dir,
      verbose = verbose
    )
    
    all_results[[file_name]] <- result
  }
  
  # --- SUMMARY TABLE ---
  if (verbose && length(all_results) > 1) {
    cat("\n\n=== OVERALL SUMMARY ===\n")
    summary_df <- do.call(rbind, lapply(names(all_results), function(name) {
      result <- all_results[[name]]
      analysis <- result$analysis
      df <- analysis$dataframe
      valid_rows <- which(!is.na(df$nodes_expanded))
      if (length(valid_rows) == 0) {
        return(data.frame(
          problem = name,
          best_algorithm = NA,
          nodes_expanded = NA,
          solution_depth = NA,
          solution_cost = NA
        ))
      }
      best_row <- df[valid_rows[which.min(df$nodes_expanded[valid_rows])], ]
      data.frame(
        problem = name,
        best_algorithm = best_row$algorithm[1],
        nodes_expanded = best_row$nodes_expanded[1],
        solution_depth = best_row$solution_depth[1],
        solution_cost = if (!is.na(best_row$solution_cost[1])) best_row$solution_cost[1] else NA
      )
    }))
    print(summary_df)
  }
  
  return(all_results)
}

# =========================================================================
# 7. Main Execution
# =========================================================================

# Option A: Process all files in data directory
all_results <- process.all.data.files(
  data_dir = "../data",
  max_iterations = 5000,
  export_csv = TRUE,
  results_dir = "../results",
  verbose = TRUE
)

# Option B: Solve a single problem (uncomment to use)
# result <- solve.instance(
#   file = "../data/01-loop-trap.txt",
#   max_iterations = 5000,
#   export_csv = TRUE,
#   csv_dir = "../results"
# )

cat("\n\n=== EXECUTION COMPLETED ===\n")
