Copilot Instructions for VI1 Project

## Required VS Code Extensions

Install these extensions to replicate the development environment:

**Core Development:**
- `github.copilot` - GitHub Copilot
- `github.copilot-chat` - GitHub Copilot Chat

**R Development:**
- `reditorsupport.r` - R language support
- `reditorsupport.r-syntax` - R syntax highlighting

**Python Development:**
- `ms-python.python` - Python language support
- `ms-python.vscode-pylance` - Python language server (Pylance)
- `ms-python.debugpy` - Python debugger
- `ms-python.isort` - Python import sorting
- `ms-python.vscode-python-envs` - Python environment manager

**Jupyter Notebooks:**
- `ms-toolsai.jupyter` - Jupyter notebook support
- `ms-toolsai.jupyter-keymap` - Jupyter keybindings
- `ms-toolsai.jupyter-renderers` - Jupyter renderers
- `ms-toolsai.vscode-jupyter-cell-tags` - Cell tags
- `ms-toolsai.vscode-jupyter-slideshow` - Slideshow support
- `ms-toolsai.datawrangler` - Data wrangler for data frames

**LaTeX/Document Processing:**
- `james-yu.latex-workshop` - LaTeX Workshop (XeLaTeX support)
- `tecosaur.latex-utilities` - LaTeX utilities
- `tomoki1207.pdf` - PDF viewer

**PowerShell:**
- `ms-vscode.powershell` - PowerShell language support

**Data/Utilities:**
- `mechatroner.rainbow-csv` - CSV syntax highlighting
- `pptxviewerpro.pptx-viewer-pro` - PowerPoint viewer
- `ms-vscode.vscode-speech` - Speech/accessibility support

**Installation command:**
```bash
code --install-extension github.copilot
code --install-extension github.copilot-chat
code --install-extension reditorsupport.r
code --install-extension reditorsupport.r-syntax
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-python.debugpy
code --install-extension ms-toolsai.jupyter
code --install-extension james-yu.latex-workshop
code --install-extension ms-vscode.powershell
code --install-extension mechatroner.rainbow-csv
code --install-extension tomoki1207.pdf
```

## Extension Installation Status (2026-02-16)

**Successfully Installed:**
- reditorsupport.r - R language support
- ms-python.python - Python language support
- ms-python.isort - Python import sorting
- ms-toolsai.jupyter - Jupyter notebook support
- ms-toolsai.datawrangler - Data wrangler for data frames
- james-yu.latex-workshop - LaTeX Workshop (XeLaTeX support)
- tecosaur.latex-utilities - LaTeX utilities
- tomoki1207.pdf - PDF viewer
- ms-vscode.powershell - PowerShell language support
- mechatroner.rainbow-csv - CSV syntax highlighting
- ms-vscode.vscode-speech - Speech/accessibility support

**Already Installed:**
- github.copilot-chat - GitHub Copilot Chat
- reditorsupport.r-syntax - R syntax highlighting
- ms-python.vscode-pylance - Python language server (Pylance)
- ms-python.debugpy - Python debugger
- ms-python.vscode-python-envs - Python environment manager
- ms-toolsai.jupyter-keymap - Jupyter keybindings
- ms-toolsai.jupyter-renderers - Jupyter renderers
- ms-toolsai.vscode-jupyter-cell-tags - Cell tags
- ms-toolsai.vscode-jupyter-slideshow - Slideshow support

**Failed to Install:**
- github.copilot - GitHub Copilot
- pptxviewerpro.pptx-viewer-pro - PowerPoint viewer

## Project Context

This is a variational Bayes (VB) research project focused on demonstrating under-dispersion in variational inference, particularly for variance components in hierarchical models.

Key Goals

Implement and compare fixed-form and mean-field variational Bayes

Demonstrate under-dispersion effects (VB underestimates uncertainty)

Compare VB with MCMC (Stan/NUTS) as gold standard

Focus on variance component estimation and shrinkage issues

Project Structure

**Five Core R Markdown Files:**

1. **M0-Hierarchical.Rmd** (or M0-Reference.Rmd)
   - Dr John's original functions ONLY (no _with_history suffix)
   - VB.mm() + normalmm.Gibbs()
   - Reference implementation for comparison
   - Hierarchical linear (flagship example)

2. **M1-Linear.Rmd**
   - Linear regression with diagnostics
   - VB.linear_with_history() + normalmm.linear.Gibbs_with_history()

3. **M2-Hierarchical.Rmd**
   - Hierarchical linear with diagnostics
   - VB.mm_with_history() + normalmm.Gibbs_with_history()
   - Compares against M0 reference

4. **M3-Logistic.Rmd**
   - Hierarchical logistic with diagnostics
   - VB.logisticmm_with_history() + logisticmm.Gibbs_with_history()

5. **M0-Hierarchical-Diagnostic.Rmd** (working file)
   - Current development version
   - Will be refined into M2-Hierarchical.Rmd
   - Contains both VB.mm and VB.mm_with_history

**Function Naming Convention:**
- Original functions: VB.mm(), normalmm.Gibbs()
- History-tracking versions: VB.mm_with_history(), normalmm.Gibbs_with_history()
- _with_history suffix indicates iteration-by-iteration tracking for convergence plots

**Model Complexity:**

Model 0/Reference: Hierarchical linear (calibration, reference implementation)

Model 1: Linear regression (conjugate, calibration model)

Synthetic data (n=500, known ground truth)

Boston Housing data (n=506, real-world example)

Dataset: Boston Housing (not mtcars) with predictors: rm, lstat, ptratio

Model 2: Hierarchical linear with diagnostics (compares to M0)

Main workhorse for demonstrating under-dispersion

Model 3: Hierarchical logistic (non-conjugate GLM)

Flagship example for variance component under-dispersion

Key References

Meeting 2 transcript (reference/tex/Meeting 2 summary.tex)

Action items assigned by John Holmes

Target audience: People new to variational Bayes

Scope and Authority of These Instructions

These instructions apply to:

R scripts (.R)

R Markdown files (.Rmd)

Stan files (.stan)

PowerShell scripts (.ps1)

JSON configuration files

All project documentation

Exemptions:

Do not rename variables, function names, file names, or folder names purely for spelling style.

If any rule below cannot be followed due to tool or environment limitations, you must:

State which rule could not be executed

State why it could not be executed

Provide the closest safe alternative

Clarification and Mistaken-Edit Handling

If there is ambiguity, conflict, questions, or fallacies in instructions, ask David for clarification before taking action.

If Copilot edits a file it was not supposed to, ask David whether to reverse the changes or revert the file to its last committed version before doing anything else.

When using search results (e.g., grep or similar), distinguish between matches in comments and matches in code, and confirm the correct context before applying edits.

Critical VB Issue: Hyper-parameter Under-Dispersion

VB commonly exhibits under-dispersion for hyper-parameters, especially variance components.

Random Effects Example

Model: y = Xb + Zu, where u ~ N(0, σ²_u K)

σ²_u is a hyper-parameter

VB approximations for σ²_u are typically too narrow

Zeta Parameter

ζ = -log(σ²_u)

Diagnostics typically compare VB and HMC on both ζ and σ² scales

VB densities are noticeably narrower

Implication for This Project

Model 1: Some under-dispersion for σ²

Model 3: Strong under-dispersion for σ²_u (primary teaching example)

Architecture and Code Organisation
Core Implementation Files (R/)

vb_linear.R: MFVB linear regression

vb_ffvb_linear.R: FFVB Gaussian approximation

exact_linear.R: Exact Normal-Inverse-Gamma posterior

vb_logistic.R: Laplace approximation for logistic regression

ffvb_diagnostics.R: FFVB stability diagnostics

vb_mog_mixture.R: Mixture of Gaussians VI

Notebook Pattern

Model1_altLinear4.Rmd

BostonEDA.Rmd

mog_vi_tweek-8A.Rmd

mog_vi_tweek-8C.Rmd

Stan Models (STAN/)

linear_regression.stan

logistic_regression.stan

model3_random_intercept.stan

Data Flow

Load or generate data

Execute methods

Save results via saveRDS()

Visualise using save-to-disk then read-back workflow

Comparison Hierarchy (Clarified)

Accuracy depends on stability and assumptions:

Exact (Model 1 only)

HMC (Stan/NUTS)

Laplace (Gaussian around MAP)

MFVB (mean-field)

FFVB (can improve on MFVB when stable, can fail if unstable)

Always state:

which method is the reference

whether FFVB instability is present

Developer Workflows
Stan Setup
source("scripts/00_setup_stan.R")
source("scripts/00_test_stan.R")

Typical Notebook Workflow

Load libraries

set.seed(82171165)

Load or generate data

Source VB functions

Compile Stan models

Run methods

Save results

CRITICAL: Content Preservation Rules

This is a pedagogical document.

NEVER Remove Without Explicit Request

Mathematical equations

Intermediate derivation steps

Explanatory narrative

Diagnostic plots or tables

Commented alternative approaches

Key insight callouts

Pattern recognition notes

Before Any Edit

Read surrounding context

Preserve simple to complex progression

Check narrative flow

Ask before removing content if unsure

Permitted Changes

Fix explicitly identified mathematical errors

Correct typos or formatting

Add requested content

Reorganise only when explicitly instructed

If the user says “parts keep being removed”, stop and ask what must be preserved.

Build Tasks and Workflow
IMPORTANT KNITTING RULES (CI-STYLE)

Definition of success
Success means: a PDF is produced by knitting in the current run, and the exact PDF filename is stated.

Rules

Knit after each batch of fixes targeting the current blocking error(s).

Do not report success unless a PDF is produced by knitting in the current run.

If knitting fails, report the error output verbatim using terminal output only.

If no PDF is produced, explicitly say: “PDF not produced”.

Stop after a user-specified number of attempts; otherwise stop after 20 attempts and summarise remaining issues.

Stop early if the same error repeats twice without change.

Ctrl+Shift+B Knit Task

Defined in .vscode/tasks.json

Runs scripts/knit_current_file.ps1

Shows diagnostic timestamps

Does not require keypress to continue

Communication Preferences
Planning Mode

Planning mode means discussion only.

No code edits

No file modifications

No execution

If a message contains both planning language and an explicit execution instruction, treat it as execution.

Exiting planning mode requires explicit instruction.

Language

Use British English for:

R Markdown narrative

Plot titles and labels

Documentation

Code comments

Do not rename identifiers for spelling alone.

Code Style
No Emoji or Icon Characters Anywhere

No emoji or icon characters in code, comments, or documentation

Use plain text markers only

Comments

Do not add explanatory comments unless requested

Preserve existing comments and commented alternatives

Formatting

Hierarchical alignment only

Never delete \newpage in R Markdown files

Pedagogical Code Style

Readability over cleverness

Step-by-step logic

Preserve commented alternatives

R Programming Conventions

Tidyverse style

Explicit over implicit

Always set.seed(82171165)

Use native |> pipe

R File Modification Workflow

Preferred when tools allow:

Trigger RStudio Save All

Re-read files from disk

Apply edits

Verify no accidental removal

Trigger RStudio reload

If not possible, instruct the user to save and reload before proceeding.

MARGIN_STRING Replacement (CRITICAL)

The MARGIN_STRING implementation is working and fragile.

Do not modify

Do not remove

Do not simplify

Do not refactor

Follow the existing implementation exactly.

Plot Workflow

Create plot objects

Save plots to disk

Read plots from disk

Display plots

Never display before saving.

Standard Colour Palette

VB / MFVB: black

HMC / Stan: #E7298A

Exact: blue

Laplace: orange

FFVB: purple

Linetypes:

VB: solid

HMC: dashed

Exact: dotted

Prettyprint Style

Align assignments

Multi-line complex calls

Format first, fix second (only if requested)

EDA Style

Technical, minimal narrative

Use print() and glue()

No interpretive prose

VB Algorithm Patterns
Laplace Clarification

Laplace is a Gaussian approximation around the MAP. Treat it as distinct from MFVB unless the implementation explicitly coincides.

Technical Stack

R

CmdStanR

Stan / NUTS

tidyverse, MASS, bayesplot

XeLaTeX (xelatex only)

Project-Specific Conventions

Correlated synthetic predictors via MASS::mvrnorm()

Consistent Stan interfaces

Standard comparison tables

SD ratios for under-dispersion detection

 