# Regenerate the cue table in StretchCues.swift from cues.py.
# Only the dictionary body is rewritten; the header comment and lookup
# function are left as they are. Run after editing cues.py.
import sys, os, json
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import cues

PATH = os.path.join(HERE, "..", "..", "AhnPointFitness", "Resources", "StretchCues.swift")
OPEN = "    static let bySlug: [String: [String]] = [\n"
CLOSE = "    ]\n\n    static func cues"

src = open(PATH).read()
head = src[:src.index(OPEN) + len(OPEN)]
tail = src[src.index(CLOSE):]
body = "".join(
    f'        "{slug}": [{", ".join(json.dumps(c, ensure_ascii=False) for c in lines)}],\n'
    for slug, lines in sorted(cues.C.items()))
open(PATH, "w").write(head + body + tail)
print("cue entries:", len(cues.C))
