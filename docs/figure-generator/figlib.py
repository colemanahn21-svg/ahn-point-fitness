# Figure generator: author joint coordinates, get SVG + asset catalogue entries.
# Every figure is auto-fitted to fill its frame, so hand-authored coordinates
# only need to be right relative to each other, never sized to the canvas.
BODY   = "#352E26"   # espresso
ACCENT = "#C65F3C"   # terracotta
PROP   = "#D9CBB8"   # equipment / floor / wall
HALO   = "#FFFFFF"   # card background, lifts a limb in front of the torso
W      = 7

VBW, VBH = 320, 300
PAD = 26

def _fit(groups, head, floor, wall):
    pts = [p for g in groups for p in g]
    if head: pts += [(head[0]-head[2], head[1]-head[2]), (head[0]+head[2], head[1]+head[2])]
    xs = [p[0] for p in pts]; ys = [p[1] for p in pts]
    w = max(xs)-min(xs) or 1; h = max(ys)-min(ys) or 1
    s = min((VBW-2*PAD)/w, (VBH-2*PAD)/h)
    ox = (VBW - w*s)/2 - min(xs)*s
    oy = (VBH - h*s)/2 - min(ys)*s
    T = lambda p: (round(p[0]*s+ox,1), round(p[1]*s+oy,1))
    return T, s

def _poly(pts, color, w=W, dash=None, op=None):
    d = " ".join(f"{x},{y}" for x, y in pts)
    e = f' stroke-dasharray="{dash}"' if dash else ""
    e += f' opacity="{op}"' if op else ""
    return (f'<polyline points="{d}" fill="none" stroke="{color}" stroke-width="{w}" '
            f'stroke-linecap="round" stroke-linejoin="round"{e}/>')

def figure(body=(), accent=(), head=None, props=(), halo=(), floor=None, wall=None, arc=None, circles=()):
    """floor: y of the ground line. wall: x of a vertical surface. Both are
    drawn edge-to-edge after fitting, so they read as environment not limbs."""
    body, accent, props, halo = list(body), list(accent), list(props), list(halo)
    circles = list(circles)
    T, s = _fit(body + accent + props + halo + [[(c[0],c[1])] for c in circles], head, floor, wall)
    sw = max(4.5, W * s)
    out = [f'<svg viewBox="0 0 {VBW} {VBH}" xmlns="http://www.w3.org/2000/svg">']
    if floor is not None:
        y = T((0, floor))[1]
        out.append(_poly([(10, y), (VBW-10, y)], PROP, w=max(5, sw*0.85)))
    if wall is not None:
        x = T((wall, 0))[0]
        out.append(_poly([(x, 12), (x, VBH-12)], PROP, w=max(5, sw*0.85)))
    for p in props:
        out.append(_poly([T(q) for q in p], PROP, w=max(6, sw*1.1)))
    if arc:
        a, b, r = arc
        A, B = T(a), T(b)
        out.append(f'<path d="M{A[0]} {A[1]} A {r*s} {r*s} 0 0 1 {B[0]} {B[1]}" fill="none" '
                   f'stroke="{ACCENT}" stroke-width="3" stroke-dasharray="5 6" opacity="0.75"/>')
    for c in circles:                    # equipment: roller, peanut, ball
        cx, cy = T((c[0], c[1]))
        out.append(f'<circle cx="{cx}" cy="{cy}" r="{round(c[2]*s,1)}" fill="{PROP}"/>')
    for p in body:
        out.append(_poly([T(q) for q in p], BODY, w=sw))
    if head:
        cx, cy = T((head[0], head[1])); r = head[2]*s
        # Filled with the card colour so limbs passing behind the head are
        # knocked out — otherwise floor-level poses read as a blob.
        out.append(f'<circle cx="{cx}" cy="{cy}" r="{round(r,1)}" fill="{HALO}" '
                   f'stroke="{BODY}" stroke-width="{sw}"/>')
    for p in halo:
        out.append(_poly([T(q) for q in p], HALO, w=sw+9))
    for p in accent:
        out.append(_poly([T(q) for q in p], ACCENT, w=sw))
    out.append('</svg>')
    return "\n".join(out)

CONTENTS = '''{
  "images" : [ { "filename" : "%s", "idiom" : "universal" } ],
  "info" : { "author" : "xcode", "version" : 1 },
  "properties" : { "preserves-vector-representation" : true }
}
'''

def emit(catalog_dir, slug, svg, suffix=""):
    import os
    d = os.path.join(catalog_dir, f"stretch-{slug}{suffix}.imageset")
    os.makedirs(d, exist_ok=True)
    fn = f"{slug}{suffix}.svg"
    open(os.path.join(d, fn), "w").write(svg)
    open(os.path.join(d, "Contents.json"), "w").write(CONTENTS % fn)
