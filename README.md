# FlipBook UI

Turn your daily Claude Code sessions into a beautiful, page-flipping book you can browse in your browser.

<p align="center">
  <img src="./assets/demo.gif" alt="FlipBook UI Demo" width="700">
</p>

## What is this?

A Claude Code skill that automatically reads your session logs and generates a physical-feeling book with:

- **Drag to flip pages** — grab and pull with your mouse, stop mid-flip
- **Paper sound effects** — synthesized with Web Audio API, no audio files
- **3D perspective** — CSS transforms with spine shadow and page curl
- **Touch support** — works on mobile too

Zero dependencies. Single HTML file output. No build step.

## Quick Start

### 1. Install the skill

```bash
cp -r skill/ ~/.claude/skills/daily-flipbook/
```

### 2. Run it in Claude Code

```
/daily-flipbook
```

Or just say: **「今日の振り返り本を作って」**

### 3. Open the book

The skill generates an HTML file and opens it in your browser. That's it.

## How It Works

```
Session Logs (JSONL)
  ↓  extract user messages + tool usage
Structured Summary
  ↓  generate chapters from sessions
template.html + pages data
  ↓  merge
/tmp/claude/daily-flipbook/YYYY-MM-DD.html
  ↓
Open in browser 📖
```

The skill reads from both Claude Code log paths:
- `~/.claude/projects/` (default)
- `~/claude-data/projects/` (when `CLAUDE_CONFIG_DIR` is set)

## Standalone Usage

Don't use Claude Code? You can use the HTML template directly:

```bash
# Just open the demo
open index.html
```

Edit the `pages` array in `<script>` to customize content:

```javascript
const pages = [
  {
    front: `<div class="page-title">Chapter Title</div>
            <div class="page-body"><p>Content here</p></div>`,
    back:  `<div class="page-body"><p>Back of page</p></div>`,
    leftContent: `<p>Shown on left page</p>`
  },
];
```

## Available CSS Classes

| Class | Usage |
|-------|-------|
| `.page-title` | Large heading |
| `.chapter-label` | Small chapter indicator (e.g., "第一章") |
| `.page-body` | Body text |
| `.code-block` | Dark code block (`.comment` `.keyword` `.string` `.property`) |
| `.quote` | Blockquote with accent border |
| `.tip-box` | Info box (`.tip-title` + `<ul>`) |
| `.comparison` | 2-column compare (`.col.good` / `.col.bad`) |
| `.divider` | Decorative separator |
| `.dropcap` | Drop cap first letter |
| `.cover-front` | Book cover styling |

## Controls

| Action | Effect |
|--------|--------|
| Drag right half ← | Next page |
| Drag left half → | Previous page |
| Release past 50° | Complete flip |
| Release before 50° | Snap back |
| `←` `→` `Space` | Keyboard nav |

## Customization

### Theme

```css
/* Cover */
.cover-front { background: linear-gradient(145deg, #1a1520, #2a1f30); }
/* Accent */
.chapter-label { color: #D97B2F; }
/* Pages */
.page .front { background: linear-gradient(135deg, #fefcf7, #f5f0e8); }
```

### Sound Volume

```javascript
// In playFlipSound(): main flip
g1.gain.setValueAtTime(0.4, ...);  // 0 to disable

// In playSoftRustle(): drag rustle
g.gain.value = 0.3;
```

## Project Structure

```
flipbook-ui/
├── index.html          # Standalone demo (works without Claude Code)
├── skill/
│   ├── SKILL.md        # Claude Code skill definition
│   ├── template.html   # HTML template with {{BOOK_TITLE}} / {{PAGES_DATA}} placeholders
│   └── generate.sh     # Session log collector script
├── LICENSE             # MIT
└── README.md
```

## Browser Support

Chrome, Firefox, Safari, Edge. Requires CSS 3D Transforms + Web Audio API.

## License

MIT
