# VI1 Report Appendix Planning Document
**Created:** 2026-02-02  
**Status:** Planning Phase (User away 2+ hours)  
**Next Review:** Upon user return

---

## 1. CURRENT PROJECT CONTEXT

### 1.1 Report Progression Files (Report/ folder)

| File | Type | Status | Purpose |
|------|------|--------|---------|
| `DRAFT-11.tex` | LaTeX | Complete | Early report version with VI basics |
| `DRAFT-12.tex` | LaTeX | Current | Main report draft (207 lines) - covers intro, VI as optimisation, factorisation, ELBO, implications |
| `report-outline.tex` | LaTeX Template | Reference | Standard academic structure template |
| `Presentation_Report.pdf` | PDF | Generated | Presentation script with slides |
| `Presentation_Report-new.Rmd` | R Markdown | Current | Latest presentation narrative (246 lines) |
| `M0-Hierarchical.pdf` / `.html` | Generated | Reference | Model 0 diagnostic outputs |
| `M1-Simple-Linear*.pdf` / `.html` | Generated | Reference | Model 1 outputs |
| `M2-Hierarchical-Linear*.pdf` / `.html` | Generated | Reference | Model 2 outputs |
| `M3-Hierarchical-Logistic*.pdf` / `.html` | Generated | Reference | Model 3 outputs |
| `Model_Reliability_Assessment.md` | Markdown | Reference | Parameter reliability ratings by model |
| `VI-UNIFIED-VBGibbsOnly.pdf` | PDF | Reference | Unified analysis document |

**Key Finding:** DRAFT-12 establishes foundation but lacks appendix-level detail on mathematical derivations and formal proofs.

### 1.2 Presentation Files with Mathematical Content (presentation/ folder)

| File | Type | Content | Mathematical Focus |
|------|------|---------|-------------------|
| `Presentation_Report-new.Rmd` | R Markdown | Full presentation script | Slides 1-8+ (Bayes, VI, Q-space, coordinate ascent, models, under-dispersion, timing) |
| `why_factorisation.pdf` | PDF | Factorisation proof/derivation | **Key Proof Resource** - Shows factorisation strategy and update equations |
| `why_factorisation.tex` | LaTeX | Source for above | Mean-field factorisation derivation |
| `why_factorisation_trim.png` | PNG | Figure | Factorisation visual summary |
| `Cascade_Proof_Slides.pptx` | PowerPoint | Proof slides | Cascading/coordinate ascent proof structure |
| `three_models_comparison.tex` | LaTeX | Model structures | Formal model definitions |
| `three_models_clean.pdf` | PDF | Visual comparison | Three models side-by-side structure |
| `Variational_Inference_15min.tex` | LaTeX | 15-minute presentation | Condensed VI theory |

**Key Finding:** `why_factorisation.pdf/tex` and `Cascade_Proof_Slides.pptx` contain the **proof/derivation material not yet in main report**.

---

## 2. FIGURE INVENTORY & PNG EXPORT TARGETS

### 2.1 Current HMC & Gibbs TikZ Diagrams (reference/tex/Taylor Winter.tex)

**Status:** Currently in LaTeX/TikZ format, pages 1-2 of PDF

**HMC Diagram:**
- Lines 25-71 in `Taylor Winter.tex`
- Title: "Gradient-Based Dynamics"
- Shows: Parameter space, posterior contour, gradient vector, momentum, Hamiltonian trajectory, proposal point
- Font sizes: Recently reduced to `\tiny` for page fit

**Gibbs Diagram:**
- Lines 199-240 in `Taylor Winter.tex`
- Title: "Full Conditional Distributions"
- Shows: Parameter space, posterior contour, three sequential steps (τᵤ, (β,u), τₑ)
- Font sizes: Recently reduced to `\tiny` for page fit

**ACTION ITEMS:**
- [ ] Export HMC diagram as PNG → `figs/HMC_diagram.png`
- [ ] Export Gibbs diagram as PNG → `figs/Gibbs_diagram.png`
- [ ] Method: Use `convert` command or TikZ standalone compilation

### 2.2 Existing PNG Figures Available in figs/

**High-Relevance for Appendix:**

| Figure | Purpose | Size | Recommendation |
|--------|---------|------|-----------------|
| `comparison_sd_ratios_table.png` | SD ratios across models (VB vs Gibbs) | Large table | **Include** - Core under-dispersion metric |
| `comparison_sd_ratios_heatmap.png` | Heatmap of SD ratios | Visual summary | **Include or reference** |
| `M0_diagnostic_variance_ratio.png` | M0 variance component diagnostics | Diagnostic | Consider |
| `M1_diagnostic_variance_ratio.png` | M1 variance diagnostics | Diagnostic | Consider |
| `M2_diagnostic_variance_ratio.png` | M2 variance diagnostics | Diagnostic | **Include** - Main model |
| `M3_diagnostic_variance_ratio.png` | M3 variance diagnostics | Diagnostic | **Include** - Hierarchical logistic |
| `M2_tau_u_overlay_comparison.png` | M2 τᵤ VB vs Gibbs overlay | Core under-dispersion | **Include** - Primary example |
| `M3_tau_u_overlay_comparison.png` | M3 τᵤ VB vs Gibbs overlay | Core under-dispersion | **Include** - Logistic case |
| `timing_vb_vs_gibbs_bars.png` | Computational time comparison | Performance | Consider |
| `timing_speedup_ratios.png` | Speedup ratios Gibbs/VB | Performance | Consider |
| `model_rating_heatmap.png` | Model reliability by parameter type | Reliability | Consider |
| `why_factorisation_trim.png` | Factorisation and update equations | Theory | **Include** - Pedagogical |

### 2.3 Explicit Figure Placement Plan (Appendix Draft)

**Appendix A (Math Foundations):**
- figs/why_factorisation_trim.png — Mean-field factorisation diagram (A.1)

**Appendix B (Computational Details):**
- figs/comparison_sd_ratios_table.png — SD ratio table (B.3)
- figs/comparison_sd_ratios_heatmap.png — SD ratio heatmap (B.3)

**Appendix C (Visual Summaries):**
- figs/HMC_diagram.png — HMC iteration diagram (C.1) [to be exported from Taylor Winter.tex]
- figs/Gibbs_diagram.png — Gibbs iteration diagram (C.1) [to be exported from Taylor Winter.tex]
- figs/M2_tau_u_overlay_comparison.png — M2 VB vs Gibbs overlay (C.2)
- figs/M3_tau_u_overlay_comparison.png — M3 VB vs Gibbs overlay (C.2)
- figs/model_rating_heatmap.png — Reliability summary (C.2)
- figs/timing_vb_vs_gibbs_bars.png — Timing comparison (C.3)
- figs/timing_speedup_ratios.png — Speedup ratios (C.3)

---

## 3. PROOF/DERIVATION CONTENT MAPPING

### 3.1 Missing Proof Material (Not Yet in DRAFT-12 Report)

**Source: `why_factorisation.pdf` and `Cascade_Proof_Slides.pptx`**

#### A. Mean-Field Factorisation Derivation
- **What:** Formal derivation showing how mean-field assumption breaks posterior dependence
- **Why needed:** Appendix should show mathematical justification for why under-dispersion occurs
- **Location in source:** `why_factorisation.pdf` (slides 2-4)
- **Complexity:** Medium - suitable for appendix

#### B. Coordinate Ascent Update Rules
- **What:** Closed-form update equations for VB factors under conjugacy
- **Why needed:** Explains how ELBO is maximised step-by-step
- **Location in source:** `why_factorisation_trim.png` caption + `Cascade_Proof_Slides.pptx`
- **Complexity:** Medium-High - mathematical but standard

#### C. Full Conditional Distributions
- **What:** Formal expressions for $q(\beta, u | \tau_e, \tau_u, y)$, $q(\tau_u | \beta, u, y)$, $q(\tau_e | \beta, u, y)$
- **Why needed:** Shows how each variational factor is updated
- **Location in source:** DRAFT-12 section 2 + presentation files
- **Complexity:** Medium - requires amsmath formatting

#### D. ELBO Decomposition & KL Divergence
- **What:** Shows ELBO = log p(y) - KL(q||p) and implications for optimisation
- **Why needed:** Mathematical foundation for why factorisation causes under-dispersion
- **Location in source:** DRAFT-12 section 2, Presentation_Report-new.Rmd
- **Complexity:** Medium - core theory

#### E. Under-Dispersion Mechanism (Formal Proof)
- **What:** Proof that mean-field factorisation implies systematic variance underestimation for hyper-parameters
- **Why needed:** Theoretical underpinning for empirical findings
- **Location in source:** `Cascade_Proof_Slides.pptx` + DRAFT-12 conclusion
- **Complexity:** High - research-level derivation

**Recommendation:** Include A, B, C, D (standard VI derivations). Include E as theorem statement with high-level explanation, full proof in subsection.

### 3.2 Which Proofs to Prioritise for Appendix

#### Must Include:
1. **Mean-field factorisation structure** (with diagram)
2. **Full conditional distributions** for Models 1 & 2
3. **ELBO as KL surrogate**
4. **Coordinate ascent algorithm** (pseudo-code + equations)

#### Should Include:
5. **Under-dispersion theorem** (statement + intuition)
6. **Variance component posterior collapse** mechanism
7. **Inverse-gamma conjugacy** for precision parameters

#### Could Include:
8. Full derivation of update rules for M3 logistic case
9. Convergence rate analysis
10. Variational bounds tightness analysis

---

## 4. REFERENCE/TEX FOLDER CONTENT

### 4.1 Existing LaTeX Theory Documents

| File | Lines | Topic | Status |
|------|-------|-------|--------|
| `Taylor Winter.tex` | 373 | HMC vs Gibbs pedagogical comparison | **CURRENT** - working file |
| `VI_Narrative_Structure.tex` | TBD | VI teaching narrative | Reference |
| `VI_Theory_Foundation.tex` | TBD | Mathematical foundations | Reference |
| `email_to_dr_john_summary.tex` | TBD | Communication summary | Context |
| `Meeting 2 summary.tex` | TBD | Meeting notes | Context |
| `Variational_Inference_15min.tex` | TBD | Condensed presentation | Reference |

**Key Finding:** Multiple theory documents exist with complementary content. `VI_Theory_Foundation.tex` likely contains formal proofs worth extracting.

### 4.2 Bibliography Inventory (report/references.bib)

**Bibliography file:** report/references.bib (420 lines)

**Foundational VI (Appendix A.1–A.3 citations):**
- `blei2017variational` — Variational Inference review
- `jordan1999introduction` — Early VI framework
- `wainwright2008graphical` — Exponential families + VI
- `ormerod2010explaining` — Mean-field explanations
- `kucukelbir2017automatic` — ADVI (contextual mention)

**Under-dispersion / VB limitations (Appendix A.4 citations):**
- `turner2011two` — VB limitations
- `wang2005inadequacy` — Interval inadequacy in VB
- `giordano2018covariances` — Covariances + VB
- `you2014variational` — VB approximation behaviour

**Hierarchical variance components (Appendix A.4 + B.1 citations):**
- `gelman2006prior` — Variance priors in hierarchical models
- `gelman2006data` — Multilevel modelling reference
- `browne2006comparison` — Bayesian vs likelihood multilevel

**MCMC / HMC references (Appendix B.1 or C.1 citations):**
- `neal2011mcmc` — HMC foundations
- `hoffman2014no` — NUTS
- `betancourt2017conceptual` — HMC conceptual intro

**Stan / CmdStanR (Appendix B.2 citations):**
- `carpenter2017stan` — Stan language
- `cmdstanr2023` — CmdStanR interface
- `stan2023reference` — Stan manual

---

## 5. REPORT STRUCTURE & APPENDIX ORGANISATION

### 5.1 Recommended Appendix Structure

Based on DRAFT-12 foundation + presentation content + missing proofs:

```
APPENDIX A: Mathematical Foundations of Variational Inference
├── A.1 Mean-Field Factorisation
│   ├── Motivation and notation
│   ├── Factorisation structure (diagram: why_factorisation_trim.png)
│   └── Implications for posterior coupling
│
├── A.2 The Evidence Lower Bound (ELBO)
│   ├── Definition and derivation
│   ├── Equivalence to KL divergence minimisation
│   └── Computational tractability
│
├── A.3 Coordinate Ascent Variational Inference
│   ├── Algorithm pseudo-code
│   ├── Full conditional distribution updates
│   │   ├── Model 1: Linear regression
│   │   ├── Model 2: Hierarchical linear
│   │   └── Model 3: Hierarchical logistic
│   └── Convergence criteria
│
└── A.4 The Under-Dispersion Mechanism
    ├── Formal statement (theorem)
    ├── Intuitive explanation
    ├── Proof sketch
    └── Empirical validation (figures)

APPENDIX B: Supporting Computational Details
├── B.1 Gibbs Sampling as Comparison Baseline
│   ├── Full conditionals
│   ├── Inverse-gamma sampling
│   └── Convergence diagnostics
│
├── B.2 Experimental Setup
│   ├── Data generation (synthetic + Boston Housing)
│   ├── Prior specification
│   └── Computational environment
│
├── B.3 Diagnostic Metrics
│   ├── SD ratios (VB / Gibbs)
│   ├── Effective sample size
│   └── Trace plots and autocorrelation
│
└── B.4 Additional Results Tables
    ├── Full SD ratio table (comparison_sd_ratios_table.png)
    ├── Model reliability matrix
    └── Timing and scaling analysis

APPENDIX C: Visual Summaries
├── C.1 Algorithm Diagrams
│   ├── HMC iteration (PNG to export)
│   ├── Gibbs iteration (PNG to export)
│   └── Coordinate ascent geometry
│
├── C.2 Under-Dispersion Illustrations
│   ├── M2 τᵤ posterior comparison
│   ├── M3 τᵤ posterior comparison
│   └── Variance ratio heatmap
│
└── C.3 Computational Performance
    ├── Speed comparison plots
    └── Scaling analysis
```

### 5.2 Density/Tone Guidance

**For Appendix (Not Main Report):**
- **Mathematical density:** HIGH (full derivations expected)
- **Audience assumption:** Reader has seen ELBO section in main report
- **Writing style:** Formal, theorem-proof structure
- **Notation:** Consistent with main report + standardised
- **Figures:** HIGH resolution, captions with cross-references
- **References:** Cite Gelman, Blei, Hoffman et al. as appropriate

**Contrasting Main Report:**
- Mathematical density: MEDIUM (intuition first, formulas second)
- Audience: People new to variational Bayes
- Tone: Pedagogical, narrative-driven
- Figures: Lead explanations, not supporting them

---

## 6. FILE CREATION & EXPORT STRATEGY

### 6.1 Two-Image PNG Export

**Current State:** Both diagrams in `Taylor Winter.tex` as TikZ code

**Options:**
1. **Extract from compiled PDF** - Use `pdfcrop` → `convert` to PNG
2. **Standalone TikZ compilation** - Create minimal standalone `.tex`, compile to PDF, convert
3. **Manual LaTeX to PNG** - Isolate diagram code, compile + convert

**Recommended:** Option 2 (cleanest output)

```bash
# Pseudocode
xelatex --interaction=nonstopmode hmc_diagram_standalone.tex
convert -density 300 hmc_diagram_standalone.pdf hmc_diagram.png

xelatex --interaction=nonstopmode gibbs_diagram_standalone.tex
convert -density 300 gibbs_diagram_standalone.pdf gibbs_diagram.png
```

**Output locations:**
- `figs/HMC_diagram.png`
- `figs/Gibbs_diagram.png`

### 6.2 Proof Content Extraction

**Source files to merge:**
1. `why_factorisation.pdf` → Extract text/math → A.1, A.3
2. `Cascade_Proof_Slides.pptx` → Extract key slides → A.2, A.4
3. `DRAFT-12.tex` → Sections 2-3 → Foundation for A.2, A.3
4. `Presentation_Report-new.Rmd` → Theoretical commentary → B.1

**Integration workflow:**
1. Read and annotate source proofs
2. Translate to consistent LaTeX notation
3. Add cross-references to main report sections
4. Embed or link figures (use `\ref{fig:...}`)

---

## 7. CURRENT PROJECT STATUS SUMMARY

### 7.1 What's Complete

✅ Main report draft (DRAFT-12) with VI fundamentals  
✅ Presentation narrative with pedagogical examples  
✅ Three core models fully implemented and tested  
✅ Comprehensive figure library (90+ PNG files)  
✅ HMC vs Gibbs pedagogical comparison (Taylor Winter.tex, 8 pages)  
✅ Empirical under-dispersion validation (SD ratio tables + plots)  

### 7.2 What's Missing from Report

❌ Formal proofs of mean-field factorisation properties  
❌ Coordinate ascent derivation with closed-form updates  
❌ Formal statement of under-dispersion theorem  
❌ HMC and Gibbs diagrams as standalone PNG figures  
❌ Integration of presentation proofs into main report appendix  
❌ Computational details appendix (Section B above)  
❌ Visual summary appendix with all key plots  

### 7.3 What User Needs Upon Return

1. **Appendix structure plan** ← *This document provides it*
2. **Proof extraction roadmap** ← *Detailed in Section 3*
3. **Figure export strategy** ← *Detailed in Section 6*
4. **PNG files ready** ← *Can generate on user request*
5. **Integration workflow** ← *Ready to execute*

---

## 8. AUTONOMOUS ACTIONS AVAILABLE (During User Absence)

### 8.1 Low-Risk Preparation Tasks

**Ready to execute without user approval:**
- [ ] Extract and catalogue all proofs from `why_factorisation.pdf`
- [ ] Parse LaTeX from `Cascade_Proof_Slides.pptx` 
- [ ] Create standalone `.tex` files for diagram export (HMC & Gibbs)
- [ ] Compile diagram PDFs and convert to PNG
- [ ] Create appendix skeleton `.tex` file with structure outline
- [ ] Inventory all figures by relevance tier
- [ ] Standardise notation across theory documents
- [ ] Create proof translation reference (source → appendix mapping)

### 8.2 Medium-Risk Preparation Tasks

**Ready if user pre-approves:**
- [ ] Draft Appendix A.1 (Mean-Field Factorisation) with proofs
- [ ] Draft Appendix A.2 (ELBO) with derivation
- [ ] Draft Appendix B.1 (Gibbs Sampling details)
- [ ] Draft Appendix C with figure captions and cross-references

### 8.3 High-Risk Tasks

**Requires user review before execution:**
- [ ] Integrate appendix into main report `.tex`
- [ ] Decide on proof inclusion depth (theorem only vs full derivation)
- [ ] Choose between equation styles (aligned, displayed, inline)
- [ ] Select final figure set and arrangement

---

## 9. DECISION POINTS FOR USER RETURN

### 9.1 Mathematical Depth Decision

**Choose one:**
- **Option A (Theorem-Statement Level):** Brief statement of under-dispersion result, intuitive explanation, empirical validation. ~3-5 pages.
- **Option B (Proof-Sketch Level):** Theorem + proof sketch with key steps, moderate detail. ~5-8 pages.
- **Option C (Full Derivation):** Complete formal proofs with all algebraic steps. ~10-15 pages.

**Recommendation for appendix:** Option B (balances rigour with readability)

### 9.2 Figure Selection Decision

**Which figures to include as PNG in appendix?**
- Essential: HMC diagram, Gibbs diagram, M2 τᵤ comparison, comparison_sd_ratios_table
- Recommended: M3 τᵤ comparison, why_factorisation_trim, model_rating_heatmap
- Optional: timing plots, individual model diagnostics

### 9.3 Report Compilation Workflow

**Order of operations:**
1. Review this planning document
2. Approve appendix structure (Section 5.1)
3. Approve mathematical depth (Section 9.1)
4. Approve figure selection (Section 9.2)
5. Specify output format (single PDF vs separate appendix?)
6. Initiate autonomous appendix generation
7. Review draft appendix
8. Compile full report with appendix
9. Fix LaTeX errors iteratively

---

## 10. NOTES FOR FUTURE WORK

### 10.1 Potential Extensions

- Variational inference for non-conjugate models (Laplace approximation section)
- Black-box variational inference (BBVI) comparison
- Automatic differentiation variational inference (ADVI) reference
- Normalizing flows as more expressive variational families
- Recent advances in hierarchical variational models

### 10.2 Related But Out-of-Scope for This Appendix

- Full implementation of VB algorithms in R (belongs in main paper methods)
- Stan/CmdStanR code examples (belongs in methods or supplementary code)
- Extensive Gibbs sampling theory (brief in appendix, full elsewhere)
- Non-Bayesian alternatives (frequentist mixed models, etc.)

### 10.3 Quality Assurance Checklist

- [ ] All figures have captions and cross-references
- [ ] All equations are numbered and referenceable
- [ ] Notation is consistent with main report
- [ ] Citations to Gelman, Blei, et al. are accurate
- [ ] Proof steps are justified and clear
- [ ] Tables have descriptive headers and legends
- [ ] Bibliography entries for cited papers complete
- [ ] Document compiles without errors in xelatex
- [ ] Page breaks occur at logical section boundaries
- [ ] Font sizes legible in printed and digital formats

---

## 11. CONTACT/DECISION PROMPT FOR USER RETURN

**Upon return, user should:**

1. **Review Sections 5.1 & 9** (Structure + Decisions)
2. **Make decisions in 9.1-9.3** (Depth, figures, workflow)
3. **Approve autonomous tasks** from Section 8 or request specific actions
4. **Provide feedback** on tone/density/figures
5. **Initiate build** once decisions made

**Expected timeline (with autonomous prep):**
- Autonomous prep: 45-90 minutes (diagrams, skeleton, proof extraction)
- User review: 15-30 minutes
- Appendix generation: 60-120 minutes (depends on depth)
- Integration & compilation: 30-45 minutes
- **Total: 2.5-4 hours** (much of it autonomous)

---

**End of Planning Document**

Last Updated: 2026-02-02  
Status: Ready for user review upon return

