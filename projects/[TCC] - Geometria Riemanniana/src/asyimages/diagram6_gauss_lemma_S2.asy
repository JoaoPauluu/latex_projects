// ============================================================
//  Diagram 6 — Gauss lemma on S^2 (redone from scratch)
//  S_eps(p) is orthogonal to the geodesics from p.
//
//  This diagram does NOT use Asymptote's 3D depth sorting (it was unreliable).
//  Everything is projected to 2D by hand (orthographic view) and drawn in an explicit order:
//     1. sphere (opaque, shaded)      -> only its FRONT hemisphere is ever drawn
//     2. grid, geodesic disc, S_eps(p), gamma, p   (all on the sphere)
//     3. tangent plane T_pS^2 and the ball B_eps(0) (the plane lies IN FRONT of the sphere)
//     4. q, gamma'(1,p,v), w, right angle, labels   (on top of everything)
//  Compile:  asy -f pdf diagram6_gauss_lemma_S2.asy
// ============================================================
// NOTE: no 'import three' here on purpose (the plain 'triple' type is enough). With it loaded,
// label(..., pair, ...) can be taken for a 3D label and end up misplaced or invisible.

settings.outformat = "pdf";
size(16cm);

usepackage("amsmath");
usepackage("amssymb");
defaultpen(fontsize(11pt));

// ---------- SHARED STYLE KIT (same colours as diagrams 1-5) ----------
pen cM  = rgb(0.86, 0.88, 0.91);          // manifold
pen cA  = rgb(0.62, 0.76, 0.93);          // blue   : open sets (geodesic disc)
pen cB  = rgb(0.95, 0.72, 0.68);          // red    : (unused here)
pen cW  = rgb(0.76, 0.62, 0.88);          // purple : (unused here)
pen dA  = rgb(0.10, 0.30, 0.65);          // dark blue
pen dB  = rgb(0.70, 0.18, 0.15);          // dark red   (geodesics, S_eps(p), B_eps(0) boundary)
pen dW  = rgb(0.40, 0.18, 0.55);          // dark purple (w, right angle)
pen ink = black;                          // vectors
real headSize = 6;
// ---------------------------------------------------------------------------

// ---------- small 3D helpers (plain vectors, no depth sorting involved) ----------
triple cross3(triple a, triple b) { return (a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x); }
real dp3(triple a, triple b) { return a.x*b.x + a.y*b.y + a.z*b.z; }

// ---------- THE VIEW: orthographic projection, built by hand ----------
triple vc = unit((-0.25, 1, 0.35));                  // direction TOWARDS the camera
triple rr = unit((-vc.y, vc.x, 0));                  // screen "right"
triple uv = cross3(rr, -vc);                         // screen "up"
pair S2(triple P) { return (dp3(P, rr), dp3(P, uv)); }          // 3D point -> page
bool front(triple P) { return dp3(P, vc) > 0; }                 // is it on the visible side of the sphere?

// draw a curve t -> f(t) lying ON the sphere; only the visible pieces are drawn
void curveOnS(triple f(real), real t0, real t1, int n, pen p) {
  path g;
  bool on = false;
  for (int i = 0; i <= n; ++i) {
    triple P = f(t0 + (t1 - t0)*i/n);
    if (front(P)) {
      pair z = S2(P);
      if (!on) { g = z; on = true; } else g = g -- z;
    } else {
      if (on) { draw(g, p); on = false; }
    }
  }
  if (on) draw(g, p);
}

// ====================== THE SPHERE ======================
real R = 4;
triple onS(real colat, real lon) { return R*(sin(colat)*cos(lon), sin(colat)*sin(lon), cos(colat)); }

// opaque, softly shaded disc (concentric fills, light from the upper left)
pen shadeDark  = rgb(0.76, 0.79, 0.85);
pen shadeLight = rgb(0.96, 0.97, 0.99);
for (int i = 0; i <= 24; ++i) {
  real t = i/24.0;
  fill(shift(t*0.32*R*(-0.6, 0.8))*scale(R*(1 - 0.7*t))*unitcircle, (1 - t)*shadeDark + t*shadeLight);
}
draw(scale(R)*unitcircle, gray(0.5) + linewidth(0.8));

for (int k = 0; k < 12; ++k) {                       // meridians (visible parts only)
  triple f(real s) { return onS(s, 2*pi*k/12); }
  curveOnS(f, 0, pi, 80, gray(0.62) + linewidth(0.3));
}
for (int k = 1; k < 6; ++k) {                        // parallels
  triple f(real s) { return onS(pi*k/6, s); }
  curveOnS(f, 0, 2*pi, 160, gray(0.62) + linewidth(0.3));
}

// ====================== p, T_pS^2 AND exp_p ======================
triple n  = unit(0.78*vc - 0.56*rr + 0.60*uv);       // p = R n  (faces the viewer; offset to the left so that q lands just right of the page centre)
triple e1 = unit(cross3((0, 0, 1), n));              // orthonormal basis of T_pS^2
triple e2 = cross3(n, e1);
triple p0 = R*n;
triple uu(real th) { return cos(th)*e1 + sin(th)*e2; }
triple pl(real r, real th) { return p0 + r*uu(th); }                       // point of the affine plane T_p
triple ex(real r, real th) { return R*(cos(r/R)*n + sin(r/R)*uu(th)); }    // exp_p(r u_th) on S^2

real eps = 0.7*R;                                    // epsilon (a geodesic radius of 0.7 rad)

// direction of the highlighted geodesic: the one that heads to the right of the page
real th0 = 0;
{
  real best = -2;
  for (int i = 0; i < 360; ++i) {
    real th = 2*pi*i/360;
    pair d = S2(uu(th));
    real sc = (d.x*0.96 - d.y*0.28)/length(d);
    if (sc > best) { best = sc; th0 = th; }
  }
}

// ---------- the geodesic disc exp_p(B_eps(0)) on S^2 (opaque blue) ----------
{
  path cap;
  for (int j = 0; j < 160; ++j) cap = cap -- S2(ex(eps, 2*pi*j/160));
  fill(cap -- cycle, cA);
}
for (int k = 0; k < 16; ++k) {                       // images of the radial lines = geodesics from p
  triple f(real s) { return ex(s, 2*pi*k/16); }
  curveOnS(f, 0, eps, 30, dA + linewidth(0.6));
}
{
  triple f(real s) { return ex(eps/2, s); }          // image of the inner circle
  curveOnS(f, 0, 2*pi, 100, dA + linewidth(0.6));
}
{
  triple f(real s) { return ex(eps, s); }            // the boundary S_eps(p)
  curveOnS(f, 0, 2*pi, 200, dB + linewidth(1.8));
}
{
  triple f(real s) { return ex(s, th0); }            // the highlighted geodesic gamma(t,p,v)
  curveOnS(f, 0, eps, 40, dB + linewidth(2.2));
}

// ====================== THE TANGENT PLANE (in FRONT of the sphere) ======================
real A = 5.4, B = 4.4;
draw(S2(p0 + A*e1 + B*e2) -- S2(p0 - A*e1 + B*e2) -- S2(p0 - A*e1 - B*e2) -- S2(p0 + A*e1 - B*e2) -- cycle,
     gray(0.45) + linewidth(0.9));

// the ball B_eps(0) in T_p: light tint, polar grid and DASHED boundary (it is an open ball)
path ballB;
for (int j = 0; j < 160; ++j) ballB = ballB -- S2(pl(eps, 2*pi*j/160));
ballB = ballB -- cycle;
fill(ballB, cA + opacity(0.28));
{
  path g;
  for (int j = 0; j < 120; ++j) g = g -- S2(pl(eps/2, 2*pi*j/120));
  draw(g -- cycle, dA + linewidth(0.6));
}
draw(ballB, dB + dashed + linewidth(1.6));

// v in T_pS^2 and the correspondence exp_p(v) = q
triple vtip = pl(eps, th0);
triple q    = ex(eps, th0);
draw(S2(p0) -- S2(vtip), ink + linewidth(1.6), Arrow(headSize));
draw(S2(vtip) -- S2(q), ink + dotted + linewidth(1.0), Arrow(5));

// ====================== q AND THE TWO ORTHOGONAL VECTORS (on top) ======================
real s0 = eps/R;
triple t1 = unit(-sin(s0)*n + cos(s0)*uu(th0));     // direction of gamma'(1,p,v)
triple w  = unit(cross3(n, uu(th0)));                // direction of a tangent vector of S_eps(p) at q
real vl = 1.9;
draw(S2(q) -- S2(q + vl*t1), ink + linewidth(1.7), Arrow(headSize));
draw(S2(q) -- S2(q + vl*w),  dW  + linewidth(1.7), Arrow(headSize));
real ra = 0.5;                                       // right-angle marker
draw(S2(q + ra*t1) -- S2(q + ra*t1 + ra*w) -- S2(q + ra*w), dW + linewidth(1.1));

dot(S2(p0), black + linewidth(0.8));
dot(S2(q),  black + linewidth(0.8));

// ====================== LABELS ======================
pair away(triple P) { return unit(S2(P) - S2(p0)); }                 // direction pointing away from p on the page
// FIX: the transform must be applied to the vector first, then scaled by the sign
// (the old version  sgn*rotate(90)*unit(...)  is 'real*transform' -> compile error, so no labels).
pair side(triple a, triple b, real s) { return s*(rotate(90)*unit(S2(b) - S2(a))); }

label("$p$", S2(p0), SW, ink);
label("$q=\gamma(1,p,v)$", S2(q), 1.6*SW, ink);
label("$v$", S2(0.55*(p0 + vtip)), 1.2*N, ink);
label("$\exp_p$", S2(0.5*(vtip + q)), 1.4*NE, ink);
label("$\gamma'(1,p,v)$", S2(q + vl*t1), unit(S2(t1)), ink);
label("$w$", S2(q + vl*w), unit(S2(w)), dW);
label("$S_\epsilon(p)$", S2(ex(eps, th0 + 2.4)), away(ex(eps, th0 + 2.4)), dB);
label("$B_\epsilon(0)$", S2(pl(eps, th0 - 2.2)), away(pl(eps, th0 - 2.2)), dB);

label("$T_pS^2$", S2(p0 - A*e1 + B*e2), away(p0 - A*e1 + B*e2), gray(0.35));
label("$S^2$", R*(cos(-0.7), sin(-0.7)), SE, ink);
