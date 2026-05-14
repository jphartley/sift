// Shared components & tokens for both Sift directions

// ─────────────────────────────────────────────────────────────
// Palettes
// ─────────────────────────────────────────────────────────────
const PALETTES = {
  paper: {
    name: 'Warm paper',
    bg: '#f3ede2',          // warm cream
    surface: '#fbf6ec',     // surface card
    surfaceAlt: '#f7f0e2',  // sunken
    ink: '#2a2520',         // warm near-black
    muted: '#7a6e5e',       // body muted
    quiet: '#a89c8a',       // tertiary
    line: 'rgba(42,37,32,0.08)',
    accent: '#8a6f4d',      // clay
    accentSoft: '#d8c6a8',
    accentInk: '#5a432a',
    helpful: '#6f8a6c',     // soft sage
    danger: '#a76154',
    tabIcon: '#8c7e6c',
    statusDark: false,
  },
  mist: {
    name: 'Misty blue',
    bg: '#eaeef3',
    surface: '#f5f8fb',
    surfaceAlt: '#e3e9ef',
    ink: '#1f2a35',
    muted: '#6a7785',
    quiet: '#a4b0bd',
    line: 'rgba(31,42,53,0.08)',
    accent: '#6b8aa6',
    accentSoft: '#c4d3df',
    accentInk: '#3e5871',
    helpful: '#7ba18a',
    danger: '#b07d7a',
    tabIcon: '#8696a5',
    statusDark: false,
  },
  sage: {
    name: 'Soft sage',
    bg: '#eaeee5',
    surface: '#f4f6ef',
    surfaceAlt: '#dfe5d7',
    ink: '#26302a',
    muted: '#6e7a6e',
    quiet: '#a3ad9f',
    line: 'rgba(38,48,42,0.08)',
    accent: '#7a9272',
    accentSoft: '#cbd6bf',
    accentInk: '#46583f',
    helpful: '#7a9272',
    danger: '#a76e54',
    tabIcon: '#8a9686',
    statusDark: false,
  },
  dawn: {
    name: 'Dawn',
    bg: '#f4ece6',
    surface: '#fbf3ed',
    surfaceAlt: '#efe2d8',
    ink: '#33252a',
    muted: '#7e6d70',
    quiet: '#b09e9f',
    line: 'rgba(51,37,42,0.08)',
    accent: '#c08672',
    accentSoft: '#ecd2c3',
    accentInk: '#7a4a3a',
    helpful: '#8a9a78',
    danger: '#b76858',
    tabIcon: '#a68f8d',
    statusDark: false,
  },
  apricot: {
    name: 'Apricot',
    bg: '#fbe8d3',
    surface: '#fff3e0',
    surfaceAlt: '#f5d9b6',
    ink: '#3a1f10',
    muted: '#8a5a3a',
    quiet: '#b78a66',
    line: 'rgba(58,31,16,0.10)',
    accent: '#e07a3c',
    accentSoft: '#fbcfa6',
    accentInk: '#7a3a14',
    helpful: '#7a9a3a',
    danger: '#c64a2c',
    tabIcon: '#a8755a',
    statusDark: false,
  },
  lilac: {
    name: 'Lilac',
    bg: '#ece6f4',
    surface: '#f6f0fb',
    surfaceAlt: '#dfd5ec',
    ink: '#2a1f3a',
    muted: '#6e5e88',
    quiet: '#a89cc0',
    line: 'rgba(42,31,58,0.08)',
    accent: '#7a5ec8',
    accentSoft: '#cdbcec',
    accentInk: '#3e2a72',
    helpful: '#6f8aa8',
    danger: '#a85e7a',
    tabIcon: '#9a8ab0',
    statusDark: false,
  },
  citrus: {
    name: 'Citrus',
    bg: '#f4f0d8',
    surface: '#fbf8e4',
    surfaceAlt: '#e6e2c0',
    ink: '#2c2a14',
    muted: '#6a6a3a',
    quiet: '#a4a474',
    line: 'rgba(44,42,20,0.08)',
    accent: '#9aa83c',
    accentSoft: '#d8de8e',
    accentInk: '#525a18',
    helpful: '#7a8a3a',
    danger: '#b86c3a',
    tabIcon: '#9a9a6a',
    statusDark: false,
  },
  ocean: {
    name: 'Ocean',
    bg: '#dbe8e6',
    surface: '#ecf3f1',
    surfaceAlt: '#c6d8d4',
    ink: '#0e2a2a',
    muted: '#4a6e6c',
    quiet: '#88a6a3',
    line: 'rgba(14,42,42,0.10)',
    accent: '#1f7a76',
    accentSoft: '#a8d2cd',
    accentInk: '#0a4a48',
    helpful: '#3a8a6e',
    danger: '#b06a52',
    tabIcon: '#7a9a96',
    statusDark: false,
  },
  rose: {
    name: 'Rose',
    bg: '#f4dde2',
    surface: '#fbecef',
    surfaceAlt: '#ecc6cf',
    ink: '#3a1822',
    muted: '#8a4a5e',
    quiet: '#bc8a96',
    line: 'rgba(58,24,34,0.10)',
    accent: '#c4566e',
    accentSoft: '#f0bcc8',
    accentInk: '#7a2c40',
    helpful: '#8a8a4a',
    danger: '#a83a3a',
    tabIcon: '#a8788a',
    statusDark: false,
  },
  plum: {
    name: 'Plum',
    bg: '#e8d8df',
    surface: '#f3e8ee',
    surfaceAlt: '#d4bcc8',
    ink: '#2a0e22',
    muted: '#6a4a5e',
    quiet: '#a48896',
    line: 'rgba(42,14,34,0.10)',
    accent: '#7a2a52',
    accentSoft: '#d8a8be',
    accentInk: '#4a0e2c',
    helpful: '#6a8a6a',
    danger: '#a83a4a',
    tabIcon: '#947684',
    statusDark: false,
  },
  forest: {
    name: 'Forest',
    bg: '#dde4d6',
    surface: '#eef2e8',
    surfaceAlt: '#c4d0b8',
    ink: '#162410',
    muted: '#4e6a3e',
    quiet: '#8a9a7a',
    line: 'rgba(22,36,16,0.10)',
    accent: '#3e6a2a',
    accentSoft: '#b8d0a4',
    accentInk: '#234414',
    helpful: '#6a8a3a',
    danger: '#a8521e',
    tabIcon: '#7a8a6a',
    statusDark: false,
  },
  ember: {
    name: 'Ember',
    bg: '#f4dcd0',
    surface: '#fbeae0',
    surfaceAlt: '#ecbfaa',
    ink: '#2c1410',
    muted: '#7a4234',
    quiet: '#b08070',
    line: 'rgba(44,20,16,0.10)',
    accent: '#c4432a',
    accentSoft: '#f4b298',
    accentInk: '#7a2010',
    helpful: '#7a8a3e',
    danger: '#a83822',
    tabIcon: '#a8786a',
    statusDark: false,
  },
  midnight: {
    name: 'Midnight',
    bg: '#dde0eb',
    surface: '#ecedf3',
    surfaceAlt: '#c8ccdd',
    ink: '#0e1430',
    muted: '#4a527a',
    quiet: '#8a90b0',
    line: 'rgba(14,20,48,0.10)',
    accent: '#3a4ab0',
    accentSoft: '#bcc4ec',
    accentInk: '#1a2270',
    helpful: '#5a7a9a',
    danger: '#a85674',
    tabIcon: '#7a82a4',
    statusDark: false,
  },
  honey: {
    name: 'Honey',
    bg: '#f4e8c8',
    surface: '#fbf2dc',
    surfaceAlt: '#e8d49c',
    ink: '#2c2010',
    muted: '#7a5e2a',
    quiet: '#b89c64',
    line: 'rgba(44,32,16,0.10)',
    accent: '#b8842a',
    accentSoft: '#ecd496',
    accentInk: '#6a4a14',
    helpful: '#7a8a3a',
    danger: '#b8523a',
    tabIcon: '#a89466',
    statusDark: false,
  },
};

// ─────────────────────────────────────────────────────────────
// Soft hand-style icons (simple strokes only)
// Each is 28x28 inside a soft circle backdrop in cards
// ─────────────────────────────────────────────────────────────
// All 14 categories from practices.yaml. Hand-style strokes, 28x28.
// Aliases preserved so any old kind="Reflection|Connection|Rest" still resolves.
function CategoryIcon({ kind, color = '#5a432a', size = 28 }) {
  const sw = 1.4;
  const s = { stroke: color, strokeWidth: sw, fill: 'none',
    strokeLinecap: 'round', strokeLinejoin: 'round' };
  const dot = { fill: color, stroke: 'none' };

  const paths = {
    // Concentric breath
    Breathwork: (
      <g {...s}>
        <circle cx="14" cy="14" r="9.5"/>
        <circle cx="14" cy="14" r="5.5"/>
        <circle cx="14" cy="14" r="1.6" {...dot}/>
      </g>
    ),
    // Seated figure, more clearly anchored — head, folded body, base line
    Meditation: (
      <g {...s}>
        <circle cx="14" cy="7.5" r="2.4"/>
        <path d="M6 22c2-5 5-7 8-7s6 2 8 7"/>
        <path d="M5 22h18"/>
      </g>
    ),
    // Sprout rooted in ground — earth + roots + shoot
    Grounding: (
      <g {...s}>
        <path d="M14 5v9"/>
        <path d="M14 9c-2-1.5-3.5-1.5-5-1M14 9c2-1.5 3.5-1.5 5-1"/>
        <path d="M3 16h22"/>
        <path d="M7 20c1.5-1 2.5-1 4 0M13 20c1.5-1 2.5-1 4 0M19 23c1-.7 1.7-.7 3 0"/>
      </g>
    ),
    // Striding figure (walker), clearly readable
    Movement: (
      <g {...s}>
        <circle cx="15" cy="5.5" r="2"/>
        <path d="M15 8l-2 6 4 1 1 5"/>
        <path d="M13 14l-4 5"/>
        <path d="M17 9l4 2"/>
      </g>
    ),
    // Open journal with a pen line
    Journaling: (
      <g {...s}>
        <path d="M5 7v15M23 7v15"/>
        <path d="M5 7c3-1.5 6-1.5 9 0 3-1.5 6-1.5 9 0"/>
        <path d="M5 22c3-1.5 6-1.5 9 0 3-1.5 6-1.5 9 0"/>
        <path d="M14 7v15"/>
        <path d="M17 13l4-3" strokeWidth="1.6"/>
      </g>
    ),
    // Heart with a soft inner ripple — feeling moving through
    'Emotional Processing': (
      <g {...s}>
        <path d="M14 22c-6-4-9-7-9-11a4 4 0 0 1 7-2.5A4 4 0 0 1 23 11c0 4-3 7-9 11z"/>
        <path d="M9 12c1.5 1 3.5 1 5 0s3.5-1 5 0" strokeOpacity="0.55"/>
      </g>
    ),
    // Two figures with hands meeting
    'Social Connection': (
      <g {...s}>
        <circle cx="9" cy="8" r="2.2"/>
        <circle cx="19" cy="8" r="2.2"/>
        <path d="M4 22c0-4 2-6 5-6"/>
        <path d="M24 22c0-4-2-6-5-6"/>
        <path d="M11 16c1 .5 2 .5 3 0M14 16c1 .5 2 .5 3 0"/>
      </g>
    ),
    // Single leaf with a soft midrib
    Nature: (
      <g {...s}>
        <path d="M22 6c-9 0-15 5-15 11 0 3 1.5 5 3.5 5C18 22 22 16 22 6z"/>
        <path d="M22 6L9 19"/>
      </g>
    ),
    // Brush stroke with a spark (creative mark)
    'Creative Expression': (
      <g {...s}>
        <path d="M5 22c3-1 5-3 7-6s3-6 4-9"/>
        <path d="M5 22c2-.4 3.5-1 5-2.5"/>
        <path d="M19 6l1.6-1.6M22 9h2.2M21 12l1.6 1" strokeWidth="1.2"/>
      </g>
    ),
    // Mug with steam — small, ordinary care
    'Practical Care': (
      <g {...s}>
        <path d="M6 12h13v8a3 3 0 0 1-3 3H9a3 3 0 0 1-3-3z"/>
        <path d="M19 14h2a2.5 2.5 0 0 1 0 5h-2"/>
        <path d="M10 8c0-1 1-1.5 1-3M14 8c0-1 1-1.5 1-3"/>
      </g>
    ),
    // Crescent moon — clean and obvious
    'Sleep & Wind-Down': (
      <g {...s}>
        <path d="M21 16a8.5 8.5 0 1 1-9.5-12 7 7 0 0 0 9.5 12z"/>
        <path d="M19 6l.6.6M22 8l.8 0M20 10l.6-.4" strokeWidth="1.1"/>
      </g>
    ),
    // Hand cradling a heart
    'Self-Compassion': (
      <g {...s}>
        <path d="M14 14c-3-2-5-3.5-5-6a2.6 2.6 0 0 1 5-1 2.6 2.6 0 0 1 5 1c0 2.5-2 4-5 6z"/>
        <path d="M5 17c1.5-1 3-1.2 5 0l4 2c2 .8 4-.4 6-2"/>
        <path d="M5 17v5"/>
      </g>
    ),
    // Compass arrow — direction & intention
    'Values & Intention': (
      <g {...s}>
        <circle cx="14" cy="14" r="9.5"/>
        <path d="M14 5.5l3 8.5-3 3-3-3z" strokeLinejoin="round"/>
        <path d="M14 14l-3 8.5 3-3 3 3z" strokeOpacity="0.5"/>
      </g>
    ),
    // Candle / single flame
    'Spiritual / Contemplative': (
      <g {...s}>
        <path d="M14 4c-3 3-4.5 5.5-4.5 8a4.5 4.5 0 0 0 9 0c0-2.5-1.5-5-4.5-8z"/>
        <path d="M9 19h10"/>
        <path d="M11 22h6"/>
      </g>
    ),

    // Aliases for legacy callers
    Reflection: null,    // → Journaling
    Connection: null,    // → Social Connection
    Rest: null,          // → Sleep & Wind-Down

    Default: (
      <g {...s}><circle cx="14" cy="14" r="8"/></g>
    ),
  };

  const aliases = {
    Reflection: 'Journaling',
    Connection: 'Social Connection',
    Rest: 'Sleep & Wind-Down',
  };
  const resolved = aliases[kind] || kind;

  return (
    <svg width={size} height={size} viewBox="0 0 28 28" aria-hidden="true">
      {paths[resolved] || paths.Default}
    </svg>
  );
}

// ─────────────────────────────────────────────────────────────
// Soft waveform ribbon
// ─────────────────────────────────────────────────────────────
function WaveformRibbon({ color, width = 280, height = 110, amplitude = 1, animated = true, seed = 0 }) {
  // Generates a few stacked sine ribbons that breathe
  const id = React.useId();
  const layers = [
    { phase: 0,    a: 22 * amplitude, op: 0.95, w: 2.2 },
    { phase: 1.6,  a: 16 * amplitude, op: 0.55, w: 1.8 },
    { phase: 3.1,  a: 11 * amplitude, op: 0.30, w: 1.4 },
  ];
  const path = (phase, a) => {
    const pts = [];
    const N = 60;
    for (let i = 0; i <= N; i++) {
      const x = (i / N) * width;
      const t = (i / N) * Math.PI * 2.4;
      const y = height/2 + Math.sin(t + phase + seed) * a * (1 - Math.abs((i/N)*2-1)*0.6);
      pts.push(`${x.toFixed(1)},${y.toFixed(1)}`);
    }
    return 'M' + pts.join(' L');
  };
  return (
    <svg width={width} height={height} viewBox={`0 0 ${width} ${height}`} style={{ display: 'block' }}>
      {layers.map((l, i) => (
        <path key={i} d={path(l.phase, l.a)} fill="none" stroke={color}
              strokeOpacity={l.op} strokeWidth={l.w} strokeLinecap="round">
          {animated && (
            <animate attributeName="d"
              dur={`${5 + i * 0.7}s`} repeatCount="indefinite"
              values={[
                path(l.phase, l.a),
                path(l.phase + Math.PI/3, l.a * 1.15),
                path(l.phase + Math.PI/2, l.a * 0.85),
                path(l.phase + Math.PI,   l.a),
                path(l.phase, l.a),
              ].join(';')} />
          )}
        </path>
      ))}
    </svg>
  );
}

// ─────────────────────────────────────────────────────────────
// Tab bar (soft, custom)
// ─────────────────────────────────────────────────────────────
function TabBar({ active = 'record', t, radius = 18 }) {
  const items = [
    { id: 'record', label: 'Today', icon: (
      <svg width="22" height="22" viewBox="0 0 22 22" fill="none">
        <circle cx="11" cy="11" r="3.2" stroke="currentColor" strokeWidth="1.5"/>
        <circle cx="11" cy="11" r="8" stroke="currentColor" strokeWidth="1.2" strokeOpacity="0.5"/>
      </svg>
    )},
    { id: 'history', label: 'History', icon: (
      <svg width="22" height="22" viewBox="0 0 22 22" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round">
        <path d="M4 7h14M4 11h14M4 15h9"/>
      </svg>
    )},
    { id: 'privacy', label: 'Privacy', icon: (
      <svg width="22" height="22" viewBox="0 0 22 22" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round">
        <path d="M11 3l7 3v5c0 4-3 7-7 8-4-1-7-4-7-8V6l7-3z"/>
      </svg>
    )},
  ];
  return (
    <div style={{
      position: 'absolute', left: 12, right: 12, bottom: 26,
      background: t.surface,
      border: `1px solid ${t.line}`,
      borderRadius: radius + 6,
      padding: '8px 6px',
      display: 'flex',
      boxShadow: '0 8px 24px rgba(0,0,0,0.06), 0 1px 0 rgba(255,255,255,0.6) inset',
      zIndex: 40,
    }}>
      {items.map(item => {
        const isActive = item.id === active;
        return (
          <div key={item.id} style={{
            flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center',
            padding: '6px 0', borderRadius: radius - 2,
            background: isActive ? t.surfaceAlt : 'transparent',
            color: isActive ? t.accent : t.tabIcon,
            transition: 'all .2s',
          }}>
            {item.icon}
            <div style={{
              fontSize: 10.5, marginTop: 3,
              fontWeight: isActive ? 600 : 500,
              letterSpacing: 0.1,
            }}>{item.label}</div>
          </div>
        );
      })}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Status bar (light variant for the iPhone bezel)
// ─────────────────────────────────────────────────────────────
function StatusBar({ color = '#000' }) {
  return (
    <div style={{
      position: 'absolute', top: 0, left: 0, right: 0, height: 54,
      display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end',
      padding: '0 28px 8px', zIndex: 30, pointerEvents: 'none',
      fontFamily: '-apple-system, "SF Pro", system-ui',
      fontSize: 15, fontWeight: 600, color,
    }}>
      <span>9:41</span>
      <span style={{ display: 'inline-flex', gap: 5, alignItems: 'center' }}>
        <svg width="16" height="10" viewBox="0 0 16 10"><rect x="0" y="6" width="2.5" height="4" rx="0.5" fill={color}/><rect x="4" y="4" width="2.5" height="6" rx="0.5" fill={color}/><rect x="8" y="2" width="2.5" height="8" rx="0.5" fill={color}/><rect x="12" y="0" width="2.5" height="10" rx="0.5" fill={color}/></svg>
        <svg width="22" height="11" viewBox="0 0 22 11"><rect x="0.5" y="0.5" width="19" height="10" rx="2.5" stroke={color} strokeOpacity="0.4" fill="none"/><rect x="2" y="2" width="16" height="7" rx="1.5" fill={color}/></svg>
      </span>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// iPhone bezel (own implementation, sized for canvas)
// ─────────────────────────────────────────────────────────────
function Phone({ children, t, w = 320, h = 680 }) {
  return (
    <div style={{
      width: w, height: h, borderRadius: 44, position: 'relative',
      background: t.bg,
      overflow: 'hidden',
      boxShadow: '0 30px 60px rgba(40,30,20,0.14), 0 0 0 8px #1a1714, 0 0 0 9px rgba(0,0,0,0.6)',
      fontFamily: 'Figtree, "Plus Jakarta Sans", -apple-system, system-ui, sans-serif',
      color: t.ink,
      WebkitFontSmoothing: 'antialiased',
    }}>
      {/* dynamic island */}
      <div style={{
        position: 'absolute', top: 9, left: '50%', transform: 'translateX(-50%)',
        width: 100, height: 28, borderRadius: 22, background: '#0a0908', zIndex: 50,
      }}/>
      <StatusBar color={t.ink} />
      <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column' }}>
        {children}
      </div>
      {/* home indicator */}
      <div style={{
        position: 'absolute', bottom: 7, left: '50%', transform: 'translateX(-50%)',
        width: 110, height: 4, borderRadius: 4,
        background: 'rgba(0,0,0,0.18)', zIndex: 60,
      }}/>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Reusable bits
// ─────────────────────────────────────────────────────────────
function ScreenScroll({ children, t, padBottom = 100, padTop = 60 }) {
  return (
    <div style={{
      flex: 1, overflow: 'auto',
      padding: `${padTop}px 22px ${padBottom}px`,
      display: 'flex', flexDirection: 'column',
    }}>
      {children}
    </div>
  );
}

function PillTag({ children, t, tone = 'default' }) {
  const colors = tone === 'helpful'
    ? { bg: 'transparent', fg: t.helpful, bd: t.helpful }
    : tone === 'soft'
      ? { bg: t.surfaceAlt, fg: t.muted, bd: 'transparent' }
      : { bg: 'transparent', fg: t.muted, bd: t.line };
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 4,
      padding: '3px 9px', borderRadius: 999,
      fontSize: 10.5, fontWeight: 500,
      letterSpacing: 0.2,
      background: colors.bg, color: colors.fg,
      border: `0.5px solid ${tone === 'soft' ? 'transparent' : colors.bd}`,
    }}>{children}</span>
  );
}

function PrimaryButton({ children, t, radius = 16, full = true, soft = false }) {
  return (
    <button style={{
      width: full ? '100%' : undefined,
      padding: '14px 22px',
      borderRadius: radius,
      border: 'none', cursor: 'pointer',
      background: soft ? t.accentSoft : t.accent,
      color: soft ? t.accentInk : '#fff',
      fontSize: 15, fontWeight: 600, letterSpacing: 0.1,
      fontFamily: 'inherit',
      boxShadow: soft ? 'none' : '0 1px 0 rgba(255,255,255,0.2) inset, 0 6px 16px rgba(80,55,30,0.12)',
    }}>{children}</button>
  );
}

function GhostButton({ children, t, radius = 16, full = true }) {
  return (
    <button style={{
      width: full ? '100%' : undefined,
      padding: '12px 22px',
      borderRadius: radius,
      border: `1px solid ${t.line}`,
      background: 'transparent',
      color: t.muted,
      fontSize: 14, fontWeight: 500,
      cursor: 'pointer',
      fontFamily: 'inherit',
    }}>{children}</button>
  );
}

Object.assign(window, {
  PALETTES, CategoryIcon, WaveformRibbon, TabBar, StatusBar, Phone,
  ScreenScroll, PillTag, PrimaryButton, GhostButton,
});
