# PRD: AI-Powered News Aggregation and Summary Push

## 1. Problem Statement
People are overwhelmed by fragmented information across social platforms, blogs, and public channels. Most users consume content passively and spend significant effort filtering noise before finding high-value updates. Existing tools either aggregate only one content type (e.g., RSS) or lack strong AI filtering and summary workflows.

This feature solves the gap by building a proactive intelligence feed: users define trusted sources, the system continuously detects updates, and AI returns high-density summaries with actionable push notifications.

## 2. Goals
- Build a unified ingestion pipeline across social accounts and site-based sources.
- Deliver concise, high-density summaries instead of raw feed overload.
- Allow users to proactively subscribe to specific people and URLs.
- Reduce time-to-insight by pushing only meaningful updates.
- Validate an MVP architecture that can later expand to more channels.

## 3. Non-Goals
- Full replacement of native social apps (no posting/replying workflows).
- Broad web search across the entire internet.
- Real-time stream processing with sub-minute latency.
- Enterprise-grade analytics/reporting in MVP.
- Long-form knowledge management, collaborative editing, or CRM features.

## 4. Personas
- Busy Operator/Founder
Description: Tracks market and competitor signals from selected experts and publications.
Need: Fast daily digest and urgent push for critical updates.

- Industry Analyst
Description: Monitors niche accounts/blogs for trends and policy changes.
Need: Source-controlled updates, deduplicated summaries, and citation links.

- Content Researcher
Description: Collects inputs from social and independent sites.
Need: Reduced noise and structured summary output for downstream writing.

## 5. User Stories
- As a user, I can add a list of X (Twitter) accounts so I receive summarized updates from those accounts.
- As a user, I can add blog/site/public-page URLs and get notified when new content appears.
- As a user, I can see one aggregated timeline combining all subscribed sources.
- As a user, I receive AI-generated summaries that highlight key points and why they matter.
- As a user, I can tune push frequency (instant, daily digest, weekly digest).
- As a user, I can open each summary and view linked original sources for verification.
- As a user, I can mute low-value topics/sources to reduce noise.

## 6. Functional Requirements
### 6.1 Source Management
- Support source onboarding by account handle or URL.
- Validate source format and accessibility during setup.
- Store metadata: source type, platform, title, status, last-checked timestamp.
- Enable source pause/resume/remove.

### 6.2 Ingestion and Update Detection
- Poll source updates on configurable intervals.
- Prioritize lightweight freshness checks (RSS, ETag, Last-Modified) when available.
- Use platform-specific adapters for different source types.
- Capture ingestion logs with success/failure reasons.

### 6.3 Normalization and Deduplication
- Normalize fetched content into a common schema.
- Deduplicate by canonical URL/content fingerprint.
- Preserve provenance fields (source, publish time, fetch time, original link).

### 6.4 AI Filtering and Summarization
- Filter low-information updates (ads, duplicates, low-signal chatter).
- Generate concise summaries with key points and optional tags/topics.
- Add “why it matters” line for contextual value.
- Keep source references for every summary item.

### 6.5 Feed and Notifications
- Show aggregated feed sorted by relevance and recency.
- Support notification modes: immediate push and scheduled digest.
- Prevent notification floods via batching/rate limits.
- Track delivery status and user interactions (opened/dismissed).

### 6.6 Reliability and Operations
- Retry transient ingestion failures with exponential backoff.
- Provide monitoring for crawl freshness, failure rate, and latency.
- Provide admin visibility for blocked sources and adapter health.

## 7. Data Sources
### 7.1 Target Source Types
- Social accounts: X/Twitter (MVP target), extensible to other platforms.
- Site sources: personal blogs, media websites, RSS/Atom feeds.
- Public channel pages where legally and technically accessible.

### 7.2 Ingestion Method Priority
1. Official APIs with valid credentials and terms compliance.
2. Feed-based access (RSS/Atom).
3. Standards-based HTTP checks (ETag/Last-Modified).
4. Web crawling only where permitted by robots/ToS/legal policy.

### 7.3 Stored Data (MVP)
- Source registry and status.
- Raw fetched metadata (not full unrestricted archival by default).
- Normalized content snippets.
- Summary records and notification logs.

## 8. Compliance and Risk
- Platform Terms/API Restrictions
Risk: API limits/costs and strict data usage terms, especially for X/Twitter.
Mitigation: API-first integrations, quota-aware scheduling, clear failover behavior.

- Scraping Legality and Policy Risk
Risk: Some platforms (e.g., Xiaohongshu, WeChat public accounts) have no stable official API and higher scraping risk.
Mitigation: Restrict MVP to legally safer sources; add per-source compliance gating and manual review.

- Copyright and Content Reuse
Risk: Over-retaining or redistributing copyrighted content.
Mitigation: Store excerpts/metadata, link back to originals, keep summary-first experience.

- Privacy and Data Protection
Risk: Improper collection of user behavior and source data.
Mitigation: Minimal retention, access control, encryption at rest/in transit, deletion workflow.

- Hallucination/Quality Risk
Risk: AI summaries may miss nuance or add unsupported claims.
Mitigation: Citation display, confidence heuristics, prompt constraints, user feedback loop.

## 9. MVP Scope
### In Scope
- Source onboarding for X accounts (API-based where available) and RSS/blog URLs.
- Scheduled update detection and normalized storage.
- AI summarization with key points + why-it-matters.
- Aggregated feed UI/API.
- Push channels: in-app + daily digest email (or one push channel if constrained).
- Basic source controls: add/remove/pause.
- Compliance guardrails: allowlist of source types and platform policy checks.

### Out of Scope (MVP)
- Xiaohongshu and WeChat scraping in production.
- Advanced personalization ranking and team collaboration.
- Multi-language translation and sentiment analytics.
- Mobile native apps.

## 10. Milestones
- Milestone 0: Discovery and Compliance Baseline (Week 1)
Deliverables: source policy matrix, MVP allowlist, architecture draft.

- Milestone 1: Ingestion Foundation (Weeks 2-3)
Deliverables: source registry, adapters (X + RSS/blog), scheduler, raw fetch logs.

- Milestone 2: Normalization + Dedup (Week 4)
Deliverables: common schema, dedup pipeline, provenance model.

- Milestone 3: AI Summary Pipeline (Weeks 5-6)
Deliverables: filtering logic, summary generation, citation linking, quality checks.

- Milestone 4: Feed + Push Delivery (Week 7)
Deliverables: aggregated feed endpoint/UI, digest scheduler, notification controls.

- Milestone 5: MVP Hardening and Launch (Week 8)
Deliverables: monitoring dashboard, rate-limit handling, compliance review, pilot rollout.

## 11. Success Metrics (MVP)
- Time-to-insight: median time from source publish to user summary delivered.
- Signal quality: user “useful” feedback rate on summaries.
- Noise reduction: % of fetched items filtered before notification.
- Engagement: digest open rate and feed return frequency.
- Reliability: ingestion success rate and adapter failure recovery time.
