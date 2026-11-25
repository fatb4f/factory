# Cyber Incident Watch

2026-11-25T11:31:51Z

## Global major cyber incidents

### Azure API Management exploitation affects energy operators

`azure-apim-norway-2026-11` · High significance; access path reportedly closed; credential rotation required · Norway and additional unspecified countries

First source-qualified coverage in sealed stream history, not a newly occurring attack. NSM identifies a shared cloud dependency spanning multiple sectors.

- NSM reported active targeting of APIM tokens and secrets and named Equinor and Skagerak Energi among affected organizations. Its November 23 update reports the vulnerability closed, without evidence of interruption to Norwegian deliveries. [NSM Azure API Management notice](https://nsm.no/aktuelt/nsm-deler-tiltak-mot-sarbarhet-i-azure-api-management)
- Equinor disclosed an IT attack November 17; on November 20 it reported containment, normal production and no indication of data theft or alteration. [Equinor Cyber-attack stopped](https://www.equinor.com/news/20261711-equinor-detected-cyber-attack)
- Help Net Security attributed to Microsoft's customer advisory a November 19 access-path fix affecting Classic tiers, and residual exposure of customer credentials requiring rotation. The underlying customer-only notice was not directly acquired. [Azure API Management vulnerability exploited to steal customers’ secrets](https://www.helpnetsecurity.com/2026/11/24/azure-apim-vulnerability-credential-theft/)

Open questions

- Total affected customers, exfiltration volume, CVE, actor and Factory deployment exposure unknown. No established OT or production interruption.

Next check — Check Microsoft public advisory revisions, customer impact and downstream credential misuse.

### GoodCloud compromise installs malware on routers and remote KVM devices

`gl-inet-goodcloud-2026-11` · High significance; cloud route blocked; device cleanup remains necessary · Global vendor disclosure; affected locations unspecified

First coverage of the vendor-confirmed incident in the sealed stream, not a new attack on November 25.

- GL.iNet reports discovery of unauthorized access and malware installation on some GoodCloud-connected routers and KVM devices November 20. The vendor reports blocking the path that day and issuing cleanup firmware. [GoodCloud Remote Management Incident](https://www.gl-inet.com/blogs/blog/glinet-security-notice-2026-11-20)
- The November 23 revision distinguishes cloud exposure from confirmed device compromise and says that some KVM cloud services can connect before account linking; attached-host compromise remains unestablished. CVE identifiers are pending. [GoodCloud Remote Management Incident](https://www.gl-inet.com/blogs/blog/glinet-security-notice-2026-11-20)

Open questions

- Compromised device count, geographic distribution, actor, and whether attached computers were affected are unknown. No Factory device inventory evidence.

Next check — Track CVE assignment, vendor device notification and investigation of connected hosts.

### Reported US intelligence analysis system intrusion

`us-cia-odni-osint-2026-11` · Unverified extent; attributed official denial of classified-system disruption · United States

November 24–25 reports identify an unclassified analysis system; original agency record not acquired.

- The Independent attributed to an AP source an unclassified CIA breach that was resolved and to ODNI a statement denying critical or classified system disruption. The reports do not establish the material accessed. [CIA system breached in latest cyberattack targeting US intelligence agencies](https://www.independent.co.uk/news/world/americas/cia-cyber-attack-dni-breach-fbi-b3090993.html)
- BleepingComputer repeats New York Times reporting of an OSINT system compromise and alleged additional agency involvement. Treat these as related reporting rather than independent technical confirmation. [Hackers reportedly breached CIA intelligence analysis system](https://www.bleepingcomputer.com/news/security/hackers-reportedly-breached-cia-intelligence-analysis-system/)

Open questions

- Incident date, access vector, data scope, actor, NGA involvement and relationship to other federal incidents are unresolved; no basis for attribution.

Next check — Obtain public CIA, ODNI or NGA statements and separately establish affected system, chronology and impact.

## Canadian surveillance and privacy

No item recorded for this stream in this run.

## Coverage gaps

- **senate / committees** — Meeting 34 notice, committee reports listing and LEGISinfo checked; adopted C-22 amendment text not acquired. Next check — Check signed committee report, minutes and Senate Journals.
- **cyber-centre / advisories** — Dated advisory search did not establish complete new-index coverage. Next check — Page by update date and serial number.
- **qc-assembly / bills** — Targeted French-language searches did not establish complete bill, clause and Gazette coverage. Next check — Review bilingual listings and Gazette instruments directly.
- **nsira / reviews** — NSIRA homepage showed latest listed October review and November 6 administrative publications; full NSICOP and Intelligence Commissioner coverage remains incomplete. Next check — Check the individual review and other oversight indexes.
- **montreal / contracts** — November 24 budget announcement acquired; camera procurement awards and deployment records not established. Next check — Check council minutes, SEAO awards and SPVM deployment records.
- **northsec / talks** — Community channel rotation remains incomplete. Next check — Check dated public talks and network operator reports.
- **bleepingcomputer / news** — Underlying CIA/ODNI agency record and original reporting not independently acquired. Next check — Obtain a directly attributable agency record.
