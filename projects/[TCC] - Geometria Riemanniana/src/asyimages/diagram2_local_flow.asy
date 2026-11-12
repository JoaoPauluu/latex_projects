// ============================================================
//  Diagram 2 — Trajectory of a vector field X on M through q (local flow)
//  d/dt phi(t,q) = X(phi(t,q)),  phi(0,q) = q
//  Compile:  asy -f pdf diagram2_local_flow.asy
// ============================================================
import three;

settings.outformat = "pdf";
settings.prc       = false;
settings.render    = 0;
size(18cm);
currentprojection = orthographic(0.6, -8, 10);

usepackage("amsmath");
usepackage("amssymb");
defaultpen(fontsize(11pt));

// ---------- SHARED STYLE KIT (identical to diagram 1) ----------
pen cM  = rgb(0.86, 0.88, 0.91);          // manifold M
pen cA  = rgb(0.62, 0.76, 0.93);          // blue   : open sets / neighbourhoods (U)
pen cB  = rgb(0.95, 0.72, 0.68);          // red    : (unused here)
pen cW  = rgb(0.76, 0.62, 0.88);          // purple : (unused here)
pen dA  = rgb(0.10, 0.30, 0.65);          // dark blue  (outlines/labels)
pen dB  = rgb(0.70, 0.18, 0.15);          // dark red   (trajectories)
pen dW  = rgb(0.40, 0.18, 0.55);          // dark purple
pen ink = black;                          // arrows / vectors
pen lightB = rgb(0.90, 0.62, 0.58);       // neighbouring trajectories
real lwOutline = 1.2;
real lwArrow   = 1.0;
real headSize  = 6;
material mat(pen p) { return material(diffusepen=0.35*p, emissivepen=0.65*p, specularpen=black); }
// ---------------------------------------------------------------------------

pair dir(real t) { return (cos(t), sin(t)); }

// ---------- Helpers (same as diagram 1, with a centre parameter) ----------
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
void openDot(triple v, pen c) {                       // open endpoint of an open interval
  dot(v, c + linewidth(1.5));
  dot(v, white + linewidth(0.9));
}

// ====================== THE MANIFOLD M ======================
real hM(pair p) { return 0.9*sin(2.4*p.x + 0.4) + 0.5*cos(2.8*p.y); }
real sM = 1.5;                                        // overall scale of M (vectors stay the same size)
triple FM(pair p) { return (sM*(9*p.x), sM*(-2.5 + 5*p.y), sM*hM(p)); }
triple zl(real k) { return (0, 0, 0.04*k); }
triple yl(real k) { return (0, -0.04*k, 0); }

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

// ====================== THE VECTOR FIELD AND ITS FLOW (in the chart (u,v)) ======================
pair Xc(pair p) { return (1.0, 0.5*sin(6*p.x)); }               // X written in the chart
pair flow(pair q, real t) {                                      // phi(t,q), RK4
  int n = (int)(abs(t)/0.01) + 1;
  real h = t/n;
  pair p = q;
  for (int i = 0; i < n; ++i) {
    pair k1 = Xc(p), k2 = Xc(p + h/2*k1), k3 = Xc(p + h/2*k2), k4 = Xc(p + h*k3);
    p = p + h/6*(k1 + 2*k2 + 2*k3 + k4);
  }
  return p;
}
real delta = 0.25;                                               // the flow time interval (-delta,delta)

path3 traj(pair c, real t0, real t1, real lift=0.12, int n=60) {
  guide3 g = FM(flow(c, t0)) + (0, 0, lift);
  for (int i = 1; i <= n; ++i) g = g -- (FM(flow(c, t0 + (t1 - t0)*i/n)) + (0, 0, lift));
  return g;
}

// ---------- The neighbourhood U of p, and the points p, q ----------
pair cp = (0.50, 0.5);                                           // p
pair qc = cp + (0.05, 0.06);                                    // q
real rU(real t) { return 0.20*(1 + 0.12*sin(2*t + 1)); }

fillBlob(blob(rU, FM, zl(1), cp), cA);
draw(outline(rU, FM, zl(4), cp), dA + linewidth(lwOutline));

// ---------- The vector field X drawn on M (small, light arrows on a regular grid) ----------
real flen = 0.6;                                       // length of the field arrows
pair[] trajPts;                                        // chart points of the trajectory (to avoid crowding it)
for (int i = 0; i <= 40; ++i) trajPts.push(flow(qc, -delta + 2*delta*i/40));
bool nearTraj(pair c) {
  for (pair z : trajPts) if (length(z - c) < 0.07) return true;
  return false;
}
int nx = 10, ny = 6;
for (int i = 0; i < nx; ++i) {
  for (int j = 0; j < ny; ++j) {
    pair c = (0.05 + 0.90*i/(nx - 1), 0.08 + 0.84*j/(ny - 1));
    if (length(c - cp) < rU(angle(c - cp))*1.1 || nearTraj(c)) continue;   // skip inside U and near the trajectory
    triple a = FM(c) + (0, 0, 0.12);
    triple d = unit(FM(c + 0.01*Xc(c)) - FM(c))*flen;
    draw(a -- (a + d), rgb(0.40, 0.45, 0.58) + linewidth(0.7), Arrow3(3.5));
  }
}

// the trajectory through q: alpha(t) = phi(t,q), t in (-delta,delta)
path3 alpha = traj(qc, -delta, delta, 0.14, 80);
draw(alpha, dB + linewidth(1.8));
openDot(FM(flow(qc, -delta)) + (0, 0, 0.14), dB);
openDot(FM(flow(qc,  delta)) + (0, 0, 0.14), dB);

// tangent vectors X(alpha(t))
real vlen = 1.1;                                      // length of the drawn tangent vectors
void vec(pair c, real len=vlen) {
  triple a = FM(c) + (0, 0, 0.14);
  triple d = unit(FM(c + 0.01*Xc(c)) - FM(c))*len;
  draw(a -- (a + d), ink + linewidth(1.5), Arrow3(headSize));
}
vec(flow(qc, -0.6*delta));
vec(qc);
vec(flow(qc,  0.6*delta));

// points
triple Pp = FM(cp) + (0, 0, 0.14), Pq = FM(qc) + (0, 0, 0.14);
dot(Pp, dA + linewidth(1.1));
dot(Pq, dB + linewidth(0.6));   // tiny dot

// labels on M
label("$p$", Pp, SW, dA);
label("$q$", Pq, NW, dB);
label("$X(q)$", Pq + unit(FM(qc + 0.01*Xc(qc)) - FM(qc))*vlen, N, ink);
label("$X(\alpha(t))$", FM(flow(qc, 0.6*delta)) + unit(FM(flow(qc,0.6*delta) + 0.01*Xc(flow(qc,0.6*delta))) - FM(flow(qc,0.6*delta)))*vlen + (0, 0, 0.3), N, ink);
label("$U$", FM(cp + rU(2.4)*dir(2.4)), NW, dA);
label("$\alpha(t)=\varphi(t,q)$", FM(flow(qc, -0.55*delta)) + (0, 0, -0.2), SW, dB);
label("$M$", FM((0.97, 0.03)) + (0, 0, -0.3), SE, ink);
