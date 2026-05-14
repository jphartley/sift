// Screens 4-8: Suggestions, Practice Detail, Reflection, History, Privacy

// ─────────────────────────────────────────────────────────────
// 4. Suggestions
// ─────────────────────────────────────────────────────────────
function SuggestionsScreen({ t, radius }) {
  const practices = [
    { id: 'box', name: 'Box Breathing', cat: 'Breathwork', mins: 3,
      summary: 'A steady four-part breath for settling when things feel fast.',
      helped: true },
    { id: 'walk', name: 'Walk Outside', cat: 'Movement', mins: 10,
      summary: 'A short walk somewhere with a little sky.', helped: false },
    { id: 'note', name: 'Three-line Note', cat: 'Journaling', mins: 4,
      summary: 'Three short lines about what feels alive right now.', helped: false },
  ];
  return (
    <Phone t={t}>
      <ScreenScroll t={t} padTop={62}>
        <div style={{ fontSize: 11, fontWeight: 600, color: t.quiet,
          textTransform: 'uppercase', letterSpacing: 1.2 }}>You shared</div>
        <p style={{
          margin: '8px 0 0', fontSize: 14, lineHeight: 1.55,
          color: t.ink, fontStyle: 'italic',
        }}>
          "Today felt heavy from the start. I keep checking my phone
          instead of starting the thing I need to do."
        </p>

        <div style={{ marginTop: 22, padding: '14px 16px',
          borderLeft: `2px solid ${t.accent}`,
          background: t.surface, borderRadius: `0 ${radius-4}px ${radius-4}px 0`,
        }}>
          <div style={{ fontSize: 10.5, fontWeight: 600, color: t.accentInk,
            textTransform: 'uppercase', letterSpacing: 1.2, marginBottom: 6 }}>
            Why these might fit
          </div>
          <div style={{ fontSize: 13, color: t.ink, lineHeight: 1.55 }}>
            Sounds like the morning has more friction than focus. Last month, a
            short walk and box breathing helped on similar days.
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
                <span style={{ fontSize: 11, color: t.quiet, flexShrink: 0 }}>
                  ~{p.mins} min
                </span>
              </div>
              <p style={{ margin: '4px 0 8px', fontSize: 12.5,
                color: t.muted, lineHeight: 1.5 }}>{p.summary}</p>
              <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
                <PillTag t={t} tone="soft">{p.cat}</PillTag>
                {p.helped && <PillTag t={t} tone="helpful">✓ Helped before</PillTag>}
              </div>
            </div>
          </div>
        ))}

        <div style={{ marginTop: 8 }}>
          <GhostButton t={t} radius={radius}>Done · maybe later</GhostButton>
        </div>
      </ScreenScroll>
    </Phone>
  );
}

// ─────────────────────────────────────────────────────────────
// 5. Practice Detail
// ─────────────────────────────────────────────────────────────
function PracticeDetailScreen({ t, radius }) {
  const steps = [
    'Sit upright with your feet grounded.',
    'Inhale through your nose for 4 seconds.',
    'Hold gently for 4 seconds.',
    'Exhale slowly for 4 seconds.',
    'Hold empty for 4 seconds.',
    'Repeat for 4–6 rounds, then breathe normally.',
  ];
  return (
    <Phone t={t}>
      <ScreenScroll t={t} padTop={56} padBottom={120}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10,
          marginBottom: 18 }}>
          <button style={{
            width: 32, height: 32, borderRadius: 999,
            border: `1px solid ${t.line}`, background: t.surface,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            cursor: 'pointer',
          }}>
            <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
              <path d="M9 2L3 7l6 5" stroke={t.muted} strokeWidth="1.6"
                strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </button>
          <PillTag t={t} tone="soft">Breathwork · 3 min</PillTag>
        </div>

        <div style={{
          background: t.surface, borderRadius: radius + 2,
          padding: 20, border: `1px solid ${t.line}`,
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12,
            marginBottom: 14 }}>
            <div style={{
              width: 48, height: 48, borderRadius: radius - 4,
              background: t.surfaceAlt,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <CategoryIcon kind="Breathwork" color={t.accentInk} size={28}/>
            </div>
            <div>
              <h2 style={{ margin: 0, fontSize: 20, fontWeight: 600,
                color: t.ink, letterSpacing: -0.3 }}>Box Breathing</h2>
              <div style={{ fontSize: 12, color: t.muted, marginTop: 2 }}>
                A steady four-part rhythm
              </div>
            </div>
          </div>
          <p style={{ margin: 0, fontSize: 13.5, lineHeight: 1.6,
            color: t.muted, fontStyle: 'italic' }}>
            The predictable rhythm gives your attention somewhere reliable to
            land, which can make the next few minutes feel more manageable.
          </p>
        </div>

        <h3 style={{ marginTop: 22, marginBottom: 10, fontSize: 13,
          fontWeight: 600, color: t.quiet, textTransform: 'uppercase',
          letterSpacing: 1 }}>The practice</h3>

        <ol style={{ listStyle: 'none', padding: 0, margin: 0 }}>
          {steps.map((s, i) => (
            <li key={i} style={{
              display: 'flex', gap: 12, padding: '10px 0',
              borderBottom: i < steps.length - 1 ? `1px solid ${t.line}` : 'none',
            }}>
              <div style={{
                width: 22, height: 22, borderRadius: '50%',
                background: t.surfaceAlt, color: t.accentInk,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontSize: 11, fontWeight: 600, flexShrink: 0, marginTop: 1,
              }}>{i+1}</div>
              <div style={{ fontSize: 14, color: t.ink, lineHeight: 1.5 }}>{s}</div>
            </li>
          ))}
        </ol>

        <div style={{ flex: 1 }}/>
        <div style={{ marginTop: 24, display: 'flex', flexDirection: 'column', gap: 8 }}>
          <PrimaryButton t={t} radius={radius}>I tried it</PrimaryButton>
          <GhostButton t={t} radius={radius}>Save for later</GhostButton>
        </div>
      </ScreenScroll>
    </Phone>
  );
}

// ─────────────────────────────────────────────────────────────
// 6. Reflection
// ─────────────────────────────────────────────────────────────
function ReflectionScreen({ t, radius }) {
  const [helpful, setHelpful] = React.useState('yes');
  const opts = [
    { id: 'yes', label: 'Yes, this helped' },
    { id: 'maybe', label: 'A little' },
    { id: 'no', label: 'Not really' },
  ];
  return (
    <Phone t={t}>
      <ScreenScroll t={t} padTop={62}>
        <div style={{ fontSize: 11, fontWeight: 600, color: t.quiet,
          textTransform: 'uppercase', letterSpacing: 1.2 }}>After Box Breathing</div>
        <h2 style={{ margin: '8px 0 0', fontSize: 24, fontWeight: 600,
          letterSpacing: -0.4, lineHeight: 1.2, color: t.ink, textWrap: 'balance' }}>
          How did that land?
        </h2>
        <p style={{ marginTop: 8, fontSize: 13.5, color: t.muted, lineHeight: 1.55 }}>
          No right answer. Tracking what works helps Sift remember what to
          suggest next time.
        </p>

        <div style={{ marginTop: 22, display: 'flex', flexDirection: 'column', gap: 8 }}>
          {opts.map(o => {
            const active = helpful === o.id;
            return (
              <div key={o.id}
                onClick={() => setHelpful(o.id)}
                style={{
                  padding: '14px 16px', borderRadius: radius,
                  background: active ? t.surface : 'transparent',
                  border: `1.5px solid ${active ? t.accent : t.line}`,
                  display: 'flex', alignItems: 'center', gap: 12,
                  cursor: 'pointer', transition: 'all .2s',
                }}>
                <div style={{
                  width: 18, height: 18, borderRadius: '50%',
                  border: `1.5px solid ${active ? t.accent : t.quiet}`,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  flexShrink: 0,
                }}>
                  {active && <div style={{ width: 8, height: 8, borderRadius: '50%',
                    background: t.accent }}/>}
                </div>
                <span style={{ fontSize: 14.5, color: t.ink, fontWeight: active ? 600 : 500 }}>
                  {o.label}
                </span>
              </div>
            );
          })}
        </div>

        <div style={{ marginTop: 18 }}>
          <div style={{ fontSize: 11, fontWeight: 600, color: t.quiet,
            textTransform: 'uppercase', letterSpacing: 1.2, marginBottom: 8 }}>
            A note (optional)
          </div>
          <div style={{
            background: t.surface, borderRadius: radius,
            border: `1px solid ${t.line}`,
            padding: 14, minHeight: 84,
          }}>
            <div style={{ fontSize: 13, color: t.ink, lineHeight: 1.55,
              fontStyle: 'italic' }}>
              The first round felt forced. The third one actually slowed me down.
            </div>
          </div>
        </div>

        <div style={{ flex: 1 }}/>
        <div style={{ marginTop: 24, display: 'flex', flexDirection: 'column', gap: 8 }}>
          <PrimaryButton t={t} radius={radius}>Save reflection</PrimaryButton>
          <GhostButton t={t} radius={radius}>Skip for now</GhostButton>
        </div>
      </ScreenScroll>
    </Phone>
  );
}

// ─────────────────────────────────────────────────────────────
// 7. History
// ─────────────────────────────────────────────────────────────
function HistoryScreen({ t, radius }) {
  const items = [
    { day: 'Today', time: 'Tue · 4:12 pm', mood: 'heavy morning, scattered',
      practice: 'Box Breathing', helpful: 'yes' },
    { day: 'Sat', time: 'Nov 1 · 9:30 pm', mood: 'restless before sleep',
      practice: '4-7-8 Breath', helpful: 'yes' },
    { day: 'Wed', time: 'Oct 29 · 7:15 am', mood: 'tired, low energy',
      practice: 'Walk Outside', helpful: 'maybe' },
    { day: 'Mon', time: 'Oct 27 · 10:02 am', mood: 'pre-meeting nerves',
      practice: 'Physiological Sigh', helpful: 'yes' },
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
          A quiet record of your check-ins and what seemed to help.
        </p>

        {/* this week summary */}
        <div style={{
          marginTop: 20, padding: 16,
          background: t.surface, borderRadius: radius,
          border: `1px solid ${t.line}`,
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between' }}>
            <span style={{ fontSize: 11, fontWeight: 600, color: t.quiet,
              textTransform: 'uppercase', letterSpacing: 1 }}>This week</span>
            <span style={{ fontSize: 11, color: t.quiet }}>4 check-ins</span>
          </div>
          <p style={{ margin: '8px 0 0', fontSize: 13.5, color: t.ink,
            lineHeight: 1.55, fontStyle: 'italic' }}>
            Mornings have been the heaviest. Box breathing and short walks
            kept showing up as helpful — both quiet, both early.
          </p>
        </div>

        <div style={{ marginTop: 22, marginBottom: 8, fontSize: 11,
          fontWeight: 600, color: t.quiet, textTransform: 'uppercase',
          letterSpacing: 1 }}>Recent</div>

        <div style={{
          background: t.surface, borderRadius: radius,
          border: `1px solid ${t.line}`, overflow: 'hidden',
        }}>
          {items.map((it, i) => {
            const m = helpfulMark(it.helpful);
            return (
              <div key={i} style={{
                padding: '14px 16px',
                borderBottom: i < items.length - 1 ? `1px solid ${t.line}` : 'none',
                display: 'flex', gap: 12, alignItems: 'flex-start',
              }}>
                <div style={{ width: 38, flexShrink: 0 }}>
                  <div style={{ fontSize: 13, fontWeight: 600, color: t.ink }}>{it.day}</div>
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 11, color: t.quiet, marginBottom: 4 }}>{it.time}</div>
                  <div style={{ fontSize: 13.5, color: t.ink,
                    fontStyle: 'italic', marginBottom: 6, lineHeight: 1.4 }}>"{it.mood}"</div>
                  <div style={{ display: 'flex', gap: 6, alignItems: 'center', flexWrap: 'wrap' }}>
                    <PillTag t={t} tone="soft">{it.practice}</PillTag>
                    <span style={{ fontSize: 10.5, color: m.color, fontWeight: 500 }}>
                      · {m.label}
                    </span>
                  </div>
                </div>
                <svg width="8" height="13" viewBox="0 0 8 13" style={{ marginTop: 6, flexShrink: 0 }}>
                  <path d="M1 1l6 5.5L1 12" stroke={t.quiet} strokeWidth="1.5"
                    fill="none" strokeLinecap="round" strokeLinejoin="round"/>
                </svg>
              </div>
            );
          })}
        </div>
      </ScreenScroll>
      <TabBar active="history" t={t} radius={radius}/>
    </Phone>
  );
}

// ─────────────────────────────────────────────────────────────
// 8. Privacy
// ─────────────────────────────────────────────────────────────
function PrivacyScreen({ t, radius }) {
  const items = [
    { title: 'Voice stays on this phone',
      body: 'Speech is transcribed on device with WhisperKit. Audio never leaves your iPhone.' },
    { title: 'Reflections are yours alone',
      body: 'Your transcripts and notes live in your private iCloud, encrypted at rest.' },
    { title: 'AI suggestions, not surveillance',
      body: "Sift sends only the words you wrote and a short summary of past wins. No identity, no biometrics, no analytics." },
  ];
  return (
    <Phone t={t}>
      <ScreenScroll t={t} padTop={62}>
        <h1 style={{ margin: 0, fontSize: 30, fontWeight: 600,
          letterSpacing: -0.6, color: t.ink }}>Privacy</h1>
        <p style={{ margin: '6px 0 0', fontSize: 13.5, color: t.muted, lineHeight: 1.55 }}>
          Sift is built to be a quiet, private companion. Here's what that
          actually means.
        </p>

        <div style={{ marginTop: 22, display: 'flex', flexDirection: 'column', gap: 12 }}>
          {items.map((it, i) => (
            <div key={i} style={{
              background: t.surface, borderRadius: radius,
              border: `1px solid ${t.line}`, padding: 16,
              display: 'flex', gap: 12, alignItems: 'flex-start',
            }}>
              <div style={{
                width: 36, height: 36, borderRadius: radius - 6,
                background: t.surfaceAlt,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                flexShrink: 0, color: t.accentInk,
              }}>
                <svg width="18" height="18" viewBox="0 0 22 22" fill="none">
                  <path d="M11 3l7 3v5c0 4-3 7-7 8-4-1-7-4-7-8V6l7-3z"
                    stroke="currentColor" strokeWidth="1.5"
                    strokeLinejoin="round"/>
                </svg>
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 14, fontWeight: 600, color: t.ink,
                  letterSpacing: -0.1 }}>{it.title}</div>
                <div style={{ marginTop: 4, fontSize: 12.5, color: t.muted,
                  lineHeight: 1.55 }}>{it.body}</div>
              </div>
            </div>
          ))}
        </div>

        <div style={{ marginTop: 24, padding: 16,
          borderRadius: radius, border: `1px dashed ${t.line}`,
        }}>
          <div style={{ fontSize: 12, color: t.muted, lineHeight: 1.55 }}>
            You can clear everything Sift remembers about you, anytime, without
            losing the app.
          </div>
          <div style={{ marginTop: 10 }}>
            <button style={{
              padding: '8px 14px', borderRadius: 999, fontSize: 12.5,
              border: `1px solid ${t.danger}55`, background: 'transparent',
              color: t.danger, fontFamily: 'inherit', fontWeight: 500,
              cursor: 'pointer',
            }}>Clear my history</button>
          </div>
        </div>
      </ScreenScroll>
      <TabBar active="privacy" t={t} radius={radius}/>
    </Phone>
  );
}

Object.assign(window, {
  SuggestionsScreen, PracticeDetailScreen, ReflectionScreen,
  HistoryScreen, PrivacyScreen,
});
