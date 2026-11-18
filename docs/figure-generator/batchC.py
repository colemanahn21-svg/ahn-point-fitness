# Flow-routine figures: movements that combine or extend earlier ones.
import sys, os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from figlib import figure
from batchB import roller, doorway, club, ninety, OPEN_A, F
from batchA import QUAD_LEGS
C = {}

# Peanut climbs from low ribs to upper back within one position.
C["peanut-climb-t10-t4"] = [roller(196), roller(148)]

# Open book, but the top arm sweeps overhead in an arc instead of parking.
C["open-book-arm-circle"] = [
 OPEN_A,
 figure(floor=F,
   body=[[(92,214),(196,216)], [(196,216),(196,162),(244,152)]],
   accent=[[(104,214),(66,178),(36,200)]], head=(70,214,15),
   arc=((110,150),(40,196),52))]

# Shin box: switch, then turn the chest over the front shin.
C["90-90-switch-turn"] = [
 ninety(True),
 figure(floor=F,
   body=[[(180,200),(240,222),(238,262)], [(180,196),(148,140)]],
   accent=[[(176,200),(116,224),(150,262)], [(150,150),(108,172)]],
   head=(138,124,15))]

# Thread under, then open to the ceiling — one continuous arc.
C["thread-open"] = [
 figure(floor=F, body=[QUAD_LEGS, [(120,168),(150,150),(196,146),(226,168)]],
   halo=[[(120,178),(150,236),(206,246)]],
   accent=[[(120,178),(150,236),(206,246)]], head=(102,196,14)),
 figure(floor=F, body=[QUAD_LEGS, [(120,168),(150,150),(196,146),(226,168)], [(120,168),(120,258)]],
   accent=[[(122,160),(140,116),(152,76)]], head=(104,176,14),
   arc=((200,240),(150,80),80))]

# Couch sink, then hands walked to one side with the ribcage turning.
C["couch-sink-rotation"] = [
 figure(floor=F, props=[[(206,200),(300,200)]],
   body=[[(100,262),(146,258),(158,212)], [(158,212),(214,200)]],
   accent=[[(214,200),(268,198)]], head=(186,214,14)),
 figure(floor=F, props=[[(206,200),(300,200)]],
   body=[[(100,262),(146,258),(158,212)], [(158,212),(214,200)]],
   accent=[[(214,200),(250,170),(282,150)]], head=(184,208,14))]

# Half-kneeling club turn, then the same turn standing.
C["kneeling-standing-club-turns"] = [
 figure(floor=F,
   body=[[(95,262),(150,262),(175,192)], [(175,192),(245,200),(245,262)], [(175,192),(182,112)]],
   accent=[[(136,104),(232,122)]], head=(187,92,15)),
 club(26)]

# Doorway pec at both heights in one step.
C["doorway-pec-90-then-135"] = [doorway(False), doorway(True)]

# Child's pose with the hands walked to each side.
C["child-s-pose-reach-each-side"] = [
 figure(floor=F, body=[[(238,262),(206,238),(212,258)], [(206,238),(150,258)]],
   accent=[[(150,258),(96,240),(70,224)]], head=(132,244,15)),
 figure(floor=F, body=[[(238,262),(206,238),(212,258)], [(206,238),(150,258)]],
   accent=[[(150,258),(100,270),(72,284)]], head=(132,244,15))]

# ---------- WORK (desk + after-work) ----------
# Office chair, side view facing right: seat, back, one leg.
def chair(x=118, seat=200, top=146):
    return [[(x, seat), (x+78, seat)], [(x+2, seat), (x, top)], [(x+40, seat), (x+40, F)]]

# Seated, arching the upper back over the top edge of the chair.
C["chair-back-extension"] = [
 figure(floor=F, props=chair(),
   body=[[(140,194),(204,192),(208,262)], [(140,194),(134,148)]],
   accent=[[(134,148),(108,118)], [(114,124),(128,90),(100,96)]],
   head=(96,104,15))]

# Seated side view: hands on the thighs, then turned — near hand back to the
# chair, far hand across to the front knee.
def seated_turn(turned):
    legs = [[(140,194),(204,192),(208,262)], [(140,194),(144,120)]]
    if not turned:
        return figure(floor=F, props=chair(), body=legs + [[(144,130),(166,166),(190,186)]],
                      head=(146,100,15))
    return figure(floor=F, props=chair(), body=legs,
                  accent=[[(144,128),(128,146),(122,156)], [(146,128),(178,150),(202,184)]],
                  head=(148,100,15), arc=((178,110),(118,118),44))
C["seated-thoracic-turn"] = [seated_turn(False), seated_turn(True)]

# Standing at the desk: palms flat fingers back, then backs of the hands down.
def desk_wrist(flip):
    hand = [(214,166),(206,180),(190,182)] if flip else [(214,180),(190,180)]
    return figure(floor=F, props=[[(184,184),(300,184)], [(292,184),(292,F)]],
      body=[[(150,80),(146,152)], [(146,152),(140,206),(138,262)], [(146,152),(162,206),(164,262)]],
      accent=[[(150,98),(186,136),(214,176)], hand], head=(152,62,15))
C["desk-wrist-flexor-extensor"] = [desk_wrist(False), desk_wrist(True)]

# Short split stance beside the desk: the stretch comes from the pelvic tuck,
# not from stance length, so it fits in a cramped spot.
C["short-stance-hip-flexor-reach"] = [figure(floor=F,
   props=[[(214,170),(300,170)], [(292,170),(292,F)]],
   body=[[(160,84),(160,152)], [(160,152),(180,206),(184,262)], [(160,100),(190,138),(216,166)]],
   accent=[[(160,152),(140,206),(122,256)], [(160,98),(150,52),(136,18)]],
   head=(162,64,15))]

# Seated at the desk, forearms on the edge, chest sinking between the arms.
C["seated-desk-sink"] = [figure(floor=F,
   props=chair() + [[(222,150),(300,150)], [(292,150),(292,F)]],
   body=[[(140,194),(198,194),(202,262)]],
   accent=[[(140,194),(190,154)], [(190,152),(238,144)]],
   head=(198,172,13))]

# Perched on the front edge of the seat, one leg straight with the heel down,
# hinging forward over it with a flat back.
C["seat-edge-hamstring-hinge"] = [figure(floor=F, props=chair(),
   body=[[(176,196),(214,198),(212,262)]],
   accent=[[(176,196),(268,254),(278,242)], [(176,196),(234,152)], [(228,156),(252,214)]],
   head=(250,138,15))]
