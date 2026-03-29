# =========================================================================
# Utility: RAG Problem Generator
# =========================================================================
# Helps create and validate new RAG Maze problem instances
# =========================================================================

# =========================================================================
# create.problem.template()
# =========================================================================
# Generates a template for a new problem
# =========================================================================
create.problem.template <- function(filename, rows = 10, cols = 10,
                                  gen_lat = 120, switch_lat = 60,
                                  eur_per_sec = 0.01) {
  
  # Create a simple grid with random walls
  grid <- matrix(".", nrow = rows, ncol = cols)
  
  # Add some random walls
  for (i in 2:(rows-1)) {
    for (j in 2:(cols-1)) {
      if (runif(1) < 0.15) {
        grid[i, j] <- "#"
      }
    }
  }
  
  # Place start and goal
  grid[2, 2] <- "S"
  grid[rows-1, cols-1] <- "G"
  
  # Build file content
  content <- c(
    "# Problem Template - Replace with your configuration",
    "[PARAMS]",
    paste0("GEN_LAT=", gen_lat),
    paste0("SWITCH_LAT=", switch_lat),
    paste0("EUR_PER_SEC=", eur_per_sec),
    "PROVIDER=VectorDB_PRO;LAT=30;COST=1.50",
    "PROVIDER=VectorDB_ECO;LAT=55;COST=0.75",
    "",
    "[MAP]",
    paste0("ROWS=", rows),
    paste0("COLS=", cols)
  )
  
  # Add grid
  for (i in 1:rows) {
    content <- c(content, paste(grid[i, ], collapse = " "))
  }
  
  # Add RAG links section
  content <- c(
    content,
    "",
    "[RAG_LINKS]",
    "# Format: PROVIDER;row_start,col_start;row_end,col_end",
    "VectorDB_ECO;1,1;2,5",
    "VectorDB_PRO;3,3;7,7"
  )
  
  # Write to file
  writeLines(content, filename)
  cat(paste0("Template created: ", filename, "\n"))
}

# =========================================================================
# validate.problem.file(filename)
# =========================================================================
# Validates that a problem file has correct format
# =========================================================================
validate.problem.file <- function(filename) {
  if (!file.exists(filename)) {
    cat("ERROR: File not found:", filename, "\n")
    return(FALSE)
  }
  
  tryCatch({
    # Try to parse the file
    lines <- readLines(filename)
    
    # Check sections exist
    has_params <- any(grepl("^\\[PARAMS\\]", lines))
    has_map <- any(grepl("^\\[MAP\\]", lines))
    has_rag <- any(grepl("^\\[RAG_LINKS\\]", lines))
    
    if (!has_params) cat("WARNING: [PARAMS] section not found\n")
    if (!has_map) cat("WARNING: [MAP] section not found\n")
    if (!has_rag) cat("WARNING: [RAG_LINKS] section not found\n")
    
    # Check for S and G in map
    map_section <- lines[grep("^\\[MAP\\]", lines):(grep("^\\[RAG_LINKS\\]", lines)-1)]
    map_text <- paste(map_section, collapse = " ")
    
    if (!grepl("S", map_text)) cat("ERROR: No start position (S) in map\n")
    if (!grepl("G", map_text)) cat("ERROR: No goal position (G) in map\n")
    
    cat("✓ Problem file is valid\n")
    return(TRUE)
    
  }, error = function(e) {
    cat("ERROR parsing file:", e$message, "\n")
    return(FALSE)
  })
}

# =========================================================================
# list.data.files()
# =========================================================================
# Lists all available problem files in data directory
# =========================================================================
list.data.files <- function(data_dir = "../data") {
  files <- list.files(data_dir, pattern = "\\.txt$", full.names = FALSE)
  
  if (length(files) == 0) {
    cat("No problem files found in", data_dir, "\n")
    return(NULL)
  }
  
  cat("Available Problems:\n")
  for (i in seq_along(files)) {
    cat(sprintf("[%d] %s\n", i, files[i]))
  }
  
  return(files)
}

# =========================================================================
# Example Usage
# =========================================================================

if (FALSE) {
  
  # Generate a new problem template
  create.problem.template(
    filename = "../data/07-custom-problem.txt",
    rows = 12,
    cols = 12,
    gen_lat = 100,
    switch_lat = 50
  )
  
  # Validate a problem file
  validate.problem.file("../data/01-loop-trap.txt")
  
  # List all available problems
  problems <- list.data.files("../data")
  
}
