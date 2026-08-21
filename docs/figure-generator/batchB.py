import sys; sys.path.insert(0,'/private/tmp/claude-501/-Users-colemanahn-Documents-RecompApp/dd8fcea9-c60b-4445-b8eb-1cc9d215fd2d/scratchpad/gen')
from figlib import figure
B = {}
F = 262   # floor

# ---------- SUPINE (lying on back, side view: head left) ----------
B["supine-90-90-exhale-breathing"] = [figure(floor=F, wall=286,
  body=[[(96,244),(190,248)], [(96,244),(128,262),(158,258)]],
  accent=[[(190,248),(194,170),(272,168)]], head=(74,234,15))]

B["legs-up-the-wall"] = [figure(floor=F, wall=286,
  body=[[(96,248),(196,252)], [(96,248),(126,264),(156,260)]],
  accent=[[(196,252),(272,150)]], head=(74,238,15))]

B["supine-spinal-twist"] = [figure(floor=F,
  body=[[(100,250),(196,252)], [(100,244),(140,214)], [(100,256),(140,286)]],
  accent=[[(196,252),(228,206),(276,214)]], head=(78,250,15))]

# Floor angel: arms slide low -> overhead (2 frames)
B["supine-floor-angel"] = [
 figure(body=[[(160,78),(160,190)], [(160,190),(138,252)], [(160,190),(182,252)],
              [(150,110),(120,178)], [(170,110),(200,178)]], head=(160,58,15)),
 figure(body=[[(160,78),(160,190)], [(160,190),(138,252)], [(160,190),(182,252)]],
        accent=[[(150,104),(120,40)], [(170,104),(200,40)]], head=(160,58,15))]

# Foam roller / peanut extension — supine, arched over the roller, arms overhead.
# The roller slides up the spine across the three peanut positions.
def roller(rx):
    return figure(floor=F,
      body=[[(212,248),(190,196),(224,250)],          # knees up, feet down
            [(212,248),(172,222),(136,234)]],          # torso arched over the roller
      circles=[(rx,246,13)],
      accent=[[(136,234),(100,202),(70,214)]],         # arms reaching overhead
      head=(114,232,15))
B["foam-roller-t-spine-extension"] = [roller(196)]
B["peanut-extension-low-ribs-t8-t10"] = [roller(196)]
B["peanut-extension-mid-t6-t8"]       = [roller(172)]
B["peanut-extension-upper-t4-t6"]     = [roller(148)]

B["box-breathing"] = [figure(floor=F,
  body=[[(100,250),(196,252)], [(196,252),(232,206),(266,254)],
        [(100,244),(136,224)], [(100,258),(136,280)]],
  accent=[[(150,238),(150,206)]], head=(78,250,15))]

# ---------- SIDE-LYING ----------
OPEN_A = figure(floor=F,
  body=[[(92,214),(196,216)], [(196,216),(196,162),(244,152)]],
  accent=[[(104,214),(104,150)]], head=(70,214,15))
OPEN_B = figure(floor=F,
  body=[[(92,214),(196,216)], [(196,216),(196,162),(244,152)]],
  accent=[[(104,214),(104,280)]], head=(70,214,15), arc=((110,152),(110,280),64))
B["open-book-side-lying"] = [OPEN_A, OPEN_B]

B["bretzel"] = [figure(floor=F,
  body=[[(96,206),(198,210)], [(198,210),(196,158),(242,150)]],
  accent=[[(198,214),(238,262),(196,286)], [(108,206),(108,150)]], head=(74,206,15))]

B["side-lying-rib-expansion-breathing"] = [figure(floor=F,
  body=[[(96,220),(200,222)], [(200,222),(202,172),(248,164)]],
  accent=[[(100,214),(64,176),(40,182)]], head=(76,224,15))]

# ---------- SEATED 90/90 (side-on, front shin across, back shin behind) ----------
def ninety(front_left=True):
    return figure(floor=F,
      body=[[(180,196),(176,128)], [(180,200),(240,222),(238,262)]],
      accent=[[(176,200),(116,224),(150,262)]] if front_left
             else [[(176,200),(120,246),(160,262)]],
      head=(172,110,15))
B["90-90-hip-switches"] = [ninety(True), ninety(False)]
B["90-90-pail-rail"] = [figure(floor=F,
  body=[[(182,200),(214,232),(238,262)]],
  accent=[[(178,204),(118,228),(152,262)], [(180,196),(150,150)]],
  head=(140,136,15))]

B["cervical-rotation"] = [
 figure(body=[[(160,150),(160,220)], [(128,158),(192,158)]], head=(160,116,17)),
 figure(body=[[(160,150),(160,220)], [(128,158),(192,158)]], head=(186,116,17),
        arc=((150,100),(196,104),40))]

# ---------- PRONE ----------
B["prone-i-y-t-w"] = [
 figure(body=[[(160,76),(160,180)], [(160,180),(146,250)], [(160,180),(174,250)]],
        accent=[[(150,100),(142,36)], [(170,100),(178,36)]], head=(160,58,15)),
 figure(body=[[(160,76),(160,180)], [(160,180),(146,250)], [(160,180),(174,250)]],
        accent=[[(150,104),(88,104)], [(170,104),(232,104)]], head=(160,58,15))]
B["prone-shoulder-extension"] = [figure(floor=F,
  body=[[(108,246),(266,250)]],
  accent=[[(120,240),(176,212),(226,232)]], head=(90,244,15))]

# ---------- STANDING (side view, facing right) ----------
def stand(arms=(), accent=(), head=(160,62,15), legs=None, **kw):
    L = legs or [[(160,150),(148,206),(146,262)], [(160,150),(174,206),(176,262)]]
    return figure(floor=F, body=[[(160,80),(160,152)]] + L + list(arms),
                  accent=list(accent), head=head, **kw)

B["standing-quad-pull-pelvic-tilt"] = [figure(floor=F,
  body=[[(160,80),(160,152)], [(160,152),(150,206),(148,262)], [(160,96),(140,140)]],
  accent=[[(160,152),(186,204),(160,240)], [(160,96),(184,164),(164,232)]],
  head=(160,62,15))]

B["standing-forward-fold-sway"] = [
 figure(floor=F, body=[[(160,152),(150,206),(148,262)], [(160,152),(174,206),(176,262)],
        [(160,152),(206,182)]], accent=[[(206,182),(212,232)]], head=(222,192,15)),
 figure(floor=F, body=[[(160,152),(150,206),(148,262)], [(160,152),(174,206),(176,262)],
        [(160,152),(202,196)]], accent=[[(202,196),(178,240)]], head=(218,208,15),
        arc=((216,230),(190,246),34))]

B["deep-squat-hold-supported-if-needed"] = [figure(floor=F,
  body=[[(160,140),(160,196)], [(160,196),(118,232),(126,262)], [(160,196),(202,232),(194,262)]],
  accent=[[(160,150),(150,196)], [(160,150),(172,196)]], head=(160,116,15))]

B["elevated-hamstring-stretch"] = [figure(floor=F, props=[[(230,196),(292,196)]],
  body=[[(150,80),(150,152)], [(150,152),(146,206),(144,262)]],
  accent=[[(150,152),(224,192)], [(150,96),(190,150)]], head=(150,62,15))]

def wall_calf(bent):
    knee = [(196,206),(206,262)] if bent else [(214,262)]
    return figure(floor=F, wall=286,
      body=[[(150,80),(150,152)], [(150,152),(140,206),(136,262)], [(150,96),(196,120)]],
      accent=[[(150,152)] + knee + [(268,232)]] if not bent
             else [[(150,152),(190,206),(268,236)]],
      head=(150,62,15))
B["wall-calf-straight-knee"] = [wall_calf(False)]
B["wall-calf-bent-knee"]     = [wall_calf(True)]

def doorway(high):
    ey = 96 if high else 118
    return figure(floor=F, wall=250,
      body=[[(150,80),(150,152)], [(150,152),(140,206),(138,262)], [(150,152),(168,206),(170,262)]],
      accent=[[(150,96),(200,ey),(236,ey-22 if high else ey)]], head=(150,62,15))
B["doorway-pec-90-elbow"]  = [doorway(False)]
B["doorway-pec-135-elbow"] = [doorway(True)]

B["doorway-lat-shoulder-hang"] = [figure(floor=F, wall=250,
  body=[[(150,110),(150,166)], [(150,166),(140,212),(138,262)], [(150,166),(168,212),(170,262)]],
  accent=[[(150,110),(198,80),(240,72)]], head=(148,84,15))]

B["wall-bicep-stretch"] = [figure(floor=F, wall=252,
  body=[[(150,80),(150,152)], [(150,152),(140,206),(138,262)], [(150,152),(168,206),(170,262)]],
  accent=[[(150,96),(204,110),(242,116)]], head=(150,62,15))]

B["overhead-tricep-stretch"] = [figure(floor=F,
  body=[[(160,80),(160,152)], [(160,152),(148,206),(146,262)], [(160,152),(174,206),(176,262)]],
  accent=[[(160,92),(186,52),(146,44)], [(160,96),(136,50),(140,42)]], head=(160,66,15))]

B["cross-body-posterior-delt"] = [figure(floor=F,
  body=[[(160,80),(160,152)], [(160,152),(148,206),(146,262)], [(160,152),(174,206),(176,262)]],
  accent=[[(184,96),(120,110)], [(136,96),(150,116),(178,112)]], head=(160,62,15))]

B["upper-trap-levator-scap"] = [figure(
  body=[[(160,152),(160,224)], [(126,160),(194,160)]],
  accent=[[(194,160),(200,120),(172,102)]], head=(154,116,17))]

def forearm(up):
    return figure(floor=F,
      body=[[(160,80),(160,152)], [(160,152),(148,206),(146,262)], [(160,152),(174,206),(176,262)]],
      accent=[[(160,96),(212,130),(228,110 if up else 152)], [(196,150),(224,124 if up else 146)]],
      head=(160,62,15))
B["forearm-flexor-stretch"]   = [forearm(True)]
B["forearm-extensor-stretch"] = [forearm(False)]

# ---------- MOVEMENT DRILLS (2 frames) ----------
def swinger(footA, footB):
    return [figure(floor=F,
      body=[[(160,80),(160,152)], [(160,152),(150,206),(148,262)]],
      accent=[[(160,152)] + f], head=(160,62,15)) for f in (footA, footB)]
B["leg-swings-front-back"] = swinger([(200,196),(232,168)], [(122,200),(96,236)])
B["leg-swings-lateral"]    = swinger([(214,204),(248,226)], [(112,208),(84,232)])
B["hip-cars"] = swinger([(206,190),(236,214)], [(200,226),(226,254)])

B["shoulder-cars"] = [
 figure(floor=F, body=[[(160,80),(160,152)], [(160,152),(148,206),(146,262)],
        [(160,152),(174,206),(176,262)]],
   accent=[[(160,96),(206,120),(232,150)]], head=(160,62,15)),
 figure(floor=F, body=[[(160,80),(160,152)], [(160,152),(148,206),(146,262)],
        [(160,152),(174,206),(176,262)]],
   accent=[[(160,96),(200,60),(216,26)]], head=(160,62,15), arc=((228,146),(220,32),64))]

# Club across shoulders — front view, rotate right then left
def club(dx):
    return figure(floor=F,
      body=[[(160,92),(160,158)], [(160,158),(140,208),(136,262)], [(160,158),(180,208),(184,262)]],
      accent=[[(160-56+dx,88+dx//3),(160+56+dx,96-dx//3)]], head=(160,60,15))
B["standing-club-rotations"] = [club(-26), club(26)]
B["club-across-shoulders-rotations"] = [club(-26), club(26)]

# Golf swing: backswing then follow-through
def swing(back):
    arms = [[(160,96),(120,70),(104,36)]] if back else [[(160,96),(206,64),(228,32)]]
    lean = [(160,92),(164,158)] if back else [(160,92),(156,158)]
    return figure(floor=F, body=[lean, [(164,158),(142,208),(138,262)],
                                 [(164,158),(186,208),(190,262)]],
                  accent=arms, head=(160,62,15))
B["ramped-swings-50-90"] = [swing(True), swing(False)]
B["left-handed-swings"]  = [swing(False), swing(True)]
