# FlipBook UI

A realistic page-flipping book UI for the web. Single HTML file, zero dependencies.

<p align="center">
  <img src="./assets/demo.gif" alt="FlipBook UI Demo" width="700">
</p>

## Features

- **Drag to flip** - Mouse drag with real-time page following. Stop mid-flip, release to complete or snap back
- **Page flip sound** - Synthesized paper sounds using Web Audio API (no audio files needed)
- **3D perspective** - CSS 3D transforms with realistic spine shadow and page curl
- **Responsive** - Keyboard (arrow keys, space) and button navigation also supported
- **Touch support** - Works on mobile with touch drag
- **Zero dependencies** - Single HTML file, no build step, no libraries

## Quick Start

```bash
# Just open it
open index.html

# Or serve it
npx serve .
```

## Usage

### Basic

Drop `index.html` into your project and open it in a browser. That's it.

### Customize Content

Edit the `pages` array in the `<script>` section:

```javascript
const pages = [
  {
    front: `<div class="page-title">My Title</div>
            <div class="page-body"><p>Front side content</p></div>`,
    back:  `<div class="page-body"><p>Back side content</p></div>`,
    leftContent: `<div class="page-body"><p>Shown on left when this page is flipped</p></div>`
  },
  // ... more pages
];
```

### Available CSS Classes

| Class | Usage |
|-------|-------|
| `.page-title` | Large heading |
| `.page-body` | Body text container |
| `.chapter-label` | Small chapter indicator |
| `.page-number` | Page number |
| `.divider` | Decorative divider |
| `.quote` | Blockquote with left border |
| `.code-block` | Dark code snippet block |
| `.tip-box` | Highlighted tip/info box |
| `.comparison` | Side-by-side comparison grid |
| `.cover-front` | Book cover styling |
| `.dropcap` | First letter drop cap (add to `<p>`) |

### Interaction

| Action | Effect |
|--------|--------|
| Drag right page left | Flip to next page |
| Drag left page right | Flip to previous page |
| Release past 50° | Complete the flip |
| Release before 50° | Snap back |
| Arrow keys / Space | Navigate pages |
| Buttons | Navigate pages |

## Customization

### Colors

The default theme uses warm book tones. Override the CSS variables:

```css
/* Cover */
.cover-front { background: linear-gradient(145deg, #1a1520, #2a1f30); }

/* Pages */
.page .front { background: linear-gradient(135deg, #fefcf7, #f5f0e8); }

/* Accent color */
.chapter-label { color: #D97B2F; }
```

### Sound

Adjust volume in `playFlipSound()` and `playSoftRustle()`:

```javascript
// Main flip sound volume
g1.gain.setValueAtTime(0.4, ...);  // 0.0 - 1.0

// Rustle during drag
g.gain.value = 0.3;  // 0.0 - 1.0
```

Set to `0` to disable sounds.

## Browser Support

Chrome, Firefox, Safari, Edge (all modern versions). Requires CSS 3D transforms and Web Audio API.

## License

MIT
