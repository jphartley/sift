// Direction A: Warm paper — and the 8 screens for either direction.
// Screens are theme-driven; same components render under any palette.

// ─────────────────────────────────────────────────────────────
// 1. Home / Today (returning state)
// ─────────────────────────────────────────────────────────────
function HomeScreen({ t, radius }) {
  return (
    <Phone t={t}>
      <ScreenScroll t={t} padTop={66}>
        <div style={{ fontSize: 12, fontWeight: 500, letterSpacing: 1.3,
          textTransform: 'uppercase', color: t.quiet, marginBottom: 6 }}>
          Tuesday · evening
        </div>
        <h1 style={{
          fontSize: 28, fontWeight: 600, lineHeight: 1.18,
          letterSpacing: -0.5, margin: 0, color: t.ink,
          textWrap: 'balance',
        }}>
          Welcome back, Alex.<br/>
          <span style={{ color: t.muted, fontWeight: 500 }}>
            Take a moment to arrive.
          </span>
        </h1>

        <p style={{
          marginTop: 18, fontSize: 14, lineHeight: 1.55,
          color: t.muted, fontWeight: 400,
        }}>
          Speak for about a minute about what feels most alive right now —
          what happened, how it feels, or what kind of support you want.
        </p>

        {/* Last check-in card */}
        <div style={{
          marginTop: 22, padding: 16,
          background: t.surface, borderRadius: radius,
          border: `1px solid ${t.line}`,
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ fontSize: 11, fontWeight: 600, color: t.quiet,
              textTransform: 'uppercase', letterSpacing: 1 }}>Last check-in</span>
            <span style={{ fontSize: 11, color: t.quiet }}>3 days ago</span>
          </div>
          <p style={{
            margin: '8px 0 0', fontSize: 13.5, lineHeight: 1.5,
            color: t.ink, fontStyle: 'italic',
          }}>
            "Slept poorly and the morning felt long. Box breathing
            actually helped before the call…"
          </p>
        </div>

        <div style={{ flex: 1 }} />

        {/* Mic CTA */}
        <div style={{
          display: 'flex', flexDirection: 'column', alignItems: 'center',
          marginTop: 30, marginBottom: 4,
        }}>
          <div style={{
            position: 'relative', width: 132, height: 132,
            borderRadius: '50%',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            background: `radial-gradient(circle at 50% 40%, ${t.accentSoft} 0%, ${t.bg} 75%)`,
          }}>
            <div style={{
              position: 'absolute', inset: 18, borderRadius: '50%',
              border: `1px solid ${t.line}`,
            }} />
            <div style={{
              width: 78, height: 78, borderRadius: '50%',
              background: t.accent,
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
          <div style={{
            marginTop: 14, fontSize: 14, color: t.muted, fontWeight: 500,
          }}>Tap to begin</div>
        </div>

        <div style={{ marginTop: 18, display: 'flex', gap: 6, justifyContent: 'center' }}>
          {['Right now I notice…', 'What feels hard…', 'What I need…'].map((p,i) => (
            <span key={i} style={{
              fontSize: 10.5, color: t.quiet, fontStyle: 'italic',
              padding: '4px 8px', border: `1px dashed ${t.line}`,
              borderRadius: 999,
            }}>{p}</span>
          ))}
        </div>
      </ScreenScroll>
      <TabBar active="record" t={t} radius={radius} />
    </Phone>
  );
}

// ─────────────────────────────────────────────────────────────
// 2. Recording (live)
// ─────────────────────────────────────────────────────────────
function RecordingLive({ t, radius }) {
  return (
    <Phone t={t}>
      <div style={{ flex: 1, position: 'relative', display: 'flex',
        flexDirection: 'column', padding: '70px 22px 120px' }}>

        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 7,
            padding: '5px 11px', borderRadius: 999,
            background: 'transparent', border: `1px solid ${t.danger}33` }}>
            <span style={{ width: 7, height: 7, borderRadius: '50%',
              background: t.danger, boxShadow: `0 0 0 3px ${t.danger}22` }} />
            <span style={{ fontSize: 11.5, fontWeight: 600, color: t.danger,
              letterSpacing: 0.4 }}>Listening</span>
          </div>
          <span style={{ fontSize: 11, color: t.quiet }}>on device</span>
        </div>

        <div style={{ flex: 1, display: 'flex', flexDirection: 'column',
          justifyContent: 'center', alignItems: 'center', gap: 18 }}>
          <div style={{
            fontFamily: '"SF Mono", ui-monospace, monospace',
            fontSize: 38, fontWeight: 300, color: t.ink, letterSpacing: -1,
          }}>
            00:42<span style={{ color: t.quiet }}>.3</span>
          </div>
          <div style={{ width: 250, opacity: 0.85 }}>
            <WaveformRibbon color={t.accent} width={250} height={120} />
          </div>
          <div style={{
            fontSize: 13, color: t.muted, fontStyle: 'italic',
            textAlign: 'center', maxWidth: 220, lineHeight: 1.5,
          }}>
            Take your time. There's no right way to do this.
          </div>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column',
          alignItems: 'center', gap: 10 }}>
          <button style={{
            width: 72, height: 72, borderRadius: '50%',
            background: t.surface, border: `1px solid ${t.line}`,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            cursor: 'pointer',
            boxShadow: '0 8px 20px rgba(0,0,0,0.06)',
          }}>
            <div style={{ width: 22, height: 22, borderRadius: 5,
              background: t.danger }}/>
          </button>
          <div style={{ fontSize: 13, color: t.muted }}>Tap to finish</div>
        </div>
      </div>
    </Phone>
  );
}

// ─────────────────────────────────────────────────────────────
// 3. Analyzing
// ─────────────────────────────────────────────────────────────
function AnalyzingScreen({ t, radius }) {
  return (
    <Phone t={t}>
      <div style={{ flex: 1, padding: '70px 22px 60px',
        display: 'flex', flexDirection: 'column' }}>
        <div style={{ display: 'flex', flexDirection: 'column',
          alignItems: 'center', gap: 28, marginTop: 30 }}>
          {/* breathing dot */}
          <div style={{ position: 'relative', width: 110, height: 110 }}>
            {[0,1,2].map(i => (
              <div key={i} style={{
                position: 'absolute', inset: i*14, borderRadius: '50%',
                border: `1px solid ${t.accent}${i===0?'66':i===1?'33':'1a'}`,
              }}/>
            ))}
            <div style={{
              position: 'absolute', inset: '50%', width: 14, height: 14,
              transform: 'translate(-50%, -50%)', marginLeft: -7, marginTop: -7,
              borderRadius: '50%', background: t.accent,
            }}/>
          </div>

          <h2 style={{
            fontSize: 22, fontWeight: 600, color: t.ink,
            margin: 0, textAlign: 'center', letterSpacing: -0.3,
          }}>Sift is reading what you shared</h2>

          <p style={{
            fontSize: 13.5, color: t.muted, lineHeight: 1.55,
            textAlign: 'center', maxWidth: 250, margin: 0,
          }}>
            Reflecting on what you said, your past wins, and a few practices
            that might fit this moment.
          </p>
        </div>

        <div style={{ marginTop: 36, padding: 14,
          background: t.surface, borderRadius: radius - 2,
          border: `1px solid ${t.line}` }}>
          <div style={{ fontSize: 10.5, fontWeight: 600, color: t.quiet,
            textTransform: 'uppercase', letterSpacing: 1, marginBottom: 6 }}>
            What I heard
          </div>
          <div style={{ fontSize: 13, color: t.ink, lineHeight: 1.55, fontStyle: 'italic' }}>
            "Today felt heavy from the start. I keep checking my phone
            instead of starting the thing I actually need to do…"
          </div>
        </div>

        <div style={{ flex: 1 }}/>
        <div style={{ display: 'flex', justifyContent: 'center', gap: 6 }}>
          {[0,1,2].map(i => (
            <span key={i} style={{
              width: 5, height: 5, borderRadius: '50%',
              background: t.accent, opacity: 0.3 + i*0.2,
            }}/>
          ))}
        </div>
      </div>
    </Phone>
  );
}

Object.assign(window, { HomeScreen, RecordingLive, AnalyzingScreen });
