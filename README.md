# Chatwoot – Customized Fork for Project Assessment

## 🛠 Setup Guide

### 1. Prerequisites

| Tool       | Version             | Install Command                                                                                   |
| ---------- | ------------------- | ------------------------------------------------------------------------------------------------- |
| Homebrew   | Latest              | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh")` |
| Ruby       | 3.4.4 (via `rbenv`) | `brew install rbenv ruby-build` then `rbenv install 3.4.4`                                        |
| Node.js    | 20.x                | `brew install node`                                                                               |
| pnpm       | 10.11.0             | `npm install -g pnpm`                                                                             |
| PostgreSQL | 14                  | `brew install postgresql@14`                                                                      |
| Redis      | latest              | `brew install redis`                                                                              |
| Overmind   | latest              | `brew install tmux overmind`                                                                      |

### 2. Backend Setup

```bash
rbenv global 3.4.4
bundle install
cp .env.example .env
# Edit .env:
#   REDIS_URL=redis://localhost:6379
#   POSTGRES_HOST=localhost
bundle exec rails secret # generate and add to SECRET_KEY_BASE
brew install pgvector
brew services restart postgresql@14
bundle exec rake db:setup
```

### 3. Frontend Setup

```bash
pnpm install
pnpm dev
```

App runs at:

* Frontend (Vite): [http://localhost:3036](http://localhost:3036)
* Backend (Rails): [http://localhost:3000](http://localhost:3000)

### 4. Admin Access (if Signup is disabled)

```bash
pnpm exec rails c
```

```ruby
user = User.new(name: 'Test', email: 'test@example.com', password: 'Test@1234', password_confirmation: 'Test@1234', confirmed_at: Time.now)
user.skip_confirmation!
user.save!
account = Account.create!(name: 'Test Account')
AccountUser.create!(account: account, user: user, role: :administrator)
```

---

## 🧪 Testing & QA

* Login at `http://localhost:3000/app/login`
* Create inbox → Website → Complete setup
* Widget script confirms inbox flow works

---

## UI

### 1. Empty inbox
<img src="https://github.com/user-attachments/assets/0b5b06be-629f-4a84-80af-b440bcd50e70" alt="Empty conversations state" width="800"/>

### 2. Widget message metadata
<img src="https://github.com/user-attachments/assets/3358d56e-e3af-4aa2-8efd-4b4071483895" alt="Message widget showing sentiment badges" width="800"/>

### 3. Integrations page

Light mode:  
<img src="https://github.com/user-attachments/assets/82d8c837-60ec-4199-9daa-6fb408e028be" alt="Integrations page - light theme" width="800"/>

Dark mode:  
<img src="https://github.com/user-attachments/assets/11586987-a502-48a1-a8c0-4df811f40f83" alt="Integrations page - dark theme" width="800"/>


### 4. Documents empty state (AI Agent Document Page)
<img src="https://github.com/user-attachments/assets/94d2b17e-3432-4211-bebd-4fd843ced67e" alt="No documents available" width="800"/>

---

