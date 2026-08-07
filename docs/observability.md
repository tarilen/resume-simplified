# Observability & SLOs

## What & where
- Live: https://resume.theginger.dev
- Status page: https://theginger.betteruptime.com/
- Monitor: Better Stack synthetic HTTPS, 3-min interval, keyword assertion "Damian Ortega"

## SLIs
- **Availability:** % of synthetic checks returning 200 AND containing "Damian Ortega", 30-day rolling.
- **Latency:** p95 response time 

## SLOs
- Availability: **99.9%** over 30 days.
- Latency: **p95 < 800ms over 30 days
- Rationale: measurable at a 3-min check interval; 99.9% uptime allows a total time allotment of about 43 minutes of downtime in a 30 day span. Anything over 99.9% would require tighter checks, and additional operational expenditures for fine grained statistics. 43 minutes of downtime has been deemed acceptable in a 30-day span.

## Error budget
- 99.9% → ~43 min of allowed downtime per 30 days.
- Burn = failed checks × 3 min.

## Error-budget policy
- If the 30-day budget is exhausted: Should we exhaust the 30-day budget, we will prioritize reliability and stability work over new features or fixes that could potentially lead to additional overages.

## Alerting

**Fast-burn (page → email)**
- Alerts fire only on *sustained* failure, not single-cycle blips.
- **Confirmation period: 5 min** (check interval: 3 min) — a failure must persist
  this long before an incident opens and email fires. Set above the check interval
  so ≥2 consecutive checks must fail, which suppresses single-cycle overseas-probe
  flaps (see the 2026-07-24 incident: its 1-min legs self-healed inside one cycle;
  the ~5-min Asia leg sat right at the confirmation boundary).
- **Recovery period: 3 min** — the site must pass for a full cycle before the
  incident closes; de-flaps rapid down/up/down into a single incident.
- **Trade-off:** accepts ~5 min of detection latency in exchange for eliminating
  false alarms. Acceptable against the 43.2-min / 30-day budget.
- **Channel: email only** — deliberate; a resume site doesn't warrant phone/SMS.

**Slow-burn (ticket)**
- Daily GitHub Action reads `total_downtime` (seconds) from the Better Stack SLA
  API over two date-granular windows and opens/updates a GitHub issue when a
  threshold trips. Lower urgency than fast-burn — a ticket, not a page.
  - **Bad day:** last 1 day, burn ≥ 3× budget (≈4.3 min downtime) → ticket.
  - **Budget guard:** rolling 30 days, ≥ 90% of the 43.2-min budget consumed
    (≈39 min) → ticket; this triggers the error-budget policy above.
  - `burn = total_downtime ÷ (0.001 × window_seconds)`. Uses the seconds counter,
    not `availability` % (whose window basis doesn't reconcile — 07-24 read 360s
    downtime yet 99.87% availability).
  - The SLA endpoint takes date-granular ranges (`YYYY-MM-DD`), so sub-day windows
    aren't possible and a daily cadence matches the data's resolution. _(In progress.)_

## Future enhancements
- Move the status page to status.theginger.dev

## Incident log

### 2026-07-24 - Brief Multi-region edge timeouts
- **Severity/Impact:** Low - North American users. Only timeout errors were observed for non-US users.
- **Duration:** Based on the details there was a total of about 2~ minutes of captured downtime from first alert recovery. Australia/Europe had a brief 1~ window of timeouts. Asia flopped twice, first recovering within 1~ minute and later taking about 5~ to recover.
- **Detection:** Notified by email from BetterStack @ 4:34am EST
- **Timeline (HDT):**
  - 11:23pm Europe timeout
  - 11:24pm Australia timeout
  - 11:24pm Asia timeout
  - 11:24pm All regions recovered
  - 11:25pm Asia timeout
  - 11:30pm Asia check recovered
  - 11:33pm Incident self-resolved
- **Root Cause:** Three overseas probes recorded timeouts. North American probes unaffected. This suggests not a problem with the app/site but potentially something in Azure's CDN.
- **Resolution:** Self healed
- **Error-budget impact:** Downtime recorded was about 6 mins, or 14% of the 43.2 minute error budget. Actual impact was less due to the quick recovery and the 3-minute interval checks.
- **Follow-ups / Action items:** No further action at this time. Given the low impact, burn-rate should be deferred.