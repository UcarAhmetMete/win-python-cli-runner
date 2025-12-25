import argparse
from pathlib import Path
import json

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--name", default="ASML")
    p.add_argument("--out", default="out")
    args = p.parse_args()

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)

    payload = {"message": f"Hello {args.name}", "status": "ok"}
    (out / "result.json").write_text(json.dumps(payload, indent=2), encoding="utf-8")
    print("Wrote out/result.json")

if __name__ == "__main__":
    main()
