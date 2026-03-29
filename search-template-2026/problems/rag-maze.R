# =========================================================================
# PROBLEM FORMULATION: RAG MAZE
# =========================================================================
# State representation:
#   A vector of length 2: c(col, row).
#   Represents the current position in the maze grid.
#
# Actions:
#   A vector of moves: c("UP", "DOWN", "LEFT", "RIGHT") for standard moves
#   Plus RAG links (provider;row,col;target_row,target_col)
#
# Transition model:
#   1. Move one cell in the chosen direction (standard moves).
#   2. Use a RAG link to teleport to another location with associated cost.
#
# Goal test:
#   The current coordinates match the final coordinates (G in the map).
#
# Cost function:
#   - Standard moves: 1 unit
#   - RAG links: provider latency + switching latency + duration cost
#
# Heuristic (if applicable):
#   Manhattan distance to goal.
#
# =========================================================================
#
# Authors / Maintainers:
#   - Generated for RAG-based search problems
#
# Last updated: March 2026
# =========================================================================

# =========================================================================
# parse.rag.file(file)
# =========================================================================
# Parses a RAG problem file with format:
#   [PARAMS]
#   GEN_LAT=value
#   ...
#   [MAP]
#   ROWS=value
#   COLS=value
#   map_grid...
#   [RAG_LINKS]
#   provider;start_row,start_col;end_row,end_col
#   ...
# =========================================================================
parse.rag.file <- function(file) {
  if (!file.exists(file)) stop(paste0("File not found: ", file))
  
  lines <- readLines(file)
  content <- list()
  
  # Find section markers
  params_idx <- grep("^\\[PARAMS\\]", lines)
  map_idx <- grep("^\\[MAP\\]", lines)
  rag_idx <- grep("^\\[RAG_LINKS\\]", lines)
  
  # --- PARAMS SECTION ---
  if (length(params_idx) > 0) {
    params_start <- params_idx[1] + 1
    params_end <- if (length(map_idx) > 0) map_idx[1] - 1 else length(lines)
    
    content$params <- list()
    for (i in params_start:params_end) {
      if (lines[i] == "" || substr(lines[i], 1, 1) == "#") next
      parts <- strsplit(lines[i], "=")[[1]]
      if (length(parts) == 2) {
        key <- trimws(parts[1])
        value <- trimws(parts[2])
        if (key == "PROVIDER") {
          if (is.null(content$params[[key]])) {
            content$params[[key]] <- list()
          }
          content$params[[key]] <- c(content$params[[key]], value)
        } else {
          content$params[[key]] <- value
        }
      }
    }
  }
  
  # --- MAP SECTION ---
  if (length(map_idx) > 0) {
    map_start <- map_idx[1] + 1
    map_end <- if (length(rag_idx) > 0) rag_idx[1] - 1 else length(lines)
    
    # Parse ROWS and COLS
    map_section <- lines[map_start:map_end]
    rows_line <- grep("^ROWS=", map_section, value = TRUE)[1]
    cols_line <- grep("^COLS=", map_section, value = TRUE)[1]
    
    if (is.na(rows_line) || is.na(cols_line)) {
      stop("ROWS and COLS must be defined in [MAP] section")
    }
    
    rows_val <- as.numeric(strsplit(rows_line, "=")[[1]][2])
    cols_val <- as.numeric(strsplit(cols_line, "=")[[1]][2])
    
    if (is.na(rows_val) || is.na(cols_val)) {
      stop("ROWS and COLS must have numeric values")
    }
    
    content$rows <- rows_val
    content$cols <- cols_val
    
    # Find grid data lines (skip ROWS= and COLS= lines)
    grid_lines <- map_section[!grepl("^(ROWS|COLS)=", map_section) & map_section != ""]
    
    # Filter to get only the grid (exactly rows_val lines)
    grid_lines <- grid_lines[1:rows_val]
    grid_lines <- grid_lines[!is.na(grid_lines)]
    
    if (length(grid_lines) < rows_val) {
      warning(paste0("Found only ", length(grid_lines), " grid lines, expected ", rows_val))
    }
    
    # Create grid matrix
    grid <- do.call(rbind, lapply(grid_lines, function(x) {
      cells <- unlist(strsplit(trimws(x), "\\s+"))
      # Pad or trim to cols_val
      if (length(cells) < cols_val) {
        cells <- c(cells, rep(".", cols_val - length(cells)))
      } else if (length(cells) > cols_val) {
        cells <- cells[1:cols_val]
      }
      return(cells)
    }))
    
    content$grid <- grid
    
    # Find S and G positions with safe indexing
    s_pos <- which(grid == "S", arr.ind = TRUE)
    g_pos <- which(grid == "G", arr.ind = TRUE)
    
    # Check if S and G were found
    if (nrow(s_pos) == 0) {
      stop("Start position 'S' not found in grid")
    }
    if (nrow(g_pos) == 0) {
      stop("Goal position 'G' not found in grid")
    }
    
    # Convert to (col, row) format with 0-based indexing
    content$state_initial <- c(s_pos[1, 2] - 1, s_pos[1, 1] - 1) # (col, row) 0-based
    content$state_final <- c(g_pos[1, 2] - 1, g_pos[1, 1] - 1)   # (col, row) 0-based
  }
  
  # --- RAG_LINKS SECTION ---
  if (length(rag_idx) > 0) {
    rag_start <- rag_idx[1] + 1
    rag_end <- length(lines)
    
    content$rag_links <- list()
    for (i in rag_start:rag_end) {
      if (lines[i] == "" || substr(lines[i], 1, 1) == "#") next
      content$rag_links[[length(content$rag_links) + 1]] <- lines[i]
    }
  }
  
  return(content)
}

# =========================================================================
# extract.provider.cost(provider_name, params_list)
# =========================================================================
# Extracts the cost and latency for a specific provider
# =========================================================================
extract.provider.cost <- function(provider_name, params_list) {
  for (key in names(params_list)) {
    if (grepl(paste0("^PROVIDER.*", provider_name), params_list[[key]])) {
      # Format: PROVIDER=VectorDB_PRO;LAT=30;COST=1.40
      parts <- strsplit(params_list[[key]], ";")[[1]]
      result <- list(lat = NA, cost = NA)
      for (part in parts) {
        if (grepl("^LAT=", part)) {
          result$lat <- as.numeric(strsplit(part, "=")[[1]][2])
        }
        if (grepl("^COST=", part)) {
          result$cost <- as.numeric(strsplit(part, "=")[[1]][2])
        }
      }
      return(result)
    }
  }
  return(list(lat = NA, cost = NA))
}

# =========================================================================
# initialize.problem(file)
# =========================================================================
# Builds the problem object for RAG maze
# =========================================================================
initialize.problem <- function(file = NULL) {
  if (is.null(file)) {
    stop("RAG Maze requires a file parameter")
  }
  
  # Parse file
  data <- parse.rag.file(file)
  
  problem <- list()
  problem$name <- paste0("RAG Maze - [", basename(file), "]")
  problem$file <- file
  
  # Basic properties
  problem$rows <- data$rows
  problem$cols <- data$cols
  problem$grid <- data$grid
  problem$params <- data$params
  
  # State definitions (convert to 1-based for R)
  problem$state_initial <- data$state_initial + 1
  problem$state_final <- data$state_final + 1
  
  # Parse providers and costs
  problem$providers <- list()
  problem$eur_per_sec <- as.numeric(data$params$EUR_PER_SEC)
  
  if (!is.null(data$params$PROVIDER)) {
    for (value in data$params$PROVIDER) {
      parts <- strsplit(value, ";")[[1]]
      provider_name <- parts[1]
      
      lat <- NA
      cost <- NA
      for (part in parts) {
        if (grepl("^LAT=", part)) {
          lat <- as.numeric(strsplit(part, "=")[[1]][2])
        }
        if (grepl("^COST=", part)) {
          cost <- as.numeric(strsplit(part, "=")[[1]][2])
        }
      }
      
      if (!is.na(lat) && !is.na(cost)) {
        problem$providers[[provider_name]] <- list(lat = lat, cost = cost)
      }
    }
  }
  
  # Parse RAG links
  problem$rag_links <- list()
  if (length(data$rag_links) > 0) {
    for (link_str in data$rag_links) {
      parts <- strsplit(link_str, ";")[[1]]
      if (length(parts) == 3) {
        provider <- trimws(parts[1])
        start_pos <- as.numeric(unlist(strsplit(parts[2], ",")))
        end_pos <- as.numeric(unlist(strsplit(parts[3], ",")))
        
        # Convert to 1-based (col, row)
        start_1based <- c(start_pos[1] + 1, start_pos[2] + 1)
        end_1based <- c(end_pos[1] + 1, end_pos[2] + 1)
        
        problem$rag_links[[length(problem$rag_links) + 1]] <- list(
          provider = provider,
          from = start_1based,
          to = end_1based,
          lat = problem$providers[[provider]]$lat,
          cost = problem$providers[[provider]]$cost
        )
      }
    }
  }
  
  # Standard actions
  problem$actions_possible <- c("UP", "DOWN", "LEFT", "RIGHT")
  
  # Add RAG actions
  for (i in seq_along(problem$rag_links)) {
    problem$actions_possible <- c(problem$actions_possible, paste0("RAG_", i))
  }
  
  return(problem)
}

# =========================================================================
# is.applicable(state, action, problem)
# =========================================================================
# Checks if an action can be applied in a state
# =========================================================================
is.applicable <- function(state, action, problem) {
  col <- state[1]
  row <- state[2]

  # Validación de rango
  if (row < 1 || row > problem$rows || col < 1 || col > problem$cols) {
    return(FALSE)
  }

  # Standard moves
  if (action == "UP") {
    return(row > 1 && problem$grid[row - 1, col] != "#")
  } else if (action == "DOWN") {
    return(row < problem$rows && problem$grid[row + 1, col] != "#")
  } else if (action == "LEFT") {
    return(col > 1 && problem$grid[row, col - 1] != "#")
  } else if (action == "RIGHT") {
    return(col < problem$cols && problem$grid[row, col + 1] != "#")
  } else if (grepl("^RAG_", action)) {
    # RAG links are always applicable
    return(TRUE)
  }

  return(FALSE)
}

# =========================================================================
# effect(state, action, problem)
# =========================================================================
# Returns the successor state after applying an action
# =========================================================================
effect <- function(state, action, problem) {
  col <- state[1]
  row <- state[2]
  
  if (action == "UP") {
    return(c(col, row - 1))
  } else if (action == "DOWN") {
    return(c(col, row + 1))
  } else if (action == "LEFT") {
    return(c(col - 1, row))
  } else if (action == "RIGHT") {
    return(c(col + 1, row))
  } else if (grepl("^RAG_", action)) {
    # Extract RAG link index
    rag_idx <- as.numeric(strsplit(action, "_")[[1]][2])
    rag_link <- problem$rag_links[[rag_idx]]
    return(rag_link$to)
  }
  
  return(state)
}

# =========================================================================
# is.final.state(state, final_state, problem)
# =========================================================================
# Checks if the state is a goal state
# =========================================================================
is.final.state <- function(state, final_state, problem) {
  return(all(state == final_state))
}

# =========================================================================
# to.string(state, problem)
# =========================================================================
# Converts state to unique string identifier (for Graph Search)
# =========================================================================
to.string <- function(state, problem) {
  return(paste(state[1], state[2], sep = ","))
}

# =========================================================================
# get.cost(state, action, problem, parent_node = NULL)
# =========================================================================
# Returns the cost in EUROS of applying an action
# Accounts for GEN_LAT, EUR_PER_SEC, SWITCH_LAT, and provider ticket costs
# =========================================================================
get.cost <- function(state, action, problem, parent_node = NULL) {
  # Safe parameter extraction with defaults
  gen_lat_ms <- 120  # default
  switch_lat_ms <- 60  # default
  eur_per_sec <- 0.01  # default

  if (!is.null(problem$params)) {
    if (!is.null(problem$params$GEN_LAT)) {
      val <- as.numeric(problem$params$GEN_LAT)
      if (!is.na(val)) gen_lat_ms <- val
    }
    if (!is.null(problem$params$SWITCH_LAT)) {
      val <- as.numeric(problem$params$SWITCH_LAT)
      if (!is.na(val)) switch_lat_ms <- val
    }
    if (!is.null(problem$params$EUR_PER_SEC)) {
      val <- as.numeric(problem$params$EUR_PER_SEC)
      if (!is.na(val)) eur_per_sec <- val
    }
  }

  cost_eur <- 0
  
  # Determine current action type
  is_gen <- FALSE
  is_rag <- FALSE
  if (is.character(action) && length(action) == 1) {
    is_gen <- action %in% c("UP", "DOWN", "LEFT", "RIGHT")
    is_rag <- grepl("^RAG_", action)
  }

  # Get previous action type (if available)
  prev_is_gen <- TRUE  # Default: assume starting with GEN
  prev_rag_provider <- NULL
  if (!is.null(parent_node) && !is.null(parent_node$actions) && length(parent_node$actions) > 0) {
    prev_action <- parent_node$actions[length(parent_node$actions)]
    if (is.character(prev_action) && length(prev_action) == 1) {
      prev_is_gen <- prev_action %in% c("UP", "DOWN", "LEFT", "RIGHT")
      if (grepl("^RAG_", prev_action)) {
        prev_rag_parts <- strsplit(prev_action, "_")[[1]]
        if (length(prev_rag_parts) >= 2) {
          prev_rag_idx <- as.numeric(prev_rag_parts[2])
          if (!is.na(prev_rag_idx) && prev_rag_idx > 0 && prev_rag_idx <= length(problem$rag_links)) {
            prev_rag_provider <- problem$rag_links[[prev_rag_idx]]$provider
          }
        }
      }
    }
  }
  
  # --- GEN ACTION ---
  if (is_gen) {
    # Latency in EUR
    gen_cost_eur <- (gen_lat_ms / 1000) * eur_per_sec
    cost_eur <- cost_eur + gen_cost_eur
    
    # SWITCH_LAT penalty if switching FROM RAG TO GEN
    if (!is.null(parent_node) && !prev_is_gen) {
      switch_cost_eur <- (switch_lat_ms / 1000) * eur_per_sec
      cost_eur <- cost_eur + switch_cost_eur
    }
  }
  # --- RAG ACTION ---
  else if (is_rag) {
    rag_parts <- strsplit(action, "_")[[1]]
    if (length(rag_parts) >= 2) {
      rag_idx <- as.numeric(rag_parts[2])
      if (!is.na(rag_idx) && rag_idx > 0 && rag_idx <= length(problem$rag_links)) {
        rag_link <- problem$rag_links[[rag_idx]]
        curr_provider <- rag_link$provider

        # Latency in EUR
        latency_cost_eur <- (rag_link$lat / 1000) * eur_per_sec
        cost_eur <- cost_eur + latency_cost_eur

        # Provider ticket cost (only first time or when switching providers)
        if (is.null(parent_node) || prev_is_gen || !identical(prev_rag_provider, curr_provider)) {
          cost_eur <- cost_eur + rag_link$cost
        }

        # SWITCH_LAT penalty if switching FROM GEN TO RAG or between providers
        if (!is.null(parent_node) && (prev_is_gen || !identical(prev_rag_provider, curr_provider))) {
          switch_cost_eur <- (switch_lat_ms / 1000) * eur_per_sec
          cost_eur <- cost_eur + switch_cost_eur
        }
      }
    }
  }
  
  # Ensure we return a numeric value
  result <- as.numeric(cost_eur)
  if (length(result) == 0 || any(is.na(result)) || any(!is.finite(result))) {
    result <- 0
  } else {
    result <- result[1]  # ensure scalar
  }
  return(result)
}

# =========================================================================
# get.evaluation(state, problem)
# =========================================================================
# Returns heuristic value h(n)
# Admissible heuristic: Manhattan distance (ignores obstacles)
# Unified cost = time + money: h(n) = manhattan_dist * (GEN_LAT/1000 * EUR_PER_SEC)
# =========================================================================
get.evaluation <- function(state, problem) {
  col <- state[1]
  row <- state[2]
  goal_col <- problem$state_final[1]
  goal_row <- problem$state_final[2]

  manhattan_dist <- abs(col - goal_col) + abs(row - goal_row)

  # Safe parameter extraction with defaults
  gen_lat_ms <- 120  # default
  eur_per_sec <- 0.01  # default

  if (!is.null(problem$params)) {
    if (!is.null(problem$params$GEN_LAT)) {
      val <- as.numeric(problem$params$GEN_LAT)
      if (!is.na(val)) gen_lat_ms <- val
    }
    if (!is.null(problem$params$EUR_PER_SEC)) {
      val <- as.numeric(problem$params$EUR_PER_SEC)
      if (!is.na(val)) eur_per_sec <- val
    }
  }

  cost_per_step_eur <- (gen_lat_ms / 1000) * eur_per_sec

  # Admissible: assumes each step costs one GEN action (worst case, ignores RAG shortcuts)
  result <- manhattan_dist * cost_per_step_eur

  # Ensure we return a numeric value
  result <- as.numeric(result)
  if (length(result) == 0 || any(is.na(result)) || any(!is.finite(result))) {
    result <- 0  # fallback
  } else {
    result <- result[1]  # ensure scalar
  }
  return(result)
}
