import sys, os, shutil
sys.path.insert(0,'/private/tmp/claude-501/-Users-colemanahn-Documents-RecompApp/dd8fcea9-c60b-4445-b8eb-1cc9d215fd2d/scratchpad/gen')
from figlib import emit
import batchA, batchB

CAT = "/Users/colemanahn/Documents/RecompApp/AhnPointFitness/Assets.xcassets/Stretch"
if os.path.isdir(CAT): shutil.rmtree(CAT)
os.makedirs(CAT)
open(os.path.join(CAT, "Contents.json"), "w").write(
    '{\n  "info" : { "author" : "xcode", "version" : 1 }\n}\n')

FIG = {}; FIG.update(batchA.A); FIG.update(batchB.B)

# Same movement, different names across days — draw once, share the artwork.
ALIASES = {
 "child-s-pose-wide-knee": ["child-s-pose-wide-knee-reach-far", "child-s-pose-box-breathing"],
 "open-book-side-lying":   ["open-book-pelvis-pinned"],
 "foam-roller-t-spine-extension": ["foam-roller-thoracic-extension", "roller-extension-full-exhale"],
 "90-90-hip-switches":     ["90-90-hip-switch-hold", "90-90-hip-transitions"],
 "doorway-pec-90-elbow":   ["doorway-pec-stretch-90-elbow"],
 "doorway-pec-135-elbow":  ["doorway-pec-stretch-135-elbow"],
 "upper-trap-levator-scap":["upper-trap-levator-scap-release"],
}

n_sets = n_files = 0
for slug, frames in FIG.items():
    for name in [slug] + ALIASES.get(slug, []):
        emit(CAT, name, frames[0]); n_sets += 1; n_files += 1
        if len(frames) > 1:
            emit(CAT, name, frames[1], suffix="-end"); n_sets += 1; n_files += 1
print("imagesets:", n_sets)
