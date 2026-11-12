// ============================================================
//  Diagram 4 — A piecewise differentiable curve alpha:[0,1] -> M built inside a minimal chain
//  of 5 open sets U_1,...,U_5, joining p=alpha(0) to q=alpha(1); the smooth curve c (grey)
//  with c(0)=p, c(1)=q is the original curve.
//  The 4 vertices (corners) of alpha lie in the intersections U_i ∩ U_{i+1};
//  the arc between two consecutive vertices lies inside a single U_i.
//  Minimal chain: U_i meets U_{i+1}, and U_i is disjoint from U_j when |i-j|>1.
//  Compile:  asy -f pdf diagram4_curve_cover.asy
// ============================================================
import three;

settings.outformat = "pdf";
settings.prc       = false;
settings.render    = 0;
size(18cm);
currentprojection = orthographic(0.6, -8, 12);

usepackage("amsmath");
usepackage("amssymb");
defaultpen(fontsize(11pt));

// ---------- SHARED STYLE KIT (identical to diagrams 1-3) ----------
pen cM  = rgb(0.86, 0.88, 0.91);          // manifold M
pen cA  = rgb(0.62, 0.76, 0.93);          // blue   : open sets
pen cB  = rgb(0.95, 0.72, 0.68);          // red    : (unused here)
pen cW  = rgb(0.76, 0.62, 0.88);          // purple : overlaps U_i ∩ U_{i+1}
pen dA  = rgb(0.10, 0.30, 0.65);          // dark blue  (outlines/labels)
pen dB  = rgb(0.70, 0.18, 0.15);          // dark red   (curve)
pen dW  = rgb(0.40, 0.18, 0.55);          // dark purple
pen ink = black;
real lwOutline = 1.2;
real lwArrow   = 1.0;
real headSize  = 6;
material mat(pen p) { return material(diffusepen=0.35*p, emissivepen=0.65*p, specularpen=black); }
// ---------------------------------------------------------------------------

pair dir(real t) { return (cos(t), sin(t)); }

// ---------- Helpers (same as diagrams 2-3) ----------
surface gridSurface(triple P(int,int), int nu, int nv) {
  patch[] ps;
  for (int i = 0; i < nu; ++i)
    for (int j = 0; j < nv; ++j)
      ps.push(patch(P(i,j) -- P(i+1,j) -- P(i+1,j+1) -- P(i,j+1) -- cycle));
  surface S;
  S.s = ps;
  return S;
}
surface blob(real r(real), triple F(pair), triple lift, pair ctr, int nu=8, int nv=120) {
  triple P(int i, int j) {
    real t = 2*pi*j/nv;
    return F(ctr + (i/nu)*r(t)*dir(t)) + lift;
  }
  return gridSurface(P, nu, nv);
}
path3 outline(real r(real), triple F(pair), triple lift, pair ctr, int n=240) {
  guide3 g = F(ctr + r(0)*dir(0)) + lift;
  for (int i = 1; i < n; ++i) {
    real t = 2*pi*i/n;
    g = g -- (F(ctr + r(t)*dir(t)) + lift);
  }
  return g -- cycle;
}
void fillBlob(surface S, pen c) {
  draw(S, c, light=nolight, meshpen=c + linewidth(0.8));
}

// ====================== THE MANIFOLD M (same as diagrams 2-3) ======================
real hM(pair p) { return 0.9*sin(2.4*p.x + 0.4) + 0.5*cos(2.8*p.y); }
real sM = 1.5;
triple FM(pair p) { return (sM*(9*p.x), sM*(-2.5 + 5*p.y), sM*hM(p)); }
triple zl(real k) { return (0, 0, 0.1 + 0.03*k); }     // lifts above M (blobs stack by index)

int nM = 32;
triple PM(int i, int j) { return FM((i/nM, j/nM)); }
draw(gridSurface(PM, nM, nM), mat(cM));
for (int k = 0; k <= 8; ++k) {
  guide3 gu = FM((k/8, 0)) + (0,0,0.02), gv = FM((0, k/8)) + (0,0,0.02);
  for (int m = 1; m <= 60; ++m) {
    gu = gu -- (FM((k/8, m/60)) + (0,0,0.02));
    gv = gv -- (FM((m/60, k/8)) + (0,0,0.02));
  }
  draw(gu, gray(0.6) + linewidth(0.3));
  draw(gv, gray(0.6) + linewidth(0.3));
}

// ====================== SKELETON of the curve (only used to place the open sets) ======================
pair cbase(real t) { return (0.2 + 0.6*t, 0.5 + 0.08*sin(2*pi*t + 0.5)); }

// ====================== THE FIVE OPEN SETS  U_1..U_5 ======================
// U_i is star-shaped about its centre C[i] = c((i-1)/4), with a wobbly radius.
int nSets = 5;
pair[] C;
real[] R  = {0.120, 0.125, 0.118, 0.124, 0.120};
real[] ph = {0.3, 1.7, 2.9, 4.1, 5.2};
for (int i = 0; i < nSets; ++i) C.push(cbase(i/4));
real rho(int i, real t) { return R[i]*(1 + 0.08*sin(2*t + ph[i])); }

// ====================== THE CURVE c(t), t in [0,1]: piecewise differentiable ======================
// Vertices: p = C[0], one vertex in each lens U_i ∩ U_{i+1} (its middle), q = C[4].
// Between two consecutive vertices c is a smooth arc (quadratic Bezier) bending alternately
// to the left and to the right, so there is a visible corner at every vertex.
pair[] PT;
PT.push(C[0]);
for (int k = 1; k < nSets; ++k) PT.push((C[k-1] + C[k])/2);
PT.push(C[nSets-1]);
real bulge = 0.07;                                   // how much each arc bends
pair ctrl(int k) {
  pair a = PT[k], b = PT[k+1];
  pair nrm = unit(rotate(90)*(b - a));
  return (a + b)/2 + ((k % 2 == 0) ? 1 : -1)*bulge*nrm;
}
pair alph(real t) {                                  // alpha(t); t_k = k/5 are the vertices
  real s = 5*t;
  int k = (int)s;
  if (k > 4) k = 4;
  real u = s - k;
  return (1-u)^2*PT[k] + 2*(1-u)*u*ctrl(k) + u^2*PT[k+1];
}

bool inside(int i, pair p) {
  pair d = p - C[i];
  if (length(d) < 1e-9) return true;
  return length(d) < rho(i, angle(d));
}
real exitR(int i, pair m, real th) {          // distance from m to the boundary of U_i along direction th
  real lo = 0, hi = 0.4;
  for (int k = 0; k < 30; ++k) {
    real mid = (lo + hi)/2;
    if (inside(i, m + mid*dir(th))) lo = mid; else hi = mid;
  }
  return lo;
}

// ---- fill the open sets ----
for (int i = 0; i < nSets; ++i) {
  real r(real t) { return rho(i, t); }
  fillBlob(blob(r, FM, zl(i), C[i]), cA);
}
// ---- fill the overlaps U_i ∩ U_{i+1} (exact: radial function = min of the two) ----
for (int i = 0; i < nSets - 1; ++i) {
  pair m = (C[i] + C[i+1])/2;
  real rl(real th) { return min(exitR(i, m, th), exitR(i + 1, m, th)); }
  fillBlob(blob(rl, FM, zl(7), m), cW);
}
// ---- outlines ----
for (int i = 0; i < nSets; ++i) {
  real r(real t) { return rho(i, t); }
  draw(outline(r, FM, zl(9), C[i]), dA + linewidth(lwOutline));
}
for (int i = 0; i < nSets - 1; ++i) {
  pair m = (C[i] + C[i+1])/2;
  real rl(real th) { return min(exitR(i, m, th), exitR(i + 1, m, th)); }
  draw(outline(rl, FM, zl(11), m), dW + linewidth(1.0));
}

// ====================== THE CURVES ======================
real lc = 0.7;                                   // lift of alpha above M
path3 trace(pair f(real), real lf, int n=120) {
  guide3 g = FM(f(0)) + (0, 0, lf);
  for (int i = 1; i <= n; ++i) g = g -- (FM(f(i/n)) + (0, 0, lf));
  return g;
}
draw(trace(cbase, lc - 0.12), gray(0.55) + linewidth(1.8));      // c : original smooth curve (grey)
draw(trace(alph,  lc),        dB + linewidth(2.0));              // alpha : piecewise differentiable
for (int i = 0; i <= nSets; ++i)                                 // tiny black dots at the vertices of alpha
  dot(FM(PT[i]) + (0, 0, lc), black + linewidth(2));

// ====================== LABELS ======================
label("$p$", FM(alph(0)) + (0, 0, lc), SW, ink);
label("$q$", FM(alph(1)) + (0, 0, lc), SE, ink);
label("$c$",      FM(cbase(0.5)) + (0, 0, lc - 1), N, gray(0.45));
label("$\alpha$", FM(alph(0.5)) + (0, 0, lc) + (-2.5, 0, -0.2), S, dB);
for (int i = 1; i < nSets; ++i) {
  real adjust = (i % 2 == 0) ? -0.2 : 0.5;

  label(
    "$\alpha(t_{" + string(i) + "})$",
    FM(PT[i]) + (0, 0, lc) + (0, 0, adjust),
    (i % 2 == 0) ? S : N,
    dB
  );
}
for (int i = 0; i < nSets; ++i) {
  real a = (i % 2 == 0) ? pi/2 : -pi/2;
  align al = (i % 2 == 0) ? N : S;
  real adjust = (i % 2 == 0) ? 0.3 : 0.4;
  label("$U_{" + string(i + 1) + "}$", FM(C[i] + rho(i, a)*dir(a)) + (0, 0, adjust), al, dA);
}
label("$M$", FM((0.97, 0.03)) + (0, 0, -0.5), SE, ink);
