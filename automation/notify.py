# Notificador: resumen diario / alertas. Nunca tira la corrida si falla (cae a print).
from .platforms.base import load_secret


def send(cfg, subject, body):
    ch = (cfg.get('notify') or {}).get('channel', 'none')
    try:
        if ch == 'telegram':
            import requests
            s = load_secret('telegram')   # {"token","chat_id"}
            requests.post(f"https://api.telegram.org/bot{s['token']}/sendMessage",
                          data={'chat_id': s['chat_id'],
                                'text': f'{subject}\n\n{body}'[:4000]}, timeout=30)
            return
        if ch == 'discord':
            import requests
            s = load_secret('discord')    # {"webhook_url": "https://discord.com/api/webhooks/..."}
            requests.post(s['webhook_url'],
                          json={'content': f'**{subject}**\n{body}'[:1900]},
                          timeout=30)
            return
        if ch == 'email':
            import smtplib
            from email.message import EmailMessage
            s = load_secret('email')      # {smtp_host,smtp_port,user,password,to}
            msg = EmailMessage()
            msg['Subject'], msg['From'], msg['To'] = subject, s['user'], s['to']
            msg.set_content(body)
            with smtplib.SMTP(s['smtp_host'], int(s['smtp_port'])) as srv:
                srv.starttls()
                srv.login(s['user'], s['password'])
                srv.send_message(msg)
            return
    except Exception as e:
        print(f'[notify {ch} error] {e}')
    print(f'[notify:{ch}] {subject}\n{body}')
