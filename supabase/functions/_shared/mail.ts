// Sends transactional e-mails through Resend (https://resend.com).
//
// Secrets (Supabase dashboard > Edge Functions > Secrets), never in the repo:
//   RESEND_API_KEY  API key from Resend
//   MAIL_FROM       verified sender, e.g. "Lookin <noreply@lookin-foodtracker.de>"
// Without both secrets nothing is sent and callers get 'not_configured', so
// the app keeps working until the owner has a domain and a Resend account.

export type MailResult = 'sent' | 'not_configured' | 'failed'

export type Mail = {
  to: string
  subject: string
  text: string
  replyTo?: string
}

export const ownerEmail = 'lookinsupport@gmail.com'

export async function sendMail(mail: Mail): Promise<MailResult> {
  const apiKey = Deno.env.get('RESEND_API_KEY')?.trim()
  const from = Deno.env.get('MAIL_FROM')?.trim()
  if (!apiKey || !from) return 'not_configured'
  const controller = new AbortController()
  const timer = setTimeout(() => controller.abort(), 10_000)
  try {
    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from,
        to: [mail.to],
        subject: mail.subject,
        text: mail.text,
        reply_to: mail.replyTo ?? ownerEmail,
      }),
      signal: controller.signal,
    })
    if (!response.ok) {
      console.error(`mail failed with HTTP ${response.status}`)
      return 'failed'
    }
    return 'sent'
  } catch (_) {
    console.error('mail request failed')
    return 'failed'
  } finally {
    clearTimeout(timer)
  }
}

// Formats a moment in German local time, e.g. "10.10.2026 um 14:32 Uhr".
export function germanDateTime(value: Date): string {
  const parts = new Intl.DateTimeFormat('de-DE', {
    timeZone: 'Europe/Berlin',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  }).formatToParts(value)
  const get = (type: string) => parts.find((part) => part.type === type)?.value ?? ''
  return `${get('day')}.${get('month')}.${get('year')} um ${get('hour')}:${get('minute')} Uhr`
}

export function englishDateTime(value: Date): string {
  return new Intl.DateTimeFormat('en-GB', {
    timeZone: 'Europe/Berlin', dateStyle: 'medium', timeStyle: 'short',
  }).format(value)
}

export const withdrawalPolicyTextEn = `Withdrawal information

Right of withdrawal
You have the right to withdraw from this contract within fourteen days without giving any reason. The withdrawal period is fourteen days from the date the contract is concluded.
To exercise this right, inform us (Mhd Khair Shikho, Am Grübchen 18, 56203 Höhr-Grenzhausen, telephone: +49 15510 338501, email: lookinsupport@gmail.com) of your decision by an unequivocal statement, such as a letter sent by post or an email. You may use the model form below, but this is not obligatory. You may also withdraw online at https://app.lookin-foodtracker.de/legal/en/widerruf-erklaeren.html without signing in, or in the app under Profile > Withdraw from contract. If you use this online function, we promptly send an acknowledgement on a durable medium, such as email, containing information about your declaration and the date and time it was received.
To meet the deadline, sending your communication before the withdrawal period expires is sufficient.

Effects of withdrawal
If you withdraw, we reimburse all payments received from you, including delivery costs (except additional costs from choosing a delivery method other than our least expensive standard delivery), without undue delay and no later than fourteen days after being informed of your decision. We use the original payment method unless expressly agreed otherwise; you incur no fees for reimbursement.
If you requested services to begin during the withdrawal period, you must pay a reasonable amount proportionate to services already provided up to the time you inform us of withdrawal, compared with the full contractual scope.

End of withdrawal information

Note: cancellation ends the subscription for the future only and is not withdrawal.

Model withdrawal form
(Complete and return this form only if you wish to withdraw.)
To Mhd Khair Shikho, Am Grübchen 18, 56203 Höhr-Grenzhausen, lookinsupport@gmail.com:
I/We (*) hereby withdraw from the contract concluded by me/us (*) for the purchase of the following goods (*) / provision of the following service (*): Lookin Premium (subscription)
Ordered on (*) / received on (*): ____________
Name of consumer(s): ____________
Address of consumer(s): ____________
Signature of consumer(s) (only for paper submissions): ____________
Date: ____________
(*) Delete as appropriate.

Full version: https://app.lookin-foodtracker.de/legal/en/widerruf.html
Terms: https://app.lookin-foodtracker.de/legal/en/agb.html`

export const withdrawalPolicyText = `Widerrufsbelehrung

Widerrufsrecht
Du hast das Recht, binnen vierzehn Tagen ohne Angabe von Gründen diesen Vertrag zu widerrufen. Die Widerrufsfrist beträgt vierzehn Tage ab dem Tag des Vertragsabschlusses.
Um dein Widerrufsrecht auszuüben, musst du uns (Mhd Khair Shikho, Am Grübchen 18, 56203 Höhr-Grenzhausen, Telefon: +49 15510 338501, E-Mail: lookinsupport@gmail.com) mittels einer eindeutigen Erklärung (z. B. ein mit der Post versandter Brief oder eine E-Mail) über deinen Entschluss, diesen Vertrag zu widerrufen, informieren. Du kannst dafür das beigefügte Muster-Widerrufsformular verwenden, das jedoch nicht vorgeschrieben ist. Du kannst dein Widerrufsrecht auch online unter https://app.lookin-foodtracker.de/legal/widerruf-erklaeren.html (ohne Anmeldung) oder in der App unter Profil > Vertrag widerrufen ausüben. Wenn du diese Online-Funktion nutzt, übermitteln wir dir auf einem dauerhaften Datenträger (z. B. durch eine E-Mail) unverzüglich eine Eingangsbestätigung mit Informationen zum Inhalt der Widerrufserklärung sowie dem Datum und der Uhrzeit ihres Eingangs.
Zur Wahrung der Widerrufsfrist reicht es aus, dass du die Mitteilung über die Ausübung des Widerrufsrechts vor Ablauf der Widerrufsfrist absendest.

Folgen des Widerrufs
Wenn du diesen Vertrag widerrufst, haben wir dir alle Zahlungen, die wir von dir erhalten haben, einschließlich der Lieferkosten (mit Ausnahme der zusätzlichen Kosten, die sich daraus ergeben, dass du eine andere Art der Lieferung als die von uns angebotene, günstigste Standardlieferung gewählt hast), unverzüglich und spätestens binnen vierzehn Tagen ab dem Tag zurückzuzahlen, an dem die Mitteilung über deinen Widerruf dieses Vertrags bei uns eingegangen ist. Für diese Rückzahlung verwenden wir dasselbe Zahlungsmittel, das du bei der ursprünglichen Transaktion eingesetzt hast, es sei denn, mit dir wurde ausdrücklich etwas anderes vereinbart; in keinem Fall werden dir wegen dieser Rückzahlung Entgelte berechnet.
Hast du verlangt, dass die Dienstleistungen während der Widerrufsfrist beginnen sollen, so hast du uns einen angemessenen Betrag zu zahlen, der dem Anteil der bis zu dem Zeitpunkt, zu dem du uns von der Ausübung des Widerrufsrechts hinsichtlich dieses Vertrags unterrichtest, bereits erbrachten Dienstleistungen im Vergleich zum Gesamtumfang der im Vertrag vorgesehenen Dienstleistungen entspricht.

Ende der Widerrufsbelehrung

Hinweis: Eine Kündigung beendet das Abo nur für die Zukunft und ist kein Widerruf.

Muster-Widerrufsformular
(Wenn du den Vertrag widerrufen willst, fülle dieses Formular aus und sende es zurück.)
An Mhd Khair Shikho, Am Grübchen 18, 56203 Höhr-Grenzhausen, lookinsupport@gmail.com:
Hiermit widerrufe(n) ich/wir (*) den von mir/uns (*) abgeschlossenen Vertrag über den Kauf der folgenden Waren (*)/die Erbringung der folgenden Dienstleistung (*): Lookin Premium (Abo)
Bestellt am (*)/erhalten am (*): ____________
Name des/der Verbraucher(s): ____________
Anschrift des/der Verbraucher(s): ____________
Unterschrift des/der Verbraucher(s) (nur bei Mitteilung auf Papier): ____________
Datum: ____________
(*) Unzutreffendes streichen.

Vollständige Fassung: https://app.lookin-foodtracker.de/legal/widerruf.html
AGB: https://app.lookin-foodtracker.de/legal/agb.html`
