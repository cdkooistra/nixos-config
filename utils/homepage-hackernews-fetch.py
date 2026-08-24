import json
import os
import tempfile
import urllib.request

LIMIT = int(os.environ.get("HACKERNEWS_LIMIT", "15"))
BASE_URL = "https://hacker-news.firebaseio.com/v0"
OUT_DIR = os.environ.get("STATE_DIRECTORY", "/var/lib/homepage-hackernews")
OUT_FILE = os.path.join(OUT_DIR, "feed.json")


def fetch(url):
    with urllib.request.urlopen(url, timeout=10) as response:
        return json.load(response)


def discussion_url(item_id):
    return f"https://news.ycombinator.com/item?id={item_id}"


def main():
    os.makedirs(OUT_DIR, exist_ok=True)

    # /v0/topstories.json: real-time ranked list of top story item IDs
    story_ids = fetch(f"{BASE_URL}/topstories.json")[:LIMIT]

    stories = []
    for story_id in story_ids:
        try:
            # /v0/item/<id>.json: full item details (title, url, score, kids, ...)
            item = fetch(f"{BASE_URL}/item/{story_id}.json")
        except OSError:
            continue

        if not item or not item.get("title"):
            continue

        stories.append(
            {
                "title": item["title"],
                "id": item["id"],
                "score": item.get("score", 0),
                "descendants": item.get("descendants", 0),
                "time": item.get("time"),
                "targetUrl": item.get("url", discussion_url(item["id"])),
                "discussionUrl": discussion_url(item["id"]),
            }
        )

    fd, tmp_path = tempfile.mkstemp(dir=OUT_DIR)
    with os.fdopen(fd, "w") as f:
        json.dump(stories, f)

    os.replace(tmp_path, OUT_FILE)


if __name__ == "__main__":
    main()
