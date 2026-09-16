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
