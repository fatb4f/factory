package cyberwatch

// Recurring discovery endpoints. Citations use the exact record and version.
// The role describes what the publisher can establish on its own channel.
sources: #Channels & {
	drupal: advisory: {role: "primary", url: "https://www.drupal.org/security"}
	cisa: kev: {role: "primary", url: "https://github.com/cisagov/kev-data"}
	"cyber-centre": advisories: {role: "primary", url: "https://www.cyber.gc.ca/en/alerts/"}
	"cert-eu": advisories: {role: "primary", url: "https://cert.europa.eu/publications/security-advisories/"}
	parliament: {
		bills: {role: "primary", url: "https://www.parl.ca/legisinfo/en/bills"}
		text: {role: "primary", url: "https://www.parl.ca/documentviewer/"}
		committees: {role: "primary", url: "https://www.ourcommons.ca/committees/en/Home"}
	}
	senate: committees: {role: "primary", url: "https://sencanada.ca/en/committees/"}
	justice: statutes: {role: "primary", url: "https://laws-lois.justice.gc.ca/eng/acts/"}
	"canada-gazette": publications: {role: "primary", url: "https://gazette.gc.ca/"}
	opc: {
		parliament: {role: "primary", url: "https://www.priv.gc.ca/en/opc-actions-and-decisions/advice-to-parliament/"}
		statements: {role: "primary", url: "https://www.priv.gc.ca/en/opc-news/speeches-and-statements/"}
	}
	"competition-bureau": announcements: {role: "primary", url: "https://competition-bureau.canada.ca/"}
	"qc-assembly": bills: {role: "primary", url: "https://www.assnat.qc.ca/fr/travaux-parlementaires/projets-loi/index.html"}
	"qc-publications": {
		gazette: {role: "primary", url: "https://www.publicationsduquebec.gouv.qc.ca/gazette-officielle"}
		statutes: {role: "primary", url: "https://www.legisquebec.gouv.qc.ca/"}
	}
	"qc-cai": decisions: {role: "primary", url: "https://www.cai.gouv.qc.ca/"}
	nsira: reviews: {role: "primary", url: "https://nsira-ossnr.gc.ca/en/"}
	nsicop: reports: {role: "primary", url: "https://www.canada.ca/en/national-security-intelligence-committee-parliamentarians.html"}
	"intelligence-commissioner": decisions: {role: "primary", url: "https://www.canada.ca/en/intelligence-commissioner.html"}
	montreal: {
		council: {role: "primary", url: "https://montreal.ca/conseils-decisionnels/conseil-municipal"}
		contracts: {role: "primary", url: "https://montreal.ca/services/appels-doffres-et-contrats"}
	}
	seao: procurement: {role: "primary", url: "https://seao.gouv.qc.ca/"}
	spvm: publications: {role: "primary", url: "https://spvm.qc.ca/"}
	"citizen-lab": research: {role: "reporting", url: "https://citizenlab.ca/"}
	"parliament-today": reporting: {role: "reporting", url: "https://www.parliamenttoday.ca/"}
	bleepingcomputer: {
		news: {role: "reporting", url: "https://www.bleepingcomputer.com/news/security/"}
		forums: {role: "community", url: "https://www.bleepingcomputer.com/forums/"}
	}
	northsec: talks: {role: "community", url: "https://nsec.io/"}
	nanog: discussions: {role: "community", url: "https://www.nanog.org/"}
}
