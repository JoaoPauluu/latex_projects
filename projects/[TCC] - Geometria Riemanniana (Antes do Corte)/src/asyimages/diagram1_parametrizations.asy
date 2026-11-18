// ============================================================
//  Diagram 1 — Two parametrizations x_alpha, x_beta of a manifold M
//  Compile:  asy -f pdf diagram1_parametrizations.asy
//  (use  -f png -render=8  if you prefer a raster output)
// ============================================================
import three;

settings.outformat = "pdf";
settings.prc       = false;   // static output, no interactive PRC
settings.render    = 0;       // vector output, no OpenGL needed
size(18cm);
currentprojection = orthographic(0.6, -8, 6);

usepackage("amsmath");
usepackage("amssymb");
defaultpen(fontsize(11pt));

// ---------- SHARED STYLE KIT (copy this block to every diagram) ----------
pen cM  = rgb(0.86, 0.88, 0.91);          // manifold M
pen cA  = rgb(0.62, 0.76, 0.93);          // alpha-chart (blue)
pen cB  = rgb(0.95, 0.72, 0.68);          // beta-chart  (red)
pen cW  = rgb(0.76, 0.62, 0.88);          // overlap W   (purple)
pen dA  = rgb(0.10, 0.30, 0.65);          // dark blue  (outlines/labels)
pen dB  = rgb(0.70, 0.18, 0.15);          // dark red
pen dW  = rgb(0.40, 0.18, 0.55);          // dark purple
pen ink = black;                          // arrows
real lwOutline = 1.2;                     // outline thickness
real lwArrow   = 1.0;                     // arrow thickness
real headSize  = 6;                       // arrow-head size
material mat(pen p) { return material(diffusepen=0.35*p, emissivepen=0.65*p, specularpen=black); }
// ---------------------------------------------------------------------------

// ---------- Mathematical (abstract) data ----------
// Everything is defined in a common "chart plane" (u,v) around the point c0.
// Both blobs are star-shaped w.r.t. c0, hence W = A ∩ B has radial function min(rA,rB).
pair c0 = (0.5, 0.5);
pair dir(real t) { return (cos(t), sin(t)); }
real rA(real t) { return 0.25 - 0.12*cos(t - 0.3) + 0.02*sin(3*t); }   // extends to the left
real rB(real t) { return 0.25 + 0.12*cos(t + 0.3) + 0.02*cos(3*t); }   // extends to the right
real rW(real t) { return min(rA(t), rB(t)); }

// ---------- The manifold M (a wavy sheet) ----------
real hM(pair p) { return 0.9*sin(2.4*p.x + 0.4) + 0.5*cos(2.8*p.y); }
triple FM(pair p) { return (6 + 9*p.x, -2.5 + 5*p.y, hM(p)); }

// ---------- The open sets U_alpha, U_beta in R^n (drawn as flat 2D blobs) ----------
real yU = 0;                                         // vertical plane y = yU
pair warp(pair p, real ang, real s, real w) {        // chart (u,v) -> plane coords
  pair q = p - c0;
  q = (q.x, q.y + w*q.x*q.x);
  return s*(rotate(ang)*q);
}
triple FUa(pair p) { pair z = warp(p, 150, 6.2, 1.2); return (-4.5 + z.x, yU, 3.7 + z.y); }
triple FUb(pair p) { pair z = warp(p,  15, 6.2, -1.0); return (-4.5 + z.x, yU, -3.4 + z.y); }

// ---------- Helpers ----------
// surface from a (nu+1)x(nv+1) grid of points, one straight-edged quad per cell
surface gridSurface(triple P(int,int), int nu, int nv) {
  patch[] ps;
  for (int i = 0; i < nu; ++i)
    for (int j = 0; j < nv; ++j)
      ps.push(patch(P(i,j) -- P(i+1,j) -- P(i+1,j+1) -- P(i,j+1) -- cycle));
  surface S;
  S.s = ps;
  return S;
}
surface blob(real r(real), triple F(pair), triple lift, int nu=8, int nv=120) {
  triple P(int i, int j) {
    real t = 2*pi*j/nv;
    return F(c0 + (i/nu)*r(t)*dir(t)) + lift;
  }
  return gridSurface(P, nu, nv);
}
path3 outline(real r(real), triple F(pair), triple lift, int n=240) {
  guide3 g = F(c0 + r(0)*dir(0)) + lift;
  for (int i = 1; i < n; ++i) {
    real t = 2*pi*i/n;
    g = g -- (F(c0 + r(t)*dir(t)) + lift);
  }
  return g -- cycle;
}
triple extreme(real r(real), triple F(pair), real sgn) {  // highest (+1) / lowest (-1) boundary point
  triple best = F(c0 + r(0)*dir(0));
  for (int i = 1; i <= 360; ++i) {
    real t = 2*pi*i/360;
    triple q = F(c0 + r(t)*dir(t));
    if (sgn*q.z > sgn*best.z) best = q;
  }
  return best;
}

// flat, unlit fill; same-colour patch edges hide the seams between patches
void fillBlob(surface S, pen c) {
  draw(S, c, light=nolight, meshpen=c + linewidth(0.8));
}

// ---------- Draw M and the images of the two charts ----------
int nM = 32;
triple PM(int i, int j) { return FM((i/nM, j/nM)); }
surface sM = gridSurface(PM, nM, nM);
draw(sM, mat(cM));
// coordinate-grid lines on M
for (int k = 0; k <= 8; ++k) {
  guide3 gu = FM((k/8, 0)) + (0,0,0.02), gv = FM((0, k/8)) + (0,0,0.02);
  for (int m = 1; m <= 60; ++m) {
    gu = gu -- (FM((k/8, m/60)) + (0,0,0.02));
    gv = gv -- (FM((m/60, k/8)) + (0,0,0.02));
  }
  draw(gu, gray(0.6) + linewidth(0.3));
  draw(gv, gray(0.6) + linewidth(0.3));
}

real e = 0.04;   // small lifts to avoid z-fighting
triple zl(real k) { return (0, 0, k*e); }
fillBlob(blob(rA, FM, zl(1)), cA);
fillBlob(blob(rB, FM, zl(2)), cB);
fillBlob(blob(rW, FM, zl(3)), cW);
draw(outline(rA, FM, zl(4)), dA + linewidth(lwOutline));
draw(outline(rB, FM, zl(4)), dB + linewidth(lwOutline));
draw(outline(rW, FM, zl(5)), dW + linewidth(lwOutline));

// ---------- Draw U_alpha and U_beta ----------
triple yl(real k) { return (0, -k*e, 0); }   // lift toward the camera (camera sits at -y)
fillBlob(blob(rA, FUa, yl(0)), cA);
fillBlob(blob(rW, FUa, yl(2)), cW);
draw(outline(rA, FUa, yl(3)), dA + linewidth(lwOutline));
draw(outline(rW, FUa, yl(4)), dW + linewidth(lwOutline));

fillBlob(blob(rB, FUb, yl(0)), cB);
fillBlob(blob(rW, FUb, yl(2)), cW);
draw(outline(rB, FUb, yl(3)), dB + linewidth(lwOutline));
draw(outline(rW, FUb, yl(4)), dW + linewidth(lwOutline));

// ---------- Parametrization arrows  x_alpha, x_beta ----------
pair qa = c0 + 0.85*rA(pi)*dir(pi);     // a point of U_alpha away from W ...
pair qb = c0 + 0.85*rB(0)*dir(0);       // ... and of U_beta away from W
triple ta = FUa(qa) + yl(5),  ha = FM(qa) + zl(8);
triple tb = FUb(qb) + yl(5),  hb = FM(qb) + zl(8);
path3 arrA = ta .. ((ta + ha)/2 + (0, 0, 1.3)) .. ha;
path3 arrB = tb .. ((tb + hb)/2 + (0, -2.5, -0.2)) .. hb;
draw(arrA, ink + linewidth(lwArrow), Arrow3(headSize));
draw(arrB, ink + linewidth(lwArrow), Arrow3(headSize));
label("$\mathbf{x}_\alpha$", relpoint(arrA, 0.5), N, dA);
label("$\mathbf{x}_\beta$",  relpoint(arrB, 0.5), S, dB);

// ---------- Transition map  x_beta^{-1} ∘ x_alpha  on the preimages of W ----------
triple pa = extreme(rW, FUa, -1) + yl(-20);     // lowest point of x_alpha^{-1}(W)
triple pb = extreme(rW, FUb, +1) + yl(+26);     // highest point of x_beta^{-1}(W)
path3 trans = pa .. ((pa + pb)/2 + (-3.2, 0, 0)) .. pb;
draw(trans, ink + linewidth(lwArrow), Arrow3(headSize));
label("$\mathbf{x}_\beta^{-1}\circ\mathbf{x}_\alpha$", relpoint(trans, 0.5), W, ink);

// ---------- Labels ----------
// preimages of W (dotted leader lines)
triple wa = FUa(c0) + yl(6), wb = FUb(c0) + yl(6);
draw(wa -- (wa + (0, 0, 2.6)), dW + dotted);
label("$\mathbf{x}_\alpha^{-1}(W)$", wa + (0, 0, 2.6), N, dW);
draw(wb -- (wb + (0, 0, -2.7)), dW + dotted);
label("$\mathbf{x}_\beta^{-1}(W)$",  wb + (0, 0, -2.7), S, dW);

label("$U_\alpha\subset\mathbb{R}^n$", FUa(c0 + rA(0)*dir(-5)), NW, dA);
label("$U_\beta\subset\mathbb{R}^n$",  FUb(c0 + rB(-2.2)*dir(-2.2)), SW, dB);
label("$W$", FM(c0) + zl(8), NoAlign, dW);
label("$M$", FM((0.97, 0.03)), SE, ink);
