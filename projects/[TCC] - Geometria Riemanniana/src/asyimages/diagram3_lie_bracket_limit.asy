// ============================================================
//  Diagram 3 — The Lie bracket as a limit
//  [X,Y]_p = lim_{t->0} (1/t) ( Y_{phi_t(p)} - d(phi_t)_p Y_p )
//  Compile:  asy -f pdf diagram3_lie_bracket.asy
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

// ---------- SHARED STYLE KIT (identical to diagrams 1 and 2) ----------
pen cM  = rgb(0.86, 0.88, 0.91);          // manifold M
pen cA  = rgb(0.62, 0.76, 0.93);          // blue   : open sets / neighbourhoods (U)
pen cB  = rgb(0.95, 0.72, 0.68);          // red    : (unused here)
pen cW  = rgb(0.76, 0.62, 0.88);          // purple : (unused here)
pen dA  = rgb(0.10, 0.30, 0.65);          // dark blue  (outlines/labels)
pen dB  = rgb(0.70, 0.18, 0.15);          // dark red   (trajectories)
pen dW  = rgb(0.40, 0.18, 0.55);          // dark purple (bracket / difference)
pen ink = black;                          // arrows / vectors
real lwOutline = 1.2;
real lwArrow   = 1.0;
real headSize  = 6;
material mat(pen p) { return material(diffusepen=0.35*p, emissivepen=0.65*p, specularpen=black); }
// ---------------------------------------------------------------------------

pair dir(real t) { return (cos(t), sin(t)); }

// ---------- Helpers ----------
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
void openDot(triple v, pen c) {
  dot(v, c + linewidth(1.5));
  dot(v, white + linewidth(0.9));
}

// ====================== THE MANIFOLD M (same as diagram 2) ======================
real hM(pair p) { return 0.9*sin(2.4*p.x + 0.4) + 0.5*cos(2.8*p.y); }
real sM = 1.5;
triple FM(pair p) { return (sM*(9*p.x), sM*(-2.5 + 5*p.y), sM*hM(p)); }
triple zl(real k) { return (0, 0, 0.04*k); }

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

// ====================== THE FIELDS X, Y AND THE FLOW (in the chart (u,v)) ======================
pair Xc(pair p) { return (1.0, 0.5*sin(6*p.x)); }                          // X
pair Yc(pair p) { return (0.4*cos(3*p.y + p.x), 0.6 + 0.4*sin(5*p.x)); }  // Y

pair rk4(pair F(pair), pair q, real t) {                  // flow of a field F for time t
  int n = (int)(abs(t)/0.01) + 1;
  real h = t/n;
  pair p = q;
  for (int i = 0; i < n; ++i) {
    pair k1 = F(p), k2 = F(p + h/2*k1), k3 = F(p + h/2*k2), k4 = F(p + h*k3);
    p = p + h/6*(k1 + 2*k2 + 2*k3 + k4);
  }
  return p;
}
pair flow(pair q, real t) { return rk4(Xc, q, t); }                        // phi_t(q)
pair dphi(pair c, pair v, real t) {                                        // d(phi_t)_c (v), numerically
  real e = 1e-4;
  return (flow(c + e*v, t) - flow(c, t))/e;
}

real delta = 0.36;       // flow time interval (-delta,delta)
real tt    = 0.30;       // the fixed time t used in the picture
real kk    = 0.34;       // chart-vector -> drawn-vector scale (Y_p, Y_{phi_t(p)}, d(phi_t)Y_p, difference)
real kb    = 0.17;       // separate scale for [X,Y]_p (it is much longer in the chart)
triple tv(pair c, pair v) { return (FM(c + 0.001*v) - FM(c))/0.001*kk; }   // drawn vector (tangent to M)
triple tvb(pair c, pair v) { return (FM(c + 0.001*v) - FM(c))/0.001*kb; }
triple lift = (0, 0, 0.14);

path3 traj(pair c, real t0, real t1, real lf=0.12, int n=60) {
  guide3 g = FM(flow(c, t0)) + (0, 0, lf);
  for (int i = 1; i <= n; ++i) g = g -- (FM(flow(c, t0 + (t1 - t0)*i/n)) + (0, 0, lf));
  return g;
}

// ---------- p, U, phi_t(p) ----------
pair cp  = (0.40, 0.5);                                   // p
pair cpt = flow(cp, tt);                                  // phi_t(p)
real rU(real t) { return 0.14*(1 + 0.12*sin(2*t + 1)); }

fillBlob(blob(rU, FM, zl(1), cp), cA);
draw(outline(rU, FM, zl(4), cp), dA + linewidth(lwOutline));

// ---------- the field X, light, on a grid ----------
real flen = 0.6;
pair[] trajPts;
for (int i = 0; i <= 40; ++i) trajPts.push(flow(cp, -delta + 2*delta*i/40));
bool nearTraj(pair c) {
  for (pair z : trajPts) if (length(z - c) < 0.08) return true;
  return false;
}
int nx = 10, ny = 6;
for (int i = 0; i < nx; ++i) {
  for (int j = 0; j < ny; ++j) {
    pair c = (0.05 + 0.90*i/(nx - 1), 0.08 + 0.84*j/(ny - 1));
    if (length(c - cp) < rU(angle(c - cp))*1.1 || nearTraj(c) || length(c - cpt) < 0.26) continue;
    triple a = FM(c) + (0, 0, 0.12);
    triple d = unit(FM(c + 0.01*Xc(c)) - FM(c))*flen;
    draw(a -- (a + d), rgb(0.40, 0.45, 0.58) + linewidth(0.7), Arrow3(3.5));
  }
}

// ---------- trajectory of p under X ----------
draw(traj(cp, -delta, delta, 0.14, 80), dB + linewidth(1.8));
openDot(FM(flow(cp, -delta)) + lift, dB);
openDot(FM(flow(cp,  delta)) + lift, dB);

// ---------- integral curve beta of Y through p, and its image phi_t(beta) ----------
real sb = 0.11;                                           // beta(s), s in (-sb,sb)
path3 curveY(real lf, int n=30) {
  guide3 g = FM(rk4(Yc, cp, -sb)) + (0, 0, lf);
  for (int i = 1; i <= n; ++i) g = g -- (FM(rk4(Yc, cp, -sb + 2*sb*i/n)) + (0, 0, lf));
  return g;
}
path3 curveYimage(real lf, int n=30) {
  guide3 g = FM(flow(rk4(Yc, cp, -sb), tt)) + (0, 0, lf);
  for (int i = 1; i <= n; ++i) g = g -- (FM(flow(rk4(Yc, cp, -sb + 2*sb*i/n), tt)) + (0, 0, lf));
  return g;
}
draw(curveY(0.14),      dA + linewidth(1.4));
draw(curveYimage(0.14), dA + dashed + linewidth(1.4));

// ---------- the vectors ----------
triple Pp  = FM(cp)  + lift;
triple Ppt = FM(cpt) + lift;

pair  Ypc   = Yc(cp);                      // Y_p
pair  Yptc  = Yc(cpt);                     // Y_{phi_t(p)}
pair  dYc   = dphi(cp, Ypc, tt);           // d(phi_t)_p Y_p
real  tb    = 0.01;                        // small t used to evaluate the limit
pair  brc   = (dphi(flow(cp, tb), Yc(flow(cp, tb)), -tb) - Ypc)/tb;   // [X,Y]_p (in the chart)

draw(Pp  -- (Pp  + tv(cp,  Ypc)),  ink + linewidth(1.6), Arrow3(headSize));    // Y_p
draw(Ppt -- (Ppt + tv(cpt, Yptc)), ink + linewidth(1.6), Arrow3(headSize));    // Y_{phi_t(p)}
draw(Ppt -- (Ppt + tv(cpt, dYc)),  dA  + linewidth(1.6), Arrow3(headSize));    // d phi_t (Y_p)
draw((Ppt + tv(cpt, dYc)) -- (Ppt + tv(cpt, Yptc)), dW + linewidth(2.0), Arrow3(5));   // difference
draw(Pp -- (Pp + tvb(cp, brc)), dW + linewidth(2.0), Arrow3(headSize));         // [X,Y]_p

dot(Pp,  dA + linewidth(1.1));
dot(Ppt, dB + linewidth(1.1));

// ---------- labels ----------
label("$p$",            Pp,  SW, dA);
label("$\varphi_t(p)$", Ppt, SE, dB);
label("$U$",            FM(cp + rU(2.4)*dir(2.4)), NW, dA);
label("$Y_p$",          Pp + tv(cp, Ypc), N, ink);
label("$[X,Y]_p$",      Pp + tvb(cp, brc), SW, dW);
label("$Y_{\varphi_t(p)}$",           Ppt + tv(cpt, Yptc) + (0.5, 0, -1.5), NW, ink);
label("$d(\varphi_t)_p Y_p$",         Ppt + tv(cpt, dYc) + (0.2, 0, -2.5),  NE, dA);
label("$Y_{\varphi_t(p)}-d(\varphi_t)_pY_p$", 0.5*((Ppt + tv(cpt, dYc)) + (Ppt + tv(cpt, Yptc))) + (-1.7, -0.5, 2.2), E, dW);
label("$M$",            FM((0.97, 0.03)) + (0, 0, -0.5), SE, ink);
