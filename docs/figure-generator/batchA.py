import sys; sys.path.insert(0,'/private/tmp/claude-501/-Users-colemanahn-Documents-RecompApp/dd8fcea9-c60b-4445-b8eb-1cc9d215fd2d/scratchpad/gen')
from figlib import figure



A = {}

# Half-kneeling hip flexor + overhead reach — back knee down, front shin vertical
A["half-kneeling-hip-flexor-overhead-reach"] = [figure(
  floor=266,
  body=[[(95,262),(150,262),(175,192)], [(175,192),(245,200),(245,262)],
        [(175,192),(182,112)], [(182,112),(170,148),(178,176)]],
  accent=[[(182,112),(202,80),(212,48)]], head=(187,92,15))]

# Couch stretch — rear foot up a wall, front shin vertical, torso tall
A["couch-stretch"] = [figure(
  floor=266, wall=268,
  body=[[(232,196),(258,232),(262,196)], [(232,196),(170,206),(170,262)],
        [(232,196),(224,118)], [(224,118),(206,152),(212,180)]],
  accent=[[(232,196),(258,232),(262,196)]], head=(220,98,15))]

# Prayer lat stretch — kneeling, forearms on a bench, chest sinking
A["prayer-lat-stretch-kneeling"] = [figure(
  floor=266, props=[[(210,214),(300,214)]],
  body=[[(96,262),(140,258),(150,206)], [(150,206),(216,214)]],
  accent=[[(216,214),(262,212)]], head=(178,196,15))]

# Child's pose — hips to heels, arms long on the floor
A["child-s-pose-wide-knee"] = [figure(
  floor=266,
  body=[[(238,262),(206,238),(212,258)], [(206,238),(150,258)]],
  accent=[[(150,258),(96,262)]], head=(132,244,15),
  )]
A["puppy-pose"] = [figure(   # hips stay high over knees, chest melts down
  floor=266,
  body=[[(240,262),(232,204),(178,222)], [(178,222),(140,254)]],
  accent=[[(140,254),(88,258)]], head=(160,236,14))]

# Bench sink — kneeling, elbows on bench, armpits opening
A["bench-sink-lat-t-spine"] = [figure(
  floor=266, props=[[(206,200),(300,200)]],
  body=[[(100,262),(146,258),(158,212)], [(158,212),(214,200)]],
  accent=[[(214,200),(268,198)]], head=(186,214,14))]

# Heel-sit reach-back — sit on heels, elbow drives to ceiling (2 frames)
A["heel-sit-reach-back"] = [
 figure(floor=266,
   body=[[(236,262),(202,240),(206,258)], [(202,240),(152,252)]],
   accent=[[(152,252),(126,222),(150,206)]], head=(136,236,14)),
 figure(floor=266,
   body=[[(236,262),(202,240),(206,258)], [(202,240),(152,252)]],
   accent=[[(152,252),(146,196),(176,168)]], head=(136,236,14))]

# Cat-cow — quadruped flexion then extension (2 frames)
QUAD_ARMS = [(120,168),(120,258)]
QUAD_LEGS = [(226,168),(226,258)]
A["cat-cow-extended-hold"] = [
 figure(floor=266, body=[QUAD_ARMS, QUAD_LEGS],
   accent=[[(120,168),(150,140),(196,140),(226,168)]], head=(104,182,14)),
 figure(floor=266, body=[QUAD_ARMS, QUAD_LEGS],
   accent=[[(120,168),(154,192),(194,192),(226,168)]], head=(104,152,14))]

# Thread the needle — quadruped, one arm threads under the body (2 frames)
A["thread-the-needle"] = [
 figure(floor=266, body=[QUAD_LEGS, [(120,168),(150,150),(196,146),(226,168)]],
   accent=[[(120,168),(120,258)]], head=(104,182,14)),
 figure(floor=266, body=[QUAD_LEGS, [(120,168),(150,150),(196,146),(226,168)]],
   halo=[[(120,178),(150,236),(206,246)]],
   accent=[[(120,178),(150,236),(206,246)]], head=(102,196,14))]

# Adductor rock-back — one leg straight out to the side, hips rock back (2 frames)
A["adductor-rock-back"] = [
 figure(floor=266, body=[[(120,168),(120,258)], [(120,168),(206,172)], [(206,172),(206,258)]],
   accent=[[(206,172),(268,196),(292,254)]], head=(104,180,15)),
 figure(floor=266, body=[[(126,196),(140,258)], [(126,196),(214,200)], [(214,200),(226,258)]],
   accent=[[(214,200),(276,214),(298,256)]], head=(110,208,15))]

# Frog stretch — knees wide, shins out, rock back
A["frog-stretch"] = [figure(
  floor=266, body=[[(122,176),(122,252)], [(196,176),(196,252)],
        [(122,176),(196,176)]],
  accent=[[(196,176),(250,206),(272,252)], [(122,176),(96,206),(84,252)]],
  head=(106,190,14))]

# Pigeon pose — front shin across, back leg long behind
A["pigeon-pose"] = [figure(
  floor=266, body=[[(184,214),(262,254),(292,258)], [(184,214),(150,190)]],
  accent=[[(184,214),(128,238),(96,232)]], head=(136,172,14))]

# World's greatest stretch / walking spiderman — deep lunge, elbow down, top arm up
WGS = figure(floor=266,
  body=[[(238,262),(196,224),(160,196)], [(160,196),(120,232),(120,262)],
        [(160,196),(128,214),(122,240)]],
  accent=[[(160,196),(182,160),(196,124)]], head=(150,176,14))
A["world-s-greatest-stretch"] = [WGS]
A["walking-spiderman-reach"] = [WGS]
