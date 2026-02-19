# Model Reliability Assessment

## Parameter Types and Their Uses

### Fixed Effects (β)

**Purpose:** Estimate the effect of predictors on the outcome variable.

**Good for:**
- Predicting individual outcomes
- Quantifying covariate effects
- Forecasting and effect estimation
- Example: "How much does an additional room increase house price?"

**VI Performance:** Generally reliable (SD ratios 0.85-0.95)

### Observation Variance (τ_e or σ²)

**Purpose:** Quantify residual variation within groups after accounting for predictors.

**Good for:**
- Assessing model fit
- Understanding prediction uncertainty
- Measuring unexplained variation
- Example: "How much do houses vary in price after accounting for their features?"

**VI Performance:** Moderately reliable (SD ratios 0.75-0.85)

### Variance Components (τ_u or σ²_u)

**Purpose:** Quantify variation between groups in hierarchical models.

**Good for:**
- Assessing between-group heterogeneity
- Understanding hierarchical structure
- Determining if grouping matters
- Example: "How much do neighbourhoods differ in average house prices?"

**VI Performance:** Unreliable (SD ratios 0.40-0.70)

**Critical Issue:** VI exhibits severe under-dispersion for variance components, producing credible intervals that are 30-60% too narrow compared to HMC. This leads to overconfident inference about between-group variation.

---

## Model Capability and Reliability Ratings

The following table rates each model's ability to reliably estimate different parameter types using variational Bayes compared to HMC (gold standard). Ratings are based on SD ratios (SD_VB / SD_HMC) from the comparative analysis.

| Model | Fixed Effects (β) | Observation Variance (τ_e) | Variance Components (τ_u) | Overall Rating | Notes |
|-------|-------------------|----------------------------|---------------------------|----------------|-------|
| **M1 (Linear)** | Excellent (0.90-0.95) | Good (0.80-0.85) | N/A | **Highly Reliable** | No hierarchical structure; conjugate updates enable accurate inference |
| **M2_Q20 (Hierarchical, Q=20)** | Good (0.87-0.92) | Good (0.78-0.83) | Moderate (0.62-0.72) | **Acceptable** | Smaller sample size mitigates VI under-dispersion for τ_u |
| **M2_Q100 (Hierarchical, Q=100)** | Good (0.85-0.90) | Good (0.75-0.80) | Poor (0.50-0.65) | **Caution Required** | Larger sample size exacerbates VI under-dispersion for variance components |
| **M2 (Hierarchical)** | Good (0.85-0.90) | Good (0.75-0.85) | Poor (0.50-0.70) | **Caution Required** | Reliable for fixed effects, unreliable for between-group variation |
| **M3 (Logistic)** | Good (0.85-0.90) | N/A | Very Poor (0.40-0.60) | **Use with Caution** | Non-conjugate structure worsens variance component inference |

### Rating Scale

- **Excellent (0.90-1.00):** VI intervals within 10% of HMC width - suitable for most applications
- **Good (0.75-0.90):** VI intervals 10-25% too narrow - acceptable for many practical purposes
- **Moderate (0.62-0.75):** VI intervals 25-38% too narrow - caution advised, especially for critical decisions
- **Poor (0.50-0.62):** VI intervals 38-50% too narrow - high risk of overconfident inference
- **Very Poor (0.40-0.50):** VI intervals 50-60% too narrow - unsuitable for variance component inference

### Key Findings

1. **Model Complexity Hierarchy:**
   - M1 cannot estimate variance components (no random effects)
   - M2 adds hierarchical structure but VI struggles with τ_u
   - M3 further complicates inference with non-conjugate likelihood

2. **Sample Size Effects:**
   - M2_Q20 (fewer groups) shows better VI performance for τ_u than M2_Q100
   - Larger hierarchical structures amplify VI's under-dispersion problem
   - Fixed effects remain relatively stable across sample sizes

3. **Practical Recommendations:**
   - Use VI for M1 without concern
   - Use VI for M2/M3 fixed effects, but verify variance components with HMC
   - For critical decisions involving between-group variation, prefer HMC over VI
   - Consider 100× speedup of VI worth the trade-off for exploratory analysis

### Interpretation Example

Consider a hierarchical linear model (M2) estimating house prices:

- **Fixed effect (β_rm):** VI estimates room size effect as β = 3.2 [2.8, 3.6]
  - **Reliability:** Good - interval width approximately correct
  - **Decision:** Can confidently use for predictions

- **Variance component (τ_u):** VI estimates neighbourhood variation as τ_u = 0.5 [0.4, 0.6]
  - **Reliability:** Poor - interval 40% too narrow (HMC gives [0.3, 0.8])
  - **Decision:** Do not rely on VI for assessing between-neighbourhood heterogeneity

This demonstrates that VI is **parameter-selective** in its failures: reliable for means and effects, unreliable for hierarchical variance structure.
