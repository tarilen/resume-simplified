# Observability & SLOs

## What & where
- Live: https://resume.theginger.dev
- Status page: https://theginger.betteruptime.com/
- Monitor: Better Stack synthetic HTTPS, 3-min interval, keyword assertion "Damian Ortega"

## SLIs
- **Availability:** % of synthetic checks returning 200 AND containing "Damian Ortega", 30-day rolling.
- **Latency:** p95 response time < 800ms over 30 days.

## SLOs
- Availability: **99.9%** over 30 days.
- Rationale: measurable at a 3-min check interval; 99.9% uptime allows a total time allotment of about 43 minutes of downtime in a 30 day span. Anything over 99.9% would require tighter checks, and additional operational expenditures for fine grained statistics. 43 minutes of downtime has been deemed acceptable in a 30-day span.

## Error budget
- 99.9% → ~43 min of allowed downtime per 30 days.
- Burn = failed checks × 3 min.

## Error-budget policy
- If the 30-day budget is exhausted: Should we exhaust the 30-day budget, we will prioritize reliability and stability work over new features or fixes that could potentially lead to additional overages.

## Future enhancements
  - Burn-rate alerting
  - Status page
  - RUM