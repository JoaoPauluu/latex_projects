// ============================================================
//  Diagram 7 — Parallel transport on S^2 (Levi-Civita connection of a surface)
//    (nabla_X Y)_p = proj_{T_pM} ( D_X Y (p) )
//  Original 3D style of diagrams 1-5 (import three, lit surface, 3D labels).
//  Compile:  asy -f pdf diagram7_parallel_transport_S2.asy
// ============================================================
import three;

settings.outformat = "pdf";
settings.prc       = false;
settings.render    = 0;
size(18cm);
currentprojection = orthographic(0.6, -8, 3.2);

usepackage("amsmath");
usepackage("amssymb");
defaultpen(fontsize(11pt));

// ---------- SHARED STYLE KIT (identical to diagrams 1-5) ----------
pen cM  = rgb(0.86, 0.88, 0.91);          // manifold M
pen cA  = rgb(0.62, 0.76, 0.93);
pen cB  = rgb(0.95, 0.72, 0.68);
pen cW  = rgb(0.76, 0.62, 0.88);
pen dA  = rgb(0.10, 0.30, 0.65);          // dark blue   (X = c')
pen dB  = rgb(0.70, 0.18, 0.15);          // dark red    (the curve c)
pen dW  = rgb(0.40, 0.18, 0.55);          // dark purple (D_X V, highlighted example)
pen ink = black;                          // the transported vectors
real lwOutline = 1.2;
real lwArrow   = 1.0;
real headSize  = 6;
material mat(pen p) { return material(diffusepen=0.35*p, emissivepen=0.65*p, specularpen=black); }
// ---------------------------------------------------------------------------

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
triple cross3(triple a, triple b) { return (a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x); }
real dp3(triple a, triple b) { return a.x*b.x + a.y*b.y + a.z*b.z; }

// ====================== THE SPHERE S^2 (the manifold M) ======================
real R = 4;
triple onS(real colat, real lon) { return R*(sin(colat)*cos(lon), sin(colat)*sin(lon), cos(colat)); }

int nu = 48, nv = 24;
triple PS(int i, int j) { return onS(pi*j/nv, 2*pi*i/nu); }
draw(gridSurface(PS, nu, nv), mat(cM));
for (int k = 0; k < 12; ++k) {                       // meridians
  guide3 g = 1.002*onS(0, 2*pi*k/12);
  for (int j = 1; j <= 60; ++j) g = g -- 1.002*onS(pi*j/60, 2*pi*k/12);
  draw(g, gray(0.65) + linewidth(0.3));
}
for (int k = 1; k < 6; ++k) {                        // parallels
  guide3 g = 1.002*onS(pi*k/6, 0);
  for (int j = 1; j <= 120; ++j) g = g -- 1.002*onS(pi*k/6, 2*pi*j/120);
  draw(g -- cycle, gray(0.65) + linewidth(0.3));
}

// ====================== THE CURVE c: an arc of a circle of latitude ======================
real Th = 62*pi/180;                                 // colatitude of that circle
real sA = -2.4, sB = 0.1;                            // c runs from s = sA (t=0) to s = sB (t=1)
triple cc(real s) { return R*(sin(Th)*cos(s), sin(Th)*sin(s), cos(Th)); }       // c(s)
triple cd(real s) { return R*sin(Th)*(-sin(s), cos(s), 0); }                    // c'(s) = X
real lf = 1.012;                                     // slight lift above the sphere

// drawn as many short pieces (Asymptote depth-sorts each piece separately)
int ns = 120;
for (int i = 0; i < ns; ++i)
  draw(lf*cc(sA + (sB - sA)*i/ns) -- lf*cc(sA + (sB - sA)*(i+1)/ns), dB + linewidth(2.2));

// ====================== PARALLEL TRANSPORT:  V' = -(V . c'/R^2) c ======================
// (the ambient derivative D_X V of a parallel field has no tangential part)
triple fV(real s, triple V) { return -(dp3(V, cd(s))/(R*R))*cc(s); }

int NN = 600;
triple[] Vs;
{
  triple tt = unit(cd(sA)), nn = unit(cc(sA));
  real al = 2.4;                                     // initial angle between V(0) and c'(0)
  triple V = cos(al)*tt + sin(al)*cross3(nn, tt);
  Vs.push(V);
  real h = (sB - sA)/NN;
  for (int i = 0; i < NN; ++i) {
    real s = sA + i*h;
    triple k1 = fV(s, V), k2 = fV(s + h/2, V + (h/2)*k1), k3 = fV(s + h/2, V + (h/2)*k2), k4 = fV(s + h, V + h*k3);
    V = V + (h/6)*(k1 + 2*k2 + 2*k3 + k4);
    triple nrm = unit(cc(s + h));                    // keep V tangent and of unit length (numerical drift)
    V = V - dp3(V, nrm)*nrm;
    V = unit(V);
    Vs.push(V);
  }
}

// ====================== THE TRANSPORTED VECTORS V(t_i) ======================
real vl = 1.7;
int nvec = 6;
for (int i = 0; i < nvec; ++i) {
  int idx = (int)(NN*i/(nvec - 1.0));
  triple b = lf*cc(sA + (sB - sA)*idx/NN);
  draw(b -- (b + vl*Vs[idx]), ink + linewidth(1.6), Arrow3(headSize));
  dot(b, black + linewidth(0.8));
}

// ====================== THE HIGHLIGHTED EXAMPLE:  D_X V  and  proj ( D_X V ) ======================
int hi = 1;                                          // which vector carries the example
int hidx = (int)(NN*hi/(nvec - 1.0));
real sh = sA + (sB - sA)*hidx/NN;
triple bh = lf*cc(sh), Vh = Vs[hidx];
triple nh = unit(bh);                                // normal to S^2
triple th = unit(cd(sh));                            // X / |X|
triple DV = 2.0*fV(sh, Vh);                          // D_X V (scaled to be visible) : it points along the normal

// the tangent plane T_{c(t)}S^2 (a small patch, outline only)
real a1 = 1.9;
triple u1 = th, u2 = cross3(nh, th);
draw((bh + a1*u1 + a1*u2) -- (bh - a1*u1 + a1*u2) -- (bh - a1*u1 - a1*u2) -- (bh + a1*u1 - a1*u2) -- cycle,
     gray(0.45) + linewidth(0.9));

draw(bh -- (bh + 1.6*th), dA + linewidth(1.7), Arrow3(headSize));      // X = c'(t)
draw(bh -- (bh + DV),     dW + linewidth(2.0), Arrow3(headSize));      // D_X V  (normal to the sphere)
real ra = 0.35;                                      // right-angle marker between D_X V and the plane
triple dv = unit(DV);
draw((bh + ra*dv) -- (bh + ra*dv + ra*u1), dW + linewidth(1.0));
draw((bh + ra*u1) -- (bh + ra*dv + ra*u1), dW + linewidth(1.0));

// ====================== LABELS ======================
label("$c$",       lf*cc(0.5*(sA + sB)), S, dB);
label("$p=c(0)$",  lf*cc(sA), SW, ink);
label("$q=c(1)$",  lf*cc(sB), SE, ink);
label("$V(0)$",    lf*cc(sA) + vl*Vs[0],  W, ink);
label("$V(1)$",    lf*cc(sB) + vl*Vs[NN], E, ink);
label("$V(t)$",    bh + vl*Vh, N, ink);
label("$X=c'(t)$", bh + 1.6*th, NE, dA);
label("$D_XV$",    bh + DV, N, dW);
label("$T_{c(t)}S^2$", bh - a1*u1 - a1*u2, SE, gray(0.35));

label("$\nabla_XV=\operatorname{proj}_{T_{c(t)}S^2}(D_XV)=0$", (0, 0, 1.45*R), NoAlign, dW);
label("$S^2$", R*unit((0.8, -0.3, -0.5)), SE, ink);
