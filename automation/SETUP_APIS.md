# Cómo sacar cada token (y dónde ponerlo)

> Todos los tokens van como archivos JSON en `automation/secrets/` (ignorada por
> git). El agente nunca ve estos valores. Empezá por los rápidos (Pinterest,
> YouTube, Telegram); los lentos (Instagram, TikTok) requieren review/audit.

---

## 1. Pinterest (rápido) — `secrets/pinterest.json`
1. developers.pinterest.com → creá una app (cuenta **business**).
2. Scopes: `boards:read`, `boards:write`, `pins:read`, `pins:write`.
3. Generá un **access token** (OAuth).
4. Guardá:
   ```json
   { "access_token": "PEGA_TU_TOKEN" }
   ```
> Apps nuevas arrancan en "trial": alcanza para postear en tu cuenta (rate limitado).

## 2. YouTube (rápido, con helper) — `secrets/youtube.json`
1. Google Cloud Console → proyecto nuevo → habilitá **YouTube Data API v3**.
2. Pantalla de consentimiento OAuth (modo **Testing**, agregate como *test user*).
3. Credenciales → OAuth client ID → tipo **Desktop app** → bajá el `client_secret.json`.
4. En tu PC: `pip install google-auth-oauthlib` y corré:
   ```
   python automation/get_youtube_token.py ruta/al/client_secret.json
   ```
   Te abre el navegador, autorizás, y deja `secrets/youtube.json` solo
   (`client_id`, `client_secret`, `refresh_token`). Copialo a la VM.

## 3. Telegram (notificaciones, rápido) — `secrets/telegram.json`
1. En Telegram hablale a **@BotFather** → `/newbot` → te da un **token**.
2. Mandale un mensaje a tu bot, y obtené tu `chat_id`
   (abrí `https://api.telegram.org/bot<TOKEN>/getUpdates` y mirá `chat.id`).
3. Guardá:
   ```json
   { "token": "BOT_TOKEN", "chat_id": "TU_CHAT_ID" }
   ```
   (en `config.yaml`, `notify.channel: telegram`). Alternativa: email (ver abajo).

## 4. Reddit (opcional — por defecto NO postea) — `secrets/reddit.json`
> El bot deja Reddit en `notify` (te arma el draft, vos lo pegás). Solo necesitás
> esto si querés activar `mode: live` a un subreddit donde tengas permiso.
1. reddit.com/prefs/apps → "create app" → tipo **script**.
2. Guardá:
   ```json
   { "client_id":"...", "client_secret":"...", "username":"...",
     "password":"...", "user_agent":"riffstream-marketing-bot" }
   ```
   y en `config.yaml` poné `reddit: { enabled: true, mode: live, subreddit: "elsubreddit" }`.

## 5. TikTok (lento — audit) — `secrets/tiktok.json`
1. developers.tiktok.com → app → habilitá **Content Posting API**.
2. Obtené un **access token** (OAuth) con scope de publicación.
3. Guardá: `{ "access_token": "..." }`.
4. En `config.yaml` queda `mode: draft` → sube como **borrador** (lo publicás en
   la app, 1 toque). Para auto-postear **público**, pasá el **audit** de TikTok y
   recién ahí poné `mode: live`.

## 6. Instagram (lento — Business + app review) — `secrets/instagram.json`
1. Pasá tu IG a cuenta **Business** y linkeala a una **Página de Facebook**.
2. developers.facebook.com → app → producto **Instagram Graph API**.
3. Pedí los permisos `instagram_business_basic` + `instagram_business_content_publish`
   → **app review** (screencast del flujo). Tarda 2-4 semanas.
4. Conseguí un **long-lived token** y tu **ig_user_id**.
5. Guardá:
   ```json
   { "access_token": "...", "ig_user_id": "..." }
   ```
6. **Importante:** IG no sube archivos, descarga el video de una URL pública.
   En `config.yaml` agregá `media_base_url: https://...` apuntando a donde estén
   los MP4 (ej. tu GitHub Pages / un host). El bot arma `media_base_url/<asset>`.
7. Cuando esté aprobado: en `config.yaml` poné `instagram: { enabled: true, mode: live }`.

---

## Email para notificaciones (alternativa a Telegram) — `secrets/email.json`
```json
{ "smtp_host":"smtp.gmail.com", "smtp_port":"587", "user":"vos@gmail.com",
  "password":"app-password", "to":"vos@gmail.com" }
```
(y `notify.channel: email`). En Gmail usá una *App Password*, no tu clave normal.

---

## Verificar
```bash
automation/.venv/bin/python -m automation.selftest        # presencia de tokens
automation/.venv/bin/python -m automation.selftest --net  # prueba liviana de tokens
```
