// Sends transactional e-mails through Resend (https://resend.com).
//
// Secrets (Supabase dashboard > Edge Functions > Secrets), never in the repo:
//   RESEND_API_KEY  API key from Resend
//   MAIL_FROM       verified sender, e.g. "Lookin <noreply@lookin-food.com>"
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

export const withdrawalPolicyText = `Widerrufsbelehrung

Widerrufsrecht
Du hast das Recht, binnen vierzehn Tagen ohne Angabe von Gründen diesen Vertrag zu widerrufen. Die Widerrufsfrist beträgt vierzehn Tage ab dem Tag des Vertragsabschlusses.
Um dein Widerrufsrecht auszuüben, musst du uns (Mhd Khair Shikho, Am Grübchen 18, 56203 Höhr-Grenzhausen, Telefon: +49 15510 338501, E-Mail: lookinsupport@gmail.com) mittels einer eindeutigen Erklärung (z. B. ein mit der Post versandter Brief oder eine E-Mail) über deinen Entschluss, diesen Vertrag zu widerrufen, informieren. Du kannst dafür das Muster-Widerrufsformular verwenden, das jedoch nicht vorgeschrieben ist. Du kannst dein Widerrufsrecht auch in der App unter Profil > Vertrag widerrufen ausüben.
Zur Wahrung der Widerrufsfrist reicht es aus, dass du die Mitteilung über die Ausübung des Widerrufsrechts vor Ablauf der Widerrufsfrist absendest.

Folgen des Widerrufs
Wenn du diesen Vertrag widerrufst, haben wir dir alle Zahlungen, die wir von dir erhalten haben, einschließlich der Lieferkosten (mit Ausnahme der zusätzlichen Kosten, die sich daraus ergeben, dass du eine andere Art der Lieferung als die von uns angebotene, günstigste Standardlieferung gewählt hast), unverzüglich und spätestens binnen vierzehn Tagen ab dem Tag zurückzuzahlen, an dem die Mitteilung über deinen Widerruf dieses Vertrags bei uns eingegangen ist. Für diese Rückzahlung verwenden wir dasselbe Zahlungsmittel, das du bei der ursprünglichen Transaktion eingesetzt hast, es sei denn, mit dir wurde ausdrücklich etwas anderes vereinbart; in keinem Fall werden dir wegen dieser Rückzahlung Entgelte berechnet.
Hast du verlangt, dass die Dienstleistungen während der Widerrufsfrist beginnen sollen, so hast du uns einen angemessenen Betrag zu zahlen, der dem Anteil der bis zu dem Zeitpunkt, zu dem du uns von der Ausübung des Widerrufsrechts hinsichtlich dieses Vertrags unterrichtest, bereits erbrachten Dienstleistungen im Vergleich zum Gesamtumfang der im Vertrag vorgesehenen Dienstleistungen entspricht.

Ende der Widerrufsbelehrung

Vollständige Fassung: https://nvctrj5v8s-cmd.github.io/livo-fitness-app/legal/widerruf.html
AGB: https://nvctrj5v8s-cmd.github.io/livo-fitness-app/legal/agb.html`
