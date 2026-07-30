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

## Future enhancements
- Multi-window burn-rate alerting
- Move the status page to status.theginger.dev
- RUM via Cloudflare Web Analytics

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