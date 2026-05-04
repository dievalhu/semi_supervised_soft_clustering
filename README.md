## Semi-Supervised Soft Clustering with Flexible Cardinality 

## Overview

This repository contains the implementation of **CapFlex**, a semi-supervised clustering framework proposed in the paper *"Semi-Supervised Soft Clustering with Flexible Cardinality"*.

Clustering under size requirements is critical in operational settings (e.g., workload distribution, territorial partitioning) but is often hindered by rigid constraints that overrule data similarity. **CapFlex** treats target cluster sizes as *soft* requirements by allowing bounded deviations around an ideal cardinality vector.

Key features:
* **Flexible Constraints:** Allows defined tolerance margins ($\delta$) around target sizes instead of strict equality.
* **Hybrid Optimization:** Combines stochastic exploration of feasible cardinality vectors with an exact Mixed-Integer Linear Programming (MILP) assignment step.
* **Pareto Optimization:** Balances the trade-off between structural quality (Silhouette) and cardinality compliance.

## Methodology
The proposed approach uses a two-level algorithm. The outer level performs a bounded exploration of the cardinality search space (using Random Search), while the inner level solves the optimal assignment problem for each candidate capacity vector using MILP.

![CapFlex Architecture](img/methodology.png)
*Figure 1: The CapFlex framework architecture, illustrating the coupling of stochastic capacity exploration with MILP-based assignment optimization.*

## Installation
This project is written in **R**. To replicate the experiments, you need a working R environment (version 4.0.0 or higher is recommended).

### Prerequisites

* **R**: Download from [CRAN](https://cran.r-project.org/).
* **RStudio** (Optional but recommended).

### Dependencies
```r
install.packages(c(
  "foreach",     
  "doParallel",  
  "lpSolve",     
  "readr",       
  "dplyr",       
  "aricode",     
  "cluster"
```

## Usage

### 1. Running the Analysis

The main script is designed to be executed either from the command line or interactively within RStudio.

**Option A: Command Line**

To run the complete pipeline using `Rscript`:

```bash
Rscript CapFlex.R
```

**Option B: RStudio**

1. Open the project in RStudio.
2. Open the `CapFlex.R` script.
3. Adjust the parameters at the beginning of the file to select the dataset or tolerance.
4. Click the **Source** button to run the complete pipeline.

### A. Notation

| Symbol | Description |
|---|---|
| $\mathcal{D}$ | Dataset. |
| $n$ | Total number of instances in the dataset. |
| $k$ | Number of *clusters*. |
| $x_j$ | $j$-th instance in the dataset. |
| $C$ | Set of *clusters*. |
| $C_i$ | Resulting cardinality of *cluster* $i$. |
| $c$ | Set of centroids. |
| $E$ | Vector of target size constraints. |
| $E_i$ | Exact cardinality for *cluster* $i$. |
| $L_i, U_i$ | Allowed bounds for the size of *cluster* $i$. |
| $Z_{ij}$ | Binary decision variable. |
| $\delta$ | Flexible tolerance coefficient. |
| $\mathcal{H}$ | Historical set of evaluated candidate solutions. |
| $\mathcal{P}$ | Pareto front containing the non-dominated solutions. |
| $J$ | Objective function representing the total dissimilarity cost. |
| $S$ | Computed Silhouette coefficient. |
| $V$ | Cardinality Violation Index (CSVI). |
| $Z$ | Binary assignment matrix. |
| $\mathcal{E}$ | Set of feasible cardinalities. |
| $r$ | Remaining instances to be assigned in the recursion. |
| $R_{min}, R_{max}$ | Lower and upper pruning bounds for future *clusters*. |
| $v$ | Candidate cardinality of the current *cluster*. |
| $d_{ij}$ | Dissimilarity between instance $x_j$ and the centroid of *cluster* $i$. |
| $\epsilon$ | Centroid convergence threshold. |

### B. Summary of evaluation datasets

| ID | Dataset Name | #Instances | #Vars. | #Clusters | Cluster Sizes |
|---|---|---:|---:|---:|---|
| 1 | Iris | 150 | 4 | 3 | [50, 50, 50] |
| 2 | Heart Disease | 1025 | 14 | 2 | [499, 526] |
| 3 | Obesity Levels | 2111 | 17 | 7 | [272, 287, 351, 297, 324, 290, 290] |
| 4 | Glass Identification | 214 | 9 | 6 | [70, 76, 17, 13, 9, 29] |
| 5 | Breast Cancer Wisconsin | 568 | 30 | 2 | [356, 212] |
| 6 | Engineering Salary | 2998 | 34 | 2 | [226, 2772] |
| 7 | Water Probability | 3276 | 10 | 2 | [1998, 1278] |
| 8 | Cure The Princess | 2338 | 14 | 2 | [1177, 1161] |
| 9 | AIDS Clinical | 2139 | 24 | 2 | [1618, 521] |
| 10 | Migration Mexico-USA | 2443 | 10 | 6 | [330, 593, 392, 93, 162, 873] |
| 11 | Bank Loan Approval | 5000 | 14 | 2 | [4520, 480] |
| 12 | Wine Quality | 6497 | 13 | 2 | [1599, 4898] |
| 13 | Clustering of Cycling | 4435 | 11 | 9 | [1399, 312, 467, 356, 290, 549, 503, 185, 374] |
| 14 | Turkiye Student Evaluation | 5820 | 33 | 3 | [775, 1444, 3601] |
| 15 | Abalone | 4177 | 8 | 3 | [1307, 1342, 1528] |

### C. Evaluation metrics for the dataset collection

Comparison between clustering algorithms according to their size. The table presents, for each dataset (ID) and algorithm, the number of groups, the resulting cluster sizes, the flexibility parameter $\delta$, the cardinality deviation metrics ILVC and CLVC, the composite CSVI index, and the internal validity index $S_e$. The best results are highlighted in **bold**.

<table>
  <thead>
    <tr>
      <th>ID</th>
      <th>Algorithm</th>
      <th>#Groups</th>
      <th>Cluster Sizes</th>
      <th>δ</th>
      <th>ILVC</th>
      <th>CLVC</th>
      <th>CSVI</th>
      <th>AMI</th>
      <th><em><strong>S<sub>e</sub></strong></em></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="5">1</td>
      <td>AHC</td>
      <td rowspan="5">3</td>
      <td>[50, 74, 26]</td>
      <td>-</td>
      <td>48</td>
      <td>2</td>
      <td>0.493</td>
      <td>0.714</td>
      <td>0.692</td>
    </tr>
    <tr>
      <td>K-Medoids</td>
      <td>[50, 62, 38]</td>
      <td>-</td>
      <td>24</td>
      <td>2</td>
      <td>0.413</td>
      <td>0.748</td>
      <td>0.626</td>
    </tr>
    <tr>
      <td>CSCLP</td>
      <td>[50, 50, 50]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.785</td>
      <td>0.781</td>
    </tr>
    <tr>
      <td>K-MedoidsSC</td>
      <td>[50, 50, 50]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.013</td>
      <td>-0.104</td>
    </tr>
    <tr>
      <td><code>CapFlex</code></td>
      <td>[49, 50, 51]</td>
      <td>0.1</td>
      <td>2</td>
      <td>2</td>
      <td><strong>0.340</strong></td>
      <td><strong>0.879</strong></td>
      <td><strong>0.837</strong></td>
    </tr>
    <tr>
      <td rowspan="5">2</td>
      <td>AHC</td>
      <td rowspan="5">2</td>
      <td>[801, 224]</td>
      <td>-</td>
      <td>604</td>
      <td>2</td>
      <td>0.795</td>
      <td>0.025</td>
      <td>0.688</td>
    </tr>
    <tr>
      <td>K-Medoids</td>
      <td>[501, 524]</td>
      <td>-</td>
      <td>4</td>
      <td>2</td>
      <td><strong>0.502</strong></td>
      <td>0.014</td>
      <td>0.602</td>
    </tr>
    <tr>
      <td>CSCLP</td>
      <td>[499, 526]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td><strong>0.110</strong></td>
      <td>0.449</td>
    </tr>
    <tr>
      <td>K-MedoidsSC</td>
      <td>[499, 526]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.018</td>
      <td>0.175</td>
    </tr>
    <tr>
      <td><code>CapFlex</code></td>
      <td>[503, 522]</td>
      <td>0.08</td>
      <td>8</td>
      <td>2</td>
      <td>0.504</td>
      <td>0.034</td>
      <td><strong>0.718</strong></td>
    </tr>
    <tr>
      <td rowspan="5">3</td>
      <td>AHC</td>
      <td rowspan="5">7</td>
      <td>[1145, 301, 248, 40, 366, 2, 9]</td>
      <td>-</td>
      <td>1680</td>
      <td>7</td>
      <td>0.898</td>
      <td>0.146</td>
      <td><strong>0.639</strong></td>
    </tr>
    <tr>
      <td>K-Medoids</td>
      <td>[343, 332, 440, 317, 179, 340, 160]</td>
      <td>-</td>
      <td>440</td>
      <td>7</td>
      <td>0.604</td>
      <td><strong>0.470</strong></td>
      <td>0.031</td>
    </tr>
    <tr>
      <td>CSCLP</td>
      <td>[272, 287, 351, 297, 324, 290, 290]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.210</td>
      <td>0.461</td>
    </tr>
    <tr>
      <td>K-MedoidsSC</td>
      <td>[272, 287, 351, 297, 324, 290, 290]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.134</td>
      <td>-0.248</td>
    </tr>
    <tr>
      <td><code>CapFlex</code></td>
      <td>[292, 292, 351, 287, 327, 251, 311]</td>
      <td>0.15</td>
      <td>42</td>
      <td>5</td>
      <td><strong>0.367</strong></td>
      <td>0.239</td>
      <td>0.579</td>
    </tr>
    <tr>
      <td rowspan="5">4</td>
      <td>AHC</td>
      <td rowspan="5">6</td>
      <td>[151, 25, 6, 27, 3, 2]</td>
      <td>-</td>
      <td>190</td>
      <td>6</td>
      <td>0.944</td>
      <td><strong>0.353</strong></td>
      <td><strong>0.817</strong></td>
    </tr>
    <tr>
      <td>K-Medoids</td>
      <td>[39, 65, 60, 20, 28, 2]</td>
      <td>-</td>
      <td>134</td>
      <td>6</td>
      <td>0.822</td>
      <td>0.304</td>
      <td>0.577</td>
    </tr>
    <tr>
      <td>CSCLP</td>
      <td>[70, 76, 17, 13, 9, 29]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.280</td>
      <td>0.438</td>
    </tr>
    <tr>
      <td>K-MedoidsSC</td>
      <td>[70, 76, 17, 13, 9, 29]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.134</td>
      <td>-0.066</td>
    </tr>
    <tr>
      <td><code>CapFlex</code></td>
      <td>[63, 86, 13, 13, 9, 30]</td>
      <td>0.18</td>
      <td>22</td>
      <td>4</td>
      <td><strong>0.388</strong></td>
      <td>0.333</td>
      <td>0.599</td>
    </tr>
    <tr>
      <td rowspan="5">5</td>
      <td>AHC</td>
      <td rowspan="5">2</td>
      <td>[44, 524]</td>
      <td>-</td>
      <td>336</td>
      <td>2</td>
      <td>0.796</td>
      <td>0.122</td>
      <td><strong>0.813</strong></td>
    </tr>
    <tr>
      <td>K-Medoids</td>
      <td>[139, 429]</td>
      <td>-</td>
      <td>146</td>
      <td>2</td>
      <td>0.623</td>
      <td>0.458</td>
      <td>0.682</td>
    </tr>
    <tr>
      <td>CSCLP</td>
      <td>[356, 212]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.448</td>
      <td>0.752</td>
    </tr>
    <tr>
      <td>K-MedoidsSC</td>
      <td>[356, 212]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.034</td>
      <td>0.191</td>
    </tr>
    <tr>
      <td><code>CapFlex</code></td>
      <td>[360, 208]</td>
      <td>0.25</td>
      <td>8</td>
      <td>2</td>
      <td><strong>0.507</strong></td>
      <td><strong>0.481</strong></td>
      <td>0.757</td>
    </tr>
    <tr>
      <td rowspan="5">6</td>
      <td>AHC</td>
      <td rowspan="5">2</td>
      <td>[2938, 60]</td>
      <td>-</td>
      <td>332</td>
      <td>2</td>
      <td>0.555</td>
      <td>0.005</td>
      <td><strong>0.885</strong></td>
    </tr>
    <tr>
      <td>K-Medoids</td>
      <td>[1664, 1334]</td>
      <td>-</td>
      <td>2216</td>
      <td>2</td>
      <td>0.867</td>
      <td><strong>0.026</strong></td>
      <td>0.306</td>
    </tr>
    <tr>
      <td>CSCLP</td>
      <td>[226, 2772]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>-0.001</td>
      <td>0.225</td>
    </tr>
    <tr>
      <td>K-MedoidsSC</td>
      <td>[226, 2772]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.004</td>
      <td>0.007</td>
    </tr>
    <tr>
      <td><code>CapFlex</code></td>
      <td>[223, 2775]</td>
      <td>0.12</td>
      <td>6</td>
      <td>2</td>
      <td><strong>0.501</strong></td>
      <td>0.011</td>
      <td>0.869</td>
    </tr>
    <tr>
      <td rowspan="5">7</td>
      <td>AHC</td>
      <td rowspan="5">2</td>
      <td>[3274, 2]</td>
      <td>-</td>
      <td>2552</td>
      <td>2</td>
      <td>0.889</td>
      <td>-0.0003</td>
      <td><strong>0.998</strong></td>
    </tr>
    <tr>
      <td>K-Medoids</td>
      <td>[1826, 1450]</td>
      <td>-</td>
      <td>344</td>
      <td>2</td>
      <td>0.552</td>
      <td>0.0001</td>
      <td>0.670</td>
    </tr>
    <tr>
      <td>CSCLP</td>
      <td>[1998, 1278]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td><strong>0.0008</strong></td>
      <td>0.686</td>
    </tr>
    <tr>
      <td>K-MedoidsSC</td>
      <td>[1998, 1278]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.0006</td>
      <td>0.243</td>
    </tr>
    <tr>
      <td><code>CapFlex</code></td>
      <td>[1999, 1277]</td>
      <td>0.09</td>
      <td>2</td>
      <td>2</td>
      <td><strong>0.500</strong></td>
      <td>-4.6e-5</td>
      <td>0.802</td>
    </tr>
    <tr>
      <td rowspan="5">8</td>
      <td>AHC</td>
      <td rowspan="5">2</td>
      <td>[1868, 470]</td>
      <td>-</td>
      <td>1382</td>
      <td>2</td>
      <td>0.796</td>
      <td>0.028</td>
      <td>0.191</td>
    </tr>
    <tr>
      <td>K-Medoids</td>
      <td>[970, 1368]</td>
      <td>-</td>
      <td>382</td>
      <td>2</td>
      <td>0.582</td>
      <td>0.003</td>
      <td>0.161</td>
    </tr>
    <tr>
      <td>CSCLP</td>
      <td>[1177, 1161]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.001</td>
      <td>0.182</td>
    </tr>
    <tr>
      <td>K-MedoidsSC</td>
      <td>[1177, 1161]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.007</td>
      <td>0.052</td>
    </tr>
    <tr>
      <td><code>CapFlex</code></td>
      <td>[1176, 1162]</td>
      <td>0.15</td>
      <td>2</td>
      <td>2</td>
      <td><strong>0.500</strong></td>
      <td><strong>0.039</strong></td>
      <td><strong>0.341</strong></td>
    </tr>
    <tr>
      <td rowspan="5">9</td>
      <td>AHC</td>
      <td rowspan="5">2</td>
      <td>[1952, 187]</td>
      <td>-</td>
      <td>668</td>
      <td>2</td>
      <td>0.656</td>
      <td>0.018</td>
      <td>0.639</td>
    </tr>
    <tr>
      <td>K-Medoids</td>
      <td>[1433, 706]</td>
      <td>-</td>
      <td>370</td>
      <td>2</td>
      <td>0.586</td>
      <td>0.011</td>
      <td>0.676</td>
    </tr>
    <tr>
      <td>CSCLP</td>
      <td>[1618, 521]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td><strong>0.065</strong></td>
      <td>0.480</td>
    </tr>
    <tr>
      <td>K-MedoidsSC</td>
      <td>[1618, 521]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.029</td>
      <td>0.151</td>
    </tr>
    <tr>
      <td><code>CapFlex</code></td>
      <td>[1613, 526]</td>
      <td>0.1</td>
      <td>10</td>
      <td>2</td>
      <td><strong>0.502</strong></td>
      <td>0.010</td>
      <td><strong>0.681</strong></td>
    </tr>
    <tr>
      <td rowspan="5">10</td>
      <td>AHC</td>
      <td rowspan="5">6</td>
      <td>[2032, 90, 110, 78, 93, 40]</td>
      <td>-</td>
      <td>2318</td>
      <td>6</td>
      <td>0.974</td>
      <td>0.003</td>
      <td><strong>0.869</strong></td>
    </tr>
    <tr>
      <td>K-Medoids</td>
      <td>[48, 738, 316, 1231, 11, 99]</td>
      <td>-</td>
      <td>1006</td>
      <td>6</td>
      <td>0.706</td>
      <td>0.018</td>
      <td>-0.078</td>
    </tr>
    <tr>
      <td>CSCLP</td>
      <td>[330, 593, 392, 93, 162, 873]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td><strong>0.032</strong></td>
      <td>0.360</td>
    </tr>
    <tr>
      <td>K-MedoidsSC</td>
      <td>[330, 593, 392, 93, 162, 873]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.016</td>
      <td>0.101</td>
    </tr>
    <tr>
      <td><code>CapFlex</code></td>
      <td>[330, 612, 374, 86, 160, 881]</td>
      <td>0.1</td>
      <td>54</td>
      <td>5</td>
      <td><strong>0.428</strong></td>
      <td>0.014</td>
      <td>0.697</td>
    </tr>
    <tr>
      <td rowspan="5">11</td>
      <td>AHC</td>
      <td rowspan="5">2</td>
      <td>[4756, 244]</td>
      <td>-</td>
      <td>472</td>
      <td>2</td>
      <td>0.547</td>
      <td>0.045</td>
      <td><strong>0.869</strong></td>
    </tr>
    <tr>
      <td>K-Medoids</td>
      <td>[2448, 2552]</td>
      <td>-</td>
      <td>3936</td>
      <td>2</td>
      <td>0.894</td>
      <td>-0.0001</td>
      <td>0.005</td>
    </tr>
    <tr>
      <td>CSCLP</td>
      <td>[4520, 480]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td><strong>0.121</strong></td>
      <td>0.517</td>
    </tr>
    <tr>
      <td>K-MedoidsSC</td>
      <td>[4520, 480]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.043</td>
      <td>0.859</td>
    </tr>
    <tr>
      <td><code>CapFlex</code></td>
      <td>[4518, 482]</td>
      <td>0.18</td>
      <td>4</td>
      <td>2</td>
      <td><strong>0.500</strong></td>
      <td>0.042</td>
      <td>0.866</td>
    </tr>
    <tr>
      <td rowspan="5">12</td>
      <td>AHC</td>
      <td rowspan="5">2</td>
      <td>[5743, 754]</td>
      <td>-</td>
      <td>1690</td>
      <td>2</td>
      <td>0.630</td>
      <td>0.303</td>
      <td><strong>0.884</strong></td>
    </tr>
    <tr>
      <td>K-Medoids</td>
      <td>[4175, 2322]</td>
      <td>-</td>
      <td>1446</td>
      <td>2</td>
      <td>0.611</td>
      <td>0.355</td>
      <td>0.589</td>
    </tr>
    <tr>
      <td>CSCLP</td>
      <td>[1599, 4898]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.116</td>
      <td>0.290</td>
    </tr>
    <tr>
      <td>K-MedoidsSC</td>
      <td>[1599, 4898]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.068</td>
      <td>0.155</td>
    </tr>
    <tr>
      <td><code>CapFlex</code></td>
      <td>[1378, 5119]</td>
      <td>0.19</td>
      <td>442</td>
      <td>2</td>
      <td><strong>0.534</strong></td>
      <td><strong>0.536</strong></td>
      <td>0.829</td>
    </tr>
    <tr>
      <td rowspan="5">13</td>
      <td>AHC</td>
      <td rowspan="5">9</td>
      <td>[30, 7, 5, 11, 42, 16, 14, 4288, 22]</td>
      <td>-</td>
      <td>5778</td>
      <td>9</td>
      <td>1.151</td>
      <td>0.029</td>
      <td><strong>0.944</strong></td>
    </tr>
    <tr>
      <td>K-Medoids</td>
      <td>[567, 658, 647, 615, 379, 394, 522, 371, 282]</td>
      <td>-</td>
      <td>1482</td>
      <td>9</td>
      <td>0.667</td>
      <td><strong>0.525</strong></td>
      <td>0.313</td>
    </tr>
    <tr>
      <td>CSCLP</td>
      <td>[1399, 312, 467, 356, 290, 549, 503, 185, 374]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.336</td>
      <td>0.253</td>
    </tr>
    <tr>
      <td>K-MedoidsSC</td>
      <td>[1399, 312, 467, 356, 290, 549, 503, 185, 374]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.161</td>
      <td>-0.016</td>
    </tr>
    <tr>
      <td><code>CapFlex</code></td>
      <td>[1461, 296, 450, 344, 289, 547, 479, 176, 393]</td>
      <td>0.09</td>
      <td>162</td>
      <td>9</td>
      <td><strong>0.518</strong></td>
      <td>0.458</td>
      <td>0.617</td>
    </tr>
    <tr>
      <td rowspan="5">14</td>
      <td>AHC</td>
      <td rowspan="5">3</td>
      <td>[4242, 528, 1050]</td>
      <td>-</td>
      <td>1282</td>
      <td>3</td>
      <td>0.610</td>
      <td>0.005</td>
      <td>0.668</td>
    </tr>
    <tr>
      <td>K-Medoids</td>
      <td>[2201, 2527, 1092]</td>
      <td>-</td>
      <td>2148</td>
      <td>3</td>
      <td>0.685</td>
      <td>0.008</td>
      <td>0.191</td>
    </tr>
    <tr>
      <td>CSCLP</td>
      <td>[775, 1444, 3601]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.002</td>
      <td>0.613</td>
    </tr>
    <tr>
      <td>K-MedoidsSC</td>
      <td>[775, 1444, 3601]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td><strong>0.017</strong></td>
      <td>-0.039</td>
    </tr>
    <tr>
      <td><code>CapFlex</code></td>
      <td>[638, 1571, 3611]</td>
      <td>0.2</td>
      <td>274</td>
      <td>3</td>
      <td><strong>0.524</strong></td>
      <td>0.003</td>
      <td><strong>0.646</strong></td>
    </tr>
    <tr>
      <td rowspan="5">15</td>
      <td>AHC</td>
      <td rowspan="5">3</td>
      <td>[3087, 1088, 2]</td>
      <td>-</td>
      <td>3118</td>
      <td>3</td>
      <td>0.873</td>
      <td>0.113</td>
      <td><strong>0.804</strong></td>
    </tr>
    <tr>
      <td>K-Medoids</td>
      <td>[1383, 1489, 1305]</td>
      <td>-</td>
      <td>62</td>
      <td>3</td>
      <td>0.507</td>
      <td>0.164</td>
      <td>0.700</td>
    </tr>
    <tr>
      <td>CSCLP</td>
      <td>[1307, 1342, 1528]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td><strong>0.168</strong></td>
      <td>0.722</td>
    </tr>
    <tr>
      <td>K-MedoidsSC</td>
      <td>[1307, 1342, 1528]</td>
      <td>-</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0.033</td>
      <td>-0.036</td>
    </tr>
    <tr>
      <td><code>CapFlex</code></td>
      <td>[1446, 1203, 1528]</td>
      <td>0.21</td>
      <td>208</td>
      <td>2</td>
      <td><strong>0.358</strong></td>
      <td>0.164</td>
      <td>0.744</td>
    </tr>
  </tbody>
</table>
