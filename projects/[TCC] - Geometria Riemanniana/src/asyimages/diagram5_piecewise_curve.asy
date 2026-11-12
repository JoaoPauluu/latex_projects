// ============================================================
//  Diagram 5 — A piecewise differentiable curve c:[a,b] -> M
//  partition a=t_0 < t_1 < t_2 < t_3=b, with c smooth on each [t_{i-1},t_i];
//  the two vertices c(t_1), c(t_2) are highlighted together with the one-sided
//  velocity vectors c'(t_i^-), c'(t_i^+) and the angle theta_i between them.
//  Compile:  asy -f pdf diagram5_piecewise_curve.asy
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

// ---------- SHARED STYLE KIT (identical to diagrams 1-4) ----------
pen cM  = rgb(0.86, 0.88, 0.91);          // manifold M
pen cA  = rgb(0.62, 0.76, 0.93);          // blue   : open sets
pen cB  = rgb(0.95, 0.72, 0.68);          // red    : (unused here)
pen cW  = rgb(0.76, 0.62, 0.88);          // purple : highlights (vertices, angle)
pen dA  = rgb(0.10, 0.30, 0.65);          // dark blue
pen dB  = rgb(0.70, 0.18, 0.15);          // dark red   (the curve)
pen dW  = rgb(0.40, 0.18, 0.55);          // dark purple (vertex hlVertex / angle)
pen ink = black;                          // vectors
real lwOutline = 1.2;
real lwArrow   = 1.0;
real headSize  = 6;
material mat(pen p) { return material(diffusepen=0.35*p, emissivepen=0.65*p, specularpen=black); }
// ---------------------------------------------------------------------------

// ---------- Helper ----------
surface gridSurface(triple P(int,int), int nu, int nv) {
  patch[] ps;
  for (int i = 0; i < nu; ++i)
    for (int j = 0; j < nv; ++j)
      ps.push(patch(P(i,j) -- P(i+1,j) -- P(i+1,j+1) -- P(i,j+1) -- cycle));
  surface S;
  S.s = ps;
  return S;
}

// ====================== THE MANIFOLD M (same as diagrams 2-4) ======================
real hM(pair p) { return 0.9*sin(2.4*p.x + 0.4) + 0.5*cos(2.8*p.y); }
real sM = 1.5;
triple FM(pair p) { return (sM*(9*p.x), sM*(-2.5 + 5*p.y), sM*hM(p)); }

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

// ====================== THE CURVE c (in the chart), 3 smooth arcs ======================
// PV[0]=c(a), PV[1]=c(t_1), PV[2]=c(t_2), PV[3]=c(b).  Each arc is a quadratic Bezier, bending
// alternately left/right, so the tangent jumps at the vertices.
pair[] PV = {(0.12, 0.30), (0.40, 0.64), (0.64, 0.34), (0.88, 0.62)};
real bulge = 0.06;
pair ctrl(int k) {
  pair a = PV[k], b = PV[k+1];
  pair nrm = unit(rotate(90)*(b - a));
  return (a + b)/2 + ((k % 2 == 0) ? 1 : -1)*bulge*nrm;
}
pair cc(real t) {                                      // t in [0,1]; vertices at t = 1/3, 2/3
  real s = 3*t;
  int k = (int)s;
  if (k > 2) k = 2;
  real u = s - k;
  return (1-u)^2*PV[k] + 2*(1-u)*u*ctrl(k) + u^2*PV[k+1];
}

real lc = 0.35;                                        // liftZ of the curve above M
triple liftZ = (0, 0, lc);
guide3 gc = FM(cc(0)) + liftZ;
for (int i = 1; i <= 150; ++i) gc = gc -- (FM(cc(i/150)) + liftZ);
draw(gc, dB + linewidth(2.0));

// ====================== VERTICES, ONE-SIDED VELOCITIES AND ANGLES ======================
triple dir3(pair c, pair v) { return unit(FM(c + 0.001*v) - FM(c)); }       // unit tangent vector on M
real dp3(triple a, triple b) { return a.x*b.x + a.y*b.y + a.z*b.z; }
real vlen = 1.9;                                       // length of the drawn velocity vectors
real arcR = 1.0;                                       // radius of the angle arc

void hlVertex(triple v) {                             // highlighted vertex: purple ring + tiny black centre
  dot(v, dW + linewidth(2.8));
  dot(v, cW + linewidth(1.9));
  dot(v, black + linewidth(0.5));
}

void drawCorner(int k, string idx) {                       // vertex c(t_k), k = 1, 2
  pair c   = PV[k];
  triple b = FM(c) + liftZ;
  pair vm  = PV[k] - ctrl(k - 1);                       // c'(t_k^-)  (direction of the incoming arc)
  pair vp  = ctrl(k) - PV[k];                           // c'(t_k^+)  (direction of the outgoing arc)
  triple u1 = dir3(c, vm), u2 = dir3(c, vp);

  // velocity vectors
  draw(b -- (b + vlen*u1), ink + linewidth(1.6), Arrow3(headSize));
  draw(b -- (b + vlen*u2), ink + linewidth(1.6), Arrow3(headSize));

  // angle arc between u1 and u2 (in the plane they span)
  real phi = acos(min(1, max(-1, dp3(u1, u2))));
  int n = 30;
  guide3 ga = b + arcR*u1;
  for (int i = 1; i <= n; ++i) {
    real s = i/n;
    ga = ga -- (b + arcR*(sin((1 - s)*phi)*u1 + sin(s*phi)*u2)/sin(phi));
  }
  draw(ga, dW + linewidth(1.6));
  triple bis = unit(u1 + u2);
  label("$\theta_{" + idx + "}$", b + 1.5*arcR*bis, NoAlign, dW);

  // labels
  label("$c'(t_{" + idx + "}^{-})$", b + (vlen + 0.7)*u1, NoAlign, ink);
  label("$c'(t_{" + idx + "}^{+})$", b + (vlen + 0.7)*u2 + (-1.2, 0, 0), NoAlign, ink);
  label("$c(t_{" + idx + "})$", b - 0.9*bis, NoAlign, dW);

  hlVertex(b);
}
drawCorner(1, "1");
drawCorner(2, "2");

// ====================== ENDPOINTS AND LABELS ======================
triple pa = FM(PV[0]) + liftZ, pb = FM(PV[3]) + liftZ;
dot(pa, black + linewidth(0.5));
dot(pb, black + linewidth(0.5));
label("$c(a)$", pa - 0.9*unit(FM(cc(0.05)) - FM(cc(0))), NoAlign, ink);
label("$c(b)$", pb - 0.9*unit(FM(cc(0.95)) - FM(cc(1))), NoAlign, ink);
label("$c$", FM(cc(0.5)) + liftZ, S, dB);
label("$M$", FM((0.97, 0.03)) + (0, 0, -0.5), SE, ink);
