# ---- 0. Paquetes -------------------------------------------------------------
packages   <- c("lpSolve", "mclust", "aricode", "proxy")
installed  <- rownames(installed.packages())
to_install <- setdiff(packages, installed)
if (length(to_install) > 0) install.packages(to_install)

library(lpSolve)
library(mclust)   
library(aricode)  
library(proxy)

# ==============================================================================
# >>>  CONFIGURACIÓN  <<<   
# ==============================================================================

dataset <- read.csv("C:/Users/emont/OneDrive/Escritorio/Tesis/Comparacion/Experimentation DATA 2025/Datasets/Large/abalone.csv")

X <- dataset[, 2:8]

y <- dataset$sex
target_card <- c(1307, 1342, 1528)

# ==============================================================================

# ---- 1. Validaciones ---------------------------------------------------------
X <- as.data.frame(lapply(X, as.numeric))
k <- length(target_card)

if (sum(target_card) != nrow(X)) {
  stop(sprintf("sum(target_card) = %d pero nrow(X) = %d. Ajusta target_card.",
               sum(target_card), nrow(X)))
}

cat(sprintf("Dataset cargado | n=%d | p=%d | k=%d | cardinalidad: %s\n",
            nrow(X), ncol(X), k, paste(target_card, collapse = "+")))

# ---- 2. MILP Assignment Solver -----------------------------------------------
solve_milp_assignment <- function(data, centroids, size_constraints) {
  n <- nrow(data)
  k <- nrow(centroids)
  
  cost_matrix <- proxy::dist(data, centroids, method = "cosine")
  cost_matrix <- as.matrix(cost_matrix)
  cost_vec    <- as.vector(t(cost_matrix))
  
  constr1 <- matrix(0, n, n * k)
  for (i in 1:n) {
    constr1[i, ((i - 1) * k + 1):(i * k)] <- 1
  }
  
  constr2 <- matrix(0, k, n * k)
  for (j in 1:k) {
    constr2[j, seq(j, n * k, by = k)] <- 1
  }
  
  f.con <- rbind(constr1, constr2)
  f.dir <- c(rep("=", n), rep("<=", k))
  f.rhs <- c(rep(1, n), size_constraints)
  
  result <- lp("min", cost_vec, f.con, f.dir, f.rhs, all.bin = TRUE)
  
  if (result$status != 0) stop("MILP no encontró solución factible.")
  
  x_opt <- matrix(result$solution, nrow = n, byrow = TRUE)
  p     <- apply(x_opt, 1, which.max)
  list(p = p)
}

# ---- 3. MILP-KM: loop iterativo ----------------------------------------------
clustering_with_size_constraints <- function(data, size_constraints,
                                             max_iter = 100, tol = 1e-6) {
  data <- as.matrix(data)
  colnames(data) <- NULL
  k <- length(size_constraints)
  d <- ncol(data)
  
  random_indices <- sample(1:nrow(data), k)
  centroids      <- data[random_indices, , drop = FALSE]
  converged      <- FALSE
  iteration      <- 0
  
  while (!converged && iteration < max_iter) {
    iteration <- iteration + 1
    p         <- solve_milp_assignment(data, centroids, size_constraints)$p
    
    new_centroids <- matrix(0, nrow = k, ncol = d)
    for (j in 1:k) {
      pts <- data[p == j, , drop = FALSE]
      new_centroids[j, ] <- if (nrow(pts) > 0) colMeans(pts) else centroids[j, ]
    }
    
    if (max(abs(centroids - new_centroids)) < tol) converged <- TRUE
    centroids <- new_centroids
  }
  
  cat(sprintf("Convergencia en %d iteración(es).\n", iteration))
  list(p = p, centroids = centroids)
}

# ---- 4. Silhouette ------------------------
silhouette_centroid_cosine <- function(X, label_pred) {
  X_mat   <- as.matrix(X)
  X_norms <- sqrt(rowSums(X_mat^2)) + 1e-10
  X_norm  <- X_mat / X_norms
  
  u_labels <- sort(unique(label_pred))
  cents    <- matrix(0, nrow = length(u_labels), ncol = ncol(X_mat))
  for (i in seq_along(u_labels)) {
    mask      <- label_pred == u_labels[i]
    cents[i,] <- if (sum(mask) == 1) X_mat[mask, ] else colMeans(X_mat[mask, ])
  }
  
  c_norms <- sqrt(rowSums(cents^2)) + 1e-10
  c_norm  <- cents / c_norms
  
  dists        <- 1 - tcrossprod(X_norm, c_norm)
  dists[dists < 0] <- 0
  
  idx <- cbind(1:nrow(X_mat), match(label_pred, u_labels))
  a_i <- dists[idx]
  dists[idx] <- Inf
  b_i <- apply(dists, 1, min)
  
  mean((b_i - a_i) / pmax(a_i, b_i), na.rm = TRUE)
}

# ---- 5. Ejecución ------------------------------------------------------------
start_time  <- Sys.time()
result      <- clustering_with_size_constraints(X, target_card)
end_time    <- Sys.time()

pred_labels <- result$p
algo_time   <- as.numeric(difftime(end_time, start_time, units = "secs"))

ari      <- adjustedRandIndex(y, pred_labels)
ami      <- AMI(y, pred_labels)
nmi      <- NMI(y, pred_labels)
sil_mean <- silhouette_centroid_cosine(X, pred_labels)

# ---- 6. Resultados -----------------------------------------------
cat("--------------------------------------------------\n")
cat(sprintf("Silhouette (Centroid-based Cosine) : %.4f\n", sil_mean))
cat(sprintf("ARI                                : %.4f\n", ari))
cat(sprintf("AMI                                : %.4f\n", ami))
cat(sprintf("NMI                                : %.4f\n", nmi))
cat(sprintf("Tiempo de ejecución (seg)          : %.2f\n",  algo_time))
cat("--------------------------------------------------\n")
cat("\nCardinalidad real:\n");    print(table(y))
cat("\nCardinalidad MILP-KM:\n"); print(table(pred_labels))