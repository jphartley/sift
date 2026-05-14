// Edge states + design system reference for Sift, locked to Midnight.

// ─────────────────────────────────────────────────────────────
// Design system reference card (rendered as wide artboard)
// ─────────────────────────────────────────────────────────────
function DesignSystemBoard({ t, radius }) {
  const Swatch = ({ color, name, hex }) => (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 4, minWidth: 0 }}>
      <div style={{ height: 60, borderRadius: radius - 4, background: color,
        border: `1px solid ${t.line}` }}/>
      <div style={{ fontSize: 11, fontWeight: 600, color: t.ink, marginTop: 2 }}>{name}</div>
      <div style={{ fontSize: 10, color: t.quiet, fontFamily: 'ui-monospace, monospace' }}>{hex}</div>
    </div>
  );

  const TypeRow = ({ label, size, weight, sample }) => (
    <div style={{ display: 'grid', gridTemplateColumns: '120px 60px 1fr', gap: 16,
      alignItems: 'baseline', padding: '12px 0',
      borderBottom: `1px solid ${t.line}` }}>
      <div style={{ fontSize: 11, fontWeight: 600, color: t.quiet,
        textTransform: 'uppercase', letterSpacing: 1 }}>{label}</div>
      <div style={{ fontSize: 10, color: t.quiet, fontFamily: 'ui-monospace, monospace' }}>{size}px · {weight}</div>
      <div style={{ fontSize: size, fontWeight: weight, color: t.ink,
        letterSpacing: size > 22 ? -0.4 : -0.1, lineHeight: 1.2 }}>{sample}</div>
    </div>
  );

  return (
    <div style={{ width: 1040, padding: 32,
      background: t.bg, color: t.ink,
      fontFamily: 'Figtree, -apple-system, system-ui, sans-serif',
      borderRadius: radius + 4,
      border: `1px solid ${t.line}`,
    }}>
      <div style={{ display: 'flex', justifyContent: 'space-between',
        alignItems: 'flex-end', marginBottom: 24 }}>
        <div>
          <div style={{ fontSize: 12, fontWeight: 600, color: t.quiet,
            textTransform: 'uppercase', letterSpacing: 1.4 }}>Sift · Design System</div>
          <h1 style={{ margin: '6px 0 0', fontSize: 38, fontWeight: 600,
            letterSpacing: -0.8, color: t.ink }}>Midnight</h1>
          <p style={{ margin: '4px 0 0', fontSize: 13, color: t.muted, maxWidth: 480, lineHeight: 1.5 }}>
            One source of truth for tokens, type, and component states. Soft
            humanist sans, low chroma, generous whitespace.
          </p>
        </div>
        <div style={{ fontSize: 11, color: t.quiet, fontFamily: 'ui-monospace, monospace' }}>v0.1 · iPhone</div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 32 }}>
        <div>
          <h3 style={{ margin: 0, fontSize: 11, fontWeight: 600, color: t.quiet,
            textTransform: 'uppercase', letterSpacing: 1.2, marginBottom: 12 }}>Colors</h3>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 10 }}>
            <Swatch color={t.bg} name="bg" hex={t.bg}/>
            <Swatch color={t.surface} name="surface" hex={t.surface}/>
            <Swatch color={t.surfaceAlt} name="surface alt" hex={t.surfaceAlt}/>
            <Swatch color={t.ink} name="ink" hex={t.ink}/>
            <Swatch color={t.muted} name="muted" hex={t.muted}/>
            <Swatch color={t.quiet} name="quiet" hex={t.quiet}/>
            <Swatch color={t.accent} name="accent" hex={t.accent}/>
            <Swatch color={t.accentSoft} name="accent soft" hex={t.accentSoft}/>
            <Swatch color={t.accentInk} name="accent ink" hex={t.accentInk}/>
            <Swatch color={t.helpful} name="helpful" hex={t.helpful}/>
            <Swatch color={t.danger} name="danger" hex={t.danger}/>
            <Swatch color={t.tabIcon} name="tab icon" hex={t.tabIcon}/>
          </div>
        </div>

        <div>
          <h3 style={{ margin: 0, fontSize: 11, fontWeight: 600, color: t.quiet,
            textTransform: 'uppercase', letterSpacing: 1.2, marginBottom: 4 }}>Type — Figtree</h3>
          <TypeRow label="Display" size={30} weight={600} sample="Welcome back, Alex."/>
          <TypeRow label="Title" size={22} weight={600} sample="How did that land?"/>
          <TypeRow label="Heading" size={17} weight={600} sample="Try one of these"/>
          <TypeRow label="Body" size={14} weight={400} sample="Take a moment to arrive."/>
          <TypeRow label="Caption" size={12} weight={500} sample="3 days ago"/>
          <TypeRow label="Eyebrow" size={11} weight={600} sample="THIS WEEK"/>
        </div>
      </div>

      <div style={{ marginTop: 28, display: 'grid',
        gridTemplateColumns: '1fr 1fr', gap: 32 }}>
        <div>
          <h3 style={{ margin: 0, fontSize: 11, fontWeight: 600, color: t.quiet,
            textTransform: 'uppercase', letterSpacing: 1.2, marginBottom: 12 }}>Buttons</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            <PrimaryButton t={t} radius={radius}>Save reflection</PrimaryButton>
            <PrimaryButton t={t} radius={radius} soft>Save for later</PrimaryButton>
            <GhostButton t={t} radius={radius}>Skip for now</GhostButton>
          </div>
        </div>

        <div>
          <h3 style={{ margin: 0, fontSize: 11, fontWeight: 600, color: t.quiet,
            textTransform: 'uppercase', letterSpacing: 1.2, marginBottom: 12 }}>Pills & tags</h3>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
            <PillTag t={t} tone="soft">Breathwork</PillTag>
            <PillTag t={t}>Meditation</PillTag>
            <PillTag t={t} tone="helpful">✓ Helped before</PillTag>
            <PillTag t={t} tone="soft">~3 min</PillTag>
          </div>
        </div>

      </div>

      <div style={{ marginTop: 28 }}>
        <h3 style={{ margin: 0, fontSize: 11, fontWeight: 600, color: t.quiet,
          textTransform: 'uppercase', letterSpacing: 1.2, marginBottom: 12 }}>Practice categories — 14</h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: 10 }}>
          {[
            'Breathwork','Meditation','Grounding','Movement',
            'Journaling','Emotional Processing','Social Connection',
            'Nature','Creative Expression','Practical Care',
            'Sleep & Wind-Down','Self-Compassion','Values & Intention',
            'Spiritual / Contemplative',
          ].map(k => (
            <div key={k} style={{
              display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6
            }}>
              <div style={{
                width: 56, height: 56, borderRadius: radius - 4,
                background: t.surfaceAlt,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <CategoryIcon kind={k} color={t.accentInk} size={32}/>
              </div>
              <div style={{ fontSize: 10, color: t.quiet, textAlign: 'center', lineHeight: 1.3 }}>{k}</div>
            </div>
          ))}
        </div>
      </div>

      <div style={{ marginTop: 28 }}>
        <h3 style={{ margin: 0, fontSize: 11, fontWeight: 600, color: t.quiet,
          textTransform: 'uppercase', letterSpacing: 1.2, marginBottom: 12 }}>Waveform · listening</h3>
        <div style={{ background: t.surface, borderRadius: radius,
          border: `1px solid ${t.line}`, padding: 16, display: 'flex',
          alignItems: 'center', justifyContent: 'center' }}>
          <WaveformRibbon color={t.accent} width={400} height={80}/>
        </div>
      </div>

      <div style={{ marginTop: 28, padding: 16, borderRadius: radius,
        border: `1px dashed ${t.line}`, fontSize: 12, color: t.muted, lineHeight: 1.55 }}>
        <strong style={{ color: t.ink }}>Spacing</strong> · 22 px gutters,
        12–24 px card padding, 10 px row gap. <strong style={{ color: t.ink }}>Radius</strong> ·
        cards {radius}px, pills 999px, buttons {radius}px, icon tiles {radius - 4}px.
        <strong style={{ color: t.ink }}> Shadow</strong> · soft, low-y, 6–28 px blur.
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Edge state · Home, first run (no transcript yet)
// ─────────────────────────────────────────────────────────────
function HomeFirstRun({ t, radius }) {
  return (
    <Phone t={t}>
      <ScreenScroll t={t} padTop={66}>
        <div style={{ fontSize: 12, fontWeight: 500, letterSpacing: 1.3,
          textTransform: 'uppercase', color: t.quiet, marginBottom: 6 }}>
          Welcome to Sift
        </div>
        <h1 style={{ fontSize: 28, fontWeight: 600, lineHeight: 1.18,
          letterSpacing: -0.5, margin: 0, color: t.ink, textWrap: 'balance' }}>
          Hi.<br/>
          <span style={{ color: t.muted, fontWeight: 500 }}>
            Take a moment to arrive.
          </span>
        </h1>
        <p style={{ marginTop: 18, fontSize: 14, lineHeight: 1.55, color: t.muted }}>
          There is no right or wrong way to do this. Speak for about a minute about
          what feels most alive right now: what happened, how it feels, or what
          kind of support you want.
        </p>
        <p style={{ marginTop: 14, fontSize: 13, lineHeight: 1.55, color: t.muted }}>
          Sift will transcribe your voice on device, reflect what it heard, and
          suggest a few practices.
        </p>

        <div style={{ flex: 1 }}/>
        <div style={{ display: 'flex', flexDirection: 'column',
          alignItems: 'center', marginTop: 30 }}>
          <div style={{
            width: 132, height: 132, borderRadius: '50%',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            background: `radial-gradient(circle at 50% 40%, ${t.accentSoft} 0%, ${t.bg} 75%)`,
          }}>
            <div style={{
              width: 78, height: 78, borderRadius: '50%', background: t.accent,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              boxShadow: `0 12px 28px ${t.accent}33, 0 0 0 6px ${t.surface}`,
            }}>
              <svg width="28" height="36" viewBox="0 0 28 36" fill="none">
                <rect x="9" y="3" width="10" height="20" rx="5" fill="#fff"/>
                <path d="M3 16c0 6.5 5 11 11 11s11-4.5 11-11M14 27v6M9 33h10"
                  stroke="#fff" strokeWidth="1.8" strokeLinecap="round" fill="none"/>
              </svg>
            </div>
          </div>
          <div style={{ marginTop: 14, fontSize: 14, color: t.muted, fontWeight: 500 }}>
            Tap to begin
          </div>
        </div>

        <div style={{ marginTop: 18, display: 'flex', gap: 6, justifyContent: 'center' }}>
          {['Right now I notice…', 'What feels hard…', 'What I need…'].map((p,i) => (
            <span key={i} style={{
              fontSize: 10.5, color: t.quiet, fontStyle: 'italic',
              padding: '4px 8px', border: `1px dashed ${t.line}`, borderRadius: 999,
            }}>{p}</span>
          ))}
        </div>
      </ScreenScroll>
      <TabBar active="record" t={t} radius={radius}/>
    </Phone>
  );
}

// ─────────────────────────────────────────────────────────────
// Edge state · Recording, mic permission denied
// ─────────────────────────────────────────────────────────────
function MicDeniedScreen({ t, radius }) {
  return (
    <Phone t={t}>
      <div style={{ flex: 1, padding: '70px 22px 70px',
        display: 'flex', flexDirection: 'column' }}>
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column',
          alignItems: 'center', justifyContent: 'center', gap: 18, textAlign: 'center' }}>
          <div style={{
            width: 64, height: 64, borderRadius: '50%',
            background: t.surface, border: `1px solid ${t.line}`,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <svg width="28" height="32" viewBox="0 0 28 32" fill="none" stroke={t.muted} strokeWidth="1.8" strokeLinecap="round">
              <rect x="9" y="3" width="10" height="16" rx="5"/>
              <path d="M3 14c0 6 5 11 11 11s11-5 11-11M14 25v5M9 30h10"/>
              <path d="M3 3l22 26" stroke={t.danger} strokeWidth="2"/>
            </svg>
          </div>
          <h2 style={{ margin: 0, fontSize: 21, fontWeight: 600, color: t.ink,
            letterSpacing: -0.3 }}>Mic access is off</h2>
          <p style={{ margin: 0, fontSize: 13.5, color: t.muted, lineHeight: 1.55,
            maxWidth: 240 }}>
            Sift needs the mic to listen and transcribe on your device. You can
            turn it back on in Settings, or write what's alive instead.
          </p>
          <div style={{ marginTop: 6, display: 'flex', flexDirection: 'column', gap: 8, width: '100%' }}>
            <PrimaryButton t={t} radius={radius}>Open Settings</PrimaryButton>
            <GhostButton t={t} radius={radius}>Type instead</GhostButton>
          </div>
        </div>
      </div>
    </Phone>
  );
}

// ─────────────────────────────────────────────────────────────
// Edge state · Network error during analysis
// ─────────────────────────────────────────────────────────────
function NetworkErrorScreen({ t, radius }) {
  return (
    <Phone t={t}>
      <div style={{ flex: 1, padding: '70px 22px 70px',
        display: 'flex', flexDirection: 'column' }}>
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column',
          alignItems: 'center', justifyContent: 'center', gap: 18, textAlign: 'center' }}>
          <div style={{
            width: 64, height: 64, borderRadius: '50%',
            background: t.surface, border: `1px solid ${t.line}`,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <svg width="32" height="22" viewBox="0 0 32 22" fill="none" stroke={t.muted} strokeWidth="1.8" strokeLinecap="round">
              <path d="M2 7c4-4 10-6 14-6s10 2 14 6M6 12c3-2.5 6-4 10-4s7 1.5 10 4M10 17c2-1.5 4-2 6-2s4 .5 6 2"/>
              <path d="M16 21v-1"/>
            </svg>
          </div>
          <h2 style={{ margin: 0, fontSize: 21, fontWeight: 600, color: t.ink,
            letterSpacing: -0.3 }}>Sift can't reach the network</h2>
          <p style={{ margin: 0, fontSize: 13.5, color: t.muted, lineHeight: 1.55, maxWidth: 250 }}>
            Your transcript is safe on this phone. We just couldn't fetch a
            fresh suggestion right now — try again in a minute.
          </p>

          <div style={{ width: '100%', marginTop: 10, padding: 14,
            background: t.surface, borderRadius: radius - 2,
            border: `1px solid ${t.line}`, textAlign: 'left' }}>
            <div style={{ fontSize: 10.5, fontWeight: 600, color: t.quiet,
              textTransform: 'uppercase', letterSpacing: 1, marginBottom: 6 }}>
              Saved transcript
            </div>
            <div style={{ fontSize: 13, color: t.ink, lineHeight: 1.5, fontStyle: 'italic' }}>
              "Today felt heavy from the start. I keep checking my phone…"
            </div>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 8, width: '100%' }}>
            <PrimaryButton t={t} radius={radius}>Try again</PrimaryButton>
            <GhostButton t={t} radius={radius}>Show me what helped before</GhostButton>
          </div>
        </div>
      </div>
    </Phone>
  );
}

// ─────────────────────────────────────────────────────────────
// Edge state · Loading the on-device speech model
// ─────────────────────────────────────────────────────────────
function ModelLoadingScreen({ t, radius }) {
  const progress = 0.62;
  return (
    <Phone t={t}>
      <div style={{ flex: 1, padding: '70px 22px 70px',
        display: 'flex', flexDirection: 'column' }}>
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column',
          alignItems: 'center', justifyContent: 'center', gap: 22, textAlign: 'center' }}>

          {/* breathing dot */}
          <div style={{ position: 'relative', width: 96, height: 96 }}>
            {[0,1,2].map(i => (
              <div key={i} style={{
                position: 'absolute', inset: i*12, borderRadius: '50%',
                border: `1px solid ${t.accent}${i===0?'66':i===1?'33':'1a'}`,
              }}/>
            ))}
            <div style={{
              position: 'absolute', top: '50%', left: '50%', width: 12, height: 12,
              transform: 'translate(-50%, -50%)',
              borderRadius: '50%', background: t.accent,
            }}/>
          </div>

          <h2 style={{ margin: 0, fontSize: 20, fontWeight: 600, color: t.ink,
            letterSpacing: -0.3 }}>Getting Sift ready</h2>
          <p style={{ margin: 0, fontSize: 13, color: t.muted, lineHeight: 1.55, maxWidth: 260 }}>
            Sift is preparing on-device speech recognition so your voice can be
            transcribed on your phone. First setup takes a moment; it's faster after.
          </p>

          <div style={{ width: '100%', maxWidth: 220 }}>
            <div style={{ height: 4, borderRadius: 4, background: t.surfaceAlt, overflow: 'hidden' }}>
              <div style={{ height: '100%', width: `${progress*100}%`,
                background: t.accent, borderRadius: 4 }}/>
            </div>
            <div style={{ marginTop: 8, fontSize: 11, color: t.quiet, fontFamily: 'ui-monospace, monospace' }}>
              {Math.round(progress*100)}% · 38 MB / 62 MB
            </div>
          </div>
        </div>
      </div>
    </Phone>
  );
}

// ─────────────────────────────────────────────────────────────
// Edge state · History, empty
// ─────────────────────────────────────────────────────────────
function HistoryEmptyScreen({ t, radius }) {
  return (
    <Phone t={t}>
      <ScreenScroll t={t} padTop={62}>
        <h1 style={{ margin: 0, fontSize: 30, fontWeight: 600,
          letterSpacing: -0.6, color: t.ink }}>History</h1>
        <p style={{ margin: '6px 0 0', fontSize: 13.5, color: t.muted, lineHeight: 1.5 }}>
          A quiet record of your check-ins and what seemed to help.
        </p>

        <div style={{ flex: 1 }}/>

        <div style={{
          marginTop: 30, padding: 26,
          background: t.surface, borderRadius: radius,
          border: `1px dashed ${t.line}`,
          display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', gap: 10,
        }}>
          <div style={{
            width: 56, height: 56, borderRadius: '50%',
            background: t.surfaceAlt, color: t.accentInk,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <svg width="26" height="26" viewBox="0 0 26 26" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round">
              <path d="M5 6h16M5 11h16M5 16h11"/>
            </svg>
          </div>
          <div style={{ fontSize: 15, fontWeight: 600, color: t.ink }}>
            Nothing here yet
          </div>
          <p style={{ margin: 0, fontSize: 13, color: t.muted, lineHeight: 1.55, maxWidth: 230 }}>
            Once you do a check-in, it'll show up here — what you shared, what
            you tried, and how it landed.
          </p>
          <div style={{ marginTop: 10, width: '100%' }}>
            <PrimaryButton t={t} radius={radius}>Start a check-in</PrimaryButton>
          </div>
        </div>

        <div style={{ flex: 1 }}/>
      </ScreenScroll>
      <TabBar active="history" t={t} radius={radius}/>
    </Phone>
  );
}

// ─────────────────────────────────────────────────────────────
// Edge state · History, long (returning user)
// ─────────────────────────────────────────────────────────────
function HistoryLongScreen({ t, radius }) {
  const groups = [
    { label: 'This week', items: [
      { day: 'Tue', time: '4:12 pm', mood: 'heavy morning, scattered', practice: 'Box Breathing', helpful: 'yes' },
      { day: 'Mon', time: '8:02 am', mood: 'tired but okay', practice: 'Walk Outside', helpful: 'yes' },
    ]},
    { label: 'Last week', items: [
      { day: 'Sat', time: 'Nov 1 · 9:30 pm', mood: 'restless before sleep', practice: '4-7-8 Breath', helpful: 'yes' },
      { day: 'Wed', time: 'Oct 29 · 7:15 am', mood: 'low energy', practice: 'Walk Outside', helpful: 'maybe' },
      { day: 'Mon', time: 'Oct 27 · 10:02 am', mood: 'pre-meeting nerves', practice: 'Physiological Sigh', helpful: 'yes' },
    ]},
    { label: 'Earlier', items: [
      { day: 'Thu', time: 'Oct 23', mood: 'frustrated, tight chest', practice: 'Sighing Practice', helpful: 'yes' },
      { day: 'Sun', time: 'Oct 19', mood: 'quiet, content', practice: 'Tea Meditation', helpful: 'yes' },
      { day: 'Wed', time: 'Oct 15', mood: 'overwhelmed by inbox', practice: 'Micro Meditation', helpful: 'maybe' },
    ]},
  ];
  const helpfulMark = (h) => h === 'yes'
    ? { color: t.helpful, label: 'Helped' }
    : h === 'maybe'
    ? { color: t.muted, label: 'A little' }
    : { color: t.quiet, label: '—' };

  return (
    <Phone t={t}>
      <ScreenScroll t={t} padTop={62}>
        <h1 style={{ margin: 0, fontSize: 30, fontWeight: 600,
          letterSpacing: -0.6, color: t.ink }}>History</h1>
        <p style={{ margin: '6px 0 0', fontSize: 13.5, color: t.muted, lineHeight: 1.5 }}>
          17 check-ins over the last 6 weeks.
        </p>

        <div style={{ marginTop: 18, padding: 16,
          background: t.surface, borderRadius: radius,
          border: `1px solid ${t.line}` }}>
          <div style={{ fontSize: 11, fontWeight: 600, color: t.quiet,
            textTransform: 'uppercase', letterSpacing: 1 }}>What seems to work</div>
          <p style={{ margin: '8px 0 0', fontSize: 13.5, color: t.ink,
            lineHeight: 1.55, fontStyle: 'italic' }}>
            Box breathing in the morning, short walks midday, 4-7-8 before bed.
            Three simple things that keep showing up.
          </p>
        </div>

        {groups.map((g, gi) => (
          <div key={gi} style={{ marginTop: 22 }}>
            <div style={{ marginBottom: 8, fontSize: 11, fontWeight: 600,
              color: t.quiet, textTransform: 'uppercase', letterSpacing: 1 }}>{g.label}</div>
            <div style={{
              background: t.surface, borderRadius: radius,
              border: `1px solid ${t.line}`, overflow: 'hidden',
            }}>
              {g.items.map((it, i) => {
                const m = helpfulMark(it.helpful);
                return (
                  <div key={i} style={{
                    padding: '12px 14px',
                    borderBottom: i < g.items.length - 1 ? `1px solid ${t.line}` : 'none',
                    display: 'flex', gap: 10, alignItems: 'flex-start',
                  }}>
                    <div style={{ width: 36, flexShrink: 0 }}>
                      <div style={{ fontSize: 13, fontWeight: 600, color: t.ink }}>{it.day}</div>
                      <div style={{ fontSize: 10, color: t.quiet, marginTop: 2 }}>{it.time}</div>
                    </div>
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{ fontSize: 13, color: t.ink,
                        fontStyle: 'italic', marginBottom: 4, lineHeight: 1.4 }}>"{it.mood}"</div>
                      <div style={{ display: 'flex', gap: 6, alignItems: 'center', flexWrap: 'wrap' }}>
                        <PillTag t={t} tone="soft">{it.practice}</PillTag>
                        <span style={{ fontSize: 10.5, color: m.color, fontWeight: 500 }}>· {m.label}</span>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        ))}
      </ScreenScroll>
      <TabBar active="history" t={t} radius={radius}/>
    </Phone>
  );
}

// ─────────────────────────────────────────────────────────────
// Edge state · Suggestions, returning user with strong memory
// ─────────────────────────────────────────────────────────────
function SuggestionsReturningScreen({ t, radius }) {
  const practices = [
    { id: 'box', name: 'Box Breathing', cat: 'Breathwork', mins: 3,
      summary: 'A steady four-part breath. Helped 4 of the last 5 times you tried it.',
      helped: true },
    { id: 'sigh', name: 'Physiological Sigh', cat: 'Breathwork', mins: 1,
      summary: 'Quick double-inhale and a long exhale. Reset in under a minute.',
      helped: true },
    { id: 'walk', name: 'Walk Outside', cat: 'Movement', mins: 10,
      summary: "Something about a little sky tends to do it. You haven't done this in a while.",
      helped: false, last: 'last tried 12 days ago' },
  ];
  return (
    <Phone t={t}>
      <ScreenScroll t={t} padTop={62}>
        <div style={{ fontSize: 11, fontWeight: 600, color: t.quiet,
          textTransform: 'uppercase', letterSpacing: 1.2 }}>You shared</div>
        <p style={{ margin: '8px 0 0', fontSize: 14, lineHeight: 1.55, color: t.ink, fontStyle: 'italic' }}>
          "Same heaviness as last Tuesday — chest is tight and I can't focus."
        </p>

        <div style={{ marginTop: 22, padding: '14px 16px',
          borderLeft: `2px solid ${t.accent}`,
          background: t.surface, borderRadius: `0 ${radius-4}px ${radius-4}px 0`,
        }}>
          <div style={{ fontSize: 10.5, fontWeight: 600, color: t.accentInk,
            textTransform: 'uppercase', letterSpacing: 1.2, marginBottom: 6 }}>
            What I remember
          </div>
          <div style={{ fontSize: 13, color: t.ink, lineHeight: 1.55 }}>
            Tight-chest mornings have softened with breath-led practices in the past.
            Box breathing has a strong record for you — the sigh works in a pinch.
          </div>
        </div>

        <div style={{ marginTop: 24, marginBottom: 10,
          display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
          <h3 style={{ margin: 0, fontSize: 17, fontWeight: 600, color: t.ink,
            letterSpacing: -0.3 }}>Try one of these</h3>
          <span style={{ fontSize: 11, color: t.quiet }}>3 suggestions</span>
        </div>

        {practices.map(p => (
          <div key={p.id} style={{
            background: t.surface, borderRadius: radius,
            border: `1px solid ${t.line}`,
            padding: 14, marginBottom: 10,
            display: 'flex', gap: 12, alignItems: 'flex-start',
          }}>
            <div style={{
              width: 42, height: 42, borderRadius: radius - 6,
              background: t.surfaceAlt,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              flexShrink: 0,
            }}>
              <CategoryIcon kind={p.cat} color={t.accentInk} size={24}/>
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between',
                alignItems: 'baseline', gap: 8 }}>
                <h4 style={{ margin: 0, fontSize: 15, fontWeight: 600, color: t.ink }}>
                  {p.name}
                </h4>
                <span style={{ fontSize: 11, color: t.quiet, flexShrink: 0 }}>~{p.mins} min</span>
              </div>
              <p style={{ margin: '4px 0 8px', fontSize: 12.5, color: t.muted, lineHeight: 1.5 }}>{p.summary}</p>
              <div style={{ display: 'flex', gap: 6, alignItems: 'center', flexWrap: 'wrap' }}>
                <PillTag t={t} tone="soft">{p.cat}</PillTag>
                {p.helped && <PillTag t={t} tone="helpful">✓ Helped before</PillTag>}
                {p.last && <span style={{ fontSize: 10.5, color: t.quiet, fontStyle: 'italic' }}>{p.last}</span>}
              </div>
            </div>
          </div>
        ))}

        <GhostButton t={t} radius={radius}>Done · maybe later</GhostButton>
      </ScreenScroll>
    </Phone>
  );
}

Object.assign(window, {
  DesignSystemBoard,
  HomeFirstRun, MicDeniedScreen, NetworkErrorScreen, ModelLoadingScreen,
  HistoryEmptyScreen, HistoryLongScreen, SuggestionsReturningScreen,
});
