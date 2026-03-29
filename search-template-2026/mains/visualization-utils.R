# =========================================================================
# Utility Script: RAG Maze Visualization & Analysis
# =========================================================================
# Displays problem information and results in a readable format
# =========================================================================

# =========================================================================
# print.rag.problem(problem)
# =========================================================================
# Prints problem details in a nice format
# =========================================================================
print.rag.problem <- function(problem) {
  cat("\n")
  cat(repeats("=", 70), "\n")
  cat("PROBLEM: ", problem$name, "\n")
  cat(repeats("=", 70), "\n\n")
  
  cat("Grid Size:        ", problem$rows, " x ", problem$cols, "\n")
  cat("Start Position:   (col=", problem$state_initial[1], ", row=", problem$state_initial[2], ")\n")
  cat("Goal Position:    (col=", problem$state_final[1], ", row=", problem$state_final[2], ")\n")
  cat("Number of RAG Links: ", length(problem$rag_links), "\n\n")
  
  # Print grid
  cat("Grid Visualization:\n")
  cat(repeats("-", 70), "\n")
  for (i in 1:problem$rows) {
    row_str <- paste(problem$grid[i, ], collapse = " ")
    cat(row_str, "\n")
  }
  cat(repeats("-", 70), "\n\n")
  
  # Print RAG Links
  if (length(problem$rag_links) > 0) {
    cat("RAG Links Available:\n")
    for (i in seq_along(problem$rag_links)) {
      link <- problem$rag_links[[i]]
      cat(sprintf("  [%d] %s: (%d,%d) -> (%d,%d) | LAT=%d, COST=%.2f\n",
                  i, link$provider, 
                  link$from[1], link$from[2],
                  link$to[1], link$to[2],
                  link$lat, link$cost))
    }
  }
  cat("\n")
}

# =========================================================================
# repeats(char, n)
# =========================================================================
# Repeats a character n times (utility)
# =========================================================================
repeats <- function(char, n) {
  paste(rep(char, n), collapse = "")
}

# =========================================================================
# print.solution(result, problem)
# =========================================================================
# Prints a solution path and statistics
# =========================================================================
print.solution <- function(result, problem) {
  if (is.null(result) || !result$found) {
    cat("Solution: NOT FOUND\n")
    return()
  }
  
  cat("Solution Found!\n")
  cat("Solution Path (", length(result$path), " steps):\n")
  
  for (i in seq_along(result$path)) {
    state <- result$path[[i]]
    action <- if (i > 1) result$actions[i-1] else "INITIAL"
    cat(sprintf("  Step %d: (col=%d, row=%d) [%s]\n", i-1, state[1], state[2], action))
  }
  
  cat("\n")
  cat("Total Cost:        ", result$cost, "\n")
  cat("Depth:             ", result$depth, "\n")
  cat("Nodes Expanded:    ", result$nodes_expanded, "\n")
  cat("Time (seconds):    ", result$time, "\n")
  cat("\n")
}

# =========================================================================
# print.comparison.table(results_list)
# =========================================================================
# Prints a comparison of all algorithm results
# =========================================================================
print.comparison.table <- function(results_list) {
  cat("\n")
  cat(repeats("=", 120), "\n")
  cat("ALGORITHM COMPARISON\n")
  cat(repeats("=", 120), "\n\n")
  
  # Create comparison dataframe
  df <- do.call(rbind, lapply(names(results_list), function(name) {
    result <- results_list[[name]]
    data.frame(
      Algorithm = name,
      Found = result$found,
      Cost = if (result$found) result$cost else NA,
      Depth = if (result$found) result$depth else NA,
      Nodes_Expanded = result$nodes_expanded,
      Time_sec = round(result$time, 4),
      Status = if (result$found) "SUCCESS" else if (result$nodes_expanded >= 5000) "MAX_ITER" else "FAILED"
    )
  }))
  
  # Sort by nodes expanded
  df <- df[order(df$Nodes_Expanded), ]
  print(df, row.names = FALSE)
  
  cat("\n")
}

# =========================================================================
# visualize.solution.path(result, problem)
# =========================================================================
# Displays the solution path on the grid
# =========================================================================
visualize.solution.path <- function(result, problem) {
  if (is.null(result) || !result$found) {
    cat("No solution to visualize.\n")
    return()
  }
  
  # Create a copy of the grid
  viz_grid <- problem$grid
  
  # Mark the path
  for (i in 2:(length(result$path)-1)) {
    state <- result$path[[i]]
    col <- state[1]
    row <- state[2]
    if (viz_grid[row, col] == ".") {
      viz_grid[row, col] <- "*"
    }
  }
  
  # Mark start and goal
  viz_grid[problem$state_initial[2], problem$state_initial[1]] <- "S"
  viz_grid[problem$state_final[2], problem$state_final[1]] <- "G"
  
  cat("\nSolution Path Visualization (* = path):\n")
  cat(repeats("-", 70), "\n")
  for (i in 1:problem$rows) {
    row_str <- paste(viz_grid[i, ], collapse = " ")
    cat(row_str, "\n")
  }
  cat(repeats("-", 70), "\n\n")
}

# =========================================================================
# export.solution.report(result, problem, filename)
# =========================================================================
# Exports a detailed solution report to a text file
# =========================================================================
export.solution.report <- function(result, problem, filename) {
  sink(filename)
  
  cat(repeats("=", 70), "\n")
  cat("SOLUTION REPORT: ", problem$name, "\n")
  cat(repeats("=", 70), "\n\n")
  
  cat(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n")
  
  print.rag.problem(problem)
  print.solution(result, problem)
  visualize.solution.path(result, problem)
  
  sink()
  
  cat(paste0("Report exported to: ", filename, "\n"))
}
