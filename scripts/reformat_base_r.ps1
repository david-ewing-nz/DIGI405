$file = "d:\github\VI1\R\VI-example-REORGANISED.Rmd"
$content = Get-Content $file -Raw

# Convergence plot - plot() calls
$content = $content -replace 'plot\(1:length\(E_tau_e_history\), E_tau_e_history, \r?\n     ', @'
plot(
  1:length(E_tau_e_history),
  E_tau_e_history,
  '@ 

$content = $content -replace 'plot\(1:length\(E_tau_u_history\), E_tau_u_history, \r?\n     ', @'
plot(
  1:length(E_tau_u_history),
  E_tau_u_history,
  '@

# vb_posteriors chunk - all plot() calls
$content = $content -replace 'plot\(x_seq, dnorm\(x_seq, mu_beta\[1\], sqrt\(Sigma_betau\[1,1\]\)\),\r?\n     ', @'
plot(
  x_seq,
  dnorm(x_seq, mu_beta[1], sqrt(Sigma_betau[1,1])),
  '@

$content = $content -replace 'plot\(x_seq, dnorm\(x_seq, mu_beta\[2\], sqrt\(Sigma_betau\[2,2\]\)\),\r?\n     ', @'
plot(
  x_seq,
  dnorm(x_seq, mu_beta[2], sqrt(Sigma_betau[2,2])),
  '@

$content = $content -replace 'plot\(x_seq, dnorm\(x_seq, mu_u\[1\], sqrt\(Sigma_uu\[1,1\]\)\),\r?\n     ', @'
plot(
  x_seq,
  dnorm(x_seq, mu_u[1], sqrt(Sigma_uu[1,1])),
  '@

$content = $content -replace 'plot\(x_seq, dnorm\(x_seq, mu_u\[2\], sqrt\(Sigma_uu\[2,2\]\)\),\r?\n     ', @'
plot(
  x_seq,
  dnorm(x_seq, mu_u[2], sqrt(Sigma_uu[2,2])),
  '@

$content = $content -replace 'plot\(x_seq, dgamma\(x_seq, a_e_new, b_e_new\),\r?\n     ', @'
plot(
  x_seq,
  dgamma(x_seq, a_e_new, b_e_new),
  '@

$content = $content -replace 'plot\(x_seq, dgamma\(x_seq, a_u_new, b_u_new\),\r?\n     ', @'
plot(
  x_seq,
  dgamma(x_seq, a_u_new, b_u_new),
  '@

# png() call
$content = $content -replace 'png\(filename = png_path, width = 10, height = 10, units = "in", res = 300\)', @'
png(
  filename = png_path,
  width    = 10,
  height   = 10,
  units    = "in",
  res      = 300)
'@

Set-Content $file -Value $content -NoNewline
Write-Output "Base R graphics reformatted"
